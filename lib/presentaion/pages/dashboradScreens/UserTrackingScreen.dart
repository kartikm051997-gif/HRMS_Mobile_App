import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/appcolor_dart.dart';
import '../../../model/UserTrackingModel/UserTrackingModel.dart';
import 'FaceIdentificationScreen.dart';

// ==================== BACKGROUND SERVICE ====================
// ==================== IMPROVED BACKGROUND SERVICE ====================
// ==================== PERSISTENT BACKGROUND SERVICE ====================
class BackgroundTrackingService {
  static final BackgroundTrackingService _instance =
      BackgroundTrackingService._internal();
  factory BackgroundTrackingService() => _instance;
  BackgroundTrackingService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tracking_channel',
      'Location Tracking',
      description: 'Tracking your location in background',
      importance: Importance.high, // Changed to high
      playSound: false,
      enableVibration: false,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true, // Critical for persistence
        notificationChannelId: 'tracking_channel',
        initialNotificationTitle: '🎯 Location Tracking Active',
        initialNotificationContent: 'Recording your route...',
        foregroundServiceNotificationId: 888,
        autoStartOnBoot: true, // ✅ Restart after device reboot
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    if (kDebugMode) print('✅ Background service initialized');
  }

  Future<void> startTracking() async {
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();

    if (!isRunning) {
      await service.startService();
      if (kDebugMode) print('🚀 Background tracking service started');
    } else {
      if (kDebugMode) print('⚠️ Service already running');
    }
  }

  Future<void> stopTracking() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
    if (kDebugMode) print('🛑 Background tracking service stopped');
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (kDebugMode)
      print('🎯 Background service STARTED - Independent Process');

    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    StreamSubscription<Position>? positionStream;
    Timer? addressCheckTimer;
    Timer? healthCheckTimer;
    String? lastAddress;
    int pointCount = 0;
    double? lastSavedLat;
    double? lastSavedLng;
    DateTime? lastUpdateTime = DateTime.now();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId =
          prefs.getString('employeeId') ?? prefs.getString('logged_in_emp_id');

      if (userId == null) {
        if (kDebugMode) print('❌ No user ID found');
        service.stopSelf();
        return;
      }

      final isCheckedIn = prefs.getBool('is_checked_in_$userId') ?? false;
      if (!isCheckedIn) {
        if (kDebugMode) print('⚠️ User not checked in');
        service.stopSelf();
        return;
      }

      if (kDebugMode) print('✅ Service running for user: $userId');

      // ✅ CRITICAL: Aggressive location tracking
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20, // Lower threshold for better tracking
        timeLimit: Duration(seconds: 30),
      );

      // ✅ Start location tracking
      positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          try {
            lastUpdateTime = DateTime.now();

            // Check movement
            if (lastSavedLat != null && lastSavedLng != null) {
              final distanceFromLast = Geolocator.distanceBetween(
                lastSavedLat!,
                lastSavedLng!,
                position.latitude,
                position.longitude,
              );

              if (distanceFromLast < 20.0) {
                // ← Match your distanceFilter
                return; // Ignore GPS drift
              }
            }

            // Save to SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            final routeKey = 'route_points_$userId';

            List<Map<String, double>> routePoints = [];
            final routeJson = prefs.getString(routeKey);

            if (routeJson != null) {
              try {
                final decoded = json.decode(routeJson) as List;
                routePoints =
                    decoded
                        .map(
                          (p) => {
                            'lat': p['lat'] as double,
                            'lng': p['lng'] as double,
                          },
                        )
                        .toList();
              } catch (e) {
                if (kDebugMode) print('⚠️ Error decoding route: $e');
                routePoints = [];
              }
            }

            // Add new point
            routePoints.add({
              'lat': position.latitude,
              'lng': position.longitude,
            });

            // Save immediately
            await prefs.setString(routeKey, json.encode(routePoints));

            // Also save timestamp
            await prefs.setString(
              'last_tracking_update_$userId',
              DateTime.now().toIso8601String(),
            );

            lastSavedLat = position.latitude;
            lastSavedLng = position.longitude;
            pointCount++;

            if (kDebugMode) {
              print('📍 BG Service: Point #$pointCount saved');
              print(
                '   Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
              );
              print('   Total stored: ${routePoints.length}');
            }

            // Update notification
            final distance = await _calculateDistance(routePoints);
            await notificationsPlugin.show(
              888,
              '🎯 Tracking Active',
              '${routePoints.length} points • ${distance.toStringAsFixed(2)} km • Updated ${_getTimeAgo(lastUpdateTime!)}',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'tracking_channel',
                  'Location Tracking',
                  icon: 'ic_bg_service_small',
                  ongoing: true,
                  autoCancel: false,
                  playSound: false,
                  priority: Priority.high,
                  importance: Importance.high,
                  enableVibration: false,
                ),
              ),
            );
          } catch (e) {
            if (kDebugMode) print('❌ BG Service Error: $e');
          }
        },
        onError: (e) {
          if (kDebugMode) print('❌ Position stream error: $e');
        },
        cancelOnError: false, // Don't cancel on errors
      );

      // ✅ Address checkpoint tracking
      addressCheckTimer = Timer.periodic(const Duration(seconds: 60), (
        timer,
      ) async {
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 15),
          );

          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );

          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            List<String> addressParts = [];

            if (place.name != null && place.name!.isNotEmpty) {
              addressParts.add(place.name!);
            }
            if (place.street != null && place.street!.isNotEmpty) {
              addressParts.add(place.street!);
            }
            if (place.locality != null && place.locality!.isNotEmpty) {
              addressParts.add(place.locality!);
            }

            String currentAddress = addressParts.join(', ');
            if (currentAddress.isEmpty) currentAddress = 'Unknown Location';

            if (lastAddress == null || lastAddress != currentAddress) {
              final prefs = await SharedPreferences.getInstance();
              final checkpointsKey = 'address_checkpoints_$userId';

              List<Map<String, dynamic>> checkpoints = [];
              final checkpointsJson = prefs.getString(checkpointsKey);

              if (checkpointsJson != null) {
                try {
                  final decoded = json.decode(checkpointsJson) as List;
                  checkpoints = decoded.cast<Map<String, dynamic>>();
                } catch (e) {
                  checkpoints = [];
                }
              }

              double distanceFromLast = 0.0;
              if (checkpoints.isNotEmpty) {
                final lastCheckpoint = checkpoints.last;
                distanceFromLast = Geolocator.distanceBetween(
                  lastCheckpoint['latitude'] as double,
                  lastCheckpoint['longitude'] as double,
                  position.latitude,
                  position.longitude,
                );
              }

              if (checkpoints.isEmpty || distanceFromLast >= 50.0) {
                checkpoints.add({
                  'latitude': position.latitude,
                  'longitude': position.longitude,
                  'address': currentAddress,
                  'timestamp': DateTime.now().toIso8601String(),
                  'distanceFromPrevious': distanceFromLast,
                });

                await prefs.setString(checkpointsKey, json.encode(checkpoints));
                lastAddress = currentAddress;

                if (kDebugMode) {
                  print(
                    '🏠 BG Checkpoint #${checkpoints.length}: $currentAddress',
                  );
                }
              }
            }
          }
        } catch (e) {
          if (kDebugMode) print('❌ Address check error: $e');
        }
      });

      // ✅ Health check - verify service is still tracking
      healthCheckTimer = Timer.periodic(const Duration(minutes: 2), (
        timer,
      ) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final isStillCheckedIn =
              prefs.getBool('is_checked_in_$userId') ?? false;

          if (!isStillCheckedIn) {
            if (kDebugMode) print('✅ User checked out, stopping service');
            positionStream?.cancel();
            addressCheckTimer?.cancel();
            timer.cancel();
            service.stopSelf();
            return;
          }

          // Check if location updates are working
          if (lastUpdateTime != null) {
            final timeSinceLastUpdate = DateTime.now().difference(
              lastUpdateTime!,
            );
            if (timeSinceLastUpdate.inMinutes > 5) {
              if (kDebugMode) {
                print(
                  '⚠️ No location updates for ${timeSinceLastUpdate.inMinutes} minutes',
                );
              }
            }
          }

          if (kDebugMode) {
            print('💓 Health Check: Service alive, $pointCount points saved');
          }
        } catch (e) {
          if (kDebugMode) print('❌ Health check error: $e');
        }
      });

      // ✅ Stop service command
      service.on('stopService').listen((event) {
        if (kDebugMode) print('🛑 Stop command received');
        positionStream?.cancel();
        addressCheckTimer?.cancel();
        healthCheckTimer?.cancel();
        service.stopSelf();
      });

      if (kDebugMode) print('✅ All timers and listeners started');
    } catch (e) {
      if (kDebugMode) print('❌ Fatal error in service: $e');
      service.stopSelf();
    }
  }

  static String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  static Future<double> _calculateDistance(
    List<Map<String, double>> points,
  ) async {
    if (points.length < 2) return 0.0;

    double total = 0.0;
    for (int i = 1; i < points.length; i++) {
      total += Geolocator.distanceBetween(
        points[i - 1]['lat']!,
        points[i - 1]['lng']!,
        points[i]['lat']!,
        points[i]['lng']!,
      );
    }
    return total / 1000;
  }
}

