// File: lib/servicesAPI/filter_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../apibaseScreen/Api_Base_Screens.dart';
import '../../model/Employee_management/getAllFiltersModel.dart';

class FilterService {
  /// Fetch all filters with Bearer token
  Future<GetAllFilters?> getAllFilters({required String token}) async {
    try {
      if (kDebugMode) {
        print("🔄 FilterService: Fetching all filters...");
        print("🔗 URL: ${ApiBase.getAllFilters}");
      }

      final response = await http.get(
        Uri.parse(ApiBase.getAllFilters),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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
          print("📦 Filters received successfully");
          print("📊 Response: ${response.body.substring(0, 200)}...");
        }

        return GetAllFilters.fromJson(jsonResponse);
      } else {
        if (kDebugMode) {
          print('❌ API Error ${response.statusCode}: ${response.body}');
        }
        throw Exception('Failed to load filters: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception in FilterService: $e');
      }
      rethrow;
    }
  }
}