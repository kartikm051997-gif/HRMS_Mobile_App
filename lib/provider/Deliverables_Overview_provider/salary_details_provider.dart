import 'package:flutter/material.dart';

class SalaryDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, String>> salaryDetails = [];

  /// Fetch bank details (Dummy API for now)
  Future<void> fetchSalaryDetails(String empId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Dummy data — replace with API response later
      salaryDetails = [
        {"Annual CTC": "420000", "Monthly Salaryr": "35000"},
      ];
    } catch (e) {
      debugPrint("Error fetching bank details: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
