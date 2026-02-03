import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../apibaseScreen/Api_Base_Screens.dart';
import '../../../model/Employee_management/InActiveUserListModelClass.dart';
import '../../APIHelper/ApiHelper.dart';

class InActiveUserService {
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

  Future<InActiveUserListModelClass?> getInActiveUsers({
    String? cmpid,
    String? zoneId,
    String? locationsId,
    String? designationsId,
    String? ctcRange,
    String? punch,
    String? dolpFromdate,
    String? dolpTodate,
    String? fromdate,
    String? todate,
    int? page,
    int? perPage,
    String? search,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (cmpid != null) queryParams['cmpid'] = cmpid;
      if (zoneId != null) queryParams['zone_id'] = zoneId;
      if (locationsId != null) queryParams['locations_id'] = locationsId;
      if (designationsId != null)
        queryParams['designations_id'] = designationsId;
      if (ctcRange != null) queryParams['ctc_range'] = ctcRange;
      if (punch != null) queryParams['punch'] = punch;
      if (dolpFromdate != null) queryParams['dolp_fromdate'] = dolpFromdate;
      if (dolpTodate != null) queryParams['dolp_todate'] = dolpTodate;
      if (fromdate != null) queryParams['fromdate'] = fromdate;
      if (todate != null) queryParams['todate'] = todate;
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['per_page'] = perPage.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(
        ApiBase.inActiveUserList,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      if (kDebugMode) {
        print("🔄 InActiveUserService → $uri");
      }

      final response = await ApiHelper.get(uri).timeout(_timeout);

      if (kDebugMode) {
        print("✅ Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final cleaned = _cleanResponseBody(response.body);
        final jsonResponse = jsonDecode(cleaned);
        
        if (kDebugMode) {
          print("📦 InActiveUserService Response type: ${jsonResponse.runtimeType}");
          if (jsonResponse is Map) {
            print("📦 Response keys: ${jsonResponse.keys}");
            print("📦 Response status: ${jsonResponse['status']}");
            if (jsonResponse['data'] != null) {
              print("📦 Data type: ${jsonResponse['data'].runtimeType}");
              if (jsonResponse['data'] is Map && jsonResponse['data']['users'] != null) {
                print("📦 Users count: ${(jsonResponse['data']['users'] as List).length}");
              } else if (jsonResponse['data'] is List) {
                print("📦 Data is List, length: ${(jsonResponse['data'] as List).length}");
              }
            }
          } else if (jsonResponse is List) {
            print("📦 List length: ${jsonResponse.length}");
          }
        }
        
        // Handle case where API returns List directly instead of Map
        if (jsonResponse is List) {
          if (kDebugMode) {
            print("⚠️ API returned List directly, wrapping in expected format");
          }
          // Wrap list in expected structure
          return InActiveUserListModelClass.fromJson({
            'status': 'success',
            'message': 'Data retrieved successfully',
            'total': jsonResponse.length,
            'data': {
              'users': jsonResponse,
              'pagination': null,
            },
          });
        }
        
        // Handle case where data field is a List instead of Map
        if (jsonResponse is Map && jsonResponse['data'] is List) {
          if (kDebugMode) {
            print("⚠️ API returned data as List, wrapping in expected format");
            print("📦 List length: ${(jsonResponse['data'] as List).length}");
          }
          // Wrap data list in expected structure
          final wrappedResponse = Map<String, dynamic>.from(jsonResponse);
          wrappedResponse['data'] = {
            'users': jsonResponse['data'],
            'pagination': null,
          };
          return InActiveUserListModelClass.fromJson(wrappedResponse);
        }
        
        // Normal Map response with data as Map
        return InActiveUserListModelClass.fromJson(jsonResponse);
      }

      throw Exception("API Error ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ InActiveUserService error: $e");
      }
      rethrow;
    }
  }
}
