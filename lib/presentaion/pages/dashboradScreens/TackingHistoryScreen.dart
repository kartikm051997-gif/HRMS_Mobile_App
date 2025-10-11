import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'UserTrackingScreen.dart'; // Import your UserTrackingScreen file

class TrackingHistoryScreen extends StatefulWidget {
  const TrackingHistoryScreen({super.key});

  @override
  State<TrackingHistoryScreen> createState() => _TrackingHistoryScreenState();
}

class _TrackingHistoryScreenState extends State<TrackingHistoryScreen> {
  GoogleMapController? mapController;
  final TrackingManager _trackingManager = TrackingManager();
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? selectedLocation;
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  void _updateMarkers() {
    markers.clear();
    polylines.clear();

    List<LatLng> polylineCoordinates = [];

    for (int i = 0; i < _trackingManager.trackingRecords.length; i++) {
      final record = _trackingManager.trackingRecords[i];

      // Add check-in marker (Green)
      markers.add(
        Marker(
          markerId: MarkerId('${record.id}_checkin'),
          position: record.checkInLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: '${record.date} - Check In',
            snippet: record.checkInTime,
          ),
          onTap: () => _onMarkerTap(record.checkInLocation, record),
        ),
      );

      // Add check-out marker (Red)
      markers.add(
        Marker(
          markerId: MarkerId('${record.id}_checkout'),
          position: record.checkOutLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: '${record.date} - Check Out',
            snippet: record.checkOutTime,
          ),
          onTap: () => _onMarkerTap(record.checkOutLocation, record),
        ),
      );

      // Add coordinates for polyline (to show path)
      polylineCoordinates.add(record.checkInLocation);
      polylineCoordinates.add(record.checkOutLocation);
    }

    // Create polyline connecting all points
    if (polylineCoordinates.length > 1) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('tracking_path'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 3,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }

    setState(() {});
  }

  void _onMarkerTap(LatLng location, TrackingRecord record) {
    setState(() {
      selectedLocation = location;
    });

    if (mapController != null && isMapReady) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 16,
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      isMapReady = true;
    });

    // Fit bounds to show all markers
    if (_trackingManager.trackingRecords.isNotEmpty) {
      _fitMapToBounds();
    }
  }

  void _fitMapToBounds() {
    if (mapController == null || !isMapReady) return;

    if (_trackingManager.trackingRecords.isEmpty) return;

    LatLngBounds bounds;
    List<LatLng> allLocations = [];

    for (var record in _trackingManager.trackingRecords) {
      allLocations.add(record.checkInLocation);
      allLocations.add(record.checkOutLocation);
    }

    if (allLocations.length == 1) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: allLocations[0], zoom: 14),
        ),
      );
      return;
    }

    double minLat = allLocations[0].latitude;
    double maxLat = allLocations[0].latitude;
    double minLng = allLocations[0].longitude;
    double maxLng = allLocations[0].longitude;

    for (var location in allLocations) {
      if (location.latitude < minLat) minLat = location.latitude;
      if (location.latitude > maxLat) maxLat = location.latitude;
      if (location.longitude < minLng) minLng = location.longitude;
      if (location.longitude > maxLng) maxLng = location.longitude;
    }

    bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initialLocation = _trackingManager.trackingRecords.isNotEmpty
        ? _trackingManager.trackingRecords.first.checkInLocation
        : const LatLng(37.7749, -122.4194);

    return Scaffold(
      body: Column(
        children: [
          // Google Map
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: initialLocation,
                    zoom: 13,
                  ),
                  markers: markers,
                  polylines: polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                ),
                // Legend
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Check In',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Check Out',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tracking History List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'History Records',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_trackingManager.trackingRecords.length} Records',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tracking History List
          Expanded(
            child: _trackingManager.trackingRecords.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tracking history available',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check in and check out to create records',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _trackingManager.trackingRecords.length,
              itemBuilder: (context, index) {
                final record = _trackingManager.trackingRecords[index];
                final isSelected = selectedLocation?.latitude ==
                    record.checkInLocation.latitude ||
                    selectedLocation?.latitude ==
                        record.checkOutLocation.latitude;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildHistoryCard(record, isSelected),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(TrackingRecord record, bool isSelected) {
    return GestureDetector(
      onTap: () => _onMarkerTap(record.checkInLocation, record),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.teal.shade50 : Colors.white,
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
            // Date and ID Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record.date,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade300),
                  ),
                  child: Text(
                    '#${record.id}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Check In Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.login,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Check In',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        record.checkInTime,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.green.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${record.checkInLocation.latitude.toStringAsFixed(6)}, ${record.checkInLocation.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Colors.green.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Check Out Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.logout,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Check Out',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        record.checkOutTime,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.red.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${record.checkOutLocation.latitude.toStringAsFixed(6)}, ${record.checkOutLocation.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Colors.red.shade700,
                          ),
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
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}