import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../apibaseScreen/Api_Base_Screens.dart';
import '../servicesAPI/APIHelper/ApiHelper.dart';

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
      importance: Importance.max,
      playSound: false,
      enableVibration: false,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await notificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
        notificationChannelId: 'tracking_channel',
        initialNotificationTitle: 'Tracking Active',
        initialNotificationContent: 'Location tracking running',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<void> startTracking() async {
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      await service.startService();
      if (kDebugMode) print('✅ Background tracking started');
    }
  }

  Future<void> stopTracking() async {
    final service = FlutterBackgroundService();
    service.invoke("stopService");
    if (kDebugMode) print('🛑 Background tracking stopped');
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

    final prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getString('employeeId') ??
        prefs.getString('logged_in_emp_id') ??
        prefs.getString('user_id');

    if (userId == null) {
      if (kDebugMode) print('❌ No user ID found, stopping background service');
      service.stopSelf();
      return;
    }

    final roleId = prefs.getString('role_id') ?? '1';
    final username =
        prefs.getString('username') ?? prefs.getString('emp_name') ?? 'User';
    final email =
        prefs.getString('email') ??
        prefs.getString('emp_email') ??
        'user@example.com';
    final fullname =
        prefs.getString('fullname') ??
        prefs.getString('emp_fullname') ??
        username;
    final avatar =
        prefs.getString('avatar') ?? prefs.getString('profile_pic') ?? '';
    final designationsId =
        prefs.getString('designation_id') ??
        prefs.getString('designations_id') ??
        '1';
    final zoneId = prefs.getString('zone_id');
    final branchId = prefs.getString('branch_id');

    if (kDebugMode) {
      print('✅ Background service started for user: $userId');
      print('   Role ID: $roleId, Designation: $designationsId');
    }

    StreamSubscription<Position>? gpsStream;
    Timer? apiSyncTimer;
    Timer? notificationTimer;
    Timer? localSaveTimer;

    List<Map<String, dynamic>> routePoints = [];
    int totalPointsSaved = 0;
    int apiSuccessCount = 0;
    int apiFailCount = 0;
    String? lastKnownAddress;

    double? lastLat;
    double? lastLng;
    int gpsUpdateCount = 0;

    Map<String, String> addressCache = {};

    // ===== GPS TRACKING =====
    gpsStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((position) async {
      if (lastLat != null && lastLng != null) {
        final distance = Geolocator.distanceBetween(
          lastLat!,
          lastLng!,
          position.latitude,
          position.longitude,
        );

        if (distance < 20.0) {
          if (kDebugMode && gpsUpdateCount % 20 == 0) {
            print(
              '⏭️ Background: Ignoring GPS drift (${distance.toStringAsFixed(1)}m)',
            );
          }
          return;
        }
      }

      gpsUpdateCount++;
      lastLat = position.latitude;
      lastLng = position.longitude;

      // ✅ Fetch address
      String address = lastKnownAddress ?? "Unknown location";
      final cacheKey =
          '${position.latitude.toStringAsFixed(4)},${position.longitude.toStringAsFixed(4)}';

      if (addressCache.containsKey(cacheKey)) {
        address = addressCache[cacheKey]!;
      } else {
        try {
          final places = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (places.isNotEmpty) {
            final place = places.first;
            address = [
              place.name,
              place.street,
              place.locality,
              place.administrativeArea,
            ].where((e) => e != null && e.isNotEmpty).join(', ');

            addressCache[cacheKey] = address;
            lastKnownAddress = address;

            if (kDebugMode) {
              print('🏠 New address: $address');
            }
          }
        } catch (e) {
          if (kDebugMode) print('❌ Address fetch error: $e');
        }
      }

      // ✅ Store point WITH address
      final point = {
        "lat": position.latitude,
        "lng": position.longitude,
        "accuracy": position.accuracy,
        "time": DateTime.now().toIso8601String(),
        "address": address,
      };

      routePoints.add(point);
      totalPointsSaved++;

      await prefs.setString('route_points_$userId', json.encode(routePoints));

      if (kDebugMode && gpsUpdateCount % 5 == 0) {
        print('📍 Background GPS Update #$gpsUpdateCount');
        print(
          '   Position: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        );
        print('   Accuracy: ${position.accuracy.toStringAsFixed(1)}m');
        print('   Address: $address');
        print('   Total points: $totalPointsSaved');
      }
    });

    // ===== API SYNC EVERY 5 MINUTES =====
    apiSyncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (routePoints.isEmpty) {
        if (kDebugMode) print('⏭️ No points to sync');
        return;
      }

      if (kDebugMode) {
        print('📤 Starting Background API Sync');
        print('   Total points to sync: ${routePoints.length}');
      }

      int successCount = 0;
      int failCount = 0;
      List<Map<String, dynamic>> failedPoints = [];

      // ✅ Send EACH point individually
      for (var i = 0; i < routePoints.length; i++) {
        final point = routePoints[i];

        // 🔥 FIX: Convert numbers to strings for backend compatibility
        final payload = {
          "user_id": userId,
          "role_id": roleId,
          "username": username,
          "email": email,
          "fullname": fullname,
          "avatar": avatar,
          "designations_id": designationsId,
          "activity_type": "ROUTE_POINT",
          "latitude": point['lat'].toString(), // 🔥 Convert to string
          "longitude": point['lng'].toString(), // 🔥 Convert to string
          "accuracy": point['accuracy'].toString(), // 🔥 Convert to string
          "captured_at": point['time'],
          "device_time": point['time'],
          "location_address": point['address'] ?? "Unknown location",
          "device_id": "BACKGROUND_SERVICE",
          "battery_level": 0,
          "network_type": "MOBILE",
          if (zoneId != null) "zone_id": zoneId,
          if (branchId != null) "branch_id": branchId,
          "remarks": "Route point ${i + 1}/${routePoints.length}",
        };

        try {
          if (kDebugMode && i == 0) {
            if (kDebugMode) {
              print('📤 Sample payload:');
            }
            print(json.encode(payload));
          }

          final response = await ApiHelper.post(
            Uri.parse(ApiBase.saveLocation),
            payload,
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            successCount++;

            if (kDebugMode && i % 10 == 0) {
              print(
                '✅ Point ${i + 1}/${routePoints.length} synced: ${point['address']}',
              );
            }
          } else {
            failCount++;
            failedPoints.add(point);

            if (kDebugMode) {
              print('❌ Point ${i + 1} failed: ${response.statusCode}');
              print('   Response: ${response.body}');
            }
          }
        } catch (e) {
          failCount++;
          failedPoints.add(point);

          if (kDebugMode) {
            print('❌ Point ${i + 1} error: $e');
          }
        }

        // ✅ Delay between requests
        if (i < routePoints.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      if (kDebugMode) {
        print('📊 Background API Sync Complete:');
        print('   Success: $successCount/${routePoints.length}');
        print('   Failed: $failCount/${routePoints.length}');
      }

      apiSuccessCount += successCount;
      apiFailCount += failCount;

      // ✅ Keep only failed points for retry
      if (failedPoints.isEmpty) {
        routePoints.clear();
      } else {
        routePoints = failedPoints;
        if (kDebugMode) {
          print('⚠️ Keeping ${failedPoints.length} failed points for retry');
        }
      }

      await prefs.setString('route_points_$userId', json.encode(routePoints));
    });

    // ===== LOCAL SAVE EVERY 30 SECONDS =====
    localSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (routePoints.isNotEmpty) {
        await prefs.setString('route_points_$userId', json.encode(routePoints));

        if (kDebugMode && routePoints.length % 10 == 0) {
          print('💾 Local save: ${routePoints.length} points');
        }
      }
    });

    // ===== UPDATE NOTIFICATION =====
    notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final uniqueAddresses = addressCache.values.toSet().length;

      FlutterLocalNotificationsPlugin().show(
        888,
        "🎯 Tracking Active",
        "📍 ${totalPointsSaved} points • 🏠 ${uniqueAddresses} places • ✅ ${apiSuccessCount} synced • ❌ ${apiFailCount} failed",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tracking_channel',
            'Location Tracking',
            icon: '@mipmap/ic_launcher',
            ongoing: true,
            autoCancel: false,
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });

    // ===== STOP SERVICE HANDLER =====
    service.on("stopService").listen((event) {
      if (kDebugMode) {
        print('🛑 Background service stopping');
        print('   Total points collected: $totalPointsSaved');
        print('   Unique places: ${addressCache.values.toSet().length}');
        print('   API success: $apiSuccessCount');
        print('   API fails: $apiFailCount');
      }

      gpsStream?.cancel();
      apiSyncTimer?.cancel();
      notificationTimer?.cancel();
      localSaveTimer?.cancel();

      service.stopSelf();
    });

    // ===== INITIAL NOTIFICATION =====
    FlutterLocalNotificationsPlugin().show(
      888,
      "🎯 Tracking Started",
      "📍 Background location tracking is active",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tracking_channel',
          'Location Tracking',
          icon: '@mipmap/ic_launcher',
          ongoing: true,
          autoCancel: false,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
