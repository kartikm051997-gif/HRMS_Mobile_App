import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../../../model/UserTrackingModel/UserTrackingModel.dart';

class TrackingManager {
  static final TrackingManager _instance = TrackingManager._internal();
  factory TrackingManager() => _instance;
  TrackingManager._internal();

  List<UserTrackingRecordModel> trackingRecords = [];
  bool isCheckedIn = false;
  String? currentCheckInTime;
  LatLng? currentCheckInLocation;
  String? currentCheckInAddress;
  List<LatLng> currentRoutePoints = [];
  List<AddressCheckpoint> currentAddressCheckpoints = [];

  final List<VoidCallback> _listeners = [];
  bool _isInitialized = false;

  // Configuration
  static const double MIN_DISTANCE_METERS = 100.0; // Track address every 100m
  static const String _keyTrackingRecords = 'tracking_records';
  static const String _keyIsCheckedIn = 'is_checked_in';
  static const String _keyCheckInTime = 'check_in_time';
  static const String _keyCheckInLat = 'check_in_lat';
  static const String _keyCheckInLng = 'check_in_lng';
  static const String _keyCheckInAddress = 'check_in_address';
  static const String _keyRoutePoints = 'route_points';
  static const String _keyAddressCheckpoints = 'address_checkpoints';

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  Future<void> loadData() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      final recordsJson = prefs.getString(_keyTrackingRecords);
      if (recordsJson != null) {
        final List<dynamic> decoded = json.decode(recordsJson);
        trackingRecords =
            decoded
                .map((item) => UserTrackingRecordModel.fromJson(item))
                .toList();
      }

      isCheckedIn = prefs.getBool(_keyIsCheckedIn) ?? false;
      currentCheckInTime = prefs.getString(_keyCheckInTime);
      currentCheckInAddress = prefs.getString(_keyCheckInAddress);

      final lat = prefs.getDouble(_keyCheckInLat);
      final lng = prefs.getDouble(_keyCheckInLng);
      if (lat != null && lng != null) {
        currentCheckInLocation = LatLng(lat, lng);
      }

      final routeJson = prefs.getString(_keyRoutePoints);
      if (routeJson != null) {
        final List<dynamic> decoded = json.decode(routeJson);
        currentRoutePoints =
            decoded.map((point) => LatLng(point['lat'], point['lng'])).toList();
      }

      final checkpointsJson = prefs.getString(_keyAddressCheckpoints);
      if (checkpointsJson != null) {
        final List<dynamic> decoded = json.decode(checkpointsJson);
        currentAddressCheckpoints =
            decoded.map((item) => AddressCheckpoint.fromJson(item)).toList();
      }

      _isInitialized = true;
      _notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final recordsJson = json.encode(
        trackingRecords.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_keyTrackingRecords, recordsJson);

      await prefs.setBool(_keyIsCheckedIn, isCheckedIn);
      await prefs.setString(_keyCheckInTime, currentCheckInTime ?? '');
      await prefs.setString(_keyCheckInAddress, currentCheckInAddress ?? '');

      if (currentCheckInLocation != null) {
        await prefs.setDouble(_keyCheckInLat, currentCheckInLocation!.latitude);
        await prefs.setDouble(
          _keyCheckInLng,
          currentCheckInLocation!.longitude,
        );
      } else {
        await prefs.remove(_keyCheckInLat);
        await prefs.remove(_keyCheckInLng);
      }

      final routeJson = json.encode(
        currentRoutePoints
            .map((point) => {'lat': point.latitude, 'lng': point.longitude})
            .toList(),
      );
      await prefs.setString(_keyRoutePoints, routeJson);

