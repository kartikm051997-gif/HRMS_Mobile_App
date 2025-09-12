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
