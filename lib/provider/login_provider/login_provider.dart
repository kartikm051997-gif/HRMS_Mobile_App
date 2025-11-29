import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../apibaseScreen/Api_Base_Screens.dart';
import '../../core/routes/routes.dart';
import '../../model/login_model/login_model.dart';

/// Allow self-signed certs (dev only)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class LoginProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  LoginApiModel? _loginData;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  LoginApiModel? get loginData => _loginData;
  String? get errorMessage => _errorMessage;

  bool rememberMe = false;

  void toggleRemember() {
    rememberMe = !rememberMe;
    notifyListeners();
  }

  LoginProvider() {
    HttpOverrides.global = MyHttpOverrides();
  }

  // ---------------------------------------------------------------------------
  // LOGIN API - Uses GetX for navigation to avoid context issues
  // ---------------------------------------------------------------------------
  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showGetXSnackBar("Please fill all fields", isError: true);
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) print("🔄 Attempting login...");

      final response = await http
          .post(
            Uri.parse(ApiBase.loginEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'id': emailController.text.trim(),
              'pass': passwordController.text.trim(),
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Connection timeout'),
          );

      if (kDebugMode) {
        print("✅ Response Status: ${response.statusCode}");
        print("📦 Response Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        _loginData = LoginApiModel.fromJson(jsonResponse);

        if (_loginData?.status?.toLowerCase() == 'success' ||
            _loginData?.status == '1' ||
            _loginData?.status?.toLowerCase() == 'ok' ||
            _loginData?.status?.toLowerCase() == 'true') {
          // Save session data
          await _saveLoginSession(jsonResponse);
          await _verifyDataSaved();

          _clearFields();

          _showGetXSnackBar("Login Successful!", isError: false);

          // ✅ Use GetX navigation - doesn't need context
          await Future.delayed(const Duration(milliseconds: 300));
          Get.offAllNamed(AppRoutes.bottomNav);
        } else {
          _errorMessage = _loginData?.message ?? "Invalid ID or Password";
          _showGetXSnackBar(_errorMessage!, isError: true);
        }
      } else {
        _errorMessage = "Login failed (HTTP ${response.statusCode})";
        _showGetXSnackBar(_errorMessage!, isError: true);
      }
    } on TimeoutException catch (e) {
      _showGetXSnackBar("Timeout: $e", isError: true);
    } on SocketException {
      _showGetXSnackBar("Network error. Check connection.", isError: true);
    } catch (e) {
      _showGetXSnackBar("Error: $e", isError: true);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // LOGOUT - Clears session and navigates to login
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear all login session data
      await prefs.remove('isLoggedIn');
      await prefs.remove('loginTime');
      await prefs.remove('userData');
      await prefs.remove('employeeId');
      await prefs.remove('logged_in_emp_id');

      // Clear local state
      _loginData = null;
      _errorMessage = null;
      _clearFields();

      notifyListeners();

      if (kDebugMode) print("✅ Logout successful - session cleared");

      // ✅ Use GetX navigation - doesn't need context
      Get.offAllNamed(AppRoutes.loginScreen);
    } catch (e) {
      if (kDebugMode) print("❌ Error during logout: $e");
      // Still try to navigate to login
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }

  // ---------------------------------------------------------------------------
  // SAVE SESSION + EMPLOYEE ID
  // ---------------------------------------------------------------------------
  Future<void> _saveLoginSession(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save entire login response
      final userDataString = jsonEncode(userData);
      await prefs.setString('userData', userDataString);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('loginTime', DateTime.now().millisecondsSinceEpoch);

      // Extract and save employee ID
      final userId = userData['userId']?.toString() ?? '';
      await prefs.setString('employeeId', userId);
      await prefs.setString('logged_in_emp_id', userId);

      if (kDebugMode) {
        print("✅ Saved to SharedPreferences:");
        print("🆔 employeeId: $userId");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error saving session: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // INITIALIZE SESSION (check expiry)
  // ---------------------------------------------------------------------------
  Future<bool> initializeSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final loginTime = prefs.getInt('loginTime');

      if (!isLoggedIn || loginTime == null) {
        _loginData = null;
        notifyListeners();
        if (kDebugMode) print("❌ No login session found");
        return false;
      }

      final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTime);
      final now = DateTime.now();

      // 2 days (2880 minutes)
      if (now.difference(loginDate).inMinutes >= 2880) {
        await prefs.remove('isLoggedIn');
        await prefs.remove('loginTime');
        await prefs.remove('userData');

        _loginData = null;
        notifyListeners();
        if (kDebugMode) print("❌ Session expired after 2 days");
        return false;
      }

      // Load user data
      final userData = prefs.getString('userData');
      if (userData != null && userData.isNotEmpty) {
        final decoded = jsonDecode(userData);
        _loginData = LoginApiModel.fromJson(decoded);
        notifyListeners();
        if (kDebugMode) print("✅ Session restored");
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print("❌ initializeSession error: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // VERIFY SAVED DATA (debug)
  // ---------------------------------------------------------------------------
  Future<void> _verifyDataSaved() async {
    final prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print("📝 userData: ${prefs.getString('userData')}");
      print("✅ isLoggedIn: ${prefs.getBool('isLoggedIn')}");
      print("⏰ loginTime: ${prefs.getInt('loginTime')}");
      print("🆔 employeeId: ${prefs.getString('employeeId')}");
    }
  }

  // ---------------------------------------------------------------------------
  // GETX SNACKBAR - Doesn't need BuildContext (safe after async)
  // ---------------------------------------------------------------------------
  void _showGetXSnackBar(String message, {required bool isError}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
    );
  }

  void _clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

/// TimeoutException class
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}
