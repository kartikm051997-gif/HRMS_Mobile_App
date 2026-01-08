// File: lib/provider/login_provider/login_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/routes.dart';
import '../../model/login_model/login_model.dart';
import '../../servicesAPI/LogInService/LogIn_Service.dart';

/// Login Provider - Manages login state and UI logic
class LoginProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State variables
  bool _isLoading = false;
  LoginApiModel? _loginData;
  String? _errorMessage;
  bool _rememberMe = false;
  String get userRole {
    return _loginData?.user?.roleId?.toString() ?? "";
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
      // Call auth service
      final loginModel = await _authService.login(
        username: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Update state
      _loginData = loginModel;
      _clearFields();

      // Show success message
      _showSnackBar("Login Successful!", isError: false);

      // Navigate to home
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed(AppRoutes.bottomNav);
    } catch (e) {
      // Handle error
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _showSnackBar(_errorMessage!, isError: true);

      if (kDebugMode) print("❌ LoginProvider: Login failed - $_errorMessage");
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
  Future<bool> initializeSession() async {
    try {
      // Check if session is valid
      final isValid = await _authService.isSessionValid();

      if (!isValid) {
        _loginData = null;
        notifyListeners();
        return false;
      }

      // Load session data
      final loginModel = await _authService.loadLoginSession();

      if (loginModel != null) {
        _loginData = loginModel;
        notifyListeners();

        if (kDebugMode) print("✅ LoginProvider: Session restored");
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
