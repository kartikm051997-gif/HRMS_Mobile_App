import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../servicesAPI/EmployeeDetailsService/employee_details_service.dart';

class SalaryDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, String>> salaryDetails = [];

  /// Fetch salary details from API
  Future<void> fetchSalaryDetails(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print("🔄 SalaryDetailsProvider: Fetching salary details for user_id: $userId");
      }

      final service = EmployeeDetailsService();
      final response = await service.getEmployeeDetails(userId);

      if (response.data?.salaryDetails != null) {
        final salary = response.data!.salaryDetails!;
        salaryDetails = [
          {
            "annual CTC": salary.annualCtc ?? "0.00",
            "monthly salary": salary.monthlyCtc ?? "0.00",
            "basic": salary.basic ?? "0.00",
            "hra": salary.hra ?? "0.00",
            "pf": salary.pf?.toString() ?? "0",
            "esi": salary.esi ?? "0.00",
            "monthly_take_home": salary.monthlyTakeHome ?? "0.00",
            "monthly_tds": salary.monthlyTds ?? "0.00",
          },
        ];

        if (kDebugMode) {
          print("✅ SalaryDetailsProvider: Salary details fetched successfully");
          print("   Annual CTC: ${salary.annualCtc ?? 'N/A'}");
          print("   Monthly CTC: ${salary.monthlyCtc ?? 'N/A'}");
        }
      } else {
        salaryDetails = [];
        if (kDebugMode) print("⚠️ SalaryDetailsProvider: No salary details in response");
      }
    } catch (e) {
      debugPrint("❌ Error fetching salary details: $e");
      salaryDetails = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