// ==================== IMPROVED LOCATION SERVICE ====================
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  LatLng? _currentLocation;
  StreamSubscription<Position>? _positionStream;
  bool _isServiceEnabled = false;
  String? _lastFetchedAddress;
  int _locationUpdateCount = 0;

  // ✅ Track last position to detect real movement
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

      if (kDebugMode) print('✅ Location service initialized');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Location error: $e');
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
    } catch (e) {
      if (kDebugMode) print('❌ Initial position error: $e');
    }
  }

  void _startLocationUpdates() {
    // ✅ IMPROVED: Only trigger updates when actually moving
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Only update when moved 10+ meters
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) async {
        // ✅ Check if actually moved significantly
        if (_lastLat != null && _lastLng != null) {
          final distance = Geolocator.distanceBetween(
            _lastLat!,
            _lastLng!,
            position.latitude,
            position.longitude,
          );

          // ✅ Ignore GPS drift - only update if moved 10+ meters
          if (distance < 20.0) {
            // ← Match your distanceFilter
            if (kDebugMode && _locationUpdateCount % 20 == 0) {
              print(
                '⏭️ Foreground: Ignoring GPS drift (${distance.toStringAsFixed(1)}m)',
              );
            }
            return;
          }
        }

        _locationUpdateCount++;
        _currentLocation = LatLng(position.latitude, position.longitude);
        _lastLat = position.latitude;
        _lastLng = position.longitude;

        if (kDebugMode && _locationUpdateCount % 5 == 0) {
          print('📡 Foreground: Location update #$_locationUpdateCount');
        }

        // ✅ Only trigger callback if actually moved
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
        if (kDebugMode) print('❌ Stream error: $e');
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
      if (kDebugMode) print('❌ Error getting location: $e');
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
  List<LatLng> currentRoutePoints = [];
  List<AddressCheckpoint> currentAddressCheckpoints = [];

  final List<VoidCallback> _listeners = [];
  String? _currentUserId;

  // ✅ IMPROVED: Better distance thresholds
  static const double MIN_DISTANCE_METERS = 100.0; // For checkpoints
  static const double MIN_POINT_DISTANCE = 20.0; // ← Match your distanceFilter
  // For route points (increased from 5)

  String _getRecordsKey() =>
      _currentUserId != null
          ? 'tracking_records_$_currentUserId'
          : 'tracking_records';
  String _getCheckedInKey() =>
      _currentUserId != null
          ? 'is_checked_in_$_currentUserId'
          : 'is_checked_in';
  String _getCheckInTimeKey() =>
      _currentUserId != null
          ? 'check_in_time_$_currentUserId'
          : 'check_in_time';
  String _getCheckInLatKey() =>
      _currentUserId != null ? 'check_in_lat_$_currentUserId' : 'check_in_lat';
  String _getCheckInLngKey() =>
      _currentUserId != null ? 'check_in_lng_$_currentUserId' : 'check_in_lng';
  String _getCheckInAddressKey() =>
      _currentUserId != null
          ? 'check_in_address_$_currentUserId'
          : 'check_in_address';
  String _getRoutePointsKey() =>
      _currentUserId != null ? 'route_points_$_currentUserId' : 'route_points';
  String _getCheckpointsKey() =>
      _currentUserId != null
          ? 'address_checkpoints_$_currentUserId'
          : 'address_checkpoints';

  Future<void> setUserId(String? userId) async {
    if (_currentUserId != userId) {
      if (kDebugMode) print('👤 Setting user ID: $userId');

      trackingRecords.clear();
      isCheckedIn = false;
      currentCheckInTime = null;
      currentCheckInLocation = null;
      currentCheckInAddress = null;
      currentRoutePoints.clear();
      currentAddressCheckpoints.clear();

      _currentUserId = userId;

      await loadData();
      _notifyListeners();
    }
  }

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  Future<void> loadData() async {
    // ✅ IMPROVED: Always refresh from storage, don't skip
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId =
          prefs.getString('employeeId') ?? prefs.getString('logged_in_emp_id');

      final recordsJson = prefs.getString(_getRecordsKey());
      if (recordsJson != null) {
        final List<dynamic> decoded = json.decode(recordsJson);
        trackingRecords =
            decoded
                .map((item) => UserTrackingRecordModel.fromJson(item))
                .toList();
      } else {
        trackingRecords = [];
      }

      isCheckedIn = prefs.getBool(_getCheckedInKey()) ?? false;
      currentCheckInTime = prefs.getString(_getCheckInTimeKey());
      currentCheckInAddress = prefs.getString(_getCheckInAddressKey());

      final lat = prefs.getDouble(_getCheckInLatKey());
      final lng = prefs.getDouble(_getCheckInLngKey());
      if (lat != null && lng != null) {
        currentCheckInLocation = LatLng(lat, lng);
      }

      // ✅ Always load route points from storage
      final routeJson = prefs.getString(_getRoutePointsKey());
      if (routeJson != null) {
        final List<dynamic> decoded = json.decode(routeJson);
        currentRoutePoints =
            decoded.map((point) => LatLng(point['lat'], point['lng'])).toList();
      } else {
        currentRoutePoints = [];
      }

      // ✅ Always load checkpoints from storage
      final checkpointsJson = prefs.getString(_getCheckpointsKey());
      if (checkpointsJson != null) {
        final List<dynamic> decoded = json.decode(checkpointsJson);
        currentAddressCheckpoints =
            decoded.map((item) {
              return AddressCheckpoint(
                location: LatLng(item['latitude'], item['longitude']),
                address: item['address'],
                timestamp: DateTime.parse(item['timestamp']),
                distanceFromPrevious:
                    (item['distanceFromPrevious'] ?? 0.0) as double,
                pointIndex: currentRoutePoints.length - 1,
              );
            }).toList();
      } else {
        currentAddressCheckpoints = [];
      }

      if (kDebugMode) {
        print('✅ Loaded data for user: $_currentUserId');
        print('   - Checked in: $isCheckedIn');
        print('   - Route points: ${currentRoutePoints.length}');
        print('   - Checkpoints: ${currentAddressCheckpoints.length}');
      }

      _notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error loading data: $e');
    }
  }

  Future<void> _refreshFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ✅ Refresh route points
      final routeJson = prefs.getString(_getRoutePointsKey());
      if (routeJson != null) {
        final List<dynamic> decoded = json.decode(routeJson);
        final newPoints =
            decoded.map((point) => LatLng(point['lat'], point['lng'])).toList();

        if (newPoints.length != currentRoutePoints.length) {
          currentRoutePoints = newPoints;
          if (kDebugMode) {
            print('🔄 Synced ${newPoints.length} points from background');
          }
        }
      }

      // ✅ Refresh checkpoints
      final checkpointsJson = prefs.getString(_getCheckpointsKey());
      if (checkpointsJson != null) {
        final List<dynamic> decoded = json.decode(checkpointsJson);
        final newCheckpoints =
            decoded.map((item) {
              return AddressCheckpoint(
                location: LatLng(item['latitude'], item['longitude']),
                address: item['address'],
                timestamp: DateTime.parse(item['timestamp']),
                distanceFromPrevious:
                    (item['distanceFromPrevious'] ?? 0.0) as double,
                pointIndex: currentRoutePoints.length - 1,
              );
            }).toList();

        if (newCheckpoints.length != currentAddressCheckpoints.length) {
          currentAddressCheckpoints = newCheckpoints;
          if (kDebugMode) {
            print(
              '🔄 Synced ${newCheckpoints.length} checkpoints from background',
            );
          }
        }
      }

      _notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error refreshing: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final recordsJson = json.encode(
        trackingRecords.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_getRecordsKey(), recordsJson);

      await prefs.setBool(_getCheckedInKey(), isCheckedIn);
      await prefs.setString(_getCheckInTimeKey(), currentCheckInTime ?? '');
      await prefs.setString(
        _getCheckInAddressKey(),
        currentCheckInAddress ?? '',
      );

      if (currentCheckInLocation != null) {
        await prefs.setDouble(
          _getCheckInLatKey(),
          currentCheckInLocation!.latitude,
        );
        await prefs.setDouble(
          _getCheckInLngKey(),
          currentCheckInLocation!.longitude,
        );
      } else {
        await prefs.remove(_getCheckInLatKey());
        await prefs.remove(_getCheckInLngKey());
      }

      final routeJson = json.encode(
        currentRoutePoints
            .map((point) => {'lat': point.latitude, 'lng': point.longitude})
            .toList(),
      );
      await prefs.setString(_getRoutePointsKey(), routeJson);

      final checkpointsJson = json.encode(
        currentAddressCheckpoints
            .map(
              (c) => {
                'latitude': c.location.latitude,
                'longitude': c.location.longitude,
                'address': c.address,
                'timestamp': c.timestamp.toIso8601String(),
                'distanceFromPrevious': c.distanceFromPrevious ?? 0.0,
              },
            )
            .toList(),
      );
      await prefs.setString(_getCheckpointsKey(), checkpointsJson);

      if (kDebugMode) {
        print('💾 Saved ${currentRoutePoints.length} points');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error saving: $e');
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

    if (kDebugMode) print('✅ Checked in at: $address');
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

      // ✅ IMPROVED: Only add point if moved 10+ meters (ignore GPS drift)
      if (distance < MIN_POINT_DISTANCE) {
        if (kDebugMode) {
          print(
            '⏭️ Skipping point - only ${distance.toStringAsFixed(1)}m from last',
          );
        }
        return;
      }

      if (kDebugMode) {
        print(
          '📍 Point #${currentRoutePoints.length + 1} added (${distance.toStringAsFixed(1)}m from last)',
        );
      }
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

    // ✅ Require 100m movement AND different address
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

      if (kDebugMode) {
        print('🏠 Checkpoint #${currentAddressCheckpoints.length}: $address');
        print('   Distance: ${distance.toStringAsFixed(1)}m from last');
      }
      _saveData();
      _notifyListeners();
    }
  }

  void checkOut() {
    if (kDebugMode) {
      print('🔴 Checking out...');
      print('   Total points: ${currentRoutePoints.length}');
      print('   Total checkpoints: ${currentAddressCheckpoints.length}');
    }

    isCheckedIn = false;
    currentCheckInTime = null;
    currentCheckInLocation = null;
    currentCheckInAddress = null;
    currentRoutePoints.clear();
    currentAddressCheckpoints.clear();
    _saveData();
    _notifyListeners();
  }

  double getTotalDistance() {
    if (currentRoutePoints.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 1; i < currentRoutePoints.length; i++) {
      totalDistance += Geolocator.distanceBetween(
        currentRoutePoints[i - 1].latitude,
        currentRoutePoints[i - 1].longitude,
        currentRoutePoints[i].latitude,
        currentRoutePoints[i].longitude,
      );
    }
    return totalDistance;
  }

  // ✅ Call this every 3 seconds when app is in foreground
  Future<void> syncWithBackground() async {
    if (isCheckedIn) {
      await _refreshFromStorage();
    }
  }

  Future<void> clearCurrentUserData({bool clearHistory = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_getCheckedInKey());
      await prefs.remove(_getCheckInTimeKey());
      await prefs.remove(_getCheckInLatKey());
      await prefs.remove(_getCheckInLngKey());
      await prefs.remove(_getCheckInAddressKey());
      await prefs.remove(_getRoutePointsKey());
      await prefs.remove(_getCheckpointsKey());

      if (clearHistory) {
        await prefs.remove(_getRecordsKey());
        trackingRecords.clear();
      }

      isCheckedIn = false;
      currentCheckInTime = null;
      currentCheckInLocation = null;
      currentCheckInAddress = null;
      currentRoutePoints.clear();
      currentAddressCheckpoints.clear();

      if (kDebugMode) print('🧹 Cleared user data');
    } catch (e) {
      if (kDebugMode) print('❌ Error clearing: $e');
    }
  }
}

