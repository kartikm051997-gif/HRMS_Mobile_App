// File: lib/servicesAPI/auth_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../apibaseScreen/Api_Base_Screens.dart';
import '../model/login_model/login_model.dart';

/// Custom HTTP overrides for development (allows self-signed certificates)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// Custom timeout exception
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}

/// Auth service - Handles all authentication API calls and session management
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal() {
    HttpOverrides.global = MyHttpOverrides();
  }

  // API timeout duration
  static const Duration _apiTimeout = Duration(seconds: 30);

  // Session expiry duration (2 days)
  static const int _sessionExpiryMinutes = 2880;

  // SharedPreferences keys
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyLoginTime = 'loginTime';
  static const String _keyUserData = 'userData';
  static const String _keyEmployeeId = 'employeeId';
  static const String _keyLoggedInEmpId = 'logged_in_emp_id';
  static const String _keyAuthToken = 'authToken';

  // ═══════════════════════════════════════════════════════════════════════
  // LOGIN API
  // ═══════════════════════════════════════════════════════════════════════

  /// Performs login with username and password
  Future<LoginApiModel> login({
    required String username,
    required String password,
  }) async {
    try {
      if (kDebugMode) print("🔄 AuthService: Attempting login...");

      final response = await http
          .post(
            Uri.parse(ApiBase.loginEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'user_name': username.trim(),
              'password': password.trim(),
            }),
          )
          .timeout(
            _apiTimeout,
            onTimeout: () => throw TimeoutException('Connection timeout'),
          );

      if (kDebugMode) {
        print("✅ Response Status: ${response.statusCode}");
        print("📦 Response Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final loginModel = LoginApiModel.fromJson(jsonResponse);

        // Check if login was successful
        if (_isLoginSuccessful(loginModel)) {
          // Save session data
          await saveLoginSession(loginModel);

          if (kDebugMode) print("✅ Login successful");
          return loginModel;
        } else {
          throw Exception(loginModel.message ?? "Invalid credentials");
        }
      } else {
        // Handle HTTP errors
        final bodyText =
            response.body.isNotEmpty && response.body.length > 160
                ? "${response.body.substring(0, 160)}..."
                : response.body;

        if (kDebugMode) {
          print("❌ Login failed. Status: ${response.statusCode}");
          print("❌ Body: $bodyText");
        }

        throw Exception(
          "Login failed (HTTP ${response.statusCode})${bodyText.isNotEmpty ? ' - $bodyText' : ''}",
        );
      }
    } on TimeoutException catch (e) {
      if (kDebugMode) print("❌ Timeout: $e");
      rethrow;
    } on SocketException catch (e) {
      if (kDebugMode) print("❌ Network error: $e");
      throw Exception("Network error. Please check your connection.");
    } catch (e) {
      if (kDebugMode) print("❌ Login error: $e");
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SESSION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════

  /// Save login session data to SharedPreferences
  Future<void> saveLoginSession(LoginApiModel loginModel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = loginModel.toJson();

      // Save entire login response
      await prefs.setString(_keyUserData, jsonEncode(userData));
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setInt(_keyLoginTime, DateTime.now().millisecondsSinceEpoch);

      // Extract and save auth token
      final token = userData['token']?.toString() ?? '';
      if (token.isNotEmpty) {
        await prefs.setString(_keyAuthToken, token);
      }

      // Extract and save employee ID
      final userId = _extractUserId(userData);
      if (userId.isNotEmpty) {
        await prefs.setString(_keyEmployeeId, userId);
        await prefs.setString(_keyLoggedInEmpId, userId);
      }

      if (kDebugMode) {
        print("✅ Session saved successfully");
        print("🔑 Token: ${token.isNotEmpty ? 'Saved' : 'Not found'}");
        print("🆔 Employee ID: $userId");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error saving session: $e");
      throw Exception("Failed to save session data");
    }
  }

  /// Load login session from SharedPreferences
  Future<LoginApiModel?> loadLoginSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;

      if (!isLoggedIn) {
        if (kDebugMode) print("❌ No login session found");
        return null;
      }

      final userData = prefs.getString(_keyUserData);
      if (userData == null || userData.isEmpty) {
        if (kDebugMode) print("❌ User data not found");
        return null;
      }

      final decoded = jsonDecode(userData);
      final loginModel = LoginApiModel.fromJson(decoded);

      if (kDebugMode) print("✅ Session loaded successfully");
      return loginModel;
    } catch (e) {
      if (kDebugMode) print("❌ Error loading session: $e");
      return null;
    }
  }

  /// Check if session is valid (not expired)
  Future<bool> isSessionValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      final loginTime = prefs.getInt(_keyLoginTime);

      if (!isLoggedIn || loginTime == null) {
        if (kDebugMode) print("❌ No valid session");
        return false;
      }

      final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTime);
      final now = DateTime.now();
      final minutesSinceLogin = now.difference(loginDate).inMinutes;

      if (minutesSinceLogin >= _sessionExpiryMinutes) {
        if (kDebugMode) print("❌ Session expired after 2 days");
        await clearSession();
        return false;
      }

      if (kDebugMode) {
        print("✅ Session is valid");
        print("⏰ Session age: $minutesSinceLogin minutes");
      }
      return true;
    } catch (e) {
      if (kDebugMode) print("❌ Error checking session validity: $e");
      return false;
    }
  }

  /// Clear all session data
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove all session keys
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyLoginTime);
      await prefs.remove(_keyUserData);
      await prefs.remove(_keyEmployeeId);
      await prefs.remove(_keyLoggedInEmpId);
      await prefs.remove(_keyAuthToken);

      if (kDebugMode) print("✅ Session cleared successfully");
    } catch (e) {
      if (kDebugMode) print("❌ Error clearing session: $e");
      throw Exception("Failed to clear session");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TOKEN & USER DATA
  // ═══════════════════════════════════════════════════════════════════════

  /// Get authentication token
  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyAuthToken);

      if (kDebugMode) {
        print(
          token != null ? "✅ Auth token retrieved" : "❌ Auth token not found",
        );
      }

      return token;
    } catch (e) {
      if (kDebugMode) print("❌ Error getting auth token: $e");
      return null;
    }
  }

  /// Get employee ID
  Future<String?> getEmployeeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyEmployeeId);
    } catch (e) {
      if (kDebugMode) print("❌ Error getting employee ID: $e");
      return null;
    }
  }

  /// Get logged-in user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_keyUserData);

      if (userData == null || userData.isEmpty) return null;

      return jsonDecode(userData) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print("❌ Error getting user data: $e");
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Check if login was successful based on response
  bool _isLoginSuccessful(LoginApiModel loginModel) {
    final status = loginModel.status?.toLowerCase();
    return status == 'success' ||
        status == '1' ||
        status == 'ok' ||
        status == 'true';
  }

  /// Extract user ID from login response
  String _extractUserId(Map<String, dynamic> userData) {
    // Try multiple possible locations for user ID
    if (userData['user'] != null && userData['user']['user_id'] != null) {
      return userData['user']['user_id'].toString();
    }

    if (userData['user_id'] != null) {
      return userData['user_id'].toString();
    }

    if (userData['userId'] != null) {
      return userData['userId'].toString();
    }

    return '';
  }

  /// Debug: Print all session data
  Future<void> debugPrintSessionData() async {
    if (!kDebugMode) return;

    final prefs = await SharedPreferences.getInstance();
    print("═══════════════════════════════════════");
    print("📝 SESSION DATA:");
    print("═══════════════════════════════════════");
    print("✅ isLoggedIn: ${prefs.getBool(_keyIsLoggedIn)}");
    print("⏰ loginTime: ${prefs.getInt(_keyLoginTime)}");
    print("🆔 employeeId: ${prefs.getString(_keyEmployeeId)}");
    print(
      "🔑 authToken: ${prefs.getString(_keyAuthToken) != null ? 'Present' : 'Missing'}",
    );
    print(
      "📦 userData: ${prefs.getString(_keyUserData)?.substring(0, 100)}...",
    );
    print("═══════════════════════════════════════");
  }
}
