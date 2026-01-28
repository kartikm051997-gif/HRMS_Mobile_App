import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Timer? _timer;
  int _selectedPersonIndex = 0;

  // 4 people with their live locations
  final List<Map<String, dynamic>> _people = [
    {
      'name': 'Mahnesh Kumar',
      'status': 'On Trip',
      'color': Colors.blue,
      'position': const LatLng(13.0827, 80.2707), // Chennai
    },
    {
      'name': 'Ramesh Singh',
      'status': 'Travelling',
      'color': Colors.green,
      'position': const LatLng(13.0900, 80.2800),
    },
    {
      'name': 'Suresh Patel',
      'status': 'In Transit',
      'color': Colors.orange,
      'position': const LatLng(13.0750, 80.2650),
    },
    {
      'name': 'Ganesh Rao',
      'status': 'On Route',
      'color': Colors.purple,
      'position': const LatLng(13.0950, 80.2900),
    },
  ];

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _startLiveTracking();
  }

  void _createMarkers() {
    _markers =
        _people.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> person = entry.value;

          return Marker(
            markerId: MarkerId('person_$index'),
            position: person['position'],
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerHue(person['color']),
            ),
            infoWindow: InfoWindow(
              title: person['name'],
              snippet: person['status'],
            ),
            onTap: () {
              setState(() {
                _selectedPersonIndex = index;
              });
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(person['position'], 15),
              );
            },
          );
        }).toSet();
  }

  double _getMarkerHue(Color color) {
    if (color == Colors.blue) return BitmapDescriptor.hueBlue;
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.purple) return BitmapDescriptor.hueViolet;
    return BitmapDescriptor.hueRed;
  }

  void _startLiveTracking() {
    // Simulate live movement every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        for (int i = 0; i < _people.length; i++) {
          LatLng currentPos = _people[i]['position'];

          // Simulate movement (small random changes)
          double newLat = currentPos.latitude + (i % 2 == 0 ? 0.001 : -0.001);
          double newLng = currentPos.longitude + (i % 2 == 0 ? 0.001 : -0.001);

          _people[i]['position'] = LatLng(newLat, newLng);
        }
        _createMarkers();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Live Tracking"),
      drawer: const TabletMobileDrawer(),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _people[0]['position'],
              zoom: 13,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),

          // Top cards showing all 4 people
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _people.length,
                itemBuilder: (context, index) {
                  return _buildPersonCard(index);
                },
              ),
            ),
          ),

          // Selected person details at bottom
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: _buildSelectedPersonCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(int index) {
    final person = _people[index];
    final isSelected = _selectedPersonIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPersonIndex = index;
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(person['position'], 15),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? person['color'] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected ? person['color'] : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.poppins,

                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              person['name'].split(' ')[0],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.poppins,

              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              person['status'],
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey[600],
                fontSize: 11,
                fontFamily: AppFonts.poppins,

              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPersonCard() {
    final person = _people[_selectedPersonIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: person['color'],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,

                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      person['status'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontFamily: AppFonts.poppins,

                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.poppins,

              ),
            ),
          ),
        ],
      ),
    );
  }
}
