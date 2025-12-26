import 'GetLocationHistoryModel.dart';

class TrackingSession {
  final DateTime date;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String? checkInAddress;
  final String? checkOutAddress;
  final List<Locations> points;

  TrackingSession({
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    this.checkInAddress,
    this.checkOutAddress,
    required this.points,
  });
}
