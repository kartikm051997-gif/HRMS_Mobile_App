import 'package:flutter/material.dart';

class AttendanceProvider extends ChangeNotifier {
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;
  List<AttendanceRecord> _attendanceRecords = [];

  // Getters
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;

  // Get formatted month year string
  String get monthYearString {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[_selectedMonth.month - 1]}, ${_selectedMonth.year}';
  }

  // Get days in selected month
  int get daysInMonth {
    return DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
  }

  // Get first day of month (for calendar layout)
  int get firstDayOfMonth {
    return DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;
  }

  // Check if a day is a working day (not weekend)
  bool isWorkingDay(int day) {
    final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
    return date.weekday != 6 && date.weekday != 7; // Not Saturday or Sunday
  }

  // Check if a day is today
  bool isToday(int day) {
    final today = DateTime.now();
    final dayDate = DateTime(_selectedMonth.year, _selectedMonth.month, day);
    return today.year == dayDate.year &&
        today.month == dayDate.month &&
        today.day == dayDate.day;
  }

  // Set selected month
  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
    _loadAttendanceData();
  }

  // Load attendance data for selected month
  Future<void> _loadAttendanceData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate dummy attendance data
    _attendanceRecords = _generateDummyAttendance();

    _isLoading = false;
    notifyListeners();
  }

  // Generate dummy attendance data (only for working days)
  List<AttendanceRecord> _generateDummyAttendance() {
    final List<AttendanceRecord> records = [];
    final random = [
      ['09:15', '18:30'],
      ['09:08', '18:45'],
      ['09:30', '19:15'],
      ['08:45', '18:20'],
      ['09:00', '18:40'],
      ['08:55', '19:00'],
      ['09:20', '18:25'],
      ['08:50', '18:35'],
    ];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);

      // Skip weekends (Saturday = 6, Sunday = 7)
      if (date.weekday == 6 || date.weekday == 7) continue;

      // Skip some random days (holidays/leaves) - only affect working days
      if (day % 12 == 0 || day % 17 == 0) continue;

      final randomTime = random[day % random.length];

      records.add(
        AttendanceRecord(
          date: date,
          inTime: randomTime[0],
          outTime: randomTime[1],
          status: _getAttendanceStatus(randomTime[0]),
        ),
      );
    }

    return records;
  }

  // Determine attendance status based on in-time
  AttendanceStatus _getAttendanceStatus(String inTime) {
    final time = TimeOfDay(
      hour: int.parse(inTime.split(':')[0]),
      minute: int.parse(inTime.split(':')[1]),
    );

    // Office starts at 9:00 AM
    const officeStart = TimeOfDay(hour: 9, minute: 0);

    if (time.hour < officeStart.hour ||
        (time.hour == officeStart.hour && time.minute <= officeStart.minute)) {
      return AttendanceStatus.onTime;
    } else if (time.hour == 9 && time.minute <= 30) {
      return AttendanceStatus.late;
    } else {
      return AttendanceStatus.veryLate;
    }
  }

  // Get attendance record for specific day
  AttendanceRecord? getAttendanceForDay(int day) {
    try {
      return _attendanceRecords.firstWhere((record) => record.date.day == day);
    } catch (e) {
      return null;
    }
  }

  // Initialize provider
  void initialize() {
    _loadAttendanceData();
  }

  // Navigate to previous month
  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    notifyListeners();
    _loadAttendanceData();
  }

  // Navigate to next month
  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    notifyListeners();
    _loadAttendanceData();
  }

  // Get attendance summary (only working days)
  AttendanceSummary getAttendanceSummary() {
    int presentDays = _attendanceRecords.length;
    int onTimeDays = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.onTime)
        .length;
    int lateDays = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.late)
        .length;
    int veryLateDays = _attendanceRecords
        .where((r) => r.status == AttendanceStatus.veryLate)
        .length;

    // Calculate total working days in month
    int totalWorkingDays = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      if (isWorkingDay(day)) totalWorkingDays++;
    }

    return AttendanceSummary(
      presentDays: presentDays,
      onTimeDays: onTimeDays,
      lateDays: lateDays,
      veryLateDays: veryLateDays,
      totalWorkingDays: totalWorkingDays,
    );
  }
}

// Data Models
class AttendanceRecord {
  final DateTime date;
  final String inTime;
  final String outTime;
  final AttendanceStatus status;

  AttendanceRecord({
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.status,
  });
}

enum AttendanceStatus { onTime, late, veryLate, absent }

class AttendanceSummary {
  final int presentDays;
  final int onTimeDays;
  final int lateDays;
  final int veryLateDays;
  final int totalWorkingDays;

  AttendanceSummary({
    required this.presentDays,
    required this.onTimeDays,
    required this.lateDays,
    required this.veryLateDays,
    required this.totalWorkingDays,
  });
}