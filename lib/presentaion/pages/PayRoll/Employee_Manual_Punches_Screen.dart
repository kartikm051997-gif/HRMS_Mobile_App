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
    with TickerProviderStateMixin {
  bool _showFilters = false;
  late TextEditingController _employeeSearchController;
  String _employeeSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _employeeSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _employeeSearchController.dispose();
    super.dispose();
  }

  int _getDaysInMonth(String? monthYear) {
    if (monthYear == null) return 31;
    final months = {
      'January': 31,
      'February': 28,
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
    String monthName = monthYear.split(' ')[0];
    return months[monthName] ?? 31;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'P':
        return const Color(0xFF0F6FFF);
      case 'A':
        return const Color(0xFFDC2626);
      case 'L':
        return const Color(0xFFD97706);
      case 'H':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeManualPunchesProvider>(context);

    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Attendance Punches"),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFilterHeader(provider),
            Consumer<EmployeeManualPunchesProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return _buildLoadingState();
                if (provider.manualPunches.isEmpty) return _buildEmptyState();

                int daysInMonth = _getDaysInMonth(provider.selectedMonth);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.manualPunches.length,
                        itemBuilder: (context, index) {
                          final employee = provider.manualPunches[index];

                          String empName =
                              (employee['name'] ?? '').toLowerCase();
                          String empId =
                              (employee['empId'] ?? '').toLowerCase();

                          if (_employeeSearchQuery.isNotEmpty) {
                            if (!empName.contains(_employeeSearchQuery) &&
                                !empId.contains(_employeeSearchQuery)) {
                              return const SizedBox.shrink();
                            }
                          }

                          return _buildEmployeeSection(employee, daysInMonth);
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

  Widget _buildSearchBar() {
    return TextField(
      controller: _employeeSearchController,
      onChanged: (value) {
        setState(() => _employeeSearchQuery = value.toLowerCase());
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Color(0xFF0F6FFF)),
        hintText: "Search employee name or ID...",
        hintStyle: TextStyle(fontFamily: AppFonts.poppins),
        filled: true,
        fillColor: Colors.white,
        suffixIcon:
            _employeeSearchQuery.isNotEmpty
                ? IconButton(
                  onPressed: () {
                    _employeeSearchController.clear();
                    setState(() => _employeeSearchQuery = "");
                  },
                  icon: const Icon(Icons.clear, color: Colors.grey),
                )
                : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF0F6FFF), width: 2),
        ),
      ),
    );
  }

  Widget _buildEmployeeSection(Map<String, dynamic> employee, int daysInMonth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmployeeHeader(employee),
          const Divider(height: 1),
          _buildCalendarGrid(employee['attendance'] ?? {}, daysInMonth),
        ],
      ),
    );
  }

  Widget _buildEmployeeHeader(Map<String, dynamic> employee) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF0F6FFF).withOpacity(0.15),
            child: Text(
              (employee['name'] ?? 'U')[0].toUpperCase(),
              style: const TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F6FFF),
              ),
            ),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 4),
                Text(
                  "ID: ${employee['empId']} • ${employee['designation'] ?? '-'}",
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Map<String, dynamic> attendance, int daysInMonth) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: daysInMonth,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          int day = index + 1;
          Map<String, dynamic>? dayData = attendance[day.toString()];
          return _buildDayTile(day, dayData);
        },
      ),
    );
  }

  Widget _buildDayTile(int day, Map<String, dynamic>? dayData) {
    String status = dayData?['status'] ?? 'N/A';
    Color bgColor = _getStatusColor(status);
    bool hasData = status != 'N/A';

    return GestureDetector(
      onTap: () => _showEditPunchDialog(day, dayData),
      child: ScaleTransition(
        scale: AlwaysStoppedAnimation(1.0),
        child: Container(
          decoration: BoxDecoration(
            color: hasData ? bgColor : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                hasData
                    ? [
                      BoxShadow(
                        color: bgColor.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : [],
            border: Border.all(
              color: hasData ? bgColor.withOpacity(0.2) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showEditPunchDialog(day, dayData),
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              hasData ? Colors.white : const Color(0xFFD1D5DB),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (status != 'N/A')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _calculateWorkingHours(String checkIn, String checkOut) {
    if (checkIn.isEmpty || checkOut.isEmpty) return '0h 0m';

    try {
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

      int diffMinutes = checkOutMinutes - checkInMinutes;
      int hours = diffMinutes ~/ 60;
      int minutes = diffMinutes % 60;

      return '${hours}h ${minutes}m';
    } catch (e) {
      return '0h 0m';
    }
  }

  void _showEditPunchDialog(int day, Map<String, dynamic>? dayData) {
    late TextEditingController checkInController;
    late TextEditingController checkOutController;
    late TextEditingController descriptionController;
    String? selectedStatus = dayData?['status'] ?? 'P';
    List<String>? times =
        dayData?['times'] != null ? List<String>.from(dayData!['times']) : [];

    checkInController = TextEditingController(
      text: (times?.isNotEmpty ?? false) ? times![0] : '',
    );
    checkOutController = TextEditingController(
      text: (times?.length ?? 0) > 1 ? times![1] : '',
    );
    descriptionController = TextEditingController();

    String workingHours = _calculateWorkingHours(
      checkInController.text,
      checkOutController.text,
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F6FFF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit_calendar,
                            color: Color(0xFF0F6FFF),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Attendance Details',
                                style: TextStyle(
                                  fontFamily: AppFonts.poppins,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              Text(
                                'Day $day',
                                style: TextStyle(
                                  fontFamily: AppFonts.poppins,
                                  fontSize: 12,
                                  color: const Color(0xFF9CA3AF),
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
                    const Divider(),
                    const SizedBox(height: 20),

                    // Status Selection
                    Text(
                      'Status',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedStatus,
                          items: [
                            DropdownMenuItem(
                              value: 'P',
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F6FFF),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Present',
                                      style: TextStyle(
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'A',
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDC2626),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Absent',
                                      style: TextStyle(
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'L',
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD97706),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Leave',
                                      style: TextStyle(
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'H',
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7C3AED),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Holiday',
                                      style: TextStyle(
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            selectedStatus = value;
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Check-in Time
                    Text(
                      'Check-in Time',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: checkInController,
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        prefixIcon: const Icon(
                          Icons.login,
                          color: Color(0xFF0F6FFF),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF0F6FFF),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Check-out Time
                    Text(
                      'Check-out Time',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: checkOutController,
                      decoration: InputDecoration(
                        hintText: 'HH:MM',
                        prefixIcon: const Icon(
                          Icons.logout,
                          color: Color(0xFFF59E0B),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFF59E0B),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'Description (Optional)',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter description here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF0F6FFF),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle submission here
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Attendance updated successfully',
                                  ),
                                  backgroundColor: const Color(0xFF0F6FFF),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F6FFF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF0F6FFF),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading attendance records...',
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              color: const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: const Color(0xFF0F6FFF).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No Records Found",
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(EmployeeManualPunchesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt_rounded, color: Color(0xFF0F6FFF)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Filters",
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: Icon(
                  _showFilters ? Icons.expand_less : Icons.expand_more,
                ),
              ),
            ],
          ),
          if (_showFilters) const SizedBox(height: 8),
          if (_showFilters)
            Column(
              children: [
                CustomSearchDropdownWithSearch(
                  isMandatory: true,
                  labelText: "Location",
                  items: provider.location,
                  selectedValue: provider.selectedLocation,
                  onChanged: provider.setSelectedLocation,
                ),
                const SizedBox(height: 10),
                CustomSearchDropdownWithSearch(
                  isMandatory: true,
                  labelText: "Month",
                  items: provider.months,
                  selectedValue: provider.selectedMonth,
                  onChanged: provider.setSelectedMonth,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F6FFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      provider.fetchManualPunches(
                        location: provider.selectedLocation!,
                        month: provider.selectedMonth!,
                      );
                      setState(() => _showFilters = false);
                    },
                    child: const Text(
                      "View Attendance ",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
//updated