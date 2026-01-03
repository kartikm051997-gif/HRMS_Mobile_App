import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/fonts/fonts.dart';
import '../../../provider/AdminTrackingProvider/AdminTrackingProvider.dart';
import '../../../provider/login_provider/login_provider.dart';

class MapTabScreen extends StatefulWidget {
  final TrackingRecord? session;
  final Function(GoogleMapController) onMapCreated;

  const MapTabScreen({
    super.key,
    required this.session,
    required this.onMapCreated,
  });

  @override
  State<MapTabScreen> createState() => _MapTabScreenState();
}

class _MapTabScreenState extends State<MapTabScreen> {
  bool showDetails = false;

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final user = loginProvider.loginData?.user;
    if (widget.session == null || widget.session!.trackingPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No tracking data available',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a session from History to view map',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final points = widget.session!.trackingPoints;
    final Set<Marker> markers = {};
    final Set<Polyline> polylines = {};

    // Create markers
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isCheckIn = i == 0;
      final isCheckOut = i == points.length - 1;

      markers.add(
        Marker(
          markerId: MarkerId('point_$i'),
          position: point.location,
          icon:
              isCheckIn
                  ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  )
                  : isCheckOut
                  ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  )
                  : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  ),
          infoWindow: InfoWindow(
            title:
                isCheckIn
                    ? 'Check In'
                    : isCheckOut
                    ? 'Check Out'
                    : 'Stop $i',
            snippet: '${point.time} - ${point.address}',
          ),
        ),
      );
    }

    // Create polyline
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: points.map((p) => p.location).toList(),
        color: const Color(0xFF8E0E6B),
        width: 5,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    );

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: points.first.location,
            zoom: 14,
          ),
          markers: markers,
          polylines: polylines,
          onMapCreated: (controller) {
            widget.onMapCreated(controller);
            _fitMapBounds(controller, points);
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
        ),

        // Info Card
        // Toggle Button (Hide / Show)
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () {
              setState(() {
                showDetails = !showDetails;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    showDetails ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF8E0E6B),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    showDetails ? "Hide Details" : "Show Details",
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      color: Color(0xFF8E0E6B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Details Card
        if (showDetails)
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullname ?? "Welcome!",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: AppFonts.poppins,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    user?.username ?? "Welcome!",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MapInfoItem(
                          icon: Icons.location_on,
                          label: "Locations",
                          value: "${widget.session!.trackingPoints.length}",
                        ),
                        Container(width: 1, height: 35, color: Colors.white30),
                        _MapInfoItem(
                          icon: Icons.straighten,
                          label: "Distance",
                          value:
                              "${(widget.session!.totalDistance / 1000).toStringAsFixed(1)} km",
                        ),
                        Container(width: 1, height: 35, color: Colors.white30),
                        _MapInfoItem(
                          icon: Icons.access_time,
                          label: "Duration",
                          value:
                              "${widget.session!.totalDuration.inMinutes} min",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _fitMapBounds(
    GoogleMapController controller,
    List<TrackingPoint> points,
  ) {
    if (points.isEmpty) return;

    double minLat = points.first.location.latitude;
    double maxLat = points.first.location.latitude;
    double minLng = points.first.location.longitude;
    double maxLng = points.first.location.longitude;

    for (var point in points) {
      if (point.location.latitude < minLat) minLat = point.location.latitude;
      if (point.location.latitude > maxLat) maxLat = point.location.latitude;
      if (point.location.longitude < minLng) minLng = point.location.longitude;
      if (point.location.longitude > maxLng) maxLng = point.location.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
}

class _MapInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MapInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: AppFonts.poppins,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ],
    );
  }
}
