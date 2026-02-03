import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../apibaseScreen/Api_Base_Screens.dart';
import '../../../model/Employee_management/ManagementApprovalListModel.dart';
import '../../APIHelper/ApiHelper.dart';

class ManagementApprovalService {
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

  Future<ManagementApprovalListModel?> getPendingApprovalList({
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
        ApiBase.managementApprovalList,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      if (kDebugMode) {
        print("🔄 ManagementApprovalService → $uri");
      }

      final response = await ApiHelper.get(uri).timeout(_timeout);

      if (kDebugMode) {
        print("✅ Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final cleaned = _cleanResponseBody(response.body);
        final jsonResponse = jsonDecode(cleaned);
        
        // Debug: Log first employee's data structure
        if (kDebugMode && jsonResponse['data'] != null && jsonResponse['data'].isNotEmpty) {
          print('📋 ManagementApproval API Response Structure:');
          print('   First employee keys: ${jsonResponse['data'][0].keys.toList()}');
          print('   First employee avatar field: ${jsonResponse['data'][0]['avatar']}');
          print('   First employee data sample: ${jsonResponse['data'][0]}');
        }
        
        return ManagementApprovalListModel.fromJson(jsonResponse);
      }

      throw Exception("API Error ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ ManagementApprovalService error: $e");
      }
      rethrow;
    }
  }
}
