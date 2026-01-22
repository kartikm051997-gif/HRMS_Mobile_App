import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../apibaseScreen/Api_Base_Screens.dart';
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../APIHelper/ApiHelper.dart';

class FilterService {
  Future<GetAllFilters?> getAllFilters() async {
    try {
      if (kDebugMode) {
        print("🔄 FilterService → ${ApiBase.getAllFilters}");
      }

      final response = await ApiHelper.get(
        Uri.parse(ApiBase.getAllFilters),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print("✅ Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return GetAllFilters.fromJson(jsonResponse);
      }

      throw Exception("API Error ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ FilterService error: $e");
      }
      rethrow;
    }
  }
}
