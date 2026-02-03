// File: lib/provider/login_provider/login_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/routes.dart';
import '../../model/login_model/login_model.dart';
import '../../servicesAPI/LogInService/LogIn_Service.dart';

/// Login Provider - Manages login state and UI logic
class LoginProvider extends ChangeNotifier {
  final LoginService _authService = LoginService();

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State variables
  bool _isLoading = false;
  LoginApiModel? _loginData;
  String? _errorMessage;
  bool _rememberMe = false;

  String get userRole {
    final roleId = _loginData?.user?.roleId?.toString()?.trim() ?? "";
    if (kDebugMode) {
      print("🔍 LoginProvider.userRole getter called");
      print("   Raw roleId: ${_loginData?.user?.roleId}");
      print("   Processed roleId: '$roleId'");
      print("   Is Admin: ${roleId == "1"}");
    }
    return roleId;
  }

  // Getters
  bool get isLoading => _isLoading;
  LoginApiModel? get loginData => _loginData;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;

  // ═══════════════════════════════════════════════════════════════════════
  // UI ACTIONS
  // ═══════════════════════════════════════════════════════════════════════

  /// Toggle remember me checkbox
  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════════════

  /// Perform login
  Future<void> login(BuildContext context) async {
    // Validate input
    if (!_validateInput()) return;

    _setLoading(true);
    _errorMessage = null;

    try {
      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("🔐 LOGIN ATTEMPT");
        print("Username: ${emailController.text.trim()}");
        print("═══════════════════════════════════════");
      }

      // Call auth service
      final loginModel = await _authService.login(
        username: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Update state
      _loginData = loginModel;

      // ✅ DEBUG: Print what we got from login
      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("🎉 LOGIN SUCCESS - Checking Data");
        print("═══════════════════════════════════════");
        print("Token: ${loginModel.token?.substring(0, 30)}...");
        print("Status: ${loginModel.status}");
        print("Message: ${loginModel.message}");

        if (loginModel.user != null) {
          print("\n👤 USER DATA:");
          final user = loginModel.user!;

          // Print user model fields
          print("  - userId: ${user.userId}");
          print("  - roleId: ${user.roleId}");
          print("  - username: ${user.username}");
          print("  - fullname: ${user.fullname}");
          print("  - email: ${user.email}");
          print("  - avatar: ${user.avatar}");
          print("  - designationId: ${user.designationsId}");
          print("  - location: ${user.location}");
          print("  - appLocation: ${user.appLocation}");
          print("  - lastLogin: ${user.lastLogin}");
          print("  - branch: ${user.location}");

          // Print raw JSON to see ALL fields
          try {
            print("\n📋 RAW USER JSON:");
            final userJson = user.toJson();
            userJson.forEach((key, value) {
              print("  $key: $value");
            });
          } catch (e) {
            print("  ⚠️ Could not print raw JSON: $e");
          }
        } else {
          print("❌ USER DATA IS NULL!");
        }
        print("═══════════════════════════════════════");

        // Verify what was saved
        print("\n🔍 VERIFYING SAVED SESSION...");
        await _authService.debugPrintSessionData();
      }

      _clearFields();

      // Show success message
      _showSnackBar("Login Successful!", isError: false);

      // Navigate to home
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.bottomNav);
    } catch (e) {
      // Handle error - Extract user-friendly message
      String errorMessage = "Invalid username or password. Please try again.";

      final errorString = e.toString();

      // Remove "Exception: " prefix if present
      String extractedMessage = errorString;
      if (errorString.contains('Exception: ')) {
        extractedMessage = errorString.replaceFirst('Exception: ', '').trim();
      } else {
        extractedMessage = errorString.trim();
      }

      // Check if message contains technical details (JSON, HTTP codes, etc.)
      final hasTechnicalDetails =
          extractedMessage.contains('HTTP') ||
          extractedMessage.contains('{') ||
          extractedMessage.contains('"status"') ||
          extractedMessage.contains('"message"') ||
          extractedMessage.startsWith('Login failed');

      // If message is user-friendly and doesn't contain technical details, use it
      if (extractedMessage.isNotEmpty && !hasTechnicalDetails) {
        errorMessage = extractedMessage;
      }
      // Otherwise, use default user-friendly message

      _errorMessage = errorMessage;
      _showSnackBar(_errorMessage!, isError: true);

      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("❌ LOGIN FAILED");
        print("User-friendly error: $_errorMessage");
        print("Raw error: $e");
        print("═══════════════════════════════════════");
      }
    } finally {
      _setLoading(false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════════════

  /// Perform logout
  Future<void> logout() async {
    try {
      if (kDebugMode) print("🚪 Logging out...");

      // Clear session via service
      await _authService.clearSession();

      // Clear local state
      _loginData = null;
      _errorMessage = null;
      _clearFields();

      notifyListeners();

      if (kDebugMode) print("✅ LoginProvider: Logout successful");

      // Navigate to login screen
      Get.offAllNamed(AppRoutes.loginScreen);
    } catch (e) {
      if (kDebugMode) print("❌ LoginProvider: Logout error - $e");

      // Still navigate to login even if error
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SESSION INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════

  /// Initialize session on app start
  /// Returns true if valid session exists, false otherwise
  /// NO inactivity check - session stays valid as long as user is logged in
  Future<bool> initializeSession() async {
    try {
      if (kDebugMode) print("🔄 Initializing session...");

      // Check if session is valid (just checks if logged in, NO inactivity check)
      final isValid = await _authService.isSessionValid();

      if (!isValid) {
        _loginData = null;
        notifyListeners();
        if (kDebugMode) print("❌ No valid session found - user not logged in");
        return false;
      }

      // Load session data
      final loginModel = await _authService.loadLoginSession();

      if (loginModel != null) {
        _loginData = loginModel;
        notifyListeners();

        if (kDebugMode) {
          print("✅ LoginProvider: Session restored");
          print("   User: ${loginModel.user?.username}");
          print("   Role: ${loginModel.user?.roleId}");
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) print("❌ LoginProvider: Session init error - $e");
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════

  /// Get auth token for API calls
  Future<String?> getAuthToken() async {
    return await _authService.getAuthToken();
  }

  /// Get employee ID
  Future<String?> getEmployeeId() async {
    return await _authService.getEmployeeId();
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _authService.getUserId();
  }

  /// Get role ID
  Future<String?> getRoleId() async {
    return await _authService.getRoleId();
  }

  /// Validate input fields
  bool _validateInput() {
    if (emailController.text.trim().isEmpty) {
      _showSnackBar("Please enter username", isError: true);
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      _showSnackBar("Please enter password", isError: true);
      return false;
    }

    return true;
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clear input fields
  void _clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  /// Show snackbar using GetX
  void _showSnackBar(String message, {required bool isError}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      isDismissible: true,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DEBUG
  // ═══════════════════════════════════════════════════════════════════════

  /// Debug: Print session data
  Future<void> debugPrintSession() async {
    await _authService.debugPrintSessionData();
  }

  /// Debug: Test all getters
  Future<void> debugTestGetters() async {
    if (!kDebugMode) return;

    if (kDebugMode) {
      print("═══════════════════════════════════════");
    }
    print("🧪 TESTING ALL GETTERS");
    print("═══════════════════════════════════════");
    print("Token: ${await getAuthToken()}");
    print("User ID: ${await getUserId()}");
    print("Role ID: ${await getRoleId()}");
    print("Employee ID: ${await getEmployeeId()}");
    print("═══════════════════════════════════════");
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DISPOSE
  // ═══════════════════════════════════════════════════════════════════════

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