// ==================== USER TRACKING SCREEN ====================
class UserTrackingScreen extends StatefulWidget {
  const UserTrackingScreen({super.key});

  @override
  State<UserTrackingScreen> createState() => _UserTrackingScreenState();
}

class _UserTrackingScreenState extends State<UserTrackingScreen>
    with WidgetsBindingObserver {
  final TrackingManager _trackingManager = TrackingManager();
  final LocationService _locationService = LocationService();
  final BackgroundTrackingService _backgroundService =
      BackgroundTrackingService();

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};

  bool isLoadingLocation = false;
  bool isLoading = false;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    _trackingManager.addListener(_onTrackingStateChanged);

    _locationService.onLocationUpdate = (LatLng location) {
      _trackingManager.addLocationPoint(location);
    };

    _locationService.onAddressChange = (LatLng location, String address) {
      _trackingManager.addAddressCheckpoint(location, address);
    };

    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_trackingManager.isCheckedIn) {
        _trackingManager.syncWithBackground();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (kDebugMode) print('📱 App state: $state');

    if (state == AppLifecycleState.resumed) {
      if (_trackingManager.isCheckedIn) {
        _trackingManager.syncWithBackground();
        if (kDebugMode) print('🔄 Syncing from background...');
      }
    }
  }

  Future<void> _initializeApp() async {
    setState(() => isLoadingLocation = true);

    await _backgroundService.initializeService();

    final prefs = await SharedPreferences.getInstance();
    final empId =
        prefs.getString('logged_in_emp_id') ?? prefs.getString('employeeId');
    await _trackingManager.setUserId(empId);

    bool success = await _locationService.initLocationService();
    setState(() => isLoadingLocation = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission required')),
      );
    } else {
      _updateMapMarkersWithRoute();
    }
  }

  void _onTrackingStateChanged() {
    if (mounted) {
      setState(() {});
      _updateMapMarkersWithRoute();
    }
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
            title: '🟢 Check In',
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
          infoWindow: const InfoWindow(title: '📍 Current Location'),
        ),
      );

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
              title: '🏠 Stop ${i + 1}',
              snippet: checkpoint.address,
            ),
          ),
        );
      }

      if (_trackingManager.isCheckedIn &&
          _trackingManager.currentRoutePoints.length >= 2) {
        if (kDebugMode) {
          print(
            '🗺️ Drawing ${_trackingManager.currentRoutePoints.length} points',
          );
        }

        _polyLines.add(
          Polyline(
            polylineId: const PolylineId('tracking_route'),

            points: _trackingManager.currentRoutePoints,
            color: AppColor.primaryColor1, // ✅ CHANGE THIS LINE
            width: 5,
            geodesic: true,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        );
      }
    }

    if (mounted) setState(() {});
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

      await _backgroundService.startTracking();
      if (kDebugMode) print('🚀 Background tracking started');

      await _updateMapMarkersWithRoute();
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));

      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Checked in at $time\n🎯 Background tracking active',
              style: const TextStyle(fontFamily: AppFonts.poppins),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
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
      await _backgroundService.stopTracking();
      if (kDebugMode) print('🛑 Background tracking stopped');

      await _trackingManager.syncWithBackground();

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
      final totalDistance = _trackingManager.getTotalDistance();

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

      if (kDebugMode) {
        print('📊 Check-out Summary:');
        print('   - Total points: ${newRecord.routePoints?.length}');
        print('   - Checkpoints: ${newRecord.addressCheckpoints?.length}');
        print('   - Distance: ${(totalDistance / 1000).toStringAsFixed(2)} km');
      }

      _trackingManager.addRecord(newRecord);
      _trackingManager.checkOut();

      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Checked out at ${newRecord.checkOutTime}\n${(totalDistance / 1000).toStringAsFixed(2)} km traveled',
              style: const TextStyle(fontFamily: AppFonts.poppins),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
    final totalDistance = _trackingManager.getTotalDistance();

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
                          '${_trackingManager.currentRoutePoints.length} points • ${_trackingManager.currentAddressCheckpoints.length} places • ${(totalDistance / 1000).toStringAsFixed(2)} km',
                          style: const TextStyle(
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
                        onPressed:
                            isLoading
                                ? null
                                : () async {
                                  // Check location permissions first
                                  bool serviceEnabled =
                                      await Geolocator.isLocationServiceEnabled();
                                  if (!serviceEnabled) {
                                    _showLocationRequiredDialog(
                                      title: 'Location Service Disabled',
                                      message:
                                          'Please enable location services to check in',
                                      isServiceIssue: true,
                                    );
                                    return;
                                  }

                                  LocationPermission permission =
                                      await Geolocator.checkPermission();
                                  if (permission == LocationPermission.denied) {
                                    permission =
                                        await Geolocator.requestPermission();
                                    if (permission ==
                                        LocationPermission.denied) {
                                      _showLocationRequiredDialog(
                                        title: 'Location Permission Denied',
                                        message:
                                            'Location permission is required',
                                        isServiceIssue: false,
                                      );
                                      return;
                                    }
                                  }

                                  if (permission ==
                                      LocationPermission.deniedForever) {
                                    _showLocationRequiredDialog(
                                      title: 'Location Permission Required',
                                      message:
                                          'Please enable location from settings',
                                      isServiceIssue: false,
                                      showSettings: true,
                                    );
                                    return;
                                  }

                                  // ✅ CHECK IF FACE ALREADY VERIFIED TODAY
                                  final hasVerified =
                                      await _hasFaceVerifiedToday();

                                  if (hasVerified) {
                                    // ✅ SKIP FACE ID - DIRECT CHECK-IN
                                    if (kDebugMode) {
                                      print('⏭️ Skipping face verification');
                                    }
                                    await _performActualCheckIn();
                                  } else {
                                    // ✅ SHOW FACE ID FOR FIRST CHECK-IN OF THE DAY
                                    if (kDebugMode) {
                                      print('📸 Showing face verification');
                                    }

                                    final result = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (
                                              context,
                                            ) => FaceIdentificationScreen(
                                              employeeId:
                                                  'EMP001', // Replace with actual
                                              employeeName:
                                                  'John Doe', // Replace with actual
                                              isCheckIn: true,
                                            ),
                                      ),
                                    );

                                    // If face verified successfully
                                    if (result == true && mounted) {
                                      // Mark as verified for today
                                      await _markFaceVerifiedToday();

                                      // Perform check-in
                                      await _performActualCheckIn();
                                    }
                                  }
                                },
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
                      onMapCreated: (controller) => _mapController = controller,
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
    WidgetsBinding.instance.removeObserver(this);
    _syncTimer?.cancel();
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
              onPressed: () => Navigator.of(context).pop(),
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
                  await Geolocator.openAppSettings();
                } else if (isServiceIssue) {
                  await Geolocator.openLocationSettings();
                } else {
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

  // NEW METHOD IN UserTrackingScreen
  Future<void> _performActualCheckIn() async {
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
      // Get location
      LatLng? location = await _locationService.getLocationOnce();
      if (location == null) {
        throw Exception('Could not fetch your current location');
      }

      // Get address
      String address = await _locationService.getAddressFromLocation(location);
      final now = DateTime.now();
      final formatter = DateFormat('hh:mm a');
      final time = formatter.format(now);

      // Save check-in data
      _trackingManager.checkIn(time, location, address);

      // Start background tracking
      await _backgroundService.startTracking();
      if (kDebugMode) print('🚀 Background tracking started');

      // Update map
      await _updateMapMarkersWithRoute();
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));

      setState(() => isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Checked in successfully at $time\n🎯 Tracking active',
              style: const TextStyle(fontFamily: AppFonts.poppins),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
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

  // Skip Face ID After First Verification
  Future<bool> _hasFaceVerifiedToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final lastVerifiedDate = prefs.getString('last_face_verified_date');

      if (lastVerifiedDate == today) {
        if (kDebugMode) print('✅ Face already verified today');
        return true;
      }

      if (kDebugMode) {
        print('⚠️ Face verification needed (last: $lastVerifiedDate)');
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking face verification: $e');
      return false;
    }
  }

  Future<void> _markFaceVerifiedToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await prefs.setString('last_face_verified_date', today);
      if (kDebugMode) print('✅ Marked face verified for: $today');
    } catch (e) {
      if (kDebugMode) print('❌ Error marking face verified: $e');
    }
  }

}
