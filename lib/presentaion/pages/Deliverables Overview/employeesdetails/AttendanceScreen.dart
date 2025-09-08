import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:provider/provider.dart';
import '../../../../provider/Deliverables_Overview_provider/attendance_provider.dart';

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
      backgroundColor: Colors.grey[50],
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Month Header with Navigation
              _buildMonthHeader(provider),

              // Calendar Grid
              Expanded(
                child:
                    provider.isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primaryColor2,
                          ),
                        )
                        : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildCalendarGrid(provider),
                              const SizedBox(height: 20),
                              _buildAttendanceSummary(provider),
                            ],
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthHeader(AttendanceProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.primaryColor2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Month Button
          IconButton(
            onPressed: provider.previousMonth,
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          ),

          // Month Year Display
          Expanded(
            child: GestureDetector(
              onTap: () => _showMonthPicker(context, provider),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.monthYearString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Next Month Button
          IconButton(
            onPressed: provider.nextMonth,
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(AttendanceProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          // Days of week header
          _buildWeekdayHeader(),

          // Calendar grid
          _buildCalendarDays(provider),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
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
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontSize: 14,
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

    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      dayWidgets.add(_buildDayCell(day, provider));
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: 0.85,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: dayWidgets,
      ),
    );
  }

  Widget _buildDayCell(int day, AttendanceProvider provider) {
    final attendance = provider.getAttendanceForDay(day);
    final isToday = _isToday(
      provider.selectedMonth.year,
      provider.selectedMonth.month,
      day,
    );

    return GestureDetector(
      onTap:
          attendance != null
              ? () => _showDayDetails(context, day, attendance)
              : null,
      child: Container(
        decoration: BoxDecoration(
          color: _getDayCellColor(attendance, isToday),
          borderRadius: BorderRadius.circular(12),
          border:
              isToday ? Border.all(color: Colors.blue[600]!, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            Text(
              day.toString(),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: _getDayTextColor(attendance, isToday),
                fontSize: 16,
                fontFamily: AppFonts.poppins,
              ),
            ),

            const SizedBox(height: 2),

            // Attendance indicator
            if (attendance != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getStatusColor(attendance.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                attendance.inTime,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ] else ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 11),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary(AttendanceProvider provider) {
    final summary = provider.getAttendanceSummary();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
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
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'On Time',
                  summary.onTimeDays.toString(),
                  Colors.blue,
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
                  Colors.orange,
                  Icons.access_time,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Very Late',
                  summary.veryLateDays.toString(),
                  Colors.red,
                  Icons.warning,
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
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
  bool _isToday(int year, int month, int day) {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  Color _getDayCellColor(AttendanceRecord? attendance, bool isToday) {
    if (attendance == null) {
      return Colors.grey[100]!;
    }

    if (isToday) {
      return Colors.blue[50]!;
    }

    switch (attendance.status) {
      case AttendanceStatus.onTime:
        return Colors.green[50]!;
      case AttendanceStatus.late:
        return Colors.orange[50]!;
      case AttendanceStatus.veryLate:
        return Colors.red[50]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getDayTextColor(AttendanceRecord? attendance, bool isToday) {
    if (isToday) {
      return Colors.blue[700]!;
    }

    if (attendance == null) {
      return Colors.grey[400]!;
    }

    return Colors.black87;
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.onTime:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.veryLate:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showMonthPicker(BuildContext context, AttendanceProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select Month',
            style: TextStyle(fontFamily: AppFonts.poppins),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: YearView(
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

  void _showDayDetails(
    BuildContext context,
    int day,
    AttendanceRecord attendance,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            style: TextStyle(fontFamily: AppFonts.poppins),
            'Attendance - ${attendance.date.day}/${attendance.date.month}/${attendance.date.year}',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'In Time:',
                attendance.inTime,
                Icons.login,
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Out Time:',
                attendance.outTime,
                Icons.logout,
                Colors.red,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Status:',
                _getStatusText(attendance.status),
                Icons.info,
                _getStatusColor(attendance.status),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(fontFamily: AppFonts.poppins),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ],
    );
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
}

// Custom Year/Month picker widget
class YearView extends StatelessWidget {
  final DateTime currentMonth;
  final Function(DateTime) onMonthSelected;

  const YearView({
    super.key,
    required this.currentMonth,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 2,
      children: List.generate(12, (index) {
        final month = DateTime(currentMonth.year, index + 1, 1);
        final monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];

        final isSelected = month.month == currentMonth.month;

        return GestureDetector(
          onTap: () => onMonthSelected(month),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[600] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                monthNames[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
