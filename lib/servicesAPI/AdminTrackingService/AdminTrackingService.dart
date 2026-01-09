import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apibaseScreen/Api_Base_Screens.dart';
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../model/UserTrackingModel/GetLocationHistoryModel.dart';

class AdminTrackingService {
  static final AdminTrackingService _instance =
  AdminTrackingService._internal();

  factory AdminTrackingService() => _instance;
  AdminTrackingService._internal();

  static const Duration _timeout = Duration(seconds: 30);

  // ═══════════════════════════════════════════════════════
  // HELPER METHOD - Clean Response Body
  // ═══════════════════════════════════════════════════════

  String _cleanResponseBody(String rawBody) {
    String cleaned = rawBody.trim();

    // Remove any leading asterisks or special characters before JSON starts
    while (cleaned.isNotEmpty &&
        !cleaned.startsWith('{') &&
        !cleaned.startsWith('[')) {
      cleaned = cleaned.substring(1);
    }

    if (kDebugMode && rawBody != cleaned) {
      print("⚠️ Cleaned response body (removed ${rawBody.length - cleaned.length} leading characters)");
    }

    return cleaned;
  }

  // ═══════════════════════════════════════════════════════
  // 1️⃣ GET ALL FILTER DATA
  // ═══════════════════════════════════════════════════════

  Future<GetAllFilters?> getAllEmployees({required String token}) async {
    try {
      final uri = Uri.parse(ApiBase.getAllFilters);

      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("🔄 Fetching filters");
        print("🔗 URL: $uri");
      }

      final response = await http
          .get(
        uri,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      )
          .timeout(_timeout);

      if (kDebugMode) {
        print("Status: ${response.statusCode}");
        print("Body (first 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}");
      }

      if (response.statusCode == 200) {
        // 🔥 CLEAN RESPONSE BEFORE PARSING
        final cleanedBody = _cleanResponseBody(response.body);
        return GetAllFilters.fromJson(jsonDecode(cleanedBody));
      } else if (response.statusCode == 401) {
        throw Exception("UNAUTHORIZED");
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ getAllEmployees Error: $e");
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════
  // 2️⃣ GET EMPLOYEE LOCATION HISTORY
  // BACKEND EXPECTS: from_date & to_date
  // ═══════════════════════════════════════════════════════

  Future<GetLocationHistoryModel?> getEmployeeLocationHistory({
    required String token,
    required String userId,
    required String roleId,
    required String fromDate,
    required String toDate,
    String? employeeId,
    String? zone,
    String? branch,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final uri = Uri.parse(ApiBase.getLocationHistory).replace(
        queryParameters: {
          "user_id": userId,
          "role_id": roleId,
          "from_date": fromDate,
          "to_date": toDate,
          "page": page.toString(),
          "per_page": perPage.toString(),
          if (employeeId != null && employeeId.isNotEmpty)
            "search_emp_id": employeeId,
          if (zone != null && zone.isNotEmpty) "zone_id": zone,
          if (branch != null && branch.isNotEmpty) "branch_id": branch,
        },
      );

      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("📡 HISTORY API (GET)");
        print("🔗 URL: $uri");
        print("🔑 Token: ${token.substring(0, token.length > 30 ? 30 : token.length)}...");
        print("📋 Parameters:");
        print("   - user_id: $userId");
        print("   - role_id: $roleId");
        print("   - from_date: $fromDate");
        print("   - to_date: $toDate");
        print("   - search_emp_id: $employeeId");
        print("   - zone_id: $zone");
        print("   - branch_id: $branch");
      }

      final response = await http
          .get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token", // 🔥 REQUIRED
        },
      )
          .timeout(_timeout);

      if (kDebugMode) {
        print("Status: ${response.statusCode}");
        print("Response (first 300 chars): ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}");
      }

      if (response.statusCode == 200) {
        // 🔥 CLEAN RESPONSE BEFORE PARSING
        final cleanedBody = _cleanResponseBody(response.body);
        final model = GetLocationHistoryModel.fromJson(jsonDecode(cleanedBody));

        if (kDebugMode) {
          print("✅ History parsed successfully");
          print("📊 Locations count: ${model.data?.locations?.length ?? 0}");
          if (model.data?.locations != null && model.data!.locations!.isNotEmpty) {
            print("📍 First location: ${model.data!.locations!.first.capturedAt} - ${model.data!.locations!.first.activityType}");
            print("📍 Last location: ${model.data!.locations!.last.capturedAt} - ${model.data!.locations!.last.activityType}");
          }
        }

        return model;
      } else if (response.statusCode == 401) {
        throw Exception("UNAUTHORIZED");
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print("⚠️ No tracking data found (404)");
        }
        return null;
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ getEmployeeLocationHistory Error: $e");
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════
  // 3️⃣ DATE FORMATTER (yyyy-MM-dd)
  // ═══════════════════════════════════════════════════════

  static String formatDateForApi(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }
}