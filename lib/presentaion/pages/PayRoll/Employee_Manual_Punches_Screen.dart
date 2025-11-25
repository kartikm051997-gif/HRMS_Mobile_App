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
    extends State<EmployeeManualPunchesScreen> with TickerProviderStateMixin {
  bool _showFilterContainer = true;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _toggleFilterContainer() {
    if (_showFilterContainer) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
    setState(() {
      _showFilterContainer = !_showFilterContainer;
    });
  }

  // Get number of days in the selected month
  int _getDaysInMonth(String? monthYear) {
    if (monthYear == null) return 31;

    final months = {
      'January': 31, 'February': 28, 'March': 31, 'April': 30,
      'May': 31, 'June': 30, 'July': 31, 'August': 31,
      'September': 30, 'October': 31, 'November': 30, 'December': 31
    };

    String monthName = monthYear.split(' ')[0];
    return months[monthName] ?? 31;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeManualPunchesProvider>(context);

    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Employee Manual Punches"),
      backgroundColor: const Color(0xFFF8F9FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Filter Section
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _showFilterContainer
                  ? Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFE8E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Manual Punches Filters",
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleFilterContainer,
                          icon: const Icon(Icons.close),
                          color: const Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Location",
                      items: provider.location,
                      selectedValue: provider.selectedLocation,
                      onChanged: provider.setSelectedLocation,
                      hintText: "Select Location...",
                    ),
                    const SizedBox(height: 12),
                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Select Month",
                      items: provider.months,
                      selectedValue: provider.selectedMonth,
                      onChanged: provider.setSelectedMonth,
                      hintText: "Select Month...",
                    ),
                    const SizedBox(height: 20),
                    if (provider.selectedLocation != null &&
                        provider.selectedMonth != null)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            provider.fetchManualPunches(
                              location: provider.selectedLocation!,
                              month: provider.selectedMonth!,
                            );
                            _toggleFilterContainer();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F6FFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Go',
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE8E8F0),
                          ),
                          color: const Color(0xFFF5F5F5),
                        ),
                        child: Center(
                          child: Text(
                            'Please fill all fields',
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),
            ),

            // Show Filter Button
            if (!_showFilterContainer)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _toggleFilterContainer,
                  icon: const Icon(Icons.tune),
                  label: Text(
                    'Show Filters',
                    style: TextStyle(fontFamily: AppFonts.poppins),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6FFF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

            // Results Section
            Consumer<EmployeeManualPunchesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF0F6FFF),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading manual punches...',
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.manualPunches.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: const Color(0xFFE8E8F0),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No manual punches found',
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select location and month to view records',
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                int daysInMonth = _getDaysInMonth(provider.selectedMonth);

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8E8F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month,
                                color: const Color(0xFF0F6FFF), size: 24),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Attendance - ${provider.selectedMonth}',
                                  style: const TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                Text(
                                  provider.selectedLocation ?? '',
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 12,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Legend
                      _buildLegend(),
                      const SizedBox(height: 20),

                      // Employee Cards
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.manualPunches.length,
                        itemBuilder: (context, index) {
                          final employee = provider.manualPunches[index];
                          return _buildEmployeeCalendarCard(
                            employee: employee,
                            daysInMonth: daysInMonth,
                            index: index,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8E8F0)),
      ),
      child: Row(
        children: [
          _buildLegendItem('P', 'Present', const Color(0xFF10B981)),
          const SizedBox(width: 16),
          _buildLegendItem('A', 'Absent', const Color(0xFFEF4444)),
          const SizedBox(width: 16),
          _buildLegendItem('L', 'Leave', const Color(0xFFF59E0B)),
          const SizedBox(width: 16),
          _buildLegendItem('H', 'Holiday', const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String code, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              code,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 11,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeCalendarCard({
    required Map<String, dynamic> employee,
    required int daysInMonth,
    required int index,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFE8E8F0)),
        ),
        child: Column(
          children: [
            // Employee Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // Employee Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F6FFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        (employee['name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F6FFF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Employee Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee['name'] ?? '-',
                          style: const TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${employee['designation'] ?? '-'} • ID: ${employee['empId'] ?? '-'}',
                          style: const TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stats
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 12, color: Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            Text(
                              '${employee['workingDays']} Days',
                              style: const TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_busy,
                                size: 12, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(
                              '${employee['allowedLeave']} Leave',
                              style: const TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Calendar Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMonthlyCalendar(
                employee['attendance'] ?? {},
                daysInMonth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCalendar(
      Map<String, dynamic> attendance,
      int daysInMonth,
      ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        int day = index + 1;
        String dayKey = day.toString();
        Map<String, dynamic>? dayData = attendance[dayKey];

        return _buildDayCell(day, dayData);
      },
    );
  }

  Widget _buildDayCell(int day, Map<String, dynamic>? dayData) {
    Color bgColor;
    Color textColor;
    String displayText;
    IconData? icon;
    List<String>? times;

    if (dayData == null) {
      // No data - minimal gray style
      bgColor = const Color(0xFFF9FAFB);
      textColor = const Color(0xFFD1D5DB);
      displayText = day.toString();
      icon = null;
      times = null;
    } else {
      String statusCode = dayData['status'] ?? 'A';
      times = dayData['times'] != null ? List<String>.from(dayData['times']) : null;

      switch (statusCode) {
        case 'P':
        // Present - Green gradient with check icon
          bgColor = const Color(0xFF10B981);
          textColor = Colors.white;
          displayText = day.toString();
          icon = Icons.check_circle;
          break;
        case 'A':
        // Absent - Red with X icon
          bgColor = const Color(0xFFEF4444);
          textColor = Colors.white;
          displayText = day.toString();
          icon = Icons.cancel;
          break;
        case 'L':
        // Leave - Orange with calendar icon
          bgColor = const Color(0xFFF59E0B);
          textColor = Colors.white;
          displayText = day.toString();
          icon = Icons.event_busy;
          break;
        case 'H':
        // Holiday - Purple with home icon
          bgColor = const Color(0xFF8B5CF6);
          textColor = Colors.white;
          displayText = day.toString();
          icon = Icons.home;
          break;
        default:
          bgColor = const Color(0xFFF9FAFB);
          textColor = const Color(0xFFD1D5DB);
          displayText = day.toString();
          icon = null;
      }
    }

    return GestureDetector(
      onTap: times != null && times.isNotEmpty ? () {
        _showPunchTimesDialog(day, times!);
      } : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: dayData != null && dayData['status'] == 'P'
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              bgColor.withOpacity(0.8),
            ],
          )
              : null,
          color: dayData != null && dayData['status'] != 'P' ? bgColor : bgColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: dayData != null && dayData['status'] != null
              ? [
            BoxShadow(
              color: bgColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Stack(
          children: [
            // Icon in top-right corner for status
            if (icon != null)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  icon,
                  size: 12,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayText,
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  if (times != null && times.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 8,
                            color: textColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${times.length}',
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Tap indicator
            if (times != null && times.isNotEmpty)
              Positioned(
                bottom: 2,
                right: 2,
                child: Icon(
                  Icons.touch_app,
                  size: 10,
                  color: textColor.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPunchTimesDialog(int day, List<String> times) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F6FFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Color(0xFF0F6FFF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Punch Times',
                            style: const TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            'Day $day',
                            style: const TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: const Color(0xFF9CA3AF),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                ...times.asMap().entries.map((entry) {
                  int index = entry.key;
                  String time = entry.value;
                  bool isCheckIn = index % 2 == 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCheckIn
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFF0F6FFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCheckIn
                            ? const Color(0xFF10B981).withOpacity(0.3)
                            : const Color(0xFF0F6FFF).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isCheckIn
                                ? const Color(0xFF10B981)
                                : const Color(0xFF0F6FFF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            isCheckIn ? Icons.login : Icons.logout,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCheckIn ? 'Check In' : 'Check Out',
                                style: TextStyle(
                                  fontFamily: AppFonts.poppins,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                time,
                                style: TextStyle(
                                  fontFamily: AppFonts.poppins,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isCheckIn
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF0F6FFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Total ${times.length} punches recorded',
                          style: const TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}