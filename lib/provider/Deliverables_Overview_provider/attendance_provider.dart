// File: providers/attendance_provider.dart
import 'package:flutter/material.dart';

import '../../model/deliverables_model/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  DateTime _selectedMonth = DateTime.now();
  DateTime? _selectedDate;
  bool _isLoading = false;
  List<AttendanceRecord> _attendanceRecords = [];
  Set<DateTime> _eventDates = {};

  // Getters
  DateTime get selectedMonth => _selectedMonth;
  DateTime? get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  Set<DateTime> get eventDates => _eventDates;

  String get monthYearString {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  int get daysInMonth {
    return DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
  }

  int get firstDayOfMonth {
    return DateTime(_selectedMonth.year, _selectedMonth.month, 1).weekday % 7;
  }

  bool isWorkingDay(int day) {
    final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
    return date.weekday != 6 && date.weekday != 7;
  }

  bool isToday(int day) {
    final today = DateTime.now();
    final dayDate = DateTime(_selectedMonth.year, _selectedMonth.month, day);
    return today.year == dayDate.year &&
        today.month == dayDate.month &&
        today.day == dayDate.day;
  }

  bool isSelected(int day) {
    if (_selectedDate == null) return false;
    final dayDate = DateTime(_selectedMonth.year, _selectedMonth.month, day);
    return _selectedDate!.year == dayDate.year &&
        _selectedDate!.month == dayDate.month &&
        _selectedDate!.day == dayDate.day;
  }

  void selectDate(int day) {
    _selectedDate = DateTime(_selectedMonth.year, _selectedMonth.month, day);
    notifyListeners();
  }

  void clearSelection() {
    _selectedDate = null;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month, 1);
    _selectedDate = null; // Reset selected date when changing month
    notifyListeners();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    _attendanceRecords = _generateDummyAttendance();
    _eventDates = _generateEventDates();

    _isLoading = false;
    notifyListeners();
  }

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

      // Generate attendance for some working days and some weekends too
      if (day % 8 == 0 || day % 13 == 0) continue; // Skip some days as holidays

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

  Set<DateTime> _generateEventDates() {
    final events = <DateTime>{};
    // Add some random events/holidays
    for (int day = 1; day <= daysInMonth; day++) {
      if (day % 7 == 0 || day % 11 == 0 || day == 15 || day == 26) {
        events.add(DateTime(_selectedMonth.year, _selectedMonth.month, day));
      }
    }
    return events;
  }

  AttendanceStatus _getAttendanceStatus(String inTime) {
    final time = TimeOfDay(
      hour: int.parse(inTime.split(':')[0]),
      minute: int.parse(inTime.split(':')[1]),
    );

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

  AttendanceRecord? getAttendanceForDay(int day) {
    try {
      return _attendanceRecords.firstWhere((record) => record.date.day == day);
    } catch (e) {
      return null;
    }
  }

  bool hasEvent(int day) {
    final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
    return _eventDates.contains(date);
  }

  void initialize() {
    _loadAttendanceData();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    _selectedDate = null;
    notifyListeners();
    _loadAttendanceData();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    _selectedDate = null;
    notifyListeners();
    _loadAttendanceData();
  }

  void goToToday() {
    final today = DateTime.now();
    _selectedMonth = DateTime(today.year, today.month, 1);
    _selectedDate = today;
    notifyListeners();
    _loadAttendanceData();
  }

  // Get attendance summary
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

