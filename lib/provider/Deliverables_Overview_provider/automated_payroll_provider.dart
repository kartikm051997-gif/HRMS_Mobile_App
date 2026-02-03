import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AutomatedPayrollProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _payrollRecords = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get payrollRecords => _payrollRecords;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchAutomatedPayroll(String empId) async {
    setLoading(true);
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Dummy data - replace with actual API call later
      _payrollRecords = [
        {
          "id": "1",
          "month": "January 2025",
          "processedDate": "2025-01-31",
          "status": "Processed",
          "grossSalary": "35000",
          "deductions": "5000",
          "netSalary": "30000",
          "paymentMethod": "NEFT",
          "transactionId": "TXN123456789",
        },
        {
          "id": "2",
          "month": "December 2024",
          "processedDate": "2024-12-31",
          "status": "Processed",
          "grossSalary": "35000",
          "deductions": "5000",
          "netSalary": "30000",
          "paymentMethod": "NEFT",
          "transactionId": "TXN987654321",
        },
        {
          "id": "3",
          "month": "November 2024",
          "processedDate": "2024-11-30",
          "status": "Processed",
          "grossSalary": "35000",
          "deductions": "5000",
          "netSalary": "30000",
          "paymentMethod": "NEFT",
          "transactionId": "TXN456789123",
        },
      ];

      if (kDebugMode) {
        print("✅ Fetched ${_payrollRecords.length} automated payroll records");
      }
    } catch (e) {
      debugPrint("❌ Error fetching automated payroll: $e");
      _payrollRecords = [];
    } finally {
      setLoading(false);
    }
  }

  void clearPayrollRecords() {
    _payrollRecords = [];
    notifyListeners();
  }
}
