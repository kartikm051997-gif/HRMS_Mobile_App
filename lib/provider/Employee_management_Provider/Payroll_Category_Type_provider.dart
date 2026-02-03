import 'package:flutter/material.dart';

class PayrollCategoryTypeProvider extends ChangeNotifier{
  // Add to your NewEmployeeProvider class

// Salary section toggle
  bool _showSalarySection = false;
  bool get showSalarySection => _showSalarySection;

  void toggleSalarySection() {
    _showSalarySection = !_showSalarySection;
    notifyListeners();
  }

// Payroll category types
  final List<String> _payrollCategoryType = [
    "By professional",
    "By student",
    "By Employee",
    "By Employee F-11",
  ];
  // ✅ Deduplicate payroll categories (case-insensitive) to remove duplicates
  List<String> get payrollCategoryType {
    final seen = <String>{};
    final unique = <String>[];
    for (final category in _payrollCategoryType) {
      final normalized = category.trim().toLowerCase();
      if (!seen.contains(normalized)) {
        seen.add(normalized);
        unique.add(category);
      }
    }
    return unique;
  }

  String? _selectedPayrollCategoryType;
  String? get selectedPayrollCategoryType => _selectedPayrollCategoryType;

  void setSelectedPayrollCategoryType(String? value) {
    _selectedPayrollCategoryType = value;
    // Clear all calculated values when changing type
    _clearAllCalculations();
    notifyListeners();
  }

  Future<void> fetchEmployeeDetails(String empId) async {
    try {
      // Dummy API response (replace with real API)
      final response = {"Employment ID": "12881"};

      // Update controllers with API data
      employmentIDController.text = response["Employment ID"] ?? "";

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching employee details: $e");
    }
  }

// Controllers for different types
  final annualProfessionalFeeController = TextEditingController();
  final annualTravelAllowanceController = TextEditingController();
  final annualStipendController = TextEditingController();
  final ctcController = TextEditingController();
  final ctcF11Controller = TextEditingController();
  final employmentIDController = TextEditingController();


// Calculated values
  String monthlyProfessionalFeeBeforeTDS = "0.00";
  String monthlyProfessionalFeeAfterTDS = "0.00";
  String tdsAmount = "0.00";
  String monthlyTravelAllowanceBeforeTDS = "0.00";
  String monthlyTravelAllowanceAfterTDS = "0.00";
  String travelTdsAmount = "0.00";
  String monthlyStipend = "0.00";
  String monthlySalary = "0.00";
  String monthlyBasic = "0.00";
  String hraAmount = "0.00";
  String allowanceAmount = "0.00";
  String pfAmount = "0.00";
  String esiAmount = "0.00";
  String monthlyTakeHomeSalary = "0.00";
  String monthlyF11Salary = "0.00";

// Calculation methods
  void calculateProfessionalFee() {
    double annual = double.tryParse(annualProfessionalFeeController.text) ?? 0;
    double monthly = annual / 12;
    double tds = annual * 0.10; // 10% TDS
    double monthlyTDS = tds / 12;
    double afterTDS = monthly - monthlyTDS;

    monthlyProfessionalFeeBeforeTDS = monthly.toStringAsFixed(2);
    tdsAmount = monthlyTDS.toStringAsFixed(2);
    monthlyProfessionalFeeAfterTDS = afterTDS.toStringAsFixed(2);
    notifyListeners();
  }

  void calculateTravelAllowance() {
    double annual = double.tryParse(annualTravelAllowanceController.text) ?? 0;
    double monthly = annual / 12;
    double tds = 20.00; // Fixed TDS amount
    double afterTDS = monthly - tds;

    monthlyTravelAllowanceBeforeTDS = monthly.toStringAsFixed(2);
    travelTdsAmount = tds.toStringAsFixed(2);
    monthlyTravelAllowanceAfterTDS = afterTDS.toStringAsFixed(2);
    notifyListeners();
  }

  void calculateStipend() {
    double annual = double.tryParse(annualStipendController.text) ?? 0;
    double monthly = annual / 12;

    monthlyStipend = monthly.toStringAsFixed(2);
    notifyListeners();
  }

  void calculateEmployeeSalary() {
    double annual = double.tryParse(ctcController.text) ?? 0;
    double monthly = annual / 12;
    double basic = monthly * 0.50; // 50% basic
    double hra = basic * 0.50; // 50% of basic for HRA
    double allowance = hra; // Same as HRA
    double pf = basic * 0.12; // 12% of basic for PF
    double esi = 0.00; // ESI is 0 in example
    double takeHome = monthly - pf - esi;

    monthlySalary = monthly.toStringAsFixed(2);
    monthlyBasic = basic.toStringAsFixed(2);
    hraAmount = hra.toStringAsFixed(2);
    allowanceAmount = allowance.toStringAsFixed(2);
    pfAmount = pf.toStringAsFixed(2);
    esiAmount = esi.toStringAsFixed(2);
    monthlyTakeHomeSalary = takeHome.toStringAsFixed(2);
    notifyListeners();
  }

  void calculateF11Salary() {
    double annual = double.tryParse(ctcF11Controller.text) ?? 0;
    double monthly = annual / 12;

    monthlyF11Salary = monthly.toStringAsFixed(2);
    notifyListeners();
  }

  void _clearAllCalculations() {
    monthlyProfessionalFeeBeforeTDS = "0.00";
    monthlyProfessionalFeeAfterTDS = "0.00";
    tdsAmount = "0.00";
    monthlyTravelAllowanceBeforeTDS = "0.00";
    monthlyTravelAllowanceAfterTDS = "0.00";
    travelTdsAmount = "0.00";
    monthlyStipend = "0.00";
    monthlySalary = "0.00";
    monthlyBasic = "0.00";
    hraAmount = "0.00";
    allowanceAmount = "0.00";
    pfAmount = "0.00";
    esiAmount = "0.00";
    monthlyTakeHomeSalary = "0.00";
    monthlyF11Salary = "0.00";
  }
}