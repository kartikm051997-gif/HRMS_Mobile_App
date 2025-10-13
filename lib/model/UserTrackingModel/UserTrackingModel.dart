import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserTrackingRecordModel {
  final String id;
  final String date;
  final String checkInTime;
  final String checkOutTime;
  final LatLng checkInLocation;
  final LatLng checkOutLocation;
  final String checkInAddress; // NEW
  final String checkOutAddress; // NEW
  final String status;

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
  });

  factory UserTrackingRecordModel.fromJson(Map<String, dynamic> json) {
    return UserTrackingRecordModel(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      checkInTime: json['checkInTime'] ?? '',
      checkOutTime: json['checkOutTime'] ?? '',
      checkInLocation: LatLng(
        json['checkInLatitude'] ?? 0.0,
        json['checkInLongitude'] ?? 0.0,
      ),
      checkOutLocation: LatLng(
        json['checkOutLatitude'] ?? 0.0,
        json['checkOutLongitude'] ?? 0.0,
      ),
      checkInAddress: json['checkInAddress'] ?? 'Address not available',
      checkOutAddress: json['checkOutAddress'] ?? 'Address not available',
      status: json['status'] ?? 'checked_out',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'checkInLatitude': checkInLocation.latitude,
      'checkInLongitude': checkInLocation.longitude,
      'checkOutLatitude': checkOutLocation.latitude,
      'checkOutLongitude': checkOutLocation.longitude,
      'checkInAddress': checkInAddress,
      'checkOutAddress': checkOutAddress,
      'status': status,
    };
  }
}
