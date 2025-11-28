import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/payroll_provider/Employee_Manual_Punches_Provider.dart';
import '../../../widgets/custom_textfield/custom_dropdown_with_search.dart';

class EmployeeManualPunchesScreen extends StatefulWidget {
  const EmployeeManualPunchesScreen({super.key});

  @override
  State<EmployeeManualPunchesScreen> createState() =>
      _EmployeeManualPunchesScreenState();
}

class _EmployeeManualPunchesScreenState
    extends State<EmployeeManualPunchesScreen>
    with SingleTickerProviderStateMixin {
  bool _showFilters = true;
  late TextEditingController _employeeSearchController;
  String _employeeSearchQuery = '';
  late AnimationController _animationController;

  // Colors
  static const Color _primaryColor = Color(0xFF8E0E6B);
  static const Color _secondaryColor = Color(0xFFD4145A);
  static const Color _presentColor = Color(0xFF10B981);
  static const Color _absentColor = Color(0xFFEF4444);
  static const Color _leaveColor = Color(0xFFF59E0B);
  static const Color _holidayColor = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _employeeSearchController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _employeeSearchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  int _getDaysInMonth(String? monthYear) {
    if (monthYear == null) return 31;
    final parts = monthYear.split(' ');
    if (parts.length < 2) return 31;
    
    final monthName = parts[0];
    final year = int.tryParse(parts[1]) ?? 2025;
    
    final months = {
      'January': 31,
      'February': _isLeapYear(year) ? 29 : 28,
      'March': 31,
      'April': 30,
      'May': 31,
      'June': 30,
      'July': 31,
      'August': 31,
      'September': 30,
      'October': 31,
      'November': 30,
      'December': 31,
    };
    return months[monthName] ?? 31;
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'P':
        return _presentColor;
      case 'A':
        return _absentColor;
      case 'L':
        return _leaveColor;
      case 'H':
        return _holidayColor;
      default:
        return Colors.grey.shade300;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'P':
        return 'Present';
      case 'A':
        return 'Absent';
      case 'L':
        return 'Leave';
      case 'H':
        return 'Holiday';
      default:
        return 'N/A';
    }
  }

  // Calculate working hours from check-in and check-out
  Map<String, dynamic> _calculateWorkingTime(List<dynamic>? times) {
    if (times == null || times.length < 2) {
      return {'hours': 0, 'minutes': 0, 'display': '-'};
    }

    try {
      final checkIn = times.first.toString();
      final checkOut = times.last.toString();

      final checkInParts = checkIn.split(':');
      final checkOutParts = checkOut.split(':');

      int checkInMinutes =
          int.parse(checkInParts[0]) * 60 + int.parse(checkInParts[1]);
      int checkOutMinutes =
          int.parse(checkOutParts[0]) * 60 + int.parse(checkOutParts[1]);

      // Handle case where checkout is next day
      if (checkOutMinutes < checkInMinutes) {
        checkOutMinutes += 24 * 60;
      }

      int totalMinutes = checkOutMinutes - checkInMinutes;
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;

      return {
        'hours': hours,
        'minutes': minutes,
        'totalMinutes': totalMinutes,
        'display': '${hours}h ${minutes}m',
      };
    } catch (e) {
      return {'hours': 0, 'minutes': 0, 'display': '-'};
    }
  }

  // Calculate total monthly working hours
  Map<String, dynamic> _calculateMonthlyStats(Map<String, dynamic> attendance) {
    int totalMinutes = 0;
    int presentDays = 0;
    int absentDays = 0;
    int leaveDays = 0;
    int holidays = 0;

    attendance.forEach((day, data) {
      if (data is Map) {
        String status = data['status'] ?? 'N/A';
        List<dynamic>? times = data['times'];

        switch (status.toUpperCase()) {
          case 'P':
            presentDays++;
            final workTime = _calculateWorkingTime(times);
            totalMinutes += (workTime['totalMinutes'] ?? 0) as int;
            break;
          case 'A':
            absentDays++;
            break;
          case 'L':
            leaveDays++;
            break;
          case 'H':
            holidays++;
            break;
        }
      }
    });

    int totalHours = totalMinutes ~/ 60;
    int remainingMinutes = totalMinutes % 60;

    return {
      'totalHours': totalHours,
      'totalMinutes': remainingMinutes,
      'display': '${totalHours}h ${remainingMinutes}m',
      'presentDays': presentDays,
      'absentDays': absentDays,
      'leaveDays': leaveDays,
      'holidays': holidays,
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeManualPunchesProvider>(context);

    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Manual Punches"),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildFilterSection(provider),
          Expanded(
            child: Consumer<EmployeeManualPunchesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return _buildLoadingState();
                if (provider.manualPunches.isEmpty) return _buildEmptyState();

                int daysInMonth = _getDaysInMonth(provider.selectedMonth);

                return FadeTransition(
                  opacity: _animationController,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: provider.manualPunches.length,
                    itemBuilder: (context, index) {
                      final employee = provider.manualPunches[index];

                      String empName = (employee['name'] ?? '').toLowerCase();
                      String empId = (employee['empId'] ?? '').toLowerCase();

                      if (_employeeSearchQuery.isNotEmpty) {
                        if (!empName.contains(_employeeSearchQuery) &&
                            !empId.contains(_employeeSearchQuery)) {
                          return const SizedBox.shrink();
                        }
                      }

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 400 + (index * 100)),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: _buildEmployeeCard(
                          employee,
                          daysInMonth,
                          provider.selectedMonth ?? '',
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(EmployeeManualPunchesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter Attendance',
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        if (provider.selectedLocation != null)
                          Text(
                            '${provider.selectedLocation} • ${provider.selectedMonth ?? ""}',
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _showFilters ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filters
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  CustomSearchDropdownWithSearch(
                    isMandatory: true,
                    labelText: "Location",
                    items: provider.location,
                    selectedValue: provider.selectedLocation,
                    onChanged: provider.setSelectedLocation,
                  ),
                  const SizedBox(height: 12),
                  CustomSearchDropdownWithSearch(
                    isMandatory: true,
                    labelText: "Month",
                    items: provider.months,
                    selectedValue: provider.selectedMonth,
                    onChanged: provider.setSelectedMonth,
                  ),
                  const SizedBox(height: 16),
                  _buildGradientButton(
                    onPressed: () {
                      if (provider.selectedLocation != null &&
                          provider.selectedMonth != null) {
                        provider.fetchManualPunches(
                          location: provider.selectedLocation!,
                          month: provider.selectedMonth!,
                        );
                        setState(() => _showFilters = false);
                      }
                    },
                    text: 'View Attendance',
                    icon: Icons.visibility_rounded,
                  ),
                ],
              ),
            ),
            crossFadeState: _showFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

          // Search Bar (when data is loaded)
          if (provider.manualPunches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildSearchBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryColor, _secondaryColor],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _employeeSearchController,
      onChanged: (value) {
        setState(() => _employeeSearchQuery = value.toLowerCase());
      },
      style: const TextStyle(
        fontFamily: AppFonts.poppins,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search_rounded, color: _primaryColor),
        hintText: 'Search by name or ID...',
        hintStyle: TextStyle(
          fontFamily: AppFonts.poppins,
          fontSize: 14,
          color: Colors.grey.shade400,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        suffixIcon: _employeeSearchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _employeeSearchController.clear();
                  setState(() => _employeeSearchQuery = '');
                },
                icon: Icon(Icons.clear_rounded, color: Colors.grey.shade400),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(
    Map<String, dynamic> employee,
    int daysInMonth,
    String monthYear,
  ) {
    final attendance = employee['attendance'] as Map<String, dynamic>? ?? {};
    final stats = _calculateMonthlyStats(attendance);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Employee Header
          _buildEmployeeHeader(employee, stats),
          
          // Stats Summary
          _buildStatsSummary(stats),
          
          // Attendance Grid
          _buildAttendanceList(attendance, daysInMonth, monthYear),
        ],
      ),
    );
  }

  Widget _buildEmployeeHeader(
    Map<String, dynamic> employee,
    Map<String, dynamic> stats,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Text(
                (employee['name'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee['name'] ?? '-',
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildHeaderChip(Icons.badge_outlined, employee['empId'] ?? '-'),
                    const SizedBox(width: 8),
                    Flexible(
                      child: _buildHeaderChip(
                        Icons.work_outline_rounded,
                        employee['designation'] ?? '-',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Total Hours
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  stats['display'] ?? '-',
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Total',
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(Map<String, dynamic> stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatItem('Present', stats['presentDays'].toString(), _presentColor),
          _buildStatItem('Absent', stats['absentDays'].toString(), _absentColor),
          _buildStatItem('Leave', stats['leaveDays'].toString(), _leaveColor),
          _buildStatItem('Holiday', stats['holidays'].toString(), _holidayColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceList(
    Map<String, dynamic> attendance,
    int daysInMonth,
    String monthYear,
  ) {
    // Sort days and get only days with data
    final sortedDays = attendance.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    'Date',
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Check In',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Check Out',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Working',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Status',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedDays.length,
            itemBuilder: (context, index) {
              final day = sortedDays[index];
              final dayData = attendance[day] as Map<String, dynamic>?;
              
              return _buildDayRow(day, dayData, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(String day, Map<String, dynamic>? dayData, int index) {
    final status = dayData?['status'] ?? 'N/A';
    final times = dayData?['times'] as List<dynamic>?;
    final statusColor = _getStatusColor(status);
    final workTime = _calculateWorkingTime(times);

    String checkIn = '-';
    String checkOut = '-';

    if (times != null && times.isNotEmpty) {
      checkIn = times.first.toString();
      if (times.length > 1) {
        checkOut = times.last.toString();
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: index.isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                day.padLeft(2, '0'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),

          // Check In
          Expanded(
            child: status == 'P'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login_rounded,
                        size: 14,
                        color: _presentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        checkIn,
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _presentColor,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
          ),

          // Check Out
          Expanded(
            child: status == 'P'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 14,
                        color: _secondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        checkOut,
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _secondaryColor,
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
          ),

          // Working Hours
          Expanded(
            child: status == 'P'
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      workTime['display'] ?? '-',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
          ),

          // Status Badge
          SizedBox(
            width: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: _primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading attendance data...',
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Attendance Records',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select location and month to view\nemployee attendance data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildGradientButton(
              onPressed: () => setState(() => _showFilters = true),
              text: 'Open Filters',
              icon: Icons.filter_list_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
