import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../model/UserTrackingModel/UserTrackingModel.dart';

class TrackingDetailProvider extends ChangeNotifier {
  final UserTrackingRecordModel record;

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  bool _showDetails = false;

  TrackingDetailProvider(this.record) {
    _initializeMap();
  }

  // Getters
  GoogleMapController? get mapController => _mapController;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polyLines => _polyLines;
  bool get showDetails => _showDetails;

  void _initializeMap() {
    _markers.clear();
    _polyLines.clear();

    // Add Check-In marker (Green)
    _markers.add(
      Marker(
        markerId: const MarkerId('check_in'),
        position: record.checkInLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Check In',
          snippet: record.checkInTime,
        ),
      ),
    );

    // Add Check-Out marker (Red)
    _markers.add(
      Marker(
        markerId: const MarkerId('check_out'),
        position: record.checkOutLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Check Out',
          snippet: record.checkOutTime,
        ),
      ),
    );

    // Add checkpoint markers (Orange)
    if (record.addressCheckpoints != null &&
        record.addressCheckpoints!.isNotEmpty) {
      for (int i = 0; i < record.addressCheckpoints!.length; i++) {
        final checkpoint = record.addressCheckpoints![i];
        _markers.add(
          Marker(
            markerId: MarkerId('checkpoint_$i'),
            position: checkpoint.location,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(
              title: 'Stop ${i + 1}',
              snippet: checkpoint.address,
            ),
          ),
        );
      }
    }

    // Draw route line
    if (record.routePoints != null && record.routePoints!.length >= 2) {
      _polyLines.add(
        Polyline(
          polylineId: const PolylineId('tracking_route'),
          points: record.routePoints!,
          color: const Color(0xFF8E0E6B),
          width: 5,
          geodesic: true,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    } else {
      _polyLines.add(
        Polyline(
          polylineId: const PolylineId('tracking_route'),
          points: [
            record.checkInLocation,
            record.checkOutLocation,
          ],
          color: const Color(0xFF8E0E6B),
          width: 5,
          geodesic: true,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }

    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    Future.delayed(const Duration(milliseconds: 500), () {
      fitMapToRoute();
    });
  }

  void fitMapToRoute() {
    if (_mapController == null) return;

    double minLat = record.checkInLocation.latitude;
    double maxLat = record.checkInLocation.latitude;
    double minLng = record.checkInLocation.longitude;
    double maxLng = record.checkInLocation.longitude;

    if (record.routePoints != null && record.routePoints!.isNotEmpty) {
      for (var point in record.routePoints!) {
        minLat = point.latitude < minLat ? point.latitude : minLat;
        maxLat = point.latitude > maxLat ? point.latitude : maxLat;
        minLng = point.longitude < minLng ? point.longitude : minLng;
        maxLng = point.longitude > maxLng ? point.longitude : maxLng;
      }
    }

    minLat = record.checkOutLocation.latitude < minLat
        ? record.checkOutLocation.latitude
        : minLat;
    maxLat = record.checkOutLocation.latitude > maxLat
        ? record.checkOutLocation.latitude
        : maxLat;
    minLng = record.checkOutLocation.longitude < minLng
        ? record.checkOutLocation.longitude
        : minLng;
    maxLng = record.checkOutLocation.longitude > maxLng
        ? record.checkOutLocation.longitude
        : maxLng;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  void toggleDetails() {
    _showDetails = !_showDetails;
    notifyListeners();
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes min';
  }

  int getTotalLocations() {
    int total = 2;
    if (record.addressCheckpoints != null) {
      total += record.addressCheckpoints!.length;
    }
    return total;
  }

  double getTotalDistance() {
    double total = 0;
    if (record.addressCheckpoints != null) {
      for (var checkpoint in record.addressCheckpoints!) {
        total += checkpoint.distanceFromPrevious;
      }
    }
    return total;
  }

  Duration getTotalDuration() {
    try {
      final checkInTime = DateFormat('hh:mm a').parse(record.checkInTime);
      final checkOutTime = DateFormat('hh:mm a').parse(record.checkOutTime);
      return checkOutTime.difference(checkInTime);
    } catch (e) {
      return const Duration(hours: 0);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}