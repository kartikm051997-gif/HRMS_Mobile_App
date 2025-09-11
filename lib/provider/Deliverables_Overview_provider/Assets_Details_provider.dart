import 'package:flutter/material.dart';

class AssetsDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, String>> assetsDetails = [];

  /// Fetch Assets details (Dummy API for now)
  Future<void> fetchAssetsDetails(String empId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Dummy data — replace with API response later
      assetsDetails = [
        {
          "Date": "",
          "Circular Name	": "Biometric Punching Requirement",
          "Download": "",
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
