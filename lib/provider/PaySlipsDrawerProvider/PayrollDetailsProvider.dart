import 'package:flutter/foundation.dart';

class PayrollDetailsProvider extends ChangeNotifier {
  // Payroll Basic Details
  double _grossSalary = 0.0;
  int _totalDays = 0;
  int _workedDays = 0;
  int _lopDays = 0;
  double _lop = 0.0;
  double _earnedAmount = 0.0;

  // Allowances
  double _basicAllowance = 0.0;
  double _hraAllowance = 0.0;
  double _incentiveBonus = 0.0;
  double _claimAllowance = 0.0;
  double _tdsNotApplicableAllowance = 0.0;
  String _allowanceComments = '';
  double _totalAllowance = 0.0;

  // Deductions
  double _providentFund = 0.0;
  double _pt = 0.0;
  double _esi = 0.0;
  double _securityDeposit = 0.0;
  double _loanAdvance = 0.0;
  double _training = 0.0;
  double _othersDeduction = 0.0;
  String _othersComments = '';
  double _totalDeductions = 0.0;

  // Final Salary Details
  double _tds = 0.0;
  double _netSalary = 0.0;
  String _status = '';
  String _statusComments = '';

  bool _isLoading = false;

  // Getters
  double get grossSalary => _grossSalary;
  int get totalDays => _totalDays;
  int get workedDays => _workedDays;
  int get lopDays => _lopDays;
  double get lop => _lop;
  double get earnedAmount => _earnedAmount;

  double get basicAllowance => _basicAllowance;
  double get hraAllowance => _hraAllowance;
  double get incentiveBonus => _incentiveBonus;
  double get claimAllowance => _claimAllowance;
  double get tdsNotApplicableAllowance => _tdsNotApplicableAllowance;
  String get allowanceComments => _allowanceComments;
  double get totalAllowance => _totalAllowance;

  double get providentFund => _providentFund;
  double get pt => _pt;
  double get esi => _esi;
  double get securityDeposit => _securityDeposit;
  double get loanAdvance => _loanAdvance;
  double get training => _training;
  double get othersDeduction => _othersDeduction;
  String get othersComments => _othersComments;
  double get totalDeductions => _totalDeductions;

  double get tds => _tds;
  double get netSalary => _netSalary;
  String get status => _status;
  String get statusComments => _statusComments;

  bool get isLoading => _isLoading;

  // Load dummy data for demonstration
  Future<void> loadPayrollDetails(String payslipId) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Set dummy data (based on the images provided)
    _grossSalary = 35000.00;
    _totalDays = 31;
    _workedDays = 31;
    _lopDays = 0;
    _lop = 0.00;
    _earnedAmount = 35000.00;

    _basicAllowance = 0.00;
    _hraAllowance = 0.00;
    _incentiveBonus = 0.00;
    _claimAllowance = 0.00;
    _tdsNotApplicableAllowance = 0.00;
    _allowanceComments = '';
    _totalAllowance = 0.00;

    _providentFund = 0.00;
    _pt = 0.00;
    _esi = 0.00;
    _securityDeposit = 0.00;
    _loanAdvance = 0.00;
    _training = 0.00;
    _othersDeduction = 0.00;
    _othersComments = '';
    _totalDeductions = 0.00;

    _tds = 0.00;
    _netSalary = 35000.00;
    _status = 'Approved';
    _statusComments = '';

    _isLoading = false;
    notifyListeners();
  }

  void clearData() {
    _grossSalary = 0.0;
    _totalDays = 0;
    _workedDays = 0;
    _lopDays = 0;
    _lop = 0.0;
    _earnedAmount = 0.0;
    _basicAllowance = 0.0;
    _hraAllowance = 0.0;
    _incentiveBonus = 0.0;
    _claimAllowance = 0.0;
    _tdsNotApplicableAllowance = 0.0;
    _allowanceComments = '';
    _totalAllowance = 0.0;
    _providentFund = 0.0;
    _pt = 0.0;
    _esi = 0.0;
    _securityDeposit = 0.0;
    _loanAdvance = 0.0;
    _training = 0.0;
    _othersDeduction = 0.0;
    _othersComments = '';
    _totalDeductions = 0.0;
    _tds = 0.0;
    _netSalary = 0.0;
    _status = '';
    _statusComments = '';
    notifyListeners();
  }
}
