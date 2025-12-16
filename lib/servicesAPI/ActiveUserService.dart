import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/Employee_management/ActiveUserListModel.dart';
import '../apibaseScreen/Api_Base_Screens.dart';

class ActiveUserService {

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
      if (designationsId != null) queryParams['designations_id'] = designationsId;
      if (ctcRange != null) queryParams['ctc_range'] = ctcRange;
      if (punch != null) queryParams['punch'] = punch;
      if (dolpFromdate != null) queryParams['dolp_fromdate'] = dolpFromdate;
      if (dolpTodate != null) queryParams['dolp_todate'] = dolpTodate;
      if (fromdate != null) queryParams['fromdate'] = fromdate;
      if (todate != null) queryParams['todate'] = todate;
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['per_page'] = perPage.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      Uri uri = Uri.parse(ApiBase.activeUserList)
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      if (kDebugMode) {
        print("🔄 ActiveUserService: Calling API - $uri");
      }

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ Bearer token
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (kDebugMode) {
        print("✅ Response Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (kDebugMode) {
          print("📦 Response received successfully");
        }
        return ActiveUserList.fromJson(jsonResponse);
      } else {
        if (kDebugMode) {
          print('❌ API Error ${response.statusCode}: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in ActiveUserService: $e');
      }
      return null;
    }
  }
}
