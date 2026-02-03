import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../servicesAPI/EmployeeDetailsService/employee_details_service.dart';

class BankDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Map<String, String>> bankDetails = [];

  /// Fetch bank details from API
  Future<void> fetchBankDetails(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print("🔄 BankDetailsProvider: Fetching bank details for user_id: $userId");
      }

      final service = EmployeeDetailsService();
      final response = await service.getEmployeeDetails(userId);

      if (response.data?.bankDetails != null) {
        final bank = response.data!.bankDetails!;
        bankDetails = [
          {
            "bank": bank.bankName ?? "N/A",
            "accountNumber": bank.accountNumber ?? "N/A",
            "ifsc": bank.bankIfscCode ?? "N/A",
            "branchName": bank.branchName ?? "",
            "accountName": bank.accountName ?? "",
            "panNumber": bank.panNumber ?? "N/A",
            "uanNumber": bank.uanNumber ?? "N/A",
          },
        ];

        if (kDebugMode) {
          print("✅ BankDetailsProvider: Bank details fetched successfully");
          print("   Bank: ${bank.bankName ?? 'N/A'}");
          print("   Account: ${bank.accountNumber ?? 'N/A'}");
        }
      } else {
        bankDetails = [];
        if (kDebugMode) print("⚠️ BankDetailsProvider: No bank details in response");
      }
    } catch (e) {
      debugPrint("❌ Error fetching bank details: $e");
      bankDetails = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
