import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../servicesAPI/EmployeeDetailsService/employee_details_service.dart';
import '../../../model/EmployeeDetailsModel/employee_details_model.dart';

class ESIDetail {
  final String date;
  final String esiMonth;
  final String esiAmount;

  ESIDetail({
    required this.date,
    required this.esiMonth,
    required this.esiAmount,
  });
}

class ESIProvider extends ChangeNotifier {
  bool isLoading = false;
  List<ESIDetail> esiDetails = [];

  /// Fetch ESI amounts from payslips
  Future<void> fetchESIDetails(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print("🔄 ESIProvider: Fetching ESI details from payslips for user_id: $userId");
      }

      final service = EmployeeDetailsService();
      final response = await service.getEmployeeDetails(userId);

      esiDetails = [];

      if (response.data?.payslips != null && response.data!.payslips!.payslipList != null) {
        final payslipList = response.data!.payslips!.payslipList!;
        
        for (var payslip in payslipList) {
          if (payslip.esi != null && payslip.esi!.isNotEmpty && payslip.esi != "0.00") {
            // Format month (e.g., "2025-01" -> "January 2025")
            String formattedMonth = _formatMonth(payslip.salaryMonth ?? '');
            String date = payslip.createdDate ?? '';
            
            esiDetails.add(ESIDetail(
              date: date,
              esiMonth: formattedMonth,
              esiAmount: payslip.esi!,
            ));
          }
        }
        
        // Sort by date descending (newest first)
        esiDetails.sort((a, b) => b.date.compareTo(a.date));
        
        if (kDebugMode) {
          print("✅ ESIProvider: Fetched ${esiDetails.length} ESI records");
        }
      } else {
        if (kDebugMode) {
          print("⚠️ ESIProvider: No payslips found");
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching ESI details: $e");
      esiDetails = [];
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
