import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../apibaseScreen/Api_Base_Screens.dart';
import '../../../model/Employee_management/AllEmployeeListModelClass.dart';
import '../../APIHelper/ApiHelper.dart';

class AllEmployeeService {
  static const Duration _timeout = Duration(seconds: 30);

  String _cleanResponseBody(String rawBody) {
    String cleaned = rawBody.trim();
    while (cleaned.isNotEmpty &&
        !cleaned.startsWith('{') &&
        !cleaned.startsWith('[')) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }

  Future<AllEmployeeListModelClass?> getAllEmployees({
    String? zoneId,
    String? locationsId,
    String? designationsId,
    int? page,
    int? perPage,
    String? search,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (zoneId != null && zoneId.isNotEmpty) {
        queryParams['zone_id'] = zoneId;
      }
      if (locationsId != null && locationsId.isNotEmpty) {
        queryParams['locations_id'] = locationsId;
      }
      if (designationsId != null && designationsId.isNotEmpty) {
        queryParams['designations_id'] = designationsId;
      }
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['per_page'] = perPage.toString();
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        ApiBase.allEmployeeList,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      if (kDebugMode) {
        print("🔄 AllEmployeeService → $uri");
      }

      final response = await ApiHelper.get(uri).timeout(_timeout);

      if (kDebugMode) {
        print("✅ Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final cleaned = _cleanResponseBody(response.body);
        final jsonResponse = jsonDecode(cleaned);
        return AllEmployeeListModelClass.fromJson(jsonResponse);
      }

      throw Exception("API Error ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ AllEmployeeService error: $e");
      }
      rethrow;
    }
  }

  Future<AllEmployeeUser?> getEmployeeById(String empId) async {
    try {
      final Map<String, String> queryParams = {'employment_id': empId};

      final uri = Uri.parse(
        ApiBase.employeeDetailsById,
      ).replace(queryParameters: queryParams);

      if (kDebugMode) {
        print("🔄 AllEmployeeService.getEmployeeById → $uri");
      }

      final response = await ApiHelper.get(uri).timeout(_timeout);

      if (kDebugMode) {
        print("✅ Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final cleaned = _cleanResponseBody(response.body);
        final jsonResponse = jsonDecode(cleaned);

        // Handle response - could be direct user object or wrapped in data
        if (jsonResponse['data'] != null &&
            jsonResponse['data']['user'] != null) {
          return AllEmployeeUser.fromJson(jsonResponse['data']['user']);
        } else if (jsonResponse['user'] != null) {
          return AllEmployeeUser.fromJson(jsonResponse['user']);
        } else if (jsonResponse['data'] != null) {
          return AllEmployeeUser.fromJson(jsonResponse['data']);
        } else {
          return AllEmployeeUser.fromJson(jsonResponse);
        }
      }

      throw Exception("API Error ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ AllEmployeeService.getEmployeeById error: $e");
      }
      rethrow;
    }
  }
}
