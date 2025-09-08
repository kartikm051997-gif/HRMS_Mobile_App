import 'package:flutter/material.dart';

class BankDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, String>> bankDetails = [];

  /// Fetch bank details (Dummy API for now)
  Future<void> fetchBankDetails(String empId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Dummy data — replace with API response later
      bankDetails = [
        {
          "bank": "ICICI BANK",
          "accountNumber": "7962038430",
          "ifsc": "IDIB000S004",
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
