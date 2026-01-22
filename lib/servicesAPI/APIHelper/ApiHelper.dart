import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../LogInService/LogIn_Service.dart';

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

    if (token == null) {
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

    // 🔴 Token expired? Refresh and retry ONCE
    if (response.statusCode == 401) {
      if (kDebugMode) print("🔄 Token expired. Refreshing...");

      final newToken = await _auth.refreshToken(token);

      if (newToken != null) {
        if (method == "POST") {
          response = await http.post(
            url,
            headers: {
              "Authorization": "Bearer $newToken",
              "Content-Type": "application/json",
            },
            body: jsonEncode(body),
          );
        } else {
          response = await http.get(
            url,
            headers: {
              "Authorization": "Bearer $newToken",
              "Content-Type": "application/json",
            },
          );
        }
      }
    }

    return response;
  }
}
