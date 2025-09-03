import 'package:flutter/material.dart';

class ForgetPasswordProvider extends ChangeNotifier {
  final forgetPasswordController = TextEditingController();

  bool isLoading = false; // ✅ Added loading state

  // Example login or forget-password request
  Future<void> login(BuildContext context) async {
    if (isLoading) return; // Avoid multiple taps
    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); // ⏳ Simulate API call

      // ✅ Show success message (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }

  }
}
