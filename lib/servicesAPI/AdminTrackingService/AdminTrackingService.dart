import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../apibaseScreen/Api_Base_Screens.dart';
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../model/UserTrackingModel/GetLocationHistoryModel.dart';
import '../APIHelper/ApiHelper.dart';

class AdminTrackingService {
  static final AdminTrackingService _instance =
      AdminTrackingService._internal();
  factory AdminTrackingService() => _instance;
  AdminTrackingService._internal();

  // ═══════════════════════════════════════════════════════
  // Clean response
  // ═══════════════════════════════════════════════════════
  String _clean(String raw) {
    String cleaned = raw.trim();
    while (cleaned.isNotEmpty &&
        !cleaned.startsWith('{') &&
        !cleaned.startsWith('[')) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }

  // ═══════════════════════════════════════════════════════
  // GET ALL FILTERS
  // ═══════════════════════════════════════════════════════
  Future<GetAllFilters?> getAllEmployees() async {
    try {
      final uri = Uri.parse(ApiBase.getAllFilters);

      final response = await ApiHelper.get(uri);

      final cleaned = _clean(response.body);
      return GetAllFilters.fromJson(jsonDecode(cleaned));
    } catch (e) {
      if (kDebugMode) print("❌ getAllEmployees: $e");
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════
  // GET LOCATION HISTORY
  // ═══════════════════════════════════════════════════════
  Future<GetLocationHistoryModel?> getEmployeeLocationHistory({
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

      if (kDebugMode) print("📡 Admin Tracking URI: $uri");

      final response = await ApiHelper.get(uri);

      final cleaned = _clean(response.body);
      return GetLocationHistoryModel.fromJson(jsonDecode(cleaned));
    } catch (e) {
      if (kDebugMode) print("❌ getEmployeeLocationHistory: $e");
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════
  static String formatDateForApi(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }
}
