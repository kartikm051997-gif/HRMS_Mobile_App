import 'package:flutter/material.dart';

class PaySlipsDrawerProvider extends ChangeNotifier {
  String _searchType = 'By Employee';
  String? _selectedEmployee;
  String? _selectedLocation;
  DateTime? _selectedMonth;
  List<Employee> _employees = [];
  List<String> _locations = [];
  List<Payslip> _payslips = [];
  bool _isLoading = false;
  String? _errorMessage;

  String get searchType => _searchType;
  String? get selectedEmployee => _selectedEmployee;
  String? get selectedLocation => _selectedLocation;
  DateTime? get selectedMonth => _selectedMonth;
  List<Employee> get employees => _employees;
  List<String> get locations => _locations;
  List<Payslip> get payslips => _payslips;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSearchType(String value) {
    _searchType = value;
    _selectedEmployee = null;
    _selectedLocation = null;
    _selectedMonth = null;
    _payslips = [];
    notifyListeners();
  }

  void setSelectedEmployee(String? value) {
    _selectedEmployee = value;
    notifyListeners();
  }

  void setSelectedLocation(String? value) {
    _selectedLocation = value;
    notifyListeners();
  }

  void setSelectedMonth(DateTime? value) {
    _selectedMonth = value;
    notifyListeners();
  }

  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _employees = [
        Employee(
          id: '10055',
          name: 'Ramya',
          designation: 'Zonal Head',
          branch: 'Management',
          zone: 'South',
        ),
        Employee(
          id: '10088',
          name: 'V.G.Lokesh',
          designation: 'Zonal Head',
          branch: 'Management',
          zone: 'North',
        ),
        Employee(
          id: '10162',
          name: 'S.Venkataraman',
          designation: 'Managing Director',
          branch: 'Management',
          zone: 'Corporate',
        ),
        Employee(
          id: '10178',
          name: 'A.M.Sreekanth',
          designation: 'Managing Director',
          branch: 'Management',
          zone: 'Corporate',
        ),
      ];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load employees';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLocations() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _locations = [
        'Aathur',
        'Assam',
        'Bangladesh',
        'Bengaluru - Dasarahalli',
        'Bengaluru - Electronic City',
        'Bengaluru - Hebbal',
        'Bengaluru - Konanakunte',
      ];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load locations';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPayslipsByEmployee(String employeeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _payslips = [
        Payslip(
          monthYear: 'January 2025',
          empId: '10055',
          name: 'Ramya',
          designation: 'Cluster Head',
          workingDays: 31,
          lopDays: 0,
          grossSalary: 35000.00,
          totalDeductions: 0.00,
          netSalary: 35000.00,
          status: 0,
        ),
        Payslip(
          monthYear: 'December 2024',
          empId: '10055',
          name: 'Ramya',
          designation: 'Cluster Head',
          workingDays: 30,
          lopDays: 0,
          grossSalary: 35000.00,
          totalDeductions: 0.00,
          netSalary: 35000.00,
          status: 0,
        ),
      ];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to search payslips';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPayslipsByLocationMonth(
    String location,
    DateTime month,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _payslips = [
        Payslip(
          monthYear: 'January 2025',
          empId: '10055',
          name: 'Ramya',
          designation: 'Cluster Head',
          workingDays: 31,
          lopDays: 0,
          grossSalary: 35000.00,
          totalDeductions: 0.00,
          netSalary: 35000.00,
          status: 0,
        ),
      ];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to search payslips';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPayslips() {
    _payslips = [];
    notifyListeners();
  }
}

// lib/providers/employee_provider.dart
class EmployeeProvider with ChangeNotifier {
  String _selectedTab = 'Active';
  String? _selectedZone;
  String? _selectedBranch;
  String? _selectedDesignation;
  String _searchQuery = '';
  List<Employee> _employees = [];
  bool _isLoading = false;
  bool _showFilters = false;

  String get selectedTab => _selectedTab;
  String? get selectedZone => _selectedZone;
  String? get selectedBranch => _selectedBranch;
  String? get selectedDesignation => _selectedDesignation;
  String get searchQuery => _searchQuery;
  List<Employee> get employees => _employees;
  bool get isLoading => _isLoading;
  bool get showFilters => _showFilters;

  List<Employee> get filteredEmployees {
    return _employees.where((emp) {
      bool matchesSearch =
          _searchQuery.isEmpty ||
          emp.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          emp.id.contains(_searchQuery);
      bool matchesZone = _selectedZone == null || emp.zone == _selectedZone;
      bool matchesBranch =
          _selectedBranch == null || emp.branch == _selectedBranch;
      bool matchesDesignation =
          _selectedDesignation == null ||
          emp.designation == _selectedDesignation;
      return matchesSearch &&
          matchesZone &&
          matchesBranch &&
          matchesDesignation;
    }).toList();
  }

  void setSelectedTab(String value) {
    _selectedTab = value;
    loadEmployees();
  }

  void setSelectedZone(String? value) {
    _selectedZone = value;
    notifyListeners();
  }

  void setSelectedBranch(String? value) {
    _selectedBranch = value;
    notifyListeners();
  }

  void setSelectedDesignation(String? value) {
    _selectedDesignation = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  void clearFilters() {
    _selectedZone = null;
    _selectedBranch = null;
    _selectedDesignation = null;
    notifyListeners();
  }

  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _employees = [
        Employee(
          id: '12867',
          name: 'Vimalkumar Palanisamy',
          designation: 'Admin',
          branch: 'chengalpattu',
          zone: 'South',
        ),
        Employee(
          id: '12866',
          name: 'Nivetha',
          designation: 'Manager',
          branch: 'chengalpattu',
          zone: 'South',
        ),
        Employee(
          id: '12865',
          name: 'Rajesh Kumar',
          designation: 'Developer',
          branch: 'bangalore',
          zone: 'South',
        ),
        Employee(
          id: '12864',
          name: 'Priya Sharma',
          designation: 'HR Manager',
          branch: 'mumbai',
          zone: 'West',
        ),
        Employee(
          id: '12863',
          name: 'Arjun Reddy',
          designation: 'Team Lead',
          branch: 'hyderabad',
          zone: 'South',
        ),
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class Employee {
  final String id;
  final String name;
  final String designation;
  final String branch;
  final String zone;

  Employee({
    required this.id,
    required this.name,
    required this.designation,
    required this.branch,
    required this.zone,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      branch: json['branch'] ?? '',
      zone: json['zone'] ?? '',
    );
  }
}

// lib/models/payslip.dart
class Payslip {
  final String monthYear;
  final String empId;
  final String name;
  final String designation;
  final int workingDays;
  final int lopDays;
  final double grossSalary;
  final double totalDeductions;
  final double netSalary;
  final int status;

  Payslip({
    required this.monthYear,
    required this.empId,
    required this.name,
    required this.designation,
    required this.workingDays,
    required this.lopDays,
    required this.grossSalary,
    required this.totalDeductions,
    required this.netSalary,
    required this.status,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    return Payslip(
      monthYear: json['monthYear'] ?? '',
      empId: json['empId'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      workingDays: json['workingDays'] ?? 0,
      lopDays: json['lopDays'] ?? 0,
      grossSalary: (json['grossSalary'] ?? 0).toDouble(),
      totalDeductions: (json['totalDeductions'] ?? 0).toDouble(),
      netSalary: (json['netSalary'] ?? 0).toDouble(),
      status: json['status'] ?? 0,
    );
  }
}
