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

class BackgroundTrackingService {
  static final BackgroundTrackingService _instance =
      BackgroundTrackingService._internal();
  factory BackgroundTrackingService() => _instance;
  BackgroundTrackingService._internal();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ✅ API Configuration
  static const String apiBaseUrl = "http://192.168.0.100/hrms/tracking/";
  static const String saveLocationEndpoint = "${apiBaseUrl}save_location";

  // ================= INITIALIZE =================
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

  // ================= START =================
  Future<void> startTracking() async {
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      await service.startService();
      if (kDebugMode) print('✅ Background tracking started');
    }
  }

  // ================= STOP =================
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

  // ================= BACKGROUND ENGINE =================
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    // ✅ Load user info
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

    // ✅ Load all user info for API
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
      print('   Username: $username');
      print('   Email: $email');
    }

    StreamSubscription<Position>? gpsStream;
    Timer? apiSyncTimer;
    Timer? notificationTimer;
    Timer? localSaveTimer;

    List<Map<String, dynamic>> routePoints = [];
    List<Map<String, dynamic>> pendingApiCalls = [];
    int totalPointsSaved = 0;
    int apiSuccessCount = 0;
    int apiFailCount = 0;
    String? lastKnownAddress;

    // Track last position to detect real movement
    double? lastLat;
    double? lastLng;
    int gpsUpdateCount = 0;

    // ===== GPS TRACKING =====
    gpsStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20, // ← Trigger updates every 20 meters
      ),
    ).listen((position) async {
      // ✅ Check if actually moved 20+ meters (matching distanceFilter)
      if (lastLat != null && lastLng != null) {
        final distance = Geolocator.distanceBetween(
          lastLat!,
          lastLng!,
          position.latitude,
          position.longitude,
        );

        // Ignore GPS drift
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

      // Add to local route points
      final point = {
        "lat": position.latitude,
        "lng": position.longitude,
        "accuracy": position.accuracy,
        "time": DateTime.now().toIso8601String(),
      };

      routePoints.add(point);
      totalPointsSaved++;

      // ✅ Save to SharedPreferences
      await prefs.setString('route_points_$userId', json.encode(routePoints));

      if (kDebugMode && gpsUpdateCount % 5 == 0) {
        print('📍 Background GPS Update #$gpsUpdateCount');
        print(
          '   Position: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        );
        print('   Accuracy: ${position.accuracy.toStringAsFixed(1)}m');
        print('   Total points: $totalPointsSaved');
      }

      // ✅ Get address every 5 real movements
      if (gpsUpdateCount % 5 == 0) {
        try {
          final places = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (places.isNotEmpty) {
            final place = places.first;
            lastKnownAddress = [
              place.name,
              place.street,
              place.locality,
              place.administrativeArea,
            ].where((e) => e != null && e.isNotEmpty).join(', ');
          }
        } catch (e) {
          if (kDebugMode) print('❌ Address error: $e');
        }
      }
    });

    // ===== API SYNC EVERY 5 MINUTES =====
    apiSyncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (routePoints.isEmpty) {
        if (kDebugMode) print('⏭️ No points to sync');
        return;
      }

      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );

        String address = lastKnownAddress ?? "Unknown location";

        // ✅ Prepare API payload
        final payload = {
          "user_id": userId,
          "role_id": roleId,
          "username": username,
          "email": email,
          "fullname": fullname,
          "avatar": avatar,
          "designations_id": designationsId,
          "activity_type": "ROUTE_POINT",
          "latitude": pos.latitude,
          "longitude": pos.longitude,
          "accuracy": pos.accuracy,
          "captured_at": DateTime.now().toIso8601String(),
          "device_time": DateTime.now().toIso8601String(),
          "location_address": address,
          "device_id": "BACKGROUND_SERVICE",
          "battery_level": 0, // Can be enhanced with battery_plus
          "network_type": "MOBILE", // Can be enhanced with connectivity_plus
          if (zoneId != null) "zone_id": zoneId,
          if (branchId != null) "branch_id": branchId,
          "remarks": "Background tracking sync - ${routePoints.length} points",
        };

        if (kDebugMode) {
          print('📤 Background API Sync:');
          print('   Endpoint: $saveLocationEndpoint');
          print('   Points to sync: ${routePoints.length}');
          print('   Location: ${pos.latitude}, ${pos.longitude}');
          print('   Address: $address');
        }

        // ✅ Make API call
        final response = await http
            .post(
              Uri.parse(saveLocationEndpoint),
              headers: {
                "Content-Type": "application/json",
                "Accept": "application/json",
              },
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 30));

        if (kDebugMode) {
          print('📥 Background API Response: ${response.statusCode}');
          print('📥 Body: ${response.body}');
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          apiSuccessCount++;

          // Clear synced points
          routePoints.clear();
          await prefs.setString(
            'route_points_$userId',
            json.encode(routePoints),
          );

          if (kDebugMode) {
            print('✅ Background API sync successful');
            print('   Success count: $apiSuccessCount');
          }
        } else {
          throw Exception('API returned ${response.statusCode}');
        }
      } catch (e) {
        apiFailCount++;

        if (kDebugMode) {
          print('❌ Background API sync failed: $e');
          print('   Fail count: $apiFailCount');
        }

        // Store failed call for retry
        pendingApiCalls.add({
          'timestamp': DateTime.now().toIso8601String(),
          'error': e.toString(),
          'points_count': routePoints.length,
        });

        // ✅ Retry logic: Try to sync pending calls
        if (pendingApiCalls.length > 3) {
          if (kDebugMode)
            print(
              '⚠️ Too many pending API calls (${pendingApiCalls.length}), clearing old ones',
            );
          pendingApiCalls = pendingApiCalls.sublist(pendingApiCalls.length - 3);
        }
      }
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

    // ===== UPDATE NOTIFICATION EVERY 30 SECONDS =====
    notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      FlutterLocalNotificationsPlugin().show(
        888,
        "🎯 Tracking Active",
        "📍 Points: $totalPointsSaved | ✅ API: $apiSuccessCount | ❌ Fails: $apiFailCount",
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
