import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/appcolor_dart.dart';

import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/payroll_provider/Attendance_Log_provider.dart';
import '../../../widgets/custom_textfield/Custom_date_field.dart';
import '../../../widgets/custom_textfield/custom_dropdown_with_search.dart';

class AttendanceLogScreen extends StatefulWidget {
  const AttendanceLogScreen({super.key});

  @override
  State<AttendanceLogScreen> createState() => _AttendanceLogScreenState();
}

class _AttendanceLogScreenState extends State<AttendanceLogScreen> {
  final TextEditingController _employeeSearchController =
      TextEditingController();
  bool _showFilterContainer = true;

  @override
  void dispose() {
    _employeeSearchController.dispose();
    Provider.of<AttendanceLogProvider>(
      context,
      listen: false,
    ).resetSelections();
    super.dispose();
  }

  void _toggleFilterContainer() {
    setState(() {
      _showFilterContainer = !_showFilterContainer;
    });
  }

  void _resetFilters() {
    Provider.of<AttendanceLogProvider>(
      context,
      listen: false,
    ).resetSelections();
    _employeeSearchController.clear();
    setState(() {
      _showFilterContainer = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceLogProvider = Provider.of<AttendanceLogProvider>(context);

    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Attendance Log"),
      backgroundColor: const Color(0xFFF8F9FF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Filter Toggle Button (Always Visible)
              if (!_showFilterContainer)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            'Reset',
                            style: TextStyle(fontFamily: AppFonts.poppins),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Filter Section (Collapsible)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child:
                    _showFilterContainer
                        ? Container(
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
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Attendance Filters",
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

                                // Zone Dropdown
                                CustomSearchDropdownWithSearch(
                                  isMandatory: true,
                                  labelText: "Zones",
                                  items: attendanceLogProvider.zones,
                                  selectedValue:
                                      attendanceLogProvider.selectedZones,
                                  onChanged:
                                      attendanceLogProvider.setSelectedZones,
                                  hintText: "Select Zone...",
                                ),
                                const SizedBox(height: 12),

                                // Branch Dropdown
                                CustomSearchDropdownWithSearch(
                                  isMandatory: true,
                                  labelText: "Branches",
                                  items: attendanceLogProvider.branches,
                                  selectedValue:
                                      attendanceLogProvider.selectedBranches,
                                  onChanged:
                                      attendanceLogProvider.setSelectedBranches,
                                  hintText: "Select Branches...",
                                ),
                                const SizedBox(height: 12),

                                // Type Dropdown
                                CustomSearchDropdownWithSearch(
                                  isMandatory: true,
                                  labelText: "Type",
                                  items: attendanceLogProvider.type,
                                  selectedValue:
                                      attendanceLogProvider.selectedType,
                                  onChanged:
                                      attendanceLogProvider.setSelectedType,
                                  hintText: "Select Type...",
                                ),
                                const SizedBox(height: 12),

                                // Employee Salary Category Dropdown
                                CustomSearchDropdownWithSearch(
                                  isMandatory: true,
                                  labelText: "Employee Salary Category",
                                  items:
                                      attendanceLogProvider
                                          .employeeSalaryCategory,
                                  selectedValue:
                                      attendanceLogProvider
                                          .selectedEmployeeSalaryCategory,
                                  onChanged:
                                      attendanceLogProvider
                                          .setSelectedEmployeeSalaryCategory,
                                  hintText: "Select Category...",
                                ),
                                const SizedBox(height: 12),

                                // Month / Day Dropdown
                                Consumer<AttendanceLogProvider>(
                                  builder: (context, provider, child) {
                                    return Column(
                                      children: [
                                        CustomSearchDropdownWithSearch(
                                          isMandatory: true,
                                          labelText: "Month / Day",
                                          items: provider.monDay,
                                          selectedValue:
                                              provider.selectedMonDay,
                                          onChanged: provider.setSelectedMonDay,
                                          hintText: "Select Month / Day...",
                                        ),
                                        const SizedBox(height: 12),

                                        if (provider.selectedMonDay != null &&
                                            provider.selectedMonDay!.isNotEmpty)
                                          CustomDateField(
                                            controller: provider.dateController,
                                            hintText:
                                                provider.selectedMonDay == "Day"
                                                    ? "Select Day"
                                                    : "Select Month",
                                            labelText:
                                                provider.selectedMonDay == "Day"
                                                    ? "Day"
                                                    : "Month",
                                            isMandatory: false,
                                            onTap: () async {
                                              if (provider.selectedMonDay ==
                                                  "Month") {
                                                final months = [
                                                  "Jan",
                                                  "Feb",
                                                  "Mar",
                                                  "Apr",
                                                  "May",
                                                  "Jun",
                                                  "Jul",
                                                  "Aug",
                                                  "Sep",
                                                  "Oct",
                                                  "Nov",
                                                  "Dec",
                                                ];

                                                String?
                                                selectedMonth = await showDialog<
                                                  String
                                                >(
                                                  context: context,
                                                  builder: (ctx) {
                                                    String? tempSelected;
                                                    return StatefulBuilder(
                                                      builder: (
                                                        context,
                                                        setState,
                                                      ) {
                                                        return AlertDialog(
                                                          title: Text(
                                                            "Select Month",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppFonts
                                                                      .poppins,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  const Color(
                                                                    0xFF1A1A2E,
                                                                  ),
                                                            ),
                                                          ),
                                                          content: SizedBox(
                                                            width:
                                                                double
                                                                    .maxFinite,
                                                            child: GridView.builder(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  months.length,
                                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    3,
                                                                childAspectRatio:
                                                                    2,
                                                                crossAxisSpacing:
                                                                    8,
                                                                mainAxisSpacing:
                                                                    8,
                                                              ),
                                                              itemBuilder: (
                                                                context,
                                                                index,
                                                              ) {
                                                                bool
                                                                isSelected =
                                                                    tempSelected ==
                                                                    months[index];
                                                                return InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                      () =>
                                                                          tempSelected =
                                                                              months[index],
                                                                    );
                                                                    Future.delayed(
                                                                      const Duration(
                                                                        milliseconds:
                                                                            200,
                                                                      ),
                                                                      () {
                                                                        Navigator.pop(
                                                                          ctx,
                                                                          months[index],
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          isSelected
                                                                              ? const Color(
                                                                                0xFF0F6FFF,
                                                                              ).withOpacity(
                                                                                0.1,
                                                                              )
                                                                              : Colors.white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            8,
                                                                          ),
                                                                      border: Border.all(
                                                                        color:
                                                                            isSelected
                                                                                ? const Color(
                                                                                  0xFF0F6FFF,
                                                                                )
                                                                                : const Color(
                                                                                  0xFFE8E8F0,
                                                                                ),
                                                                        width:
                                                                            1.5,
                                                                      ),
                                                                    ),
                                                                    child: Center(
                                                                      child: Text(
                                                                        months[index],
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              AppFonts.poppins,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              isSelected
                                                                                  ? FontWeight.w700
                                                                                  : FontWeight.w500,
                                                                          color:
                                                                              isSelected
                                                                                  ? const Color(
                                                                                    0xFF0F6FFF,
                                                                                  )
                                                                                  : const Color(
                                                                                    0xFF1A1A2E,
                                                                                  ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );

                                                if (selectedMonth != null) {
                                                  provider.dateController.text =
                                                      selectedMonth;
                                                }
                                              } else if (provider
                                                      .selectedMonDay ==
                                                  "Day") {
                                                DateTime?
                                                selectedDay = await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(2000),
                                                  lastDate: DateTime(2100),
                                                  builder: (context, child) {
                                                    return Theme(
                                                      data: Theme.of(
                                                        context,
                                                      ).copyWith(
                                                        colorScheme:
                                                            const ColorScheme.light(
                                                              primary: Color(
                                                                0xFF0F6FFF,
                                                              ),
                                                            ),
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                );

                                                if (selectedDay != null) {
                                                  provider.dateController.text =
                                                      "${selectedDay.day}-${selectedDay.month}-${selectedDay.year}";
                                                }
                                              }
                                            },
                                          ),

                                        const SizedBox(height: 20),

                                        // Search Button
                                        SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (provider.selectedZones !=
                                                      null &&
                                                  provider.selectedBranches !=
                                                      null &&
                                                  provider.selectedType !=
                                                      null &&
                                                  provider.selectedEmployeeSalaryCategory !=
                                                      null &&
                                                  provider.selectedMonDay !=
                                                      null &&
                                                  provider
                                                      .dateController
                                                      .text
                                                      .isNotEmpty) {
                                                provider.fetchAttendanceData(
                                                  zones:
                                                      provider.selectedZones!,
                                                  branches:
                                                      provider
                                                          .selectedBranches!,
                                                  type: provider.selectedType!,
                                                  salaryCategory:
                                                      provider
                                                          .selectedEmployeeSalaryCategory!,
                                                  period:
                                                      provider.selectedMonDay!,
                                                  date:
                                                      provider
                                                          .dateController
                                                          .text,
                                                  employeeSearch:
                                                      _employeeSearchController
                                                          .text,
                                                );

                                                // Hide filter container
                                                setState(() {
                                                  _showFilterContainer = false;
                                                });
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Please fill all required fields",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFonts.poppins,
                                                      ),
                                                    ),
                                                    backgroundColor: Color(
                                                      0xFFEF4444,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF0F6FFF,
                                              ),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              elevation: 2,
                                            ),
                                            child: Text(
                                              'Search',
                                              style: TextStyle(
                                                fontFamily: AppFonts.poppins,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
              ),

              // Results Section

              // Employee Search
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<AttendanceLogProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF0F6FFF),
                          ),
                        );
                      }

                      if (provider.attendanceData.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'No data found. Please search to display results.',
                              style: TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 14,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Employee Search',
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _employeeSearchController,
                            decoration: InputDecoration(
                              hintText: 'Search by employee ID or name...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontFamily: AppFonts.poppins,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF0F6FFF),
                              ),
                              suffixIcon:
                                  _employeeSearchController.text.isNotEmpty
                                      ? IconButton(
                                        onPressed: () {
                                          _employeeSearchController.clear();
                                          setState(() {});
                                        },
                                        icon: const Icon(
                                          Icons.close,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      )
                                      : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE8E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0F6FFF),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Attendance Records',
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.attendanceData.length,
                            itemBuilder: (context, index) {
                              final item = provider.attendanceData[index];
                              return _buildAnimatedAttendanceCard(
                                item: item,
                                index: index,
                                total: provider.attendanceData.length,
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for animated card
  Widget _buildAnimatedAttendanceCard({
    required Map<String, dynamic> item,
    required int index,
    required int total,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle card tap
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with ID and Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0F6FFF,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['empId'] ?? '-',
                                    style: const TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F6FFF),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item['name'] ?? '-',
                                    style: const TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['designation'] ?? '-',
                              style: const TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['hoursWorked'] ?? '-',
                          style: const TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE8E8F0)),
                  const SizedBox(height: 16),
                  // Branch Info
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item['branch'] ?? '-',
                          style: const TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 13,
                            color: Color(0xFF1A1A2E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Time Info Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeBox(
                          title: 'In Time',
                          time: item['inTime'] ?? '-',
                          icon: Icons.login,
                          color: const Color(0xFF0F6FFF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTimeBox(
                          title: 'Out Time',
                          time: item['outTime'] ?? '-',
                          icon: Icons.logout,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for time boxes
  Widget _buildTimeBox({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
