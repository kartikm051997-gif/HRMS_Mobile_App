import 'package:flutter/material.dart';

class ESIProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, String>> ESIDetails = [];

  /// Fetch bank details (Dummy API for now)
  Future<void> fetchESIDetails(String empId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Dummy data — replace with API response later
      ESIDetails = [
        {
          "Date": "11-02-2025",
          "ESI Month": "January 2025",
          "ESI Amount": "0.00",
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
