import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart'; // ✅ Add this
import '../../apibaseScreen/Api_Base_Screens.dart';
import '../../core/routes/routes.dart';
import '../../model/login_model/login_model.dart';
import '../UserTrackingProvider/UserTrackingProvider.dart'; // ✅ Add this

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
  // LOGIN API
  // ---------------------------------------------------------------------------
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
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );

      if (kDebugMode) {
        print("✅ Response Status: ${response.statusCode}");
        print("📦 Response Body: ${response.body}");
      }
      if (_loginData != null) {
        print("✅ Restored user: ${_loginData?.user?.fullname}");
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        _loginData = LoginApiModel.fromJson(jsonResponse);

        if (_loginData?.status?.toLowerCase() == 'success' ||
            _loginData?.status == '1' ||
            _loginData?.status?.toLowerCase() == 'ok' ||
            _loginData?.status?.toLowerCase() == 'true') {
          _showSnackBar(context, "✅ Login Successful!");

          await _saveLoginSession(jsonResponse);

          // ✅ Handle tracking provider login
          await handleLoginSuccess(context, jsonResponse);

          await _verifyDataSaved();

          _clearFields();

          await Future.delayed(const Duration(milliseconds: 400));
          _navigateToDashboard(context);
        } else {
          _errorMessage = _loginData?.message ?? "Invalid ID or Password";
          _showSnackBar(context, _errorMessage!);
        }
      } else {
        _errorMessage = "Login failed (HTTP ${response.statusCode})";
        _showSnackBar(context, _errorMessage!);
      }
    } on TimeoutException catch (e) {
      _showSnackBar(context, "⏱️ Timeout: $e");
    } on SocketException {
      _showSnackBar(context, "❌ Network error. Check connection.");
    } catch (e) {
      _showSnackBar(context, "❌ Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
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

      // ✅ Extract and save employee ID
      final userId = userData['userId']?.toString() ?? '';
      await prefs.setString('employeeId', userId);
      await prefs.setString('logged_in_emp_id', userId); // Also save as logged_in_emp_id

      if (kDebugMode) {
        print("✅ Saved to SharedPreferences:");
        print("🆔 employeeId: $userId");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error saving session: $e");
    }
  }

  // ---------------------------------------------------------------------------
  // HANDLE LOGIN SUCCESS - CLEAN UP TRACKING DATA
  // ---------------------------------------------------------------------------
  Future<void> handleLoginSuccess(
      BuildContext context,
      Map<String, dynamic> userData,
      ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newUserId = userData['userId']?.toString() ?? '';

      // ✅ Get the tracking provider from context
      final trackingProvider = context.read<UserTrackingProvider>();

      // Load previous user ID
      final oldUserId = prefs.getString('employeeId');

      if (kDebugMode) {
        print("👥 Old User: $oldUserId | New User: $newUserId");
      }

      // ✅ If different user logs in
      if (oldUserId != null && oldUserId != newUserId) {
        // Clear everything for previous user
        await trackingProvider.setUserId(oldUserId);
        await trackingProvider.clearCurrentUserData(clearHistory: true);

        if (kDebugMode) print("🧹 Cleared old user's full tracking data");
      } else {
        // Same user logs in again - keep history
        await trackingProvider.clearCurrentUserData(clearHistory: false);
        if (kDebugMode) print("✅ Same user re-login, kept history");
      }

      // ✅ Set up for the new user
      await prefs.setString('employeeId', newUserId);
      await prefs.setString('logged_in_emp_id', newUserId);
      await trackingProvider.setUserId(newUserId);

      if (kDebugMode) {
        print("✅ Tracking provider now active for user: $newUserId");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error in handleLoginSuccess: $e");
      // Don't throw - allow login to continue even if tracking setup fails
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
        // ❌ Session expired, clear only login data (not employeeId)
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
  // SNACKBAR / NAVIGATION / UTILITIES
  // ---------------------------------------------------------------------------
  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 3),
        backgroundColor: msg.contains("✅") ? Colors.green : Colors.red,
      ),
    );
  }

  void _navigateToDashboard(BuildContext context) {
    try {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.bottomNav,
            (route) => false,
      );
    } catch (_) {
      Get.offAllNamed(AppRoutes.bottomNav);
    }
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

/// TimeoutException class (for clarity)
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}