import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../model/UserTrackingModel/UserTrackingModel.dart';

// ==================== DIRECTIONS SERVICE ====================
class DirectionsService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  static const String _apiKey = 'AIzaSyAj0Wx6E4wZcM1-Og7ympdaB9kNv-f9JgE';

  /// Fetch directions between origin and destination
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
            print('Error message: ${data['error_message'] ?? 'No message'}');
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print('HTTP error: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching directions: $e');
      }
      return null;
    }
  }

  /// Decode Google's encoded polyline format
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

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;

      polyline.add(LatLng(latitude, longitude));
    }

    return polyline;
  }
}

// ==================== TRACKING MANAGER ====================
class TrackingManager {
  static final TrackingManager _instance = TrackingManager._internal();
  factory TrackingManager() => _instance;
  TrackingManager._internal();

  List<UserTrackingRecordModel> trackingRecords = [];
  bool isCheckedIn = false;
  String? currentCheckInTime;
  LatLng? currentCheckInLocation;
  String? currentCheckInAddress;

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void addRecord(UserTrackingRecordModel record) {
    trackingRecords.insert(0, record);
    _notifyListeners();
  }

  void checkIn(String time, LatLng location, String address) {
    isCheckedIn = true;
    currentCheckInTime = time;
    currentCheckInLocation = location;
    currentCheckInAddress = address;
    _notifyListeners();
  }

  void checkOut() {
    isCheckedIn = false;
    currentCheckInTime = null;
    currentCheckInLocation = null;
    currentCheckInAddress = null;
    _notifyListeners();
  }
}

// ==================== LOCATION SERVICE ====================
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStream;
  bool _isServiceEnabled = false;

  LatLng? get currentLocation => _currentLocation;
  bool get isServiceEnabled => _isServiceEnabled;

  Future<bool> initLocationService() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Location service is disabled on device');
        }
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('Location permissions are permanently denied');
        }
        await Geolocator.openLocationSettings();
        return false;
      }

      await _getInitialPosition();
      _startLocationUpdates();
      _isServiceEnabled = true;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Location service initialization error: $e');
      }
      return false;
    }
  }

  Future<void> _getInitialPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 15),
      );
      _currentLocation = LatLng(position.latitude, position.longitude);
      if (kDebugMode) {
        print('Initial location fetched: $_currentLocation');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial position: $e');
      }
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _currentLocation = LatLng(position.latitude, position.longitude);
        if (kDebugMode) {
          print('Location fetched with high accuracy: $_currentLocation');
        }
      } catch (e2) {
        if (kDebugMode) {
          print('Failed to get location with any accuracy: $e2');
        }
      }
    }
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
      timeLimit: Duration(seconds: 20),
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _currentLocation = LatLng(position.latitude, position.longitude);
        if (kDebugMode) {
          print('Location updated: $_currentLocation');
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print('Position stream error: $e');
        }
      },
    );
  }

  Future<LatLng?> getLocationOnce() async {
    try {
      if (kDebugMode) {
        print('Fetching fresh location...');
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 20),
      );
      final location = LatLng(position.latitude, position.longitude);
      _currentLocation = location;
      if (kDebugMode) {
        print('Fresh location fetched: $location');
      }
      return location;
    } catch (e) {
      if (kDebugMode) {
        print('Error with best accuracy: $e');
      }
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );
        final location = LatLng(position.latitude, position.longitude);
        _currentLocation = location;
        if (kDebugMode) {
          print('Location fetched with high accuracy: $location');
        }
        return location;
      } catch (e2) {
        if (kDebugMode) {
          print('Error with high accuracy: $e2');
        }
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 10),
          );
          final location = LatLng(position.latitude, position.longitude);
          _currentLocation = location;
          if (kDebugMode) {
            print('Location fetched with medium accuracy: $location');
          }
          return location;
        } catch (e3) {
          if (kDebugMode) {
            print('Failed to get location: $e3');
          }
          if (_currentLocation != null) {
            if (kDebugMode) {
              print('Using last known location: $_currentLocation');
            }
            return _currentLocation;
          }
          return null;
        }
      }
    }
  }

  Future<String> getAddressFromLocation(LatLng location) async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placeMarks.isNotEmpty) {
        Placemark place = placeMarks[0];

        String address = '';
        if (place.street != null && place.street!.isNotEmpty) {
          address += '${place.street!}, ';
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          address += '${place.subLocality!}, ';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += '${place.locality!}, ';
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          address += '${place.administrativeArea!}, ';
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          address += place.postalCode!;
        }

        address = address.replaceAll(RegExp(r', $'), '');
        return address.isEmpty ? 'Address not found' : address;
      }
      return 'Address not found';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting address: $e');
      }
      return 'Unable to fetch address';
    }
  }

  void dispose() {
    _positionStream?.cancel();
  }
}

