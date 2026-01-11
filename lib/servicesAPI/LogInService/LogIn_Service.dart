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
class LoginService {
  // Singleton pattern
  static final LoginService _instance = LoginService._internal();
  factory LoginService() => _instance;
  DateTime? _lastTokenRefresh;

  LoginService._internal() {
    HttpOverrides.global = MyHttpOverrides();
  }

  Future<String?> getValidToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(_keyAuthToken);

      if (token == null || token.isEmpty) {
        return null;
      }

      // Check if 5 minutes passed since last refresh
      if (_lastTokenRefresh == null ||
          DateTime.now().difference(_lastTokenRefresh!) >
              Duration(minutes: 5)) {
        if (kDebugMode) print("🔄 Refreshing token...");
        final newToken = await refreshToken(token);

        if (newToken != null) {
          token = newToken;
          _lastTokenRefresh = DateTime.now();
        }
      }

      return token;
    } catch (e) {
      return await getAuthToken(); // If refresh fails, use old token
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // METHOD 2: Call API to refresh the token
  // ═══════════════════════════════════════════════════════════════════════
  Future<String?> refreshToken(String oldToken) async {
    try {
      if (kDebugMode) print("🔄 Calling refresh token API...");

      final response = await http
          .post(
            Uri.parse(ApiBase.refreshToken), // You need to add this URL
            headers: {
              'Authorization': 'Bearer $oldToken',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Get new token from response (adjust based on your API)
        String? newToken = data['token'] ?? data['data']?['token'];

        if (newToken != null) {
          // Save new token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keyAuthToken, newToken);

          if (kDebugMode) print("✅ New token saved!");
          return newToken;
        }
      } else if (response.statusCode == 401) {
        // Token is completely dead - user must login again
        if (kDebugMode) print("❌ Token expired - need to login again");
        return null;
      }

      return oldToken; // If anything fails, return old token
    } catch (e) {
      if (kDebugMode) print("❌ Error refreshing token: $e");
      return oldToken;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // METHOD 3: Update clearSession to reset refresh tracker
  // ═══════════════════════════════════════════════════════════════════════
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyLoginTime);
      await prefs.remove(_keyUserData);
      await prefs.remove(_keyEmployeeId);
      await prefs.remove(_keyLoggedInEmpId);
      await prefs.remove(_keyAuthToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyRoleId);

      _lastTokenRefresh = null; // ✅ Reset this

      if (kDebugMode) print("✅ Session cleared");
    } catch (e) {
      if (kDebugMode) print("❌ Error clearing session: $e");
    }
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
  static const String _keyUserId = 'user_id'; // ✅ Added
  static const String _keyRoleId = 'role_id';

  // ✅ Added

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

      // ✅ Extract and save token
      String token = _extractToken(userData);
      if (token.isNotEmpty) {
        await prefs.setString(_keyAuthToken, token);
        if (kDebugMode) {
          print("✅ Token saved successfully");
          print(
            "🔑 Token (first 30 chars): ${token.substring(0, min(30, token.length))}...",
          );
          print("📏 Token length: ${token.length} characters");
        }
      } else {
        if (kDebugMode) {
          print("⚠️ WARNING: No token found in login response!");
          print("📦 Available keys in response: ${userData.keys.toList()}");
          if (userData['data'] != null) {
            print(
              "📦 Keys in 'data': ${(userData['data'] as Map).keys.toList()}",
            );
          }
          if (userData['user'] != null) {
            print(
              "📦 Keys in 'user': ${(userData['user'] as Map).keys.toList()}",
            );
          }
        }
      }

      // ✅ Extract and save user_id
      final userId = _extractUserId(userData);
      if (userId.isNotEmpty) {
        await prefs.setString(_keyEmployeeId, userId);
        await prefs.setString(_keyLoggedInEmpId, userId);
        await prefs.setString(_keyUserId, userId); // ✅ Save to user_id key
        if (kDebugMode) print("✅ User ID saved: $userId");
      } else {
        if (kDebugMode) print("⚠️ Warning: No user ID found");
      }

      // ✅ Extract and save role_id
      final roleId = _extractRoleId(userData);
      if (roleId.isNotEmpty) {
        await prefs.setString(_keyRoleId, roleId);
        if (kDebugMode) print("✅ Role ID saved: $roleId");
      } else {
        // Default to "1" if not found
        await prefs.setString(_keyRoleId, "1");
        if (kDebugMode) print("⚠️ Role ID not found, defaulting to '1'");
      }

      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("✅ Session saved successfully");
        print("═══════════════════════════════════════");

        // Verify what was saved
        print("\n🔍 Verifying saved data:");
        print(
          "  Token: ${prefs.getString(_keyAuthToken)?.substring(0, 30)}...",
        );
        print("  User ID: ${prefs.getString(_keyUserId)}");
        print("  Role ID: ${prefs.getString(_keyRoleId)}");
        print("  Employee ID: ${prefs.getString(_keyEmployeeId)}");
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
        print("🆔 User ID: ${await getUserId()}");
        print("🎭 Role ID: ${await getRoleId()}");
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
          print(
            "⏰ Session was ${minutesSinceLogin} minutes old (max: $_sessionExpiryMinutes)",
          );
        }
        await clearSession();
        return false;
      }

      if (kDebugMode) {
        print("✅ Session is valid");
        print(
          "⏰ Session age: $minutesSinceLogin minutes (expires in ${_sessionExpiryMinutes - minutesSinceLogin} min)",
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) print("❌ Error checking session validity: $e");
      return false;
    }
  }

  /// Clear all session data

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
          print(
            "🔑 Token (first 30 chars): ${token.substring(0, min(30, token.length))}...",
          );
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

  /// Get user ID (✅ IMPROVED)
  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try to get from saved user_id key first
      String? userId = prefs.getString(_keyUserId);

      if (userId != null && userId.isNotEmpty) {
        if (kDebugMode) print("👤 User ID retrieved: $userId");
        return userId;
      }

      // Fallback: try employee_id
      userId = prefs.getString(_keyEmployeeId);
      if (userId != null && userId.isNotEmpty) {
        if (kDebugMode) print("👤 User ID from employee_id: $userId");
        return userId;
      }

      // Last resort: try to extract from userData
      final userData = prefs.getString(_keyUserData);
      if (userData != null) {
        final decoded = jsonDecode(userData) as Map<String, dynamic>;
        userId = _extractUserId(decoded);
        if (userId.isNotEmpty) {
          // Save it for next time
          await prefs.setString(_keyUserId, userId);
          if (kDebugMode) print("👤 User ID extracted and saved: $userId");
          return userId;
        }
      }

      if (kDebugMode) print("❌ User ID not found!");
      return null;
    } catch (e) {
      if (kDebugMode) print("❌ Error getting user ID: $e");
      return null;
    }
  }

  /// Get role ID (✅ IMPROVED)
  Future<String?> getRoleId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try to get from saved role_id key first
      String? roleId = prefs.getString(_keyRoleId);

      if (roleId != null && roleId.isNotEmpty) {
        if (kDebugMode) print("🎭 Role ID retrieved: $roleId");
        return roleId;
      }

      // Last resort: try to extract from userData
      final userData = prefs.getString(_keyUserData);
      if (userData != null) {
        final decoded = jsonDecode(userData) as Map<String, dynamic>;
        roleId = _extractRoleId(decoded);
        if (roleId.isNotEmpty) {
          // Save it for next time
          await prefs.setString(_keyRoleId, roleId);
          if (kDebugMode) print("🎭 Role ID extracted and saved: $roleId");
          return roleId;
        }
      }

      // Default to admin role
      if (kDebugMode) print("⚠️ Role ID not found, defaulting to '1'");
      return "1";
    } catch (e) {
      if (kDebugMode) print("❌ Error getting role ID: $e");
      return "1";
    }
  }

  /// Get employee ID
  Future<String?> getEmployeeId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final empId = prefs.getString(_keyEmployeeId);

      // If not found, try user_id as fallback
      if (empId == null || empId.isEmpty) {
        return await getUserId();
      }

      return empId;
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
    if (userData['access_token'] != null &&
        userData['access_token'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 Token found in: userData['access_token']");
      return userData['access_token'].toString();
    }

    // 5. data.access_token
    if (userData['data'] != null && userData['data'] is Map) {
      final data = userData['data'] as Map;
      if (data['access_token'] != null &&
          data['access_token'].toString().isNotEmpty) {
        if (kDebugMode)
          print("🔍 Token found in: userData['data']['access_token']");
        return data['access_token'].toString();
      }
    }

    // 6. bearer_token
    if (userData['bearer_token'] != null &&
        userData['bearer_token'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 Token found in: userData['bearer_token']");
      return userData['bearer_token'].toString();
    }

    if (kDebugMode) print("❌ Token not found in any expected location");
    return '';
  }

  /// Extract user ID from login response (✅ IMPROVED)
  String _extractUserId(Map<String, dynamic> userData) {
    // Try multiple possible locations for user ID

    // 1. user.user_id
    if (userData['user'] != null && userData['user'] is Map) {
      final user = userData['user'] as Map;

      if (user['user_id'] != null && user['user_id'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 User ID found in: user.user_id");
        return user['user_id'].toString();
      }
      if (user['id'] != null && user['id'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 User ID found in: user.id");
        return user['id'].toString();
      }
      if (user['employee_id'] != null &&
          user['employee_id'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 User ID found in: user.employee_id");
        return user['employee_id'].toString();
      }
      if (user['employment_id'] != null &&
          user['employment_id'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 User ID found in: user.employment_id");
        return user['employment_id'].toString();
      }
    }

    // 2. Direct fields
    if (userData['user_id'] != null &&
        userData['user_id'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 User ID found in: userData.user_id");
      return userData['user_id'].toString();
    }

    if (userData['userId'] != null &&
        userData['userId'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 User ID found in: userData.userId");
      return userData['userId'].toString();
    }

    if (userData['employee_id'] != null &&
        userData['employee_id'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 User ID found in: userData.employee_id");
      return userData['employee_id'].toString();
    }

    if (userData['employment_id'] != null &&
        userData['employment_id'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 User ID found in: userData.employment_id");
      return userData['employment_id'].toString();
    }

    // 3. data.user_id
    if (userData['data'] != null && userData['data'] is Map) {
      final data = userData['data'] as Map;
      if (data['user_id'] != null && data['user_id'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 User ID found in: data.user_id");
        return data['user_id'].toString();
      }
      if (data['employee_id'] != null &&
          data['employee_id'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 User ID found in: data.employee_id");
        return data['employee_id'].toString();
      }
      if (data['id'] != null && data['id'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 User ID found in: data.id");
        return data['id'].toString();
      }
    }

    if (kDebugMode) print("⚠️ User ID not found in any expected location");
    return '';
  }

  /// Extract role ID from login response (✅ NEW METHOD)
  String _extractRoleId(Map<String, dynamic> userData) {
    // Try multiple possible locations for role ID

    // 1. user.role_id
    if (userData['user'] != null && userData['user'] is Map) {
      final user = userData['user'] as Map;

      if (user['role_id'] != null && user['role_id'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 Role ID found in: user.role_id");
        return user['role_id'].toString();
      }
      if (user['roleId'] != null && user['roleId'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 Role ID found in: user.roleId");
        return user['roleId'].toString();
      }
      if (user['role'] != null && user['role'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 Role ID found in: user.role");
        return user['role'].toString();
      }
    }

    // 2. Direct fields
    if (userData['role_id'] != null &&
        userData['role_id'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 Role ID found in: userData.role_id");
      return userData['role_id'].toString();
    }

    if (userData['roleId'] != null &&
        userData['roleId'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 Role ID found in: userData.roleId");
      return userData['roleId'].toString();
    }

    if (userData['role'] != null && userData['role'].toString().isNotEmpty) {
      if (kDebugMode) print("🔍 Role ID found in: userData.role");
      return userData['role'].toString();
    }

    // 3. data.role_id
    if (userData['data'] != null && userData['data'] is Map) {
      final data = userData['data'] as Map;
      if (data['role_id'] != null && data['role_id'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 Role ID found in: data.role_id");
        return data['role_id'].toString();
      }
      if (data['role'] != null && data['role'].toString().isNotEmpty) {
        if (kDebugMode) print("🔍 Role ID found in: data.role");
        return data['role'].toString();
      }
    }

    if (kDebugMode) print("⚠️ Role ID not found in any expected location");
    return '';
  }

  /// Debug: Print all session data (✅ IMPROVED)
  Future<void> debugPrintSessionData() async {
    if (!kDebugMode) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      print("═══════════════════════════════════════");
      print("📝 COMPLETE SESSION DATA:");
      print("═══════════════════════════════════════");
      print("✅ isLoggedIn: ${prefs.getBool(_keyIsLoggedIn)}");
      print("⏰ loginTime: ${prefs.getInt(_keyLoginTime)}");
      print("🆔 user_id: ${prefs.getString(_keyUserId) ?? 'NOT SET ❌'}");
      print("🎭 role_id: ${prefs.getString(_keyRoleId) ?? 'NOT SET ❌'}");
      print("🆔 employeeId: ${prefs.getString(_keyEmployeeId)}");
      print("🆔 logged_in_emp_id: ${prefs.getString(_keyLoggedInEmpId)}");

      final token = prefs.getString(_keyAuthToken);
      if (token != null && token.isNotEmpty) {
        print("🔑 authToken: ${token.substring(0, min(50, token.length))}...");
        print("📏 Token length: ${token.length} chars");
      } else {
        print("🔑 authToken: NOT FOUND ❌");
      }

      final userData = prefs.getString(_keyUserData);
      if (userData != null && userData.isNotEmpty) {
        print(
          "📦 userData (first 200 chars): ${userData.substring(0, min(200, userData.length))}...",
        );
      } else {
        print("📦 userData: NOT FOUND ❌");
      }

      print("═══════════════════════════════════════");
      print("🔧 All SharedPreferences Keys:");
      print(prefs.getKeys().toList());
      print("═══════════════════════════════════════");

      print("\n🧪 Testing getters:");
      print("getUserId(): ${await getUserId()}");
      print("getRoleId(): ${await getRoleId()}");
      print("getEmployeeId(): ${await getEmployeeId()}");
      print("═══════════════════════════════════════");
    } catch (e) {
      print("❌ Error printing debug data: $e");
    }
  }

  /// Validate token format (basic check)
  bool isValidTokenFormat(String? token) {
    if (token == null || token.isEmpty) return false;
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
