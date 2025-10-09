// lib/provider/login_provider/login_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apibaseScreen/Api_Base_Screens.dart';
import '../../core/routes/routes.dart';
import 'package:get/get.dart';
import '../../model/login_model/login_model.dart';

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

  LoginProvider() {
    HttpOverrides.global = MyHttpOverrides();
  }

  /// LOGIN API
  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar(context, "Please fill all fields");
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
            onTimeout:
                () =>
                    throw TimeoutException(
                      'Connection timeout after 30 seconds',
                    ),
          );

      if (kDebugMode) print("✅ Response Status: ${response.statusCode}");
      if (kDebugMode) print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          _loginData = LoginApiModel.fromJson(jsonResponse);

          if (kDebugMode) print("📊 Login Status: ${_loginData?.status}");
          if (kDebugMode) print("📝 Login Message: ${_loginData?.message}");
          if (kDebugMode) print("👤 User: ${_loginData?.user}");
          if (kDebugMode) print("🆔 User ID: ${_loginData?.userId}");

          // Check success
          if (_loginData?.status == 'success' ||
              _loginData?.status == '1' ||
              _loginData?.status?.toLowerCase() == 'ok' ||
              _loginData?.status?.toLowerCase() == 'true') {
            _showSnackBar(context, "✅ Login Successful!");

            // FIRST: Save to SharedPreferences
            await _saveLoginSession(jsonResponse);

            // SECOND: Verify it was saved
            await _verifyDataSaved();

            _clearFields();

            await Future.delayed(const Duration(milliseconds: 500));
            _navigateToDashboard(context);
          } else {
            _errorMessage = _loginData?.message ?? "Invalid ID or Password";
            _showSnackBar(context, _errorMessage!);
          }
        } catch (e) {
          _errorMessage = "Error parsing response: $e";
          _showSnackBar(context, _errorMessage!);
          if (kDebugMode) print("❌ Parse Error: $e");
        }
      } else if (response.statusCode == 401) {
        _errorMessage = "Invalid ID or Password";
        _showSnackBar(context, _errorMessage!);
      } else if (response.statusCode == 404) {
        _errorMessage = "API endpoint not found";
        _showSnackBar(context, _errorMessage!);
      } else if (response.statusCode == 500) {
        _errorMessage = "Server error. Please try again later";
        _showSnackBar(context, _errorMessage!);
      } else {
        _errorMessage = "Login failed. Status: ${response.statusCode}";
        _showSnackBar(context, _errorMessage!);
      }
    } on TimeoutException catch (e) {
      _errorMessage =
          "⏱️ Connection timeout. Please check your internet connection";
      _showSnackBar(context, _errorMessage!);
      if (kDebugMode) print("❌ Timeout Error: $e");
    } on SocketException catch (e) {
      _errorMessage = "❌ Network error. Please check your internet connection";
      _showSnackBar(context, _errorMessage!);
      if (kDebugMode) print("❌ Socket Error: $e");
    } catch (e) {
      _errorMessage = "Error: ${e.toString()}";
      _showSnackBar(context, _errorMessage!);
      if (kDebugMode) print("❌ Login Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// VERIFY DATA SAVED
  Future<void> _verifyDataSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('userData');
      if (kDebugMode) print("📝 Saved userData: $savedData");
      if (kDebugMode) print("✅ isLoggedIn: ${prefs.getBool('isLoggedIn')}");
      if (kDebugMode) print("⏰ loginTime: ${prefs.getInt('loginTime')}");
    } catch (e) {
      if (kDebugMode) print("❌ Verify error: $e");
    }
  }

  /// SHOW SNACKBAR
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: message.contains("✅") ? Colors.green : Colors.red,
      ),
    );
  }

  /// Initialize session: load user data + check session validity
  Future<bool> initializeSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      final loginTime = prefs.getInt('loginTime');

      if (kDebugMode) print("🔍 Checking session...");
      if (kDebugMode) print("✅ isLoggedIn: $isLoggedIn");
      if (kDebugMode) print("⏰ loginTime: $loginTime");

      if (!isLoggedIn || loginTime == null) {
        _loginData = null;
        notifyListeners();
        if (kDebugMode) print("❌ No login session found");
        return false;
      }

      // Check if session expired (20 minutes)
      final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTime);
      final now = DateTime.now();
      if (now.difference(loginDate).inMinutes >= 20) {
        await prefs.clear();
        _loginData = null;
        notifyListeners();
        if (kDebugMode) print("❌ Session expired");
        return false;
      }

      // Load user data from SharedPreferences
      final userData = prefs.getString('userData');
      if (kDebugMode) print("📝 Loading userData: $userData");

      if (userData != null && userData.isNotEmpty) {
        try {
          final decodedData = jsonDecode(userData);
          _loginData = LoginApiModel.fromJson(decodedData);
          notifyListeners();
          if (kDebugMode) print("✅ User data loaded successfully");
          if (kDebugMode) print("👤 User: ${_loginData?.user?.fullname}");
          if (kDebugMode) print("🏢 Branch: ${_loginData?.user?.branch}");
          return true;
        } catch (e) {
          if (kDebugMode) print("❌ Error decoding userData: $e");
          return false;
        }
      } else {
        if (kDebugMode) print("❌ userData is null or empty");
        return false;
      }
    } catch (e) {
      _loginData = null;
      notifyListeners();
      if (kDebugMode) print("❌ Initialize session error: $e");
      return false;
    }
  }

  /// CLEAR TEXT FIELDS
  void _clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  /// NAVIGATE TO DASHBOARD
  void _navigateToDashboard(BuildContext context) {
    try {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.dashboardScreen, (route) => false);
    } catch (e) {
      if (kDebugMode) print("❌ Navigation Error: $e");
      Get.offAllNamed(AppRoutes.dashboardScreen);
    }
  }

  /// SAVE LOGIN SESSION WITH USER DATA
  Future<void> _saveLoginSession(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save the entire response as userData
      final userDataString = jsonEncode(userData);
      await prefs.setString('userData', userDataString);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setInt('loginTime', DateTime.now().millisecondsSinceEpoch);

      if (kDebugMode) print("✅ Saved to SharedPreferences:");
      if (kDebugMode) print("📝 userData: $userDataString");
      if (kDebugMode) print("✅ isLoggedIn: true");
    } catch (e) {
      if (kDebugMode) print("❌ Error saving session: $e");
    }
  }

  /// CHECK SESSION VALIDITY (used in SplashScreen)
  Future<bool> checkSessionValidity() async {
    return await initializeSession();
  }

  /// LOGOUT

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
