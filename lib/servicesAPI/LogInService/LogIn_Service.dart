// File: lib/servicesAPI/LogInService/LogIn_Service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../apibaseScreen/Api_Base_Screens.dart';
import '../../model/login_model/login_model.dart';

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
      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("🔄 AuthService: Attempting login...");
        print("👤 Username: $username");
        print("═══════════════════════════════════════");
      }

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

          if (kDebugMode) {
            print("═══════════════════════════════════════");
            print("✅ Login successful");
            print("═══════════════════════════════════════");
          }
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

      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("💾 Saving login session...");
        print("📦 Full Response: ${jsonEncode(userData)}");
        print("═══════════════════════════════════════");
      }

      // Save entire login response
      await prefs.setString(_keyUserData, jsonEncode(userData));
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setInt(_keyLoginTime, DateTime.now().millisecondsSinceEpoch);

      // ✅ IMPROVED: Extract token from multiple possible locations
      String token = _extractToken(userData);

      // Save token
      if (token.isNotEmpty) {
        await prefs.setString(_keyAuthToken, token);
        if (kDebugMode) {
          print("✅ Token saved successfully");
          print("🔑 Token (first 30 chars): ${token.substring(0, min(30, token.length))}...");
          print("📏 Token length: ${token.length} characters");
        }
      } else {
        if (kDebugMode) {
          print("⚠️ WARNING: No token found in login response!");
          print("📦 Available keys in response: ${userData.keys.toList()}");

          // Check nested data
          if (userData['data'] != null) {
            print("📦 Keys in 'data': ${(userData['data'] as Map).keys.toList()}");
          }
          if (userData['user'] != null) {
            print("📦 Keys in 'user': ${(userData['user'] as Map).keys.toList()}");
          }
        }
      }

      // Extract and save employee ID
      final userId = _extractUserId(userData);
      if (userId.isNotEmpty) {
        await prefs.setString(_keyEmployeeId, userId);
        await prefs.setString(_keyLoggedInEmpId, userId);
        if (kDebugMode) print("✅ Employee ID saved: $userId");
      } else {
        if (kDebugMode) print("⚠️ Warning: No employee ID found");
      }

      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("✅ Session saved successfully");
        print("═══════════════════════════════════════");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error saving session: $e");
        print("Stack trace: ${StackTrace.current}");
      }
      throw Exception("Failed to save session data: $e");
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

      if (kDebugMode) {
        print("✅ Session loaded successfully");
        print("🆔 User ID: ${await getEmployeeId()}");
      }
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
        if (kDebugMode) {
          print("❌ Session expired");
          print("⏰ Session was ${minutesSinceLogin} minutes old (max: $_sessionExpiryMinutes)");
        }
        await clearSession();
        return false;
      }

      if (kDebugMode) {
        print("✅ Session is valid");
        print("⏰ Session age: $minutesSinceLogin minutes (expires in ${_sessionExpiryMinutes - minutesSinceLogin} min)");
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

      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("✅ Session cleared successfully");
        print("═══════════════════════════════════════");
      }
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
        if (token != null && token.isNotEmpty) {
          print("✅ Auth token retrieved");
          print("🔑 Token (first 30 chars): ${token.substring(0, min(30, token.length))}...");
        } else {
          print("❌ Auth token not found in storage");
          print("💡 Available keys: ${prefs.getKeys().toList()}");
        }
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

  /// Check if user is currently logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      if (kDebugMode) print("❌ Error checking login status: $e");
      return false;
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

  /// Extract token from login response - checks multiple possible locations
  String _extractToken(Map<String, dynamic> userData) {
    // Try different possible token locations

    // 1. Direct token field
    if (userData['token'] != null && userData['token'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 Token found in: userData['token']");
      return userData['token'].toString();
    }

    // 2. data.token
    if (userData['data'] != null && userData['data'] is Map) {
      final data = userData['data'] as Map;
      if (data['token'] != null && data['token'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 Token found in: userData['data']['token']");
        return data['token'].toString();
      }
    }

    // 3. user.token
    if (userData['user'] != null && userData['user'] is Map) {
      final user = userData['user'] as Map;
      if (user['token'] != null && user['token'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 Token found in: userData['user']['token']");
        return user['token'].toString();
      }
    }

    // 4. access_token
    if (userData['access_token'] != null && userData['access_token'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 Token found in: userData['access_token']");
      return userData['access_token'].toString();
    }

    // 5. data.access_token
    if (userData['data'] != null && userData['data'] is Map) {
      final data = userData['data'] as Map;
      if (data['access_token'] != null && data['access_token'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 Token found in: userData['data']['access_token']");
        return data['access_token'].toString();
      }
    }

    // 6. bearer_token
    if (userData['bearer_token'] != null && userData['bearer_token'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 Token found in: userData['bearer_token']");
      return userData['bearer_token'].toString();
    }

    if (kDebugMode) print("❌ Token not found in any expected location");
    return '';
  }

  /// Extract user ID from login response
  String _extractUserId(Map<String, dynamic> userData) {
    // Try multiple possible locations for user ID

    // 1. user.user_id
    if (userData['user'] != null && userData['user'] is Map) {
      final user = userData['user'] as Map;
      if (user['user_id'] != null) {
        return user['user_id'].toString();
      }
      if (user['id'] != null) {
        return user['id'].toString();
      }
      if (user['employee_id'] != null) {
        return user['employee_id'].toString();
      }
      if (user['employment_id'] != null) {
        return user['employment_id'].toString();
      }
    }

    // 2. Direct fields
    if (userData['user_id'] != null) {
      return userData['user_id'].toString();
    }

    if (userData['userId'] != null) {
      return userData['userId'].toString();
    }

    if (userData['employee_id'] != null) {
      return userData['employee_id'].toString();
    }

    if (userData['employment_id'] != null) {
      return userData['employment_id'].toString();
    }

    // 3. data.user_id
    if (userData['data'] != null && userData['data'] is Map) {
      final data = userData['data'] as Map;
      if (data['user_id'] != null) {
        return data['user_id'].toString();
      }
      if (data['employee_id'] != null) {
        return data['employee_id'].toString();
      }
    }

    if (kDebugMode) print("⚠️ User ID not found in any expected location");
    return '';
  }

  /// Debug: Print all session data
  Future<void> debugPrintSessionData() async {
    if (!kDebugMode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyAuthToken);
      final userData = prefs.getString(_keyUserData);

      print("═══════════════════════════════════════");
      print("📝 COMPLETE SESSION DATA:");
      print("═══════════════════════════════════════");
      print("✅ isLoggedIn: ${prefs.getBool(_keyIsLoggedIn)}");
      print("⏰ loginTime: ${prefs.getInt(_keyLoginTime)}");
      print("🆔 employeeId: ${prefs.getString(_keyEmployeeId)}");
      print("🆔 logged_in_emp_id: ${prefs.getString(_keyLoggedInEmpId)}");

      if (token != null && token.isNotEmpty) {
        print("🔑 authToken: ${token.substring(0, min(50, token.length))}...");
        print("📏 Token length: ${token.length} chars");
      } else {
        print("🔑 authToken: NOT FOUND");
      }

      if (userData != null && userData.isNotEmpty) {
        print("📦 userData (first 200 chars): ${userData.substring(0, min(200, userData.length))}...");
      } else {
        print("📦 userData: NOT FOUND");
      }

      print("═══════════════════════════════════════");
      print("🔧 All SharedPreferences Keys:");
      print(prefs.getKeys().toList());
      print("═══════════════════════════════════════");
    } catch (e) {
      print("❌ Error printing debug data: $e");
    }
  }

  /// Validate token format (basic check)
  bool isValidTokenFormat(String? token) {
    if (token == null || token.isEmpty) return false;

    // Basic validation: token should be at least 20 characters
    // and contain alphanumeric characters
    return token.length >= 20 && RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(token);
  }

  /// Force refresh session (call after login)
  Future<void> refreshSession() async {
    try {
      final session = await loadLoginSession();
      if (session != null) {
        await saveLoginSession(session);
        if (kDebugMode) print("✅ Session refreshed");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error refreshing session: $e");
    }
  }
}