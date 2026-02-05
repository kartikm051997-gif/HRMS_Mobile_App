import 'package:flutter/foundation.dart';
import '../../model/EmployeeDetailsModel/employee_details_model.dart';
import '../../servicesAPI/EmployeeDetailsService/employee_details_service.dart';

class PaySlipProvider extends ChangeNotifier {
  List<PayslipItem> _payslip = [];
  bool _isLoading = false;

  List<PayslipItem> get payslip => _payslip;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchPaySlip(String userId) async {
    setLoading(true);
    try {
      if (kDebugMode) {
        print("🔄 PaySlipProvider: Fetching payslips for user_id: $userId");
      }

      final service = EmployeeDetailsService();
      final response = await service.getEmployeeDetails(userId);

      if (response.data?.payslips != null &&
          response.data!.payslips!.payslipList != null) {
        _payslip = response.data!.payslips!.payslipList!;

        if (kDebugMode) {
          print(
            "✅ PaySlipProvider: Fetched ${_payslip.length} payslip documents",
          );
          // Debug: Print payslip details
          for (var slip in _payslip) {
            print("📄 Payslip ${slip.payslipId}: ${slip.salaryMonth}");
          }
        }
      } else {
        _payslip = [];
        if (kDebugMode) {
          print("⚠️ PaySlipProvider: No payslips found");
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching payslip documents: $e");
      _payslip = [];
    } finally {
      setLoading(false);
    }
  }

  void refreshDocuments(String empId) {
    fetchPaySlip(empId);
  }

  void clearDocuments() {
    _payslip.clear();
    notifyListeners();
  }
}
