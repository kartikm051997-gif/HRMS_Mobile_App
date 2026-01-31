import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math';

import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Timer? _liveUpdateTimer;
  Timer? _statsUpdateTimer;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  int _selectedPersonIndex = 0;
  bool _showHeatmap = false;
  bool _trackingEnabled = true;
  String _mapStyle = '';

  // Enhanced people data with realistic tracking info
  final List<Map<String, dynamic>> _people = [
    {
      'name': 'Ganesh Kumar',
      'designation': 'Senior Field Officer',
      'status': 'On Trip',
      'color': Colors.blue,
      'position': const LatLng(13.0827, 80.2707),
      'startPosition': const LatLng(13.0827, 80.2707),
      'destination': const LatLng(13.0950, 80.2900),
      'speed': 45.5, // km/h
      'distance': 12.8, // km traveled
      'battery': 85,
      'lastUpdate': 'Just now',
      'checkInTime': '09:15 AM',
      'tasksCompleted': 3,
      'tasksRemaining': 2,
      'route': <LatLng>[], // Will store route path
    },
    {
      'name': 'Ramesh Singh',
      'designation': 'Sales Executive',
      'status': 'Travelling',
      'color': Colors.green,
      'position': const LatLng(13.0900, 80.2800),
      'startPosition': const LatLng(13.0900, 80.2800),
      'destination': const LatLng(13.0750, 80.2650),
      'speed': 32.0,
      'distance': 8.5,
      'battery': 72,
      'lastUpdate': '2 mins ago',
      'checkInTime': '08:45 AM',
      'tasksCompleted': 5,
      'tasksRemaining': 1,
      'route': <LatLng>[],
    },
    {
      'name': 'Suresh Patel',
      'designation': 'Field Officer',
      'status': 'In Transit',
      'color': Colors.orange,
      'position': const LatLng(13.0750, 80.2650),
      'startPosition': const LatLng(13.0750, 80.2650),
      'destination': const LatLng(13.0827, 80.2707),
      'speed': 28.5,
      'distance': 15.2,
      'battery': 58,
      'lastUpdate': '5 mins ago',
      'checkInTime': '09:00 AM',
      'tasksCompleted': 2,
      'tasksRemaining': 4,
      'route': <LatLng>[],
    },
    {
      'name': 'Priya Sharma',
      'designation': 'Team Lead',
      'status': 'On Route',
      'color': Colors.purple,
      'position': const LatLng(13.0950, 80.2900),
      'startPosition': const LatLng(13.0950, 80.2900),
      'destination': const LatLng(13.0900, 80.2800),
      'speed': 55.0,
      'distance': 22.3,
      'battery': 91,
      'lastUpdate': 'Just now',
      'checkInTime': '08:30 AM',
      'tasksCompleted': 7,
      'tasksRemaining': 1,
      'route': <LatLng>[],
    },
    {
      'name': 'Vikram Reddy',
      'designation': 'Sales Manager',
      'status': 'Active',
      'color': Colors.teal,
      'position': const LatLng(13.0600, 80.2500),
      'startPosition': const LatLng(13.0600, 80.2500),
      'destination': const LatLng(13.0750, 80.2650),
      'speed': 38.5,
      'distance': 18.7,
      'battery': 67,
      'lastUpdate': '1 min ago',
      'checkInTime': '08:50 AM',
      'tasksCompleted': 4,
      'tasksRemaining': 3,
      'route': <LatLng>[],
    },
  ];

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _initializeRoutes();
    _createMarkers();
    _startLiveTracking();
    _startStatsUpdates();
  }

  void _initializeRoutes() {
    for (var person in _people) {
      person['route'] = [person['position']];
    }
  }

  void _startLiveTracking() {
    _liveUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_trackingEnabled) return;

      setState(() {
        for (int i = 0; i < _people.length; i++) {
          _updatePersonLocation(i);
        }
        _createMarkers();
        _createPolylines();
      });
    });
  }

  void _startStatsUpdates() {
    _statsUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        for (var person in _people) {
          // Update stats realistically
          person['distance'] =
              (person['distance'] as double) + _random.nextDouble() * 0.5;
          person['speed'] = 20.0 + _random.nextDouble() * 40.0;
          person['battery'] = max(
            20,
            (person['battery'] as int) - _random.nextInt(2),
          );
        }
      });
    });
  }

  void _updatePersonLocation(int index) {
    var person = _people[index];
    LatLng currentPos = person['position'];
    LatLng destination = person['destination'];

    // Calculate direction towards destination
    double latDiff = destination.latitude - currentPos.latitude;
    double lngDiff = destination.longitude - currentPos.longitude;

    // Move slightly towards destination with some randomness
    double moveFactor = 0.0008 + _random.nextDouble() * 0.0004;
    double newLat = currentPos.latitude + (latDiff * moveFactor);
    double newLng = currentPos.longitude + (lngDiff * moveFactor);

    // Add slight random deviation for realistic movement
    newLat += (_random.nextDouble() - 0.5) * 0.0002;
    newLng += (_random.nextDouble() - 0.5) * 0.0002;

    LatLng newPosition = LatLng(newLat, newLng);
    person['position'] = newPosition;

    // Add to route history
    List<LatLng> route = person['route'];
    route.add(newPosition);
    if (route.length > 20) {
      route.removeAt(0); // Keep only last 20 points
    }

    // Update last update time
    person['lastUpdate'] = 'Just now';

    // If reached destination, set new random destination
    double distanceToDestination = _calculateDistance(currentPos, destination);
    if (distanceToDestination < 0.01) {
      person['destination'] = _getRandomDestination();
    }
  }

  LatLng _getRandomDestination() {
    double baseLat = 13.0827;
    double baseLng = 80.2707;
    double range = 0.03;

    return LatLng(
      baseLat + (_random.nextDouble() - 0.5) * range,
      baseLng + (_random.nextDouble() - 0.5) * range,
    );
  }

  double _calculateDistance(LatLng pos1, LatLng pos2) {
    double latDiff = pos1.latitude - pos2.latitude;
    double lngDiff = pos1.longitude - pos2.longitude;
    return sqrt(latDiff * latDiff + lngDiff * lngDiff);
  }

  void _createMarkers() {
    _markers =
        _people.asMap().entries.map((entry) {
          int index = entry.key;
          var person = entry.value;

          return Marker(
            markerId: MarkerId('person_$index'),
            position: person['position'],
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerHue(person['color']),
            ),
            infoWindow: InfoWindow(
              title: person['name'],
              snippet:
                  '${person['status']} - ${person['speed'].toStringAsFixed(1)} km/h',
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

  void _createPolylines() {
    _polylines =
        _people.asMap().entries.map((entry) {
          int index = entry.key;
          var person = entry.value;
          List<LatLng> route = person['route'];

          return Polyline(
            polylineId: PolylineId('route_$index'),
            points: route,
            color: (person['color'] as Color).withOpacity(0.6),
            width: 4,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          );
        }).toSet();
  }

  double _getMarkerHue(Color color) {
    if (color == Colors.blue) return BitmapDescriptor.hueBlue;
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.purple) return BitmapDescriptor.hueViolet;
    if (color == Colors.teal) return BitmapDescriptor.hueCyan;
    return BitmapDescriptor.hueRed;
  }

  @override
  void dispose() {
    _liveUpdateTimer?.cancel();
    _statsUpdateTimer?.cancel();
    _pulseController.dispose();
    _slideController.dispose();
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
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _people[0]['position'],
              zoom: 13,
            ),
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),

          // Header with stats
          _buildLiveHeader(),

          // Horizontal scrolling person cards
          _buildPersonCardsScroller(),

          // Selected person detailed card
          _buildSelectedPersonDetailCard(),

          // Floating controls
          _buildFloatingControls(),
        ],
      ),
    );
  }

  Widget _buildLiveHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Row(
                children: [
                  ScaleTransition(
                    scale: Tween(
                      begin: 0.8,
                      end: 1.0,
                    ).animate(_pulseController),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'LIVE TRACKING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_people.length} Active',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickStat(
                      '${_getTotalDistance().toStringAsFixed(1)} km',
                      'Total Distance',
                      Icons.route,
                    ),
                  ),
                  Expanded(
                    child: _buildQuickStat(
                      '${_getAverageSpeed().toStringAsFixed(1)} km/h',
                      'Avg Speed',
                      Icons.speed,
                    ),
                  ),
                  Expanded(
                    child: _buildQuickStat(
                      '${_getTotalTasks()}',
                      'Tasks Done',
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.poppins,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 10,
            fontFamily: AppFonts.poppins,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPersonCardsScroller() {
    return Positioned(
      top: 160,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _people.length,
          itemBuilder: (context, index) => _buildPersonCard(index),
        ),
      ),
    );
  }

  Widget _buildPersonCard(int index) {
    final person = _people[index];
    final isSelected = _selectedPersonIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPersonIndex = index);
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(person['position'], 15),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? person['color'] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? person['color'] : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? person['color'] : Colors.black).withOpacity(
                0.15,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ScaleTransition(
                    scale: Tween(
                      begin: 0.8,
                      end: 1.0,
                    ).animate(_pulseController),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
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
                  const Spacer(),
                  Icon(
                    Icons.battery_charging_full,
                    size: 16,
                    color:
                        isSelected
                            ? Colors.white
                            : _getBatteryColor(person['battery']),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person['name'].split(' ')[0],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.poppins,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCardStat(
                    '${person['speed'].toStringAsFixed(0)}',
                    'km/h',
                    isSelected,
                  ),
                  _buildCardStat(
                    '${person['distance'].toStringAsFixed(1)}',
                    'km',
                    isSelected,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardStat(String value, String label, bool isSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.poppins,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white70 : Colors.grey[600],
            fontSize: 9,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedPersonDetailCard() {
    final person = _people[_selectedPersonIndex];

    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.black.withOpacity(0.95)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: person['color'],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (person['color'] as Color).withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                        Text(
                          person['designation'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ScaleTransition(
                    scale: Tween(
                      begin: 0.9,
                      end: 1.0,
                    ).animate(_pulseController),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, size: 8, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailStat(
                      Icons.speed,
                      '${person['speed'].toStringAsFixed(1)} km/h',
                      'Current Speed',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildDetailStat(
                      Icons.route,
                      '${person['distance'].toStringAsFixed(1)} km',
                      'Distance',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildDetailStat(
                      Icons.battery_charging_full,
                      '${person['battery']}%',
                      'Battery',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniStat(
                      'Check-in',
                      person['checkInTime'],
                      Icons.login,
                    ),
                    _buildMiniStat(
                      'Completed',
                      '${person['tasksCompleted']}',
                      Icons.check_circle,
                    ),
                    _buildMiniStat(
                      'Remaining',
                      '${person['tasksRemaining']}',
                      Icons.pending,
                    ),
                    _buildMiniStat(
                      'Updated',
                      person['lastUpdate'],
                      Icons.update,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showPersonDetails(person),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text(
                        'Details',
                        style: TextStyle(fontFamily: AppFonts.poppins),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: person['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text(
                        'Call',
                        style: TextStyle(fontFamily: AppFonts.poppins),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.poppins,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontFamily: AppFonts.poppins,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.poppins,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 9,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingControls() {
    return Positioned(
      right: 16,
      top: 300,
      child: Column(
        children: [
          _buildControlButton(Icons.my_location, () {
            if (_selectedPersonIndex < _people.length) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  _people[_selectedPersonIndex]['position'],
                  15,
                ),
              );
            }
          }),
          const SizedBox(height: 12),
          _buildControlButton(
            _trackingEnabled ? Icons.pause : Icons.play_arrow,
            () => setState(() => _trackingEnabled = !_trackingEnabled),
          ),
          const SizedBox(height: 12),
          _buildControlButton(
            Icons.layers,
            () => setState(() => _showHeatmap = !_showHeatmap),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF667EEA)),
        onPressed: onTap,
      ),
    );
  }

  void _showPersonDetails(Map<String, dynamic> person) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  person['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
                Text(
                  person['designation'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontFamily: AppFonts.poppins,
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Status', person['status'], Icons.info),
                _buildDetailRow(
                  'Speed',
                  '${person['speed'].toStringAsFixed(1)} km/h',
                  Icons.speed,
                ),
                _buildDetailRow(
                  'Distance',
                  '${person['distance'].toStringAsFixed(1)} km',
                  Icons.route,
                ),
                _buildDetailRow(
                  'Battery',
                  '${person['battery']}%',
                  Icons.battery_full,
                ),
                _buildDetailRow('Check-in', person['checkInTime'], Icons.login),
                _buildDetailRow(
                  'Tasks Done',
                  '${person['tasksCompleted']}/${person['tasksCompleted'] + person['tasksRemaining']}',
                  Icons.task_alt,
                ),
                _buildDetailRow(
                  'Last Update',
                  person['lastUpdate'],
                  Icons.update,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF667EEA)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: AppFonts.poppins,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(int battery) {
    if (battery > 70) return Colors.green;
    if (battery > 30) return Colors.orange;
    return Colors.red;
  }

  double _getTotalDistance() {
    return _people.fold(
      0.0,
      (sum, person) => sum + (person['distance'] as double),
    );
  }

  double _getAverageSpeed() {
    double total = _people.fold(
      0.0,
      (sum, person) => sum + (person['speed'] as double),
    );
    return total / _people.length;
  }

  int _getTotalTasks() {
    return _people.fold(
      0,
      (sum, person) => sum + (person['tasksCompleted'] as int),
    );
  }
}
