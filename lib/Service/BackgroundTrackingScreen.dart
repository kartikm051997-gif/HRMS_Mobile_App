import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundTrackingService {
  static final BackgroundTrackingService _instance =
  BackgroundTrackingService._internal();
  factory BackgroundTrackingService() => _instance;
  BackgroundTrackingService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // ✅ Create notification channel FIRST
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tracking_channel',
      'Location Tracking',
      description: 'Tracking your location in background',
      importance: Importance.max, // ← Changed to MAX
      playSound: false,
      enableVibration: false,
      showBadge: true,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // ✅ Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await notificationsPlugin.initialize(initializationSettings);

    // ✅ Configure service with proper settings
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true, // ← CRITICAL: Must be true
        notificationChannelId: 'tracking_channel',
        initialNotificationTitle: '🎯 Location Tracking Active',
        initialNotificationContent: 'Recording your route...',
        foregroundServiceNotificationId: 888,
        autoStartOnBoot: true,
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

    // ✅ Check if service is already running
    bool isRunning = await service.isRunning();

    if (!isRunning) {
      // ✅ Save tracking state BEFORE starting service
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('employeeId') ??
          prefs.getString('logged_in_emp_id');

      if (userId != null) {
        await prefs.setBool('is_checked_in_$userId', true);
        await prefs.setString('tracking_start_time',
            DateTime.now().toIso8601String());
        if (kDebugMode) print('✅ Saved tracking state for user: $userId');
      }

      await service.startService();
      if (kDebugMode) print('🚀 Background tracking service started');

      // ✅ Verify service started
      await Future.delayed(const Duration(seconds: 1));
      bool verified = await service.isRunning();
      if (kDebugMode) print('✅ Service running: $verified');
    } else {
      if (kDebugMode) print('⚠️ Service already running');
    }
  }

  Future<void> stopTracking() async {
    final service = FlutterBackgroundService();

    // ✅ Clear tracking state BEFORE stopping
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('employeeId') ??
        prefs.getString('logged_in_emp_id');

    if (userId != null) {
      await prefs.setBool('is_checked_in_$userId', false);
      if (kDebugMode) print('✅ Cleared tracking state');
    }

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

    if (kDebugMode) {
      print('🎯 Background service STARTED - Independent Process');
      print('📅 Service started at: ${DateTime.now()}');
    }

    final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

    // ✅ Initialize notifications in background isolate
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(initializationSettings);

    StreamSubscription<Position>? positionStream;
    Timer? addressCheckTimer;
    Timer? healthCheckTimer;
    Timer? persistenceTimer; // ✅ NEW: Keep service alive
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

      // ✅ Location settings: 20 meters threshold
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20, // ← Trigger every 20 meters
        timeLimit: Duration(seconds: 30),
      );

      // ✅ Start location tracking
      positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
            (Position position) async {
          try {
            lastUpdateTime = DateTime.now();

            // ✅ Check movement threshold (20 meters)
            if (lastSavedLat != null && lastSavedLng != null) {
              final distanceFromLast = Geolocator.distanceBetween(
                lastSavedLat!,
                lastSavedLng!,
                position.latitude,
                position.longitude,
              );

              // ✅ Skip if less than 20 meters (GPS drift)
              if (distanceFromLast < 20.0) {
                if (kDebugMode && pointCount % 10 == 0) {
                  print('⏭️ Skipping GPS drift: ${distanceFromLast.toStringAsFixed(1)}m');
                }
                return;
              }
            }

            // ✅ Save to SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            final routeKey = 'route_points_$userId';

            List<Map<String, double>> routePoints = [];
            final routeJson = prefs.getString(routeKey);

            if (routeJson != null) {
              try {
                final decoded = json.decode(routeJson) as List;
                routePoints = decoded
                    .map((p) => {
                  'lat': p['lat'] as double,
                  'lng': p['lng'] as double,
                })
                    .toList();
              } catch (e) {
                if (kDebugMode) print('⚠️ Error decoding route: $e');
                routePoints = [];
              }
            }

            // ✅ Add new point with timestamp
            routePoints.add({
              'lat': position.latitude,
              'lng': position.longitude,
            });

            // ✅ Save immediately with error handling
            try {
              await prefs.setString(routeKey, json.encode(routePoints));
              await prefs.setString(
                'last_tracking_update_$userId',
                DateTime.now().toIso8601String(),
              );

              lastSavedLat = position.latitude;
              lastSavedLng = position.longitude;
              pointCount++;

              if (kDebugMode) {
                print('📍 BG Service: Point #$pointCount saved');
                print('   Location: ${position.latitude.toStringAsFixed(6)}, '
                    '${position.longitude.toStringAsFixed(6)}');
                print('   Total stored: ${routePoints.length}');
              }
            } catch (e) {
              if (kDebugMode) print('❌ Error saving point: $e');
            }

            // ✅ Update notification with current status
            final distance = await _calculateDistance(routePoints);
            await notificationsPlugin.show(
              888,
              '🎯 Tracking Active',
              '${routePoints.length} points • ${distance.toStringAsFixed(2)} km • '
                  'Updated ${_getTimeAgo(lastUpdateTime!)}',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'tracking_channel',
                  'Location Tracking',
                  icon: '@mipmap/ic_launcher',
                  ongoing: true, // ← CRITICAL: Keeps notification persistent
                  autoCancel: false,
                  playSound: false,
                  priority: Priority.max, // ← Changed to max
                  importance: Importance.max, // ← Changed to max
                  enableVibration: false,
                  showWhen: true,
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
        cancelOnError: false,
      );

      // ✅ Address checkpoint tracking (every 60 seconds)
      addressCheckTimer = Timer.periodic(
        const Duration(seconds: 60),
            (timer) async {
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

                  await prefs.setString(
                      checkpointsKey, json.encode(checkpoints));
                  lastAddress = currentAddress;

                  if (kDebugMode) {
                    print('🏠 BG Checkpoint #${checkpoints.length}: $currentAddress');
                  }
                }
              }
            }
          } catch (e) {
            if (kDebugMode) print('❌ Address check error: $e');
          }
        },
      );

      // ✅ Health check timer (every 2 minutes)
      healthCheckTimer = Timer.periodic(
        const Duration(minutes: 2),
            (timer) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final isStillCheckedIn =
                prefs.getBool('is_checked_in_$userId') ?? false;

            if (!isStillCheckedIn) {
              if (kDebugMode) print('✅ User checked out, stopping service');
              positionStream?.cancel();
              addressCheckTimer?.cancel();
              persistenceTimer?.cancel();
              timer.cancel();
              service.stopSelf();
              return;
            }

            if (lastUpdateTime != null) {
              final timeSinceLastUpdate =
              DateTime.now().difference(lastUpdateTime!);
              if (timeSinceLastUpdate.inMinutes > 5) {
                if (kDebugMode) {
                  print('⚠️ No location updates for '
                      '${timeSinceLastUpdate.inMinutes} minutes');
                }
              }
            }

            if (kDebugMode) {
              print('💓 Health Check: Service alive, $pointCount points saved');
            }
          } catch (e) {
            if (kDebugMode) print('❌ Health check error: $e');
          }
        },
      );

      // ✅ NEW: Persistence timer - keeps service alive
      persistenceTimer = Timer.periodic(
        const Duration(seconds: 30),
            (timer) async {
          try {
            // Update notification to keep service alive
            await notificationsPlugin.show(
              888,
              '🎯 Tracking Active',
              'Service running • $pointCount points tracked',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'tracking_channel',
                  'Location Tracking',
                  icon: '@mipmap/ic_launcher',
                  ongoing: true,
                  autoCancel: false,
                  playSound: false,
                  priority: Priority.max,
                  importance: Importance.max,
                  enableVibration: false,
                  showWhen: true,
                ),
              ),
            );
          } catch (e) {
            if (kDebugMode) print('❌ Persistence update error: $e');
          }
        },
      );

      // ✅ Stop service command
      service.on('stopService').listen((event) {
        if (kDebugMode) print('🛑 Stop command received');
        positionStream?.cancel();
        addressCheckTimer?.cancel();
        healthCheckTimer?.cancel();
        persistenceTimer?.cancel();
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