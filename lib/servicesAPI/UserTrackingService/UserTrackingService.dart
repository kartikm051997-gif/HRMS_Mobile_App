import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../apibaseScreen/Api_Base_Screens.dart';
import '../../model/UserTrackingModel/GetLocationHistoryModel.dart';
import '../../model/UserTrackingModel/SaveLoactionModel.dart';
import '../APIHelper/ApiHelper.dart';

class TrackingApiService {
  // ==================== API HEALTH CHECK ====================
  static Future<bool> testConnection() async {
    try {
      final response = await ApiHelper.get(
        Uri.parse(ApiBase.getLocationHistory),
      );

      if (kDebugMode) {
        print("🌐 API Ping Status: ${response.statusCode}");
      }

      return response.statusCode == 200;
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
        print("📤 Tracking payload:");
        print(jsonEncode(payload));
      }

      final response = await ApiHelper.post(
        Uri.parse(ApiBase.saveLocation), // ✅ HERE
        payload,
      );

      if (kDebugMode) {
        print("📥 Response: ${response.statusCode}");
        print("📥 Body: ${response.body}");
      }

      return SaveLocationModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      if (kDebugMode) print("❌ saveLocation failed: $e");
      rethrow;
    }
  }

  // ==================== GET LOCATION HISTORY ====================
  static Future<GetLocationHistoryModel> getLocationHistory({
    required String userId,
    String? activityType,
    String? fromDate,
    String? toDate,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final uri = Uri.parse(ApiBase.getLocationHistory).replace(
        // ✅ HERE
        queryParameters: {
          "user_id": userId,
          if (activityType != null) "activity_type": activityType,
          if (fromDate != null) "from_date": fromDate,
          if (toDate != null) "to_date": toDate,
          "page": page.toString(),
          "per_page": perPage.toString(),
        },
      );

      if (kDebugMode) print("🌐 Tracking history URI: $uri");

      final response = await ApiHelper.get(uri);

      return GetLocationHistoryModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      if (kDebugMode) print("❌ getLocationHistory failed: $e");
      rethrow;
    }
  }

  // ==================== BATCH SAVE ====================
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
    try {
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

      final response = await ApiHelper.post(
        Uri.parse(ApiBase.saveLocationBatch),
        payload,
      );

      final data = jsonDecode(response.body);
      return {
        "successCount": data["success_count"] ?? locations.length,
        "failCount": data["fail_count"] ?? 0,
      };
    } catch (e) {
      if (kDebugMode) print("❌ Batch save failed: $e");
      rethrow;
    }
  }

  // ==================== DEVICE HELPERS ====================
  static Future<String> _getDeviceId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) return (await info.androidInfo).id;
    if (Platform.isIOS) {
      return (await info.iosInfo).identifierForVendor ?? "IOS";
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
