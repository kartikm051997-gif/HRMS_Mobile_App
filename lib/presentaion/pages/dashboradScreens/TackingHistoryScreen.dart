import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../../core/fonts/fonts.dart';
import '../../../model/UserTrackingModel/UserTrackingModel.dart';
import 'UserTrackingScreen.dart';

// ==================== TRACKING HISTORY SCREEN ====================
class TrackingHistoryScreen extends StatefulWidget {
  const TrackingHistoryScreen({super.key});

  @override
  State<TrackingHistoryScreen> createState() => _TrackingHistoryScreenState();
}

class _TrackingHistoryScreenState extends State<TrackingHistoryScreen> {
  final TrackingManager _trackingManager = TrackingManager();

  @override
  void initState() {
    super.initState();
    _trackingManager.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      _trackingManager.trackingRecords.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No tracking history yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _trackingManager.trackingRecords.length,
        separatorBuilder:
            (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final record = _trackingManager.trackingRecords[index];
          return _buildHistoryCard(record);
        },
      ),
    );
  }

  Widget _buildHistoryCard(UserTrackingRecordModel record) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrackingDetailScreen(record: record),
          ),
        );
      },
      child: Container(
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
                    'Session #${record.id.substring(record.id.length - 6)}',
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  record.date,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.login,
                    color: Colors.green.shade700,
                    size: 20,
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
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.checkInTime,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              record.checkInAddress,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                fontFamily: AppFonts.poppins,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Container(width: 2, height: 30, color: Colors.grey.shade300),
                ],
              ),
            ),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.logout,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Check Out',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.checkOutTime,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              record.checkOutAddress,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _trackingManager.removeListener(_onDataChanged);
    super.dispose();
  }
}

// ==================== DIRECTIONS SERVICE (for Detail Screen) ====================
class DirectionsService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  static const String _apiKey = 'AIzaSyAj0Wx6E4wZcM1-Og7ympdaB9kNv-f9JgE';

  static Future<List<LatLng>?> getDirections({
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving',
  }) async {
    try {
      final String url =
          '$_baseUrl?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&mode=$mode'
          '&key=$_apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final String encodedPolyline =
          data['routes'][0]['overview_polyline']['points'];

          return _decodePolyline(encodedPolyline);
        } else {
          if (kDebugMode) {
            print('Directions API error: ${data['status']}');
          }
          return null;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching directions: $e');
      }
      return null;
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }
}

// ==================== TRACKING DETAIL SCREEN ====================
class TrackingDetailScreen extends StatefulWidget {
  final UserTrackingRecordModel record;

  const TrackingDetailScreen({super.key, required this.record});

  @override
  State<TrackingDetailScreen> createState() => _TrackingDetailScreenState();
}

class _TrackingDetailScreenState extends State<TrackingDetailScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _setupMapData();
  }

  Future<void> _setupMapData() async {
    // Add markers
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

    setState(() => isLoadingRoute = true);

    // Fetch route from Directions API
    List<LatLng>? routePoints = await DirectionsService.getDirections(
      origin: widget.record.checkInLocation,
      destination: widget.record.checkOutLocation,
      mode: 'driving',
    );

    setState(() => isLoadingRoute = false);

    if (routePoints != null && routePoints.isNotEmpty) {
      // Add polyline following roads
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints,
          color: Colors.teal,
          width: 4,
        ),
      );
    } else {
      // Fallback to straight line
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [widget.record.checkInLocation, widget.record.checkOutLocation],
          color: Colors.teal.withOpacity(0.5),
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Session #${widget.record.id.substring(widget.record.id.length - 6)}',
          style: const TextStyle(fontFamily: AppFonts.poppins, fontSize: 16),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.record.checkInLocation,
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) {
                    _mapController = controller;

                    // Fit bounds to show both markers
                    LatLngBounds bounds = LatLngBounds(
                      southwest: LatLng(
                        widget.record.checkInLocation.latitude <
                            widget.record.checkOutLocation.latitude
                            ? widget.record.checkInLocation.latitude
                            : widget.record.checkOutLocation.latitude,
                        widget.record.checkInLocation.longitude <
                            widget.record.checkOutLocation.longitude
                            ? widget.record.checkInLocation.longitude
                            : widget.record.checkOutLocation.longitude,
                      ),
                      northeast: LatLng(
                        widget.record.checkInLocation.latitude >
                            widget.record.checkOutLocation.latitude
                            ? widget.record.checkInLocation.latitude
                            : widget.record.checkOutLocation.latitude,
                        widget.record.checkInLocation.longitude >
                            widget.record.checkOutLocation.longitude
                            ? widget.record.checkInLocation.longitude
                            : widget.record.checkOutLocation.longitude,
                      ),
                    );

                    Future.delayed(const Duration(milliseconds: 500), () {
                      controller.animateCamera(
                        CameraUpdate.newLatLngBounds(bounds, 100),
                      );
                    });
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),

                // Loading indicator
                if (isLoadingRoute)
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Loading route...',
                              style: TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tracking Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 20),

                _buildTimelineItem(
                  icon: Icons.login,
                  iconColor: Colors.green,
                  title: 'Check In',
                  time: widget.record.checkInTime,
                  location: widget.record.checkInAddress,
                  isLast: false,
                ),

                const SizedBox(height: 16),

                _buildTimelineItem(
                  icon: Icons.logout,
                  iconColor: Colors.red,
                  title: 'Check Out',
                  time: widget.record.checkOutTime,
                  location: widget.record.checkOutAddress,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required String location,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: AppFonts.poppins,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontFamily: AppFonts.poppins,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}