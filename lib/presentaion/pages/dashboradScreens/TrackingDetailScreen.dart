import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/fonts/fonts.dart';
import '../../../model/UserTrackingModel/UserTrackingModel.dart';

// Address Checkpoint Model

class TrackingDetailScreen extends StatefulWidget {
  final UserTrackingRecordModel record;

  const TrackingDetailScreen({super.key, required this.record});

  @override
  State<TrackingDetailScreen> createState() => _TrackingDetailScreenState();
}

class _TrackingDetailScreenState extends State<TrackingDetailScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  int _selectedCheckpointIndex = -1;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    _markers.clear();
    _polyLines.clear();

    // Add Check-In marker (Green)
    _markers.add(
      Marker(
        markerId: const MarkerId('check_in'),
        position: widget.record.checkInLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Check In',
          snippet: widget.record.checkInTime,
        ),
      ),
    );

    // Add Check-Out marker (Red)
    _markers.add(
      Marker(
        markerId: const MarkerId('check_out'),
        position: widget.record.checkOutLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Check Out',
          snippet: widget.record.checkOutTime,
        ),
      ),
    );

    // Add address checkpoint markers (Orange)
    if (widget.record.addressCheckpoints != null &&
        widget.record.addressCheckpoints!.isNotEmpty) {
      for (int i = 0; i < widget.record.addressCheckpoints!.length; i++) {
        final checkpoint = widget.record.addressCheckpoints![i];
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
            onTap: () {
              setState(() => _selectedCheckpointIndex = i);
            },
          ),
        );
      }
    }

    // Draw route line
    if (widget.record.routePoints != null &&
        widget.record.routePoints!.length >= 2) {
      _polyLines.add(
        Polyline(
          polylineId: const PolylineId('tracking_route'),
          points: widget.record.routePoints!,
          color: const Color(0xFF4285F4),
          width: 6,
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
            widget.record.checkInLocation,
            widget.record.checkOutLocation,
          ],
          color: const Color(0xFF4285F4),
          width: 6,
          geodesic: true,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _fitMapToRoute() {
    if (_mapController == null) return;

    double minLat = widget.record.checkInLocation.latitude;
    double maxLat = widget.record.checkInLocation.latitude;
    double minLng = widget.record.checkInLocation.longitude;
    double maxLng = widget.record.checkInLocation.longitude;

    if (widget.record.routePoints != null &&
        widget.record.routePoints!.isNotEmpty) {
      for (var point in widget.record.routePoints!) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }
    }

    if (widget.record.checkOutLocation.latitude < minLat) {
      minLat = widget.record.checkOutLocation.latitude;
    }
    if (widget.record.checkOutLocation.latitude > maxLat) {
      maxLat = widget.record.checkOutLocation.latitude;
    }
    if (widget.record.checkOutLocation.longitude < minLng) {
      minLng = widget.record.checkOutLocation.longitude;
    }
    if (widget.record.checkOutLocation.longitude > maxLng) {
      maxLng = widget.record.checkOutLocation.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  Duration _getDurationBetween(DateTime start, DateTime end) {
    return end.difference(start);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final addressCheckpoints = widget.record.addressCheckpoints ?? [];
    final routePoints = widget.record.routePoints ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tracking Details',
          style: TextStyle(
            fontFamily: AppFonts.poppins,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Session Info Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Session #${widget.record.id.substring(widget.record.id.length - 6)}',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.record.date,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (routePoints.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.route,
                              color: Colors.blue.shade700,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${routePoints.length} tracked points',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFonts.poppins,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (addressCheckpoints.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_city,
                              color: Colors.orange.shade700,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${addressCheckpoints.length} places',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFonts.poppins,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Address Journey Timeline
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Check-In
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade700,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.login,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Check In',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.record.checkInTime,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.record.checkInAddress,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade800,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Timeline connector and stops
                  if (addressCheckpoints.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 2,
                          height: 24,
                          child: Container(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    ...addressCheckpoints.asMap().entries.map((entry) {
                      int index = entry.key;
                      AddressCheckpoint checkpoint = entry.value;
                      bool isSelected = _selectedCheckpointIndex == index;

                      Duration? timeDiff;
                      if (index > 0) {
                        timeDiff = _getDurationBetween(
                          addressCheckpoints[index - 1].timestamp,
                          checkpoint.timestamp,
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(
                                  () => _selectedCheckpointIndex = index,
                                );
                                if (_mapController != null) {
                                  _mapController!.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                      checkpoint.location,
                                      17,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.orange.shade100
                                          : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.orange.shade700
                                            : Colors.orange.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade700,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: AppFonts.poppins,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            checkpoint.address,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800,
                                              fontFamily: AppFonts.poppins,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatTime(
                                                  checkpoint.timestamp,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade500,
                                                  fontFamily: AppFonts.poppins,
                                                ),
                                              ),
                                              if (checkpoint
                                                      .distanceFromPrevious >
                                                  0) ...[
                                                const SizedBox(width: 12),
                                                Icon(
                                                  Icons.straighten,
                                                  size: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDistance(
                                                    checkpoint
                                                        .distanceFromPrevious,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade500,
                                                    fontFamily:
                                                        AppFonts.poppins,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (timeDiff != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Waited: ${_formatDuration(timeDiff)}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.blue.shade600,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: AppFonts.poppins,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < addressCheckpoints.length - 1)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 2,
                                  height: 16,
                                  child: Container(color: Colors.grey.shade300),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 2,
                          height: 24,
                          child: Container(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],

                  // Check-Out
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Check Out',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.record.checkOutTime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.record.checkOutAddress,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade800,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Map
          SizedBox(
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.record.checkInLocation,
                    zoom: 15,
                  ),
                  markers: _markers,
                  polylines: _polyLines,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    Future.delayed(const Duration(milliseconds: 500), () {
                      _fitMapToRoute();
                    });
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
