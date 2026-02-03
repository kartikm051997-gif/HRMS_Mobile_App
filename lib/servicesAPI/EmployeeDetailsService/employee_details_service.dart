import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../apibaseScreen/Api_Base_Screens.dart';
import '../../../model/EmployeeDetailsModel/employee_details_model.dart';
import '../APIHelper/ApiHelper.dart';

class EmployeeDetailsService {
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

  /// Fetch employee details by user_id
  /// POST request to /api/get_employee_details
  /// Body: {"user_id": "1842"}
  Future<EmployeeDetailsModel> getEmployeeDetails(String userId) async {
    try {
      final uri = Uri.parse(ApiBase.getEmployeeDetails);

      if (kDebugMode) {
        print("🔄 EmployeeDetailsService → $uri");
        print("📤 Request Body: {\"user_id\": \"$userId\"}");
      }

      final requestBody = {"user_id": userId};

      final response = await ApiHelper.post(uri, requestBody).timeout(_timeout);

      if (kDebugMode) {
        print("✅ Status: ${response.statusCode}");
        print(
          "📦 Response Body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...",
        );
      }

      if (response.statusCode == 200) {
        final cleaned = _cleanResponseBody(response.body);
        final jsonResponse = jsonDecode(cleaned);

        if (kDebugMode) {
          print("✅ EmployeeDetailsService: Successfully parsed response");
          print("📋 Status: ${jsonResponse['status']}");
          print("📋 Message: ${jsonResponse['message']}");
        }

        return EmployeeDetailsModel.fromJson(jsonResponse);
      }

      throw Exception("API Error ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ EmployeeDetailsService error: $e");
      }
      rethrow;
    }
  }
}
