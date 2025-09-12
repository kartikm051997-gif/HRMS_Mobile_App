import 'package:flutter/material.dart';

class PfProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, String>> pfDetails = [];

  /// Fetch bank details (Dummy API for now)
  Future<void> fetchPfDetails(String empId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Dummy data — replace with API response later
      pfDetails = [
        {
          "Date": "11-02-2025",
          "PF Month	": "January 2025",
          "PF Amount": "0.00",
        },
      ];
    } catch (e) {
      debugPrint("Error fetching bank details: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
