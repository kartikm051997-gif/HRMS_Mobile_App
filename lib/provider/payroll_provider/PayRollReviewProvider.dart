import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PayrollReviewProvider extends ChangeNotifier {
  // Filter Controllers
  final TextEditingController monthController = TextEditingController();

  // Filter Options
  final List<String> _locations = [
    'Corporate Office - Guindy',
    'Trichy',
    'Tanjore',
    'Pollachi',
    'Bengaluru - Electronic City',
    'Chennai - Tambaram',
    'Madurai',
    'Bengaluru - Konanakutte',
    'Harur',
    'Karur',
    'Tirupati',
    'Sathyamangalam',
    'Coimbatore - Thudiyalur',
    'Kallakurichi',
    'Bengaluru - Hebbal',
    'Vellore',
    'Assam',
    'Chennai - Vadapalani',
    'Villupuram',
    'Bengaluru - Dasarahalli',
  ];

  final List<String> _designations = [
    'Software Developer',
    'HR Executive',
    'Manager',
    'Designer',
    'QA Engineer',
    'Business Analyst',
    'Project Manager',
    'Admin',
  ];

  // Selected Filters
  String? _selectedLocation;
  String? _selectedDesignation;

  // View Mode
  bool _isCardView = true; // true for card view, false for list view

  // Loading States
  bool _isLoading = false;

  // Employee Payroll Data
  List<PayrollEmployeeModel> _payrollEmployees = [];
  PayrollEmployeeModel? _selectedEmployee;

  // Getters
  List<String> get locations => _locations;
  List<String> get designations => _designations;
  String? get selectedLocation => _selectedLocation;
  String? get selectedDesignation => _selectedDesignation;
  bool get isCardView => _isCardView;
  bool get isLoading => _isLoading;
  List<PayrollEmployeeModel> get payrollEmployees => _payrollEmployees;
  PayrollEmployeeModel? get selectedEmployee => _selectedEmployee;

  // Setters
  void setSelectedLocation(String? location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setSelectedDesignation(String? designation) {
    _selectedDesignation = designation;
    notifyListeners();
  }

  void toggleViewMode() {
    _isCardView = !_isCardView;
    notifyListeners();
  }

  void setSelectedEmployee(PayrollEmployeeModel? employee) {
    _selectedEmployee = employee;
    notifyListeners();
  }

  // Fetch Payroll Data
  Future<void> fetchPayrollData() async {
    if (_selectedLocation == null ||
        _selectedDesignation == null ||
        monthController.text.isEmpty) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Generate dummy data based on filters
      _payrollEmployees = _generateDummyPayrollData();

      if (kDebugMode) {
        print('Fetched ${_payrollEmployees.length} payroll records');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching payroll data: $e');
      }
      _payrollEmployees = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<PayrollEmployeeModel> _generateDummyPayrollData() {
    // Generate sample data based on selected filters
    return [
      // Employee with salary >= 30000 (No PF/ESI)
      _createEmployeeModel(
        empId: '11771',
        name: 'Vignesh Raja',
        designation: _selectedDesignation ?? 'Software Developer',
        location: _selectedLocation ?? 'Corporate Office - Guindy',
        employeeType: 'employeef11',
        daysWorked: 29,
        leaveDays: 6,
        allowedLeaveDays: 4,
        lopDays: 2,
        avgHours: '7H:50S',
        actualCTC: 35000.0,
        allowance: 0.0,
        trainingFees: 0.0,
      ),
      // Employee with salary < 30000 (Has PF/ESI)
      _createEmployeeModel(
        empId: '12570',
        name: 'Prasanth K',
        designation: 'Software Developer',
        location: _selectedLocation ?? 'Corporate Office - Guindy',
        employeeType: 'employee',
        daysWorked: 31,
        leaveDays: 4,
        allowedLeaveDays: 4,
        lopDays: 0,
        avgHours: '7H:39S',
        actualCTC: 21000.0,
        allowance: 0.0,
        trainingFees: 0.0,
      ),
      // Another employee with salary < 30000
      _createEmployeeModel(
        empId: '11530',
        name: 'M.Sneha',
        designation: 'HR Trainee',
        location: _selectedLocation ?? 'Corporate Office - Guindy',
        employeeType: 'employee',
        daysWorked: 28,
        leaveDays: 2,
        allowedLeaveDays: 2,
        lopDays: 0,
        avgHours: '8H:15S',
        actualCTC: 25000.0,
        allowance: 1000.0,
        trainingFees: 0.0,
      ),
    ];
  }

  // Helper method to create employee model with PF/ESI calculation
  PayrollEmployeeModel _createEmployeeModel({
    required String empId,
    required String name,
    required String designation,
    required String location,
    required String employeeType,
    required int daysWorked,
    required int leaveDays,
    required int allowedLeaveDays,
    required int lopDays,
    required String avgHours,
    required double actualCTC,
    required double allowance,
    required double trainingFees,
  }) {
    // Calculate PF and ESI based on salary
    final pfEsiData = _calculatePFAndESI(actualCTC);
    final bool hasPF = pfEsiData['hasPF'] as bool;
    final bool hasESI = pfEsiData['hasESI'] as bool;
    final double pfAmount = pfEsiData['pfAmount'] as double;
    final double esiAmount = pfEsiData['esiAmount'] as double;

    // Calculate LOP amount (assuming LOP is calculated as (CTC / 30) * LOP days)
    final double dailySalary = actualCTC / 30;
    final double lopAmount = dailySalary * lopDays;

    // Calculate current month salary (CTC + allowance - training fees)
    final double currentMonthSalary = actualCTC + allowance - trainingFees;

    // Calculate deductions (PF + ESI + LOP)
    final double deductions = pfAmount + esiAmount + lopAmount;

    // Calculate take home salary
    final double takeHomeSalary = currentMonthSalary - deductions;

    return PayrollEmployeeModel(
      empId: empId,
      name: name,
      designation: designation,
      location: location,
      employeeType: employeeType,
      daysWorked: daysWorked,
      leaveDays: leaveDays,
      allowedLeaveDays: allowedLeaveDays,
      lopDays: lopDays,
      avgHours: avgHours,
      trainingFees: trainingFees,
      actualCTC: actualCTC,
      allowance: allowance,
      deductions: deductions,
      currentMonthSalary: currentMonthSalary,
      takeHomeSalary: takeHomeSalary,
      lopAmount: lopAmount,
      pfAmount: pfAmount,
      esiAmount: esiAmount,
      hasPF: hasPF,
      hasESI: hasESI,
      attendanceLogs: _generateAttendanceLogs(),
    );
  }

  // Helper method to calculate PF and ESI based on salary
  Map<String, dynamic> _calculatePFAndESI(double salary) {
    const double pfRate = 0.12; // 12% PF on basic salary
    const double esiRate = 0.0075; // 0.75% ESI (employee contribution)
    const double salaryThreshold = 30000.0;
    const double esiSalaryLimit = 21000.0; // ESI applies only up to 21000

    bool hasPF = salary < salaryThreshold;
    bool hasESI = salary < salaryThreshold && salary <= esiSalaryLimit;

    double pfAmount = 0.0;
    double esiAmount = 0.0;

    if (hasPF) {
      // PF is calculated on basic salary (assuming 50% of CTC is basic)
      double basicSalary = salary * 0.5;
      pfAmount = basicSalary * pfRate;
    }

    if (hasESI) {
      // ESI is calculated on gross salary (full salary)
      esiAmount = salary * esiRate;
    }

    return {
      'hasPF': hasPF,
      'hasESI': hasESI,
      'pfAmount': pfAmount,
      'esiAmount': esiAmount,
    };
  }

  List<AttendanceLogModel> _generateAttendanceLogs() {
    // Generate attendance logs for the month
    final logs = <AttendanceLogModel>[];
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    // Generate logs for last 25 days (Oct 16 - Nov 9)
    final startDate = DateTime(year, month == 1 ? 12 : month - 1, 16);

    for (int i = 0; i < 25; i++) {
      final date = startDate.add(Duration(days: i));
      final dayOfWeek = date.weekday;

      // Skip weekends (optional - you can remove this)
      if (dayOfWeek == 6 || dayOfWeek == 7) {
        continue;
      }

      String? checkIn;
      String? checkOut;
      String? workingHours;
      String status = 'present';

      // Randomly assign some as absent or present
      if (i % 7 == 0) {
        // Absent
        status = 'absent';
      } else if (i % 9 == 0) {
        // Holiday
        status = 'holiday';
      } else {
        // Present - generate random times
        final checkInHour = 9 + (i % 2); // 9 or 10
        final checkInMin = 0 + (i % 60);
        checkIn = '${checkInHour.toString().padLeft(2, '0')}:${checkInMin.toString().padLeft(2, '0')}';

        final checkOutHour = 18 + (i % 3); // 18, 19, or 20
        final checkOutMin = 0 + (i % 60);
        checkOut = '${checkOutHour.toString().padLeft(2, '0')}:${checkOutMin.toString().padLeft(2, '0')}';

        // Calculate working hours (simplified)
        final hours = checkOutHour - checkInHour;
        final mins = checkOutMin - checkInMin;
        workingHours = '${hours}H:${mins.toString().padLeft(2, '0')}S';
      }

      logs.add(AttendanceLogModel(
        date: date,
        checkIn: checkIn,
        checkOut: checkOut,
        workingHours: workingHours,
        status: status,
      ));
    }

    return logs;
  }

  // Reset filters
  void resetFilters() {
    _selectedLocation = null;
    _selectedDesignation = null;
    monthController.clear();
    _payrollEmployees = [];
    _selectedEmployee = null;
    notifyListeners();
  }

  @override
  void dispose() {
    monthController.dispose();
    super.dispose();
  }
}

// Payroll Employee Model
class PayrollEmployeeModel {
  final String empId;
  final String name;
  final String designation;
  final String location;
  final String employeeType;
  final int daysWorked;
  final int leaveDays;
  final int allowedLeaveDays;
  final int lopDays;
  final String avgHours;
  final double trainingFees;
  final double actualCTC;
  final double allowance;
  final double deductions;
  final double currentMonthSalary;
  final double takeHomeSalary;
  final double lopAmount;
  final double pfAmount; // PF deduction
  final double esiAmount; // ESI deduction
  final bool hasPF; // Whether employee has PF
  final bool hasESI; // Whether employee has ESI
  final List<AttendanceLogModel> attendanceLogs;

  PayrollEmployeeModel({
    required this.empId,
    required this.name,
    required this.designation,
    required this.location,
    required this.employeeType,
    required this.daysWorked,
    required this.leaveDays,
    required this.allowedLeaveDays,
    required this.lopDays,
    required this.avgHours,
    required this.trainingFees,
    required this.actualCTC,
    required this.allowance,
    required this.deductions,
    required this.currentMonthSalary,
    required this.takeHomeSalary,
    required this.lopAmount,
    required this.pfAmount,
    required this.esiAmount,
    required this.hasPF,
    required this.hasESI,
    required this.attendanceLogs,
  });
}

// Attendance Log Model
class AttendanceLogModel {
  final DateTime date;
  final String? checkIn;
  final String? checkOut;
  final String? workingHours;
  final String status; // 'present', 'absent', 'holiday'

  AttendanceLogModel({
    required this.date,
    this.checkIn,
    this.checkOut,
    this.workingHours,
    required this.status,
  });

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}';
  }
}
