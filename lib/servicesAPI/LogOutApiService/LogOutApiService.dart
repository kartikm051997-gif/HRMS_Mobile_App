import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../apibaseScreen/Api_Base_Screens.dart';
import '../../model/LogOutModelClass/LogOutModel.dart'; // Make sure to import your model class.

class ApiService {
  // Use the logoutEndpoint from ApiBase
  static Future<LogoutModelClass> logoutUser(String token) async {
    if (kDebugMode) {
      // Print the API URL and Token for debugging purposes
      print('API URL: ${ApiBase.logoutEndpoint}');
      print('Token: $token');
    }

    final response = await http.post(
      Uri.parse(ApiBase.logoutEndpoint), // Use the endpoint from ApiBase
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Successful response
      return LogoutModelClass.fromJson(json.decode(response.body));
    } else {
      // Handle failure (you can return a default error model or throw an error)
      throw Exception('Failed to log out');
    }
  }
}