      final checkpointsJson = json.encode(
        currentAddressCheckpoints.map((c) => c.toJson()).toList(),
      );
      await prefs.setString(_keyAddressCheckpoints, checkpointsJson);
    } catch (e) {
      if (kDebugMode) print('Error saving data: $e');
    }
  }

  void addRecord(UserTrackingRecordModel record) {
    trackingRecords.insert(0, record);
    _saveData();
    _notifyListeners();
  }

  void checkIn(String time, LatLng location, String address) {
    isCheckedIn = true;
    currentCheckInTime = time;
    currentCheckInLocation = location;
    currentCheckInAddress = address;
    currentRoutePoints = [location];
    currentAddressCheckpoints = [
      AddressCheckpoint(
        location: location,
        address: address,
        timestamp: DateTime.now(),
        pointIndex: 0,
      ),
    ];
    _saveData();
    _notifyListeners();
  }

  void addLocationPoint(LatLng location) {
    if (!isCheckedIn) return;

    if (currentRoutePoints.isNotEmpty) {
      final lastPoint = currentRoutePoints.last;
      final distance = Geolocator.distanceBetween(
        lastPoint.latitude,
        lastPoint.longitude,
        location.latitude,
        location.longitude,
      );
      if (distance < 5) return;
    }

    currentRoutePoints.add(location);
    _saveData();
    _notifyListeners();
  }

  Future<void> addAddressCheckpoint(LatLng location, String address) async {
    if (!isCheckedIn || currentAddressCheckpoints.isEmpty) return;

    final lastCheckpoint = currentAddressCheckpoints.last;
    final distance = Geolocator.distanceBetween(
      lastCheckpoint.location.latitude,
      lastCheckpoint.location.longitude,
      location.latitude,
      location.longitude,
    );

    // Only add if 100+ meters away AND address is different
    if (distance >= MIN_DISTANCE_METERS && address != lastCheckpoint.address) {
      currentAddressCheckpoints.add(
        AddressCheckpoint(
          location: location,
          address: address,
          timestamp: DateTime.now(),
          distanceFromPrevious: distance,
          pointIndex: currentRoutePoints.length - 1,
        ),
      );
      print('New Address: $address (${distance.toStringAsFixed(0)}m away)');
      _saveData();
      _notifyListeners();
    }
  }

  void checkOut() {
    isCheckedIn = false;
    currentCheckInTime = null;
    currentCheckInLocation = null;
    currentCheckInAddress = null;
    currentRoutePoints.clear();
    currentAddressCheckpoints.clear();
    _saveData();
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
  String? _lastFetchedAddress;

  Function(LatLng)? onLocationUpdate;
  Function(LatLng, String)? onAddressChange;

  LatLng? get currentLocation => _currentLocation;
  String? get lastFetchedAddress => _lastFetchedAddress;
  bool get isServiceEnabled => _isServiceEnabled;

  Future<bool> initLocationService() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openLocationSettings();
        return false;
      }

      await _getInitialPosition();
      _startLocationUpdates();
      _isServiceEnabled = true;
      return true;
    } catch (e) {
      if (kDebugMode) print('Location service error: $e');
      return false;
    }
  }

  Future<void> _getInitialPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      _currentLocation = LatLng(position.latitude, position.longitude);
    } catch (e) {
      if (kDebugMode) print('Error getting initial position: $e');
    }
  }

  void _startLocationUpdates() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) async {
        _currentLocation = LatLng(position.latitude, position.longitude);

        if (onLocationUpdate != null) {
          onLocationUpdate!(_currentLocation!);
        }

        if (onAddressChange != null) {
          try {
            final address = await getAddressFromLocation(_currentLocation!);
            _lastFetchedAddress = address;
            onAddressChange!(_currentLocation!, address);
          } catch (e) {
            if (kDebugMode) print('Error fetching address: $e');
          }
        }
      },
      onError: (e) {
        if (kDebugMode) print('Position stream error: $e');
      },
    );
  }

  Future<LatLng?> getLocationOnce() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      final location = LatLng(position.latitude, position.longitude);
      _currentLocation = location;
      return location;
    } catch (e) {
      return _currentLocation;
    }
  }

  Future<String> getAddressFromLocation(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];

        // Add all available components for full address
        if (place.name != null && place.name!.isNotEmpty) {
          addressParts.add(place.name!);
        }
        if (place.street != null &&
            place.street!.isNotEmpty &&
            place.street != place.name) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(place.subAdministrativeArea!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        String address = addressParts.join(', ');
        return address.isEmpty ? 'Address not found' : address;
      }
      return 'Address not found';
    } catch (e) {
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

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _trackingManager.addListener(_onTrackingStateChanged);

    _locationService.onLocationUpdate = (LatLng location) {
      _trackingManager.addLocationPoint(location);
    };

    _locationService.onAddressChange = (LatLng location, String address) {
      _trackingManager.addAddressCheckpoint(location, address);
    };
  }

  Future<void> _initializeApp() async {
    setState(() => isLoadingLocation = true);
    await _trackingManager.loadData();
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
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _locationService.currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );

      // Add address checkpoint markers (orange)
      for (
        int i = 0;
        i < _trackingManager.currentAddressCheckpoints.length;
        i++
      ) {
        final checkpoint = _trackingManager.currentAddressCheckpoints[i];
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

      if (_trackingManager.isCheckedIn &&
          _trackingManager.currentRoutePoints.length >= 2) {
        _polyLines.add(
          Polyline(
            polylineId: const PolylineId('tracking_route'),
            points: _trackingManager.currentRoutePoints,
            color: const Color(0xFF4285F4),
            width: 6,
            geodesic: true,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {});
    }
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

    // ✅ CHECK LOCATION SERVICE AND PERMISSION FIRST
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationRequiredDialog(
        title: 'Location Service Disabled',
        message: 'Please enable location services to check in',
        isServiceIssue: true,
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationRequiredDialog(
          title: 'Location Permission Denied',
          message: 'Location permission is required to check in',
          isServiceIssue: false,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationRequiredDialog(
        title: 'Location Permission Required',
        message:
            'Please enable location permission from app settings to check in',
        isServiceIssue: false,
        showSettings: true,
      );
      return;
    }

    // ✅ NOW PROCEED WITH CHECK-IN
    setState(() => isLoading = true);

    try {
      LatLng? location = await _locationService.getLocationOnce();
      if (location == null) {
        throw Exception('Could not fetch your current location');
      }

      String address = await _locationService.getAddressFromLocation(location);
      final now = DateTime.now();
      final formatter = DateFormat('hh:mm a');
      final time = formatter.format(now);

      _trackingManager.checkIn(time, location, address);
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
        throw Exception('Could not fetch your current location');
      }

      _trackingManager.addLocationPoint(location);
      String checkOutAddress = await _locationService.getAddressFromLocation(
        location,
      );
      await _trackingManager.addAddressCheckpoint(location, checkOutAddress);

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
        routePoints: List<LatLng>.from(_trackingManager.currentRoutePoints),
        addressCheckpoints: List<AddressCheckpoint>.from(
          _trackingManager.currentAddressCheckpoints,
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                          '${_trackingManager.currentRoutePoints.length} points • ${_trackingManager.currentAddressCheckpoints.length} places',
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
                          child: Text(
                            _trackingManager.currentCheckInAddress ?? '',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFonts.poppins,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
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
          Expanded(
            child:
                _locationService.currentLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _locationService.currentLocation!,
                        zoom: 15,
                      ),
                      markers: _markers,
                      polylines: _polyLines,
                      onMapCreated: (controller) {
                        _mapController = controller;
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _trackingManager.removeListener(_onTrackingStateChanged);
    _mapController?.dispose();
    _locationService.dispose();
    super.dispose();
  }

  void _showLocationRequiredDialog({
    required String title,
    required String message,
    bool isServiceIssue = false,
    bool showSettings = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: AppFonts.poppins, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No Thanks',
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (showSettings) {
                  // Open app settings for permission
                  await Geolocator.openAppSettings();
                } else if (isServiceIssue) {
                  // Open location settings
                  await Geolocator.openLocationSettings();
                } else {
                  // Request permission again
                  await Geolocator.requestPermission();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                showSettings ? 'Open Settings' : 'Turn On',
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
