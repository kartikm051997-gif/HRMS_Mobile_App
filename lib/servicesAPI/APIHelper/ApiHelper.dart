import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../LogInService/LogIn_Service.dart';
import '../../core/utils/helper_utils.dart';

class ApiHelper {
  static final LoginService _auth = LoginService();

  // 🔥 GET REQUEST
  static Future<http.Response> get(Uri url) async {
    return await _send("GET", url);
  }

  // 🔥 POST REQUEST
  static Future<http.Response> post(Uri url, Map body) async {
    return await _send("POST", url, body: body);
  }

  // 🔥 CORE METHOD
  static Future<http.Response> _send(
    String method,
    Uri url, {
    Map? body,
  }) async {
    String? token = await _auth.getValidToken();

    if (token == null || token.isEmpty) {
      if (kDebugMode) print("❌ No valid token - navigating to login");
      await _auth.clearSession();
      HelperUtil.navigateToLoginOnTokenExpiry();
      throw Exception("User not logged in");
    }

    http.Response response;

    if (method == "POST") {
      response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    } else {
      response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    }

    // 🔴 Token expired (401)? Navigate to login immediately
    if (response.statusCode == 401) {
      if (kDebugMode) {
        print("❌ Token expired (401) - navigating to login");
      }
      await _auth.clearSession();
      HelperUtil.navigateToLoginOnTokenExpiry();
      throw Exception("Session expired - please login again");
    }

    // ✅ Update last app usage time on successful API call (200, 201, etc.)
    // Note: This is just for tracking, not for logout logic
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await _auth.updateLastAppUsage();
    }

    return response;
  }
}
