import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../model/Employee_management/ActiveUserListModel.dart';
import '../../apibaseScreen/Api_Base_Screens.dart';

class ActiveUserService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Clean response body by removing leading asterisks or non-JSON characters
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

  /// Fetch active users with Bearer token
  Future<ActiveUserList?> getActiveUsers({
    required String token, // 👈 Bearer token
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
      Map<String, dynamic> queryParams = {};

      if (cmpid != null) queryParams['cmpid'] = cmpid;
      if (zoneId != null) queryParams['zone_id'] = zoneId;
      if (locationsId != null) queryParams['locations_id'] = locationsId;
      if (designationsId != null) {
        queryParams['designations_id'] = designationsId;
      }
      if (ctcRange != null) queryParams['ctc_range'] = ctcRange;
      if (punch != null) queryParams['punch'] = punch;
      if (dolpFromdate != null) queryParams['dolp_fromdate'] = dolpFromdate;
      if (dolpTodate != null) queryParams['dolp_todate'] = dolpTodate;
      if (fromdate != null) queryParams['fromdate'] = fromdate;
      if (todate != null) queryParams['todate'] = todate;
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['per_page'] = perPage.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      Uri uri = Uri.parse(
        ApiBase.activeUserList,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      if (kDebugMode) {
        print("🔄 ActiveUserService: Calling API - $uri");
      }

      final response = await http
          .get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ Bearer token
        },
      )
          .timeout(
        _timeout,
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (kDebugMode) {
        print("✅ Response Status: ${response.statusCode}");
        print("📦 Raw Response (first 100 chars): ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}");
      }

      if (response.statusCode == 200) {
        // 🔥 CLEAN THE RESPONSE BODY BEFORE PARSING
        final cleanedBody = _cleanResponseBody(response.body);

        final jsonResponse = jsonDecode(cleanedBody);

        if (kDebugMode) {
          print("✅ Response parsed successfully");

          // Log summary data if available
          if (jsonResponse['data'] != null && jsonResponse['data']['users'] != null) {
            print("📊 Users count: ${jsonResponse['data']['users'].length}");
          }
        }

        return ActiveUserList.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('❌ Unauthorized - Token may be invalid or expired');
        }
        throw Exception('UNAUTHORIZED');
      } else {
        if (kDebugMode) {
          print('❌ API Error ${response.statusCode}: ${response.body}');
        }
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in ActiveUserService: $e');
      }
      rethrow; // ⚠️ Changed from return null to rethrow
    }
  }
}