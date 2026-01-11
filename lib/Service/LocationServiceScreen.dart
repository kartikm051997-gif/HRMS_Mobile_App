import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStream;
  bool _isServiceEnabled = false;
  String? _lastFetchedAddress;
  int _locationUpdateCount = 0;

  // Track last position to detect real movement
  double? _lastLat;
  double? _lastLng;

  Function(LatLng)? onLocationUpdate;
  Function(LatLng, String)? onAddressChange;

  LatLng? get currentLocation => _currentLocation;
  String? get lastFetchedAddress => _lastFetchedAddress;
  bool get isServiceEnabled => _isServiceEnabled;

  Future<bool> initLocationService() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) print('❌ Location service not enabled');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) print('❌ Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) print('❌ Location permission denied forever');
        await Geolocator.openLocationSettings();
        return false;
      }

      await _getInitialPosition();
      _startLocationUpdates();
      _isServiceEnabled = true;

      if (kDebugMode) print('✅ Location service initialized');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Location initialization error: $e');
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
      _lastLat = position.latitude;
      _lastLng = position.longitude;

      if (kDebugMode) {
        print(
          '📍 Initial position: ${position.latitude}, ${position.longitude}',
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Initial position error: $e');
    }
  }

  void _startLocationUpdates() {
    // ✅ Trigger updates every 20 meters for better accuracy
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20, // ← Trigger updates every 20 meters
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) async {
        // ✅ Check if actually moved 20+ meters (matching distanceFilter)
        if (_lastLat != null && _lastLng != null) {
          final distance = Geolocator.distanceBetween(
            _lastLat!,
            _lastLng!,
            position.latitude,
            position.longitude,
          );

          // ✅ Use same threshold as distanceFilter (20m)
          if (distance < 20.0) {
            if (kDebugMode && _locationUpdateCount % 20 == 0) {
              if (kDebugMode) {
                print(
                  '⏭️ Foreground: Ignoring GPS drift (${distance.toStringAsFixed(1)}m)',
                );
              }
            }
            return;
          }
        }

        _locationUpdateCount++;
        _currentLocation = LatLng(position.latitude, position.longitude);
        _lastLat = position.latitude;
        _lastLng = position.longitude;

        if (kDebugMode && _locationUpdateCount % 5 == 0) {
          if (kDebugMode) {
            print('📡 Foreground: Location update #$_locationUpdateCount');
          }
          if (kDebugMode) {
            print(
              '   Position: ${position.latitude.toStringAsFixed(6)}, '
              '${position.longitude.toStringAsFixed(6)}',
            );
          }
        }

        // ✅ Trigger callback if actually moved
        if (onLocationUpdate != null) {
          onLocationUpdate!(_currentLocation!);
        }

        // ✅ Check address less frequently (every 5 real movements)
        if (_locationUpdateCount % 5 == 0 && onAddressChange != null) {
          try {
            final address = await getAddressFromLocation(_currentLocation!);
            _lastFetchedAddress = address;
            onAddressChange!(_currentLocation!, address);
          } catch (e) {
            if (kDebugMode) print('❌ Address error: $e');
          }
        }
      },
      onError: (e) {
        if (kDebugMode) print('❌ Position stream error: $e');
      },
      cancelOnError: false, // ← Don't stop on errors
    );

    if (kDebugMode) print('✅ Location updates started');
  }

  Future<LatLng?> getLocationOnce() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      final location = LatLng(position.latitude, position.longitude);
      _currentLocation = location;

      if (kDebugMode) {
        print(
          '📍 Got location once: ${position.latitude}, ${position.longitude}',
        );
      }

      return location;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting location: $e');
      return _currentLocation; // Return last known location
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

        // Build complete address from available components
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
      if (kDebugMode) print('❌ Geocoding error: $e');
      return 'Unable to fetch address';
    }
  }

  // ✅ NEW: Force refresh location (useful for debugging)
  Future<void> refreshLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      _currentLocation = LatLng(position.latitude, position.longitude);
      _lastLat = position.latitude;
      _lastLng = position.longitude;

      if (kDebugMode) {
        print(
          '🔄 Location refreshed: ${position.latitude}, ${position.longitude}',
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Refresh error: $e');
    }
  }

  // ✅ NEW: Get current accuracy
  Future<double?> getCurrentAccuracy() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position.accuracy;
    } catch (e) {
      if (kDebugMode) print('❌ Accuracy check error: $e');
      return null;
    }
  }

  void dispose() {
    _positionStream?.cancel();
    _isServiceEnabled = false;
    if (kDebugMode) print('🧹 Location service disposed');
  }
}
