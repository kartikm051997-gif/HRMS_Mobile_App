import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../apibaseScreen/Api_Base_Screens.dart';
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../model/UserTrackingModel/GetLocationHistoryModel.dart';

/// Service class for Admin Tracking APIs
class AdminTrackingService {
  // Singleton pattern
  static final AdminTrackingService _instance =
      AdminTrackingService._internal();
  factory AdminTrackingService() => _instance;
  AdminTrackingService._internal();

  static const Duration _timeout = Duration(seconds: 30);

  // ═══════════════════════════════════════════════════════════════════════
  // 1. GET ALL FILTERS (Employee List, Zone, Branch, Role)
  // ═══════════════════════════════════════════════════════════════════════

  /// Fetch all employees from filters API
  Future<GetAllFilters?> getAllEmployees({required String token}) async {
    try {
      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("🔄 AdminTrackingService: Fetching employees...");
        print("🔗 URL: ${ApiBase.getAllFilters}");
      }

      final response = await http
          .get(
            Uri.parse(ApiBase.getAllFilters),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      if (kDebugMode) {
        print("✅ Response Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (kDebugMode) {
          print("✅ Employees fetched successfully");
          print("📦 Response keys: ${jsonData.keys.toList()}");
        }

        return GetAllFilters.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED: Please login again');
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error fetching employees: $e");
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 2. GET LOCATION HISTORY
  // ═══════════════════════════════════════════════════════════════════════

  /// Fetch location history for a specific employee
  Future<GetLocationHistoryModel?> getEmployeeLocationHistory({
    required String token,
    required String userId, // employment_id
    String? employeeId,
    String? branch, // Can be comma-separated for multiple branches
    String? designation,
    String? zone, // Can be comma-separated for multiple zones
    String? date,
    String? fromDate,
    String? toDate,
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'employment_id': userId,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      // Add optional filters
      if (zone != null && zone.isNotEmpty) {
        queryParams['zone'] = zone; // e.g., "South,West,North"
      }

      if (branch != null && branch.isNotEmpty) {
        queryParams['branch'] = branch; // e.g., "Branch A,Branch B"
      }

      if (designation != null && designation.isNotEmpty) {
        queryParams['designation'] = designation;
      }

      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams['from_date'] = fromDate;
      }

      if (toDate != null && toDate.isNotEmpty) {
        queryParams['to_date'] = toDate;
      }

      final uri = Uri.parse(
        ApiBase.getLocationHistory,
      ).replace(queryParameters: queryParams);

      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("🔄 AdminTrackingService: Fetching location history...");
        print("🔗 URL: $uri");
        print("📋 Filters:");
        print("   - Employment ID: $userId");
        print("   - Zone(s): $zone");
        print("   - Branch(es): $branch");
        print("   - Designation: $designation");
        print("   - Date: $date");
      }

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      if (kDebugMode) {
        print("✅ Response Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (kDebugMode) {
          print("✅ Location history fetched successfully");
          final locationsCount = jsonData['data']?['locations']?.length ?? 0;
          print("📍 Total locations: $locationsCount");
        }

        return GetLocationHistoryModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('UNAUTHORIZED: Please login again');
      } else if (response.statusCode == 404) {
        if (kDebugMode) print("⚠️ No tracking data found");
        return null;
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error fetching location history: $e");
      }
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 3. TEST CONNECTION
  // ═══════════════════════════════════════════════════════════════════════

  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse(ApiBase.baseUrl))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      if (kDebugMode) print("❌ Connection test failed: $e");
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  static String formatDateForApi(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  static DateTime? parseDateFromApi(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      if (kDebugMode) print("⚠️ Failed to parse date: $dateStr");
      return null;
    }
  }
}
