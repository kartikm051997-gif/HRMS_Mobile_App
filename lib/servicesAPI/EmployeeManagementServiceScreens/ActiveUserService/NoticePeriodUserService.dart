import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../apibaseScreen/Api_Base_Screens.dart';
import '../../../model/Employee_management/NoticePeriodUserListModel.dart';
import '../../APIHelper/ApiHelper.dart';

class NoticePeriodUserService {
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

  Future<NoticePeriodUserListModel?> getNoticePeriodUsers({
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
      if (designationsId != null)
        queryParams['designations_id'] = designationsId;
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['per_page'] = perPage.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(
        ApiBase.noticePeriodUserList,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      if (kDebugMode) {
        print("🔄 NoticePeriodUserService → $uri");
      }

      final response = await ApiHelper.get(uri).timeout(_timeout);

      if (kDebugMode) {
        print("✅ NoticePeriodUserService Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final cleaned = _cleanResponseBody(response.body);
        final jsonResponse = jsonDecode(cleaned);
        return NoticePeriodUserListModel.fromJson(jsonResponse);
      }

      throw Exception("API Error ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ NoticePeriodUserService error: $e");
      }
      rethrow;
    }
  }
}
