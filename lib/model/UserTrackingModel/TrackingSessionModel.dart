class TrackingSession {
  final DateTime date;
  final DateTime checkInTime;
  DateTime? checkOutTime;
  final String? checkInAddress;
  String? checkOutAddress;
  final String? checkInLat;
  final String? checkInLng;
  String? checkOutLat;
  String? checkOutLng;

  TrackingSession({
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    this.checkInAddress,
    this.checkOutAddress,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });
}
