import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../servicesAPI/EmployeeDetailsService/employee_details_service.dart';
import '../../../model/EmployeeDetailsModel/employee_details_model.dart';

class PfDetail {
  final String date;
  final String pfMonth;
  final String pfAmount;

  PfDetail({
    required this.date,
    required this.pfMonth,
    required this.pfAmount,
  });
}

class PfProvider extends ChangeNotifier {
  bool isLoading = false;
  List<PfDetail> pfDetails = [];

  /// Fetch PF amounts from payslips
  Future<void> fetchPfDetails(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print("🔄 PfProvider: Fetching PF details from payslips for user_id: $userId");
      }

      final service = EmployeeDetailsService();
      final response = await service.getEmployeeDetails(userId);

      pfDetails = [];

      if (response.data?.payslips != null && response.data!.payslips!.payslipList != null) {
        final payslipList = response.data!.payslips!.payslipList!;
        
        for (var payslip in payslipList) {
          if (payslip.pf != null && payslip.pf!.isNotEmpty && payslip.pf != "0.00") {
            // Format month (e.g., "2025-01" -> "January 2025")
            String formattedMonth = _formatMonth(payslip.salaryMonth ?? '');
            String date = payslip.createdDate ?? '';
            
            pfDetails.add(PfDetail(
              date: date,
              pfMonth: formattedMonth,
              pfAmount: payslip.pf!,
            ));
          }
        }
        
        // Sort by date descending (newest first)
        pfDetails.sort((a, b) => b.date.compareTo(a.date));
        
        if (kDebugMode) {
          print("✅ PfProvider: Fetched ${pfDetails.length} PF records");
        }
      } else {
        if (kDebugMode) {
          print("⚠️ PfProvider: No payslips found");
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching PF details: $e");
      pfDetails = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _formatMonth(String? salaryMonth) {
    if (salaryMonth == null || salaryMonth.isEmpty) return 'N/A';
    
    try {
      final parts = salaryMonth.split('-');
      if (parts.length == 2) {
        final year = parts[0];
        final monthNum = int.tryParse(parts[1]) ?? 1;
        final monthNames = [
          '', 'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        return '${monthNames[monthNum]} $year';
      }
    } catch (e) {
      // Keep original format if parsing fails
    }
    return salaryMonth;
  }
}
