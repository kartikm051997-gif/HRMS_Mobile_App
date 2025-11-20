import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/UserTrackingProvider/TrackingDetailProvider.dart';

class TrackingMapTab extends StatelessWidget {
  const TrackingMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrackingDetailProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: provider.record.checkInLocation,
                zoom: 14,
              ),
              markers: provider.markers,
              polylines: provider.polyLines,
              onMapCreated: (controller) {
                provider.setMapController(controller);
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

            // Toggle Button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  provider.toggleDetails();
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
                        provider.showDetails ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF8E0E6B),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        provider.showDetails ? "Hide Details" : "Show Details",
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
            if (provider.showDetails)
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
                            child: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.record.date,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontFamily: AppFonts.poppins,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Session #${provider.record.id.substring(provider.record.id.length - 6)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                    fontFamily: AppFonts.poppins,
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
                              value: "${provider.getTotalLocations()}",
                            ),
                            Container(width: 1, height: 35, color: Colors.white30),
                            _MapInfoItem(
                              icon: Icons.straighten,
                              label: "Distance",
                              value:
                              "${(provider.getTotalDistance() / 1000).toStringAsFixed(1)} km",
                            ),
                            Container(width: 1, height: 35, color: Colors.white30),
                            _MapInfoItem(
                              icon: Icons.access_time,
                              label: "Duration",
                              value: "${provider.getTotalDuration().inMinutes} min",
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
      },
    );
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