// ==================== USER TRACKING SCREEN ====================
class UserTrackingScreen extends StatefulWidget {
  const UserTrackingScreen({super.key});

  @override
  State<UserTrackingScreen> createState() => _UserTrackingScreenState();
}

class _UserTrackingScreenState extends State<UserTrackingScreen> {
  final TrackingManager _trackingManager = TrackingManager();
  final LocationService _locationService = LocationService();

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};

  bool isLoadingLocation = false;
  bool isLoading = false;
  bool isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _trackingManager.addListener(_onTrackingStateChanged);
  }

  Future<void> _initializeLocation() async {
    setState(() => isLoadingLocation = true);
    bool success = await _locationService.initLocationService();
    setState(() => isLoadingLocation = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission required',
            style: TextStyle(fontFamily: AppFonts.poppins),
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      _updateMapMarkersWithRoute();
    }
  }

  void _onTrackingStateChanged() {
    _updateMapMarkersWithRoute();
  }

  Future<void> _updateMapMarkersWithRoute() async {
    _markers.clear();
    _polyLines.clear();

    if (_trackingManager.isCheckedIn &&
        _trackingManager.currentCheckInLocation != null) {
      // Add check-in marker
      _markers.add(
        Marker(
          markerId: const MarkerId('check_in'),
          position: _trackingManager.currentCheckInLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: 'Check In',
            snippet: _trackingManager.currentCheckInTime ?? '',
          ),
        ),
      );
    }

    if (_locationService.currentLocation != null) {
      // Add current location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _locationService.currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );

      // Draw route polyline if checked in
      if (_trackingManager.isCheckedIn &&
          _trackingManager.currentCheckInLocation != null) {
        setState(() => isLoadingRoute = true);

        // Fetch directions from Google Directions API
        List<LatLng>? routePoints = await DirectionsService.getDirections(
          origin: _trackingManager.currentCheckInLocation!,
          destination: _locationService.currentLocation!,
          mode: 'driving', // Change to 'walking' if needed
        );

        setState(() => isLoadingRoute = false);

        if (routePoints != null && routePoints.isNotEmpty) {
          // Add polyline with route points following roads
          _polyLines.add(
            Polyline(
              polylineId: const PolylineId('tracking_route'),
              points: routePoints,
              color: Colors.teal,
              width: 4,
              patterns: [PatternItem.dash(20), PatternItem.gap(10)],
            ),
          );
        } else {
          // Fallback to straight line if API fails
          _polyLines.add(
            Polyline(
              polylineId: const PolylineId('tracking_route'),
              points: [
                _trackingManager.currentCheckInLocation!,
                _locationService.currentLocation!,
              ],
              color: Colors.teal.withOpacity(0.5),
              width: 4,
              patterns: [PatternItem.dash(20), PatternItem.gap(10)],
            ),
          );
        }
      }
    }

    setState(() {});
  }

  Future<void> _handleCheckIn() async {
    if (_trackingManager.isCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Already checked in',
            style: TextStyle(fontFamily: AppFonts.poppins),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      LatLng? location = await _locationService.getLocationOnce();

      if (location == null) {
        setState(() => isLoading = false);
        throw Exception(
          'Could not fetch your current location. Please enable GPS and try again.',
        );
      }

      String address = await _locationService.getAddressFromLocation(location);

      final now = DateTime.now();
      final formatter = DateFormat('hh:mm a');
      final time = formatter.format(now);

      _trackingManager.checkIn(time, location, address);

      // Update map with route
      await _updateMapMarkersWithRoute();

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));

      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Checked in at $time',
              style: const TextStyle(fontFamily: AppFonts.poppins),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Check in failed: ${e.toString()}',
              style: const TextStyle(fontFamily: AppFonts.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCheckOut() async {
    if (!_trackingManager.isCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please check in first',
            style: TextStyle(fontFamily: AppFonts.poppins),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      LatLng? location = await _locationService.getLocationOnce();

      if (location == null) {
        setState(() => isLoading = false);
        throw Exception(
          'Could not fetch your current location. Please enable GPS and try again.',
        );
      }

      String checkOutAddress = await _locationService.getAddressFromLocation(
        location,
      );

      final now = DateTime.now();
      final formatter = DateFormat('hh:mm a');
      final dateFormatter = DateFormat('dd/MM/yyyy');

      final newRecord = UserTrackingRecordModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: dateFormatter.format(now),
        checkInTime: _trackingManager.currentCheckInTime ?? 'N/A',
        checkOutTime: formatter.format(now),
        checkInLocation: _trackingManager.currentCheckInLocation ?? location,
        checkOutLocation: location,
        checkInAddress:
            _trackingManager.currentCheckInAddress ?? 'Address not available',
        checkOutAddress: checkOutAddress,
        status: 'checked_out',
      );

      _trackingManager.addRecord(newRecord);
      _trackingManager.checkOut();

      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Checked out at ${newRecord.checkOutTime}',
              style: const TextStyle(fontFamily: AppFonts.poppins),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Check out failed: ${e.toString()}',
              style: const TextStyle(fontFamily: AppFonts.poppins),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _fitMapToBounds() {
    if (_mapController == null || _trackingManager.trackingRecords.isEmpty) {
      return;
    }

    List<LatLng> allLocations = [];

    for (var record in _trackingManager.trackingRecords) {
      allLocations.add(record.checkInLocation);
      allLocations.add(record.checkOutLocation);
    }

    if (allLocations.length == 1) {
      _mapController!.animateCamera(
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

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // TOP SECTION - Check In/Out Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status Badge (when checked in)
                if (_trackingManager.isCheckedIn) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tracking started at ${_trackingManager.currentCheckInTime}',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Address Display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_trackingManager.currentCheckInAddress !=
                                  null)
                                Text(
                                  _trackingManager.currentCheckInAddress!,
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleCheckIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Check In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : _handleCheckOut,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Colors.red, width: 1.5),
                        ),
                        child: const Text(
                          'Check Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // MAP SECTION - Expands to fill space
          Expanded(
            child:
                _locationService.currentLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _locationService.currentLocation!,
                            zoom: 15,
                          ),
                          markers: _markers,
                          polylines: _polyLines,
                          onMapCreated: (controller) {
                            _mapController = controller;
                            if (_trackingManager.trackingRecords.isNotEmpty) {
                              _fitMapToBounds();
                            }
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true,
                          mapToolbarEnabled: true,
                          gestureRecognizers:
                              <Factory<OneSequenceGestureRecognizer>>{
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                          zoomGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          rotateGesturesEnabled: true,
                          tiltGesturesEnabled: true,
                        ),

                        // Loading Route Indicator
                        if (isLoadingRoute)
                          Positioned(
                            bottom: 16,
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
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

                        // Legend
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLegendItem('Check In', Colors.green),
                                const SizedBox(height: 8),
                                _buildLegendItem('Check Out', Colors.red),
                                const SizedBox(height: 8),
                                _buildLegendItem('Current', Colors.blue),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _trackingManager.removeListener(_onTrackingStateChanged);
    _mapController?.dispose();
    _locationService.dispose();
    super.dispose();
  }
}
