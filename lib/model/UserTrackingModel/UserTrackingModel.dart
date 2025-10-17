import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserTrackingRecordModel {
  final String id;
  final String date;
  final String checkInTime;
  final String checkOutTime;
  final LatLng checkInLocation;
  final LatLng checkOutLocation;
  final String checkInAddress;
  final String checkOutAddress;
  final String status;
  final List<LatLng>? routePoints;
  final List<AddressCheckpoint>? addressCheckpoints; // ✅ ADD THIS LINE

  UserTrackingRecordModel({
    required this.id,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInLocation,
    required this.checkOutLocation,
    required this.checkInAddress,
    required this.checkOutAddress,
    required this.status,
    this.routePoints,
    this.addressCheckpoints, // ✅ ADD THIS LINE
  });

  // toJson method
  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'checkInTime': checkInTime,
    'checkOutTime': checkOutTime,
    'checkInLocation': {
      'lat': checkInLocation.latitude,
      'lng': checkInLocation.longitude,
    },
    'checkOutLocation': {
      'lat': checkOutLocation.latitude,
      'lng': checkOutLocation.longitude,
    },
    'checkInAddress': checkInAddress,
    'checkOutAddress': checkOutAddress,
    'status': status,
    'routePoints':
        routePoints
            ?.map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
    'addressCheckpoints':
        addressCheckpoints?.map((c) => c.toJson()).toList(), // ✅ ADD THIS LINE
  };

  // fromJson method
  factory UserTrackingRecordModel.fromJson(Map<String, dynamic> json) {
    // Parse route points
    List<LatLng>? routePoints;
    if (json['routePoints'] != null) {
      routePoints =
          (json['routePoints'] as List)
              .map((p) => LatLng(p['lat'], p['lng']))
              .toList();
    }

    // Parse address checkpoints
    List<AddressCheckpoint>? addressCheckpoints;
    if (json['addressCheckpoints'] != null) {
      addressCheckpoints =
          (json['addressCheckpoints'] as List)
              .map((c) => AddressCheckpoint.fromJson(c))
              .toList();
    }

    return UserTrackingRecordModel(
      id: json['id'],
      date: json['date'],
      checkInTime: json['checkInTime'],
      checkOutTime: json['checkOutTime'],
      checkInLocation: LatLng(
        json['checkInLocation']['lat'],
        json['checkInLocation']['lng'],
      ),
      checkOutLocation: LatLng(
        json['checkOutLocation']['lat'],
        json['checkOutLocation']['lng'],
      ),
      checkInAddress: json['checkInAddress'],
      checkOutAddress: json['checkOutAddress'],
      status: json['status'],
      routePoints: routePoints,
      addressCheckpoints: addressCheckpoints, // ✅ ADD THIS LINE
    );
  }
}

// ✅ ADD AddressCheckpoint class to the same file
class AddressCheckpoint {
  final LatLng location;
  final String address;
  final DateTime timestamp;
  final double distanceFromPrevious;
  final int pointIndex;

  AddressCheckpoint({
    required this.location,
    required this.address,
    required this.timestamp,
    this.distanceFromPrevious = 0.0,
    this.pointIndex = 0,
  });

  Map<String, dynamic> toJson() => {
    'lat': location.latitude,
    'lng': location.longitude,
    'address': address,
    'timestamp': timestamp.toIso8601String(),
    'distance': distanceFromPrevious,
    'pointIndex': pointIndex,
  };

  factory AddressCheckpoint.fromJson(Map<String, dynamic> json) =>
      AddressCheckpoint(
        location: LatLng(json['lat'], json['lng']),
        address: json['address'],
        timestamp: DateTime.parse(json['timestamp']),
        distanceFromPrevious: (json['distance'] ?? 0.0).toDouble(),
        pointIndex: json['pointIndex'] ?? 0,
      );
}
