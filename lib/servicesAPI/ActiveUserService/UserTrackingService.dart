import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/UserTrackingModel/GetLocationHistoryModel.dart';
import '../../model/UserTrackingModel/SaveLoactionModel.dart';

class TrackingApiService {
  static const String baseUrl = "http://192.168.0.100/hrms/tracking/";
  static const String saveLocationEndpoint = "${baseUrl}save_location";
  static const String getLocationHistoryEndpoint =
      "${baseUrl}get_location_history";
  static const String saveBatchEndpoint = "${baseUrl}save_location_batch";

  static const Duration timeout = Duration(seconds: 30);

  // ==================== TOKEN ====================
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (kDebugMode) print("🔑 Token: $token");

    return token;
  }

  // ==================== API HEALTH CHECK ====================
  static Future<bool> testConnection() async {
    try {
      final token = await _getToken();
      final pingUrl =
          "${baseUrl}get_location_history"; // must be a valid endpoint

      final response = await http
          .get(
            Uri.parse(pingUrl),
            headers: {
              "Accept": "application/json",
              if (token != null) "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) print("🌐 API Ping Status: ${response.statusCode}");

      return response.statusCode == 200 || response.statusCode == 401;
    } catch (e) {
      if (kDebugMode) print("❌ API Ping failed: $e");
      return false;
    }
  }

  // ==================== SAVE SINGLE LOCATION ====================
  static Future<SaveLocationModel> saveLocation({
    required String userId,
    required String roleId,
    required String username,
    required String email,
    required String fullname,
    required String avatar,
    required String designationsId,
    required String activityType,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String locationAddress,
    String? zoneId,
    String? branchId,
    String? remarks,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("Token missing");

      final deviceId = await _getDeviceId();
      final batteryLevel = await _getBatteryLevel();
      final networkType = await _getNetworkType();

      final payload = {
        'user_id': userId,
        'role_id': roleId,
        'username': username,
        'email': email,
        'fullname': fullname,
        'avatar': avatar,
        'designations_id': designationsId,
        'activity_type': activityType,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'captured_at': DateTime.now().toIso8601String(),
        'device_time': DateTime.now().toIso8601String(),
        'location_address': locationAddress,
        'device_id': deviceId,
        'battery_level': batteryLevel,
        'network_type': networkType,
        if (zoneId != null) 'zone_id': zoneId,
        if (branchId != null) 'branch_id': branchId,
        if (remarks != null) 'remarks': remarks,
      };

      if (kDebugMode) {
        print("📤 Sending payload to API:");
        print(jsonEncode(payload));
      }

      final response = await http
          .post(
            Uri.parse(saveLocationEndpoint),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(payload),
          )
          .timeout(timeout);

      if (kDebugMode) {
        print("📥 Response status: ${response.statusCode}");
        print("📥 Response body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SaveLocationModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Save failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      if (kDebugMode) print("❌ saveLocation error: $e");
      rethrow;
    }
  }

  // ==================== GET LOCATION HISTORY ====================
  static Future<GetLocationHistoryModel> getLocationHistory({
    required String? userId,
    String? activityType,
    String? fromDate,
    String? toDate,
    int page = 1,
    int perPage = 50,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception("No token");

    final queryParams = {
      'user_id': userId,
      if (activityType != null) 'activity_type': activityType,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    final uri = Uri.parse(
      getLocationHistoryEndpoint,
    ).replace(queryParameters: queryParams);

    if (kDebugMode) print("🌐 GET Location History URI: $uri");

    final response = await http
        .get(
          uri,
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        )
        .timeout(timeout);

    if (kDebugMode) {
      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");
    }

    if (response.statusCode == 200) {
      return GetLocationHistoryModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("History error ${response.statusCode} ${response.body}");
    }
  }

  // ==================== BATCH SAVE LOCATIONS ====================
  static Future<Map<String, dynamic>> saveBatchLocations({
    required String userId,
    required String roleId,
    required String username,
    required String email,
    required String fullname,
    required String avatar,
    required String designationsId,
    required List<Map<String, dynamic>> locations,
    String? zoneId,
    String? branchId,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception("Token missing");

    final payload = {
      "user_id": userId,
      "role_id": roleId,
      "username": username,
      "email": email,
      "fullname": fullname,
      "avatar": avatar,
      "designations_id": designationsId,
      if (zoneId != null) "zone_id": zoneId,
      if (branchId != null) "branch_id": branchId,
      "locations": locations,
    };

    if (kDebugMode) {
      print("📤 Sending batch payload:");
      print(jsonEncode(payload));
    }

    final response = await http
        .post(
          Uri.parse(saveBatchEndpoint),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode(payload),
        )
        .timeout(timeout);

    if (kDebugMode) {
      print("📥 Batch response status: ${response.statusCode}");
      print("📥 Batch response body: ${response.body}");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        "successCount": data["success_count"] ?? locations.length,
        "failCount": data["fail_count"] ?? 0,
      };
    } else {
      throw Exception(
        "Batch save failed: ${response.statusCode} ${response.body}",
      );
    }
  }

  // ==================== HELPERS ====================
  static Future<String> _getDeviceId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      return android.id;
    }
    if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return ios.identifierForVendor ?? "IOS";
    }
    return "UNKNOWN";
  }

  static Future<int> _getBatteryLevel() async {
    try {
      return await Battery().batteryLevel;
    } catch (_) {
      return 0;
    }
  }

  static Future<String> _getNetworkType() async {
    final result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.mobile) return "MOBILE";
    if (result == ConnectivityResult.wifi) return "WIFI";
    return "UNKNOWN";
  }
}
