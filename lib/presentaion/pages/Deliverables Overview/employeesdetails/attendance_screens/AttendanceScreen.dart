// File: screens/attendance_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/attendance_screens/year_month_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../model/deliverables_model/attendance_model.dart';
import '../../../../../provider/Deliverables_Overview_provider/attendance_provider.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;

  const AttendanceCalendarScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AttendanceProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return provider.isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1976D2)),
              )
              : Column(
                children: [
                  _buildCalendarHeader(provider),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildCalendarGrid(provider),
                            const SizedBox(height: 20),
                            if (provider.selectedDate != null)
                              _buildSelectedDateInfo(provider),
                            const SizedBox(height: 20),
                            _buildAttendanceSummary(provider),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
        },
      ),
    );
  }

  Widget _buildCalendarHeader(AttendanceProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showMonthYearPicker(context, provider),
              child: Row(
                children: [
                  Text(
                    provider.monthYearString,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF202124),
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF5F6368),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              _buildNavButton(Icons.chevron_left, provider.previousMonth),
              const SizedBox(width: 8),
              _buildNavButton(Icons.chevron_right, provider.nextMonth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: const Color(0xFF5F6368), size: 24),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(AttendanceProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [_buildWeekdayHeader(), _buildCalendarDays(provider)],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Row(
        children:
            weekdays
                .map(
                  (day) => Expanded(
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF70757A),
                        letterSpacing: 0.8,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCalendarDays(AttendanceProvider provider) {
    final daysInMonth = provider.daysInMonth;
    final firstDayOfMonth = provider.firstDayOfMonth;

    List<Widget> dayWidgets = [];

    // Add empty cells for days before month starts
    for (int i = 0; i < firstDayOfMonth; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Add day cells - ALL dates are now enabled
    for (int day = 1; day <= daysInMonth; day++) {
      dayWidgets.add(_buildDayCell(day, provider));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: dayWidgets,
      ),
    );
  }

  Widget _buildDayCell(int day, AttendanceProvider provider) {
    final attendance = provider.getAttendanceForDay(day);
    final isToday = provider.isToday(day);
    final isSelected = provider.isSelected(day);
    final hasEvent = provider.hasEvent(day);
    final isWorkingDay = provider.isWorkingDay(day);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => provider.selectDate(day), // All dates are clickable
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _getDayCellBackgroundColor(isToday, isSelected, attendance),
            borderRadius: BorderRadius.circular(20),
            border:
                isToday && !isSelected
                    ? Border.all(color: const Color(0xFF1976D2), width: 2)
                    : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.toString(),
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,

                        fontSize: 14,
                        fontWeight:
                            isToday || isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                        color: _getDayTextColor(
                          isToday,
                          isSelected,
                          isWorkingDay,
                          attendance,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Attendance status indicator
                    if (attendance != null)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _getStatusColor(attendance.status),
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      const SizedBox(height: 4),
                  ],
                ),
              ),
              // Event indicator (top-right corner)
              if (hasEvent)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1976D2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDateInfo(AttendanceProvider provider) {
    final selectedDate = provider.selectedDate!;
    final attendance = provider.getAttendanceForDay(selectedDate.day);
    final hasEvent = provider.hasEvent(selectedDate.day);
    final isWorkingDay = provider.isWorkingDay(selectedDate.day);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _formatSelectedDate(selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202124),
                    fontFamily: AppFonts.poppins,
                  ),
                  overflow: TextOverflow.ellipsis, // prevent overflow
                ),
              ),
              TextButton(
                onPressed: provider.clearSelection,
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontSize: 14,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isWorkingDay ? 'Working Day' : 'Weekend',
            style: TextStyle(
              fontFamily: AppFonts.poppins,

              fontSize: 12,
              color:
                  isWorkingDay
                      ? const Color(0xFF34A853)
                      : const Color(0xFFFF6D01),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          if (attendance != null) ...[
            _buildInfoRow(
              Icons.login,
              'Check-in',
              attendance.inTime,
              const Color(0xFF34A853),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.logout,
              'Check-out',
              attendance.outTime,
              const Color(0xFFEA4335),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.info_outline,
              'Status',
              _getStatusText(attendance.status),
              _getStatusColor(attendance.status),
            ),
          ] else if (hasEvent) ...[
            _buildInfoRow(
              Icons.event,
              'Event',
              'Holiday/Special Event',
              const Color(0xFF1976D2),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No attendance record for this day',
                      style: TextStyle(
                        color: Color(0xFF70757A),
                        fontSize: 14,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF70757A),
            fontWeight: FontWeight.w500,
            fontFamily: AppFonts.poppins,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceSummary(AttendanceProvider provider) {
    final summary = provider.getAttendanceSummary();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202124),
              fontFamily: AppFonts.poppins,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Present Days',
                  summary.presentDays.toString(),
                  const Color(0xFF34A853),
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'On Time',
                  summary.onTimeDays.toString(),
                  const Color(0xFF1976D2),
                  Icons.schedule,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Late Arrivals',
                  summary.lateDays.toString(),
                  const Color(0xFFFBBC04),
                  Icons.access_time,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Very Late',
                  summary.veryLateDays.toString(),
                  const Color(0xFFEA4335),
                  Icons.warning_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Working Days:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF70757A),
                    fontFamily: AppFonts.poppins,
                  ),
                ),
                Text(
                  summary.totalWorkingDays.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202124),
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: AppFonts.poppins,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF70757A),
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.poppins,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getDayCellBackgroundColor(
    bool isToday,
    bool isSelected,
    AttendanceRecord? attendance,
  ) {
    if (isSelected) {
      return const Color(0xFF1976D2);
    }
    if (isToday) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }

  Color _getDayTextColor(
    bool isToday,
    bool isSelected,
    bool isWorkingDay,
    AttendanceRecord? attendance,
  ) {
    if (isSelected) {
      return Colors.white;
    }
    if (isToday) {
      return const Color(0xFF1976D2);
    }
    if (!isWorkingDay) {
      return const Color(0xFFBDBDBD);
    }
    return const Color(0xFF202124);
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return const Color(0xFF34A853);
      case AttendanceStatus.late:
        return const Color(0xFFFBBC04);
      case AttendanceStatus.veryLate:
        return const Color(0xFFEA4335);
      default:
        return const Color(0xFF9AA0A6);
    }
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return 'On Time';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.veryLate:
        return 'Very Late';
      default:
        return 'Unknown';
    }
  }

  String _formatSelectedDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '$weekday, ${date.day} $month ${date.year}';
  }

  // Dialog methods
  void _showMonthYearPicker(BuildContext context, AttendanceProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Select Month & Year',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: YearMonthPicker(
              currentMonth: provider.selectedMonth,
              onMonthSelected: (DateTime month) {
                provider.setSelectedMonth(month);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}
