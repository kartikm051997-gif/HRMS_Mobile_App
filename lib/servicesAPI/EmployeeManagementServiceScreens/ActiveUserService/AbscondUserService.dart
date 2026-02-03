import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../apibaseScreen/Api_Base_Screens.dart';
import '../../../model/Employee_management/AbscondUserListModelClass.dart';
import '../../APIHelper/ApiHelper.dart';

class AbscondUserService {
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

  Future<AbscondUserListModelClass?> getAbscondUsers({
    String? cmpid,
    String? zoneId,
    String? locationsId,
    String? designationsId,
    int? page,
    int? perPage,
    String? search,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (cmpid != null) queryParams['cmpid'] = cmpid;
      if (zoneId != null) queryParams['zone_id'] = zoneId;
      if (locationsId != null) queryParams['locations_id'] = locationsId;
      if (designationsId != null) queryParams['designations_id'] = designationsId;
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['per_page'] = perPage.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(ApiBase.abscondUserList)
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      if (kDebugMode) {
        print("🔄 AbscondUserService → $uri");
      }

      final response = await ApiHelper.get(uri).timeout(_timeout);

      if (kDebugMode) {
        print("✅ AbscondUserService Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final cleaned = _cleanResponseBody(response.body);
        final jsonResponse = jsonDecode(cleaned);
        
        if (kDebugMode) {
          print("📦 AbscondUserService Response type: ${jsonResponse.runtimeType}");
          if (jsonResponse is Map) {
            print("📦 Response keys: ${jsonResponse.keys}");
            print("📦 Response status: ${jsonResponse['status']}");
          }
        }
        
        // Handle case where API returns List directly instead of Map
        if (jsonResponse is List) {
          if (kDebugMode) {
            print("⚠️ API returned List directly, wrapping in expected format");
            print("📦 List length: ${jsonResponse.length}");
          }
          // Wrap list in expected structure
          return AbscondUserListModelClass.fromJson({
            'status': 'success',
            'message': 'Data retrieved successfully',
            'total': jsonResponse.length,
            'data': {
              'users': jsonResponse,
              'pagination': null,
            },
          });
        }
        
        // Normal Map response
        return AbscondUserListModelClass.fromJson(jsonResponse);
      }

      // Log response body for debugging
      if (kDebugMode) {
        print("❌ AbscondUserService ${response.statusCode} Response: ${response.body}");
      }
      
      throw Exception("API Error ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ AbscondUserService error: $e");
      }
      rethrow;
    }
  }
}
