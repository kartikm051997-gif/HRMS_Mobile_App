import 'package:flutter/material.dart';

import '../../model/Employee_management/Employee_management.dart';

class ActiveProvider extends ChangeNotifier {
  /// Toggle filter section
  bool _showFilters = false;
  bool get showFilters => _showFilters;
  int pageSize = 10;
  int currentPage = 0;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Flag to control whether to show employee cards
  /// Cards should only show after filters are applied
  bool _hasAppliedFilters = false;
  bool get hasAppliedFilters => _hasAppliedFilters;

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  void setPageSize(int newSize) {
    pageSize = newSize;
    currentPage = 0; // reset when changed
    notifyListeners();
  }

  /// Clear all filters and reset view
  void clearAllFilters() {
    _selectedCompany = null;
    _selectedZone = null;
    _selectedBranch = null;
    _selectedDesignation = null;
    _selectedCTC = null;
    dojFromController.clear();
    fojToController.clear();
    searchController.clear();
    _filteredEmployees = [];
    _hasAppliedFilters = false;
    notifyListeners();
  }

  /// Dropdown data
  final List<String> _company = ["Dr.Aravind's", "The MindMax"];
  final List<String> _zone = ["North", "South", "East", "West"];
  final List<String> _branch = [
    "Chennai",
    "Bangalore",
    "Hyderabad",
    "Tiruppur",
  ];
  final List<String> _designation = [
    "Manager",
    "HR",
    "Developer",
    "Admin",
    "Receptionist",
    "Jr.Admin",
    "Lab Technician",
  ];
  final List<String> _ctc = ["< 5 LPA", "5–10 LPA", "> 10 LPA"];

  List<String> get company => _company;
  List<String> get zone => _zone;
  List<String> get branch => _branch;
  List<String> get designation => _designation;
  List<String> get ctc => _ctc;

  /// Selected values
  String? _selectedCompany;
  String? _selectedZone;
  String? _selectedBranch;
  String? _selectedDesignation;
  String? _selectedCTC;
  DateTime? _dojFrom;
  DateTime? _dojTo;

  String? get selectedCompany => _selectedCompany;
  String? get selectedZone => _selectedZone;
  String? get selectedBranch => _selectedBranch;
  String? get selectedDesignation => _selectedDesignation;
  String? get selectedCTC => _selectedCTC;
  DateTime? get dojFrom => _dojFrom;
  DateTime? get dojTo => _dojTo;

  /// Check if all required filters are selected
  bool get areAllFiltersSelected {
    return _selectedCompany != null &&
        _selectedZone != null &&
        _selectedBranch != null &&
        _selectedDesignation != null;
  }

  /// Employee data
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];

  List<Employee> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  void onSearchChanged(String query) {
    if (!_hasAppliedFilters) return;
    
    if (query.isEmpty) {
      // Reset to all employees when search is cleared
      _filteredEmployees = List.from(_allEmployees);
    } else {
      // Filter from all employees, not just filtered list
      _filteredEmployees = _allEmployees.where((employee) {
        return employee.name.toLowerCase().contains(query.toLowerCase()) ||
            employee.employeeId.toLowerCase().contains(query.toLowerCase()) ||
            employee.designation.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    if (_hasAppliedFilters) {
      searchEmployees();
    }
  }

  /// Initialize with sample data (replace with API call)
  /// Only loads data if not already loaded - preserves state when navigating
  void initializeEmployees() {
    // If data is already loaded, don't reset
    if (_allEmployees.isNotEmpty) {
      return;
    }
    
    _allEmployees = [
      Employee(
        employeeId: "12867",
        name: "Vimalkumar Palanisamy",
        branch: "chengalpattu",
        doj: "15/09/2025",
        department: "HOSPITAL",
        designation: "Admin",
        monthlyCTC: "23000",
        payrollCategory: "employee",
        status: "Active",
        photoUrl: "https://example.com/photo1.jpg",
        recruiterName: "John Recruiter",
        recruiterPhotoUrl: "https://example.com/recruiter1.jpg",
        createdByName: "Sarah Manager",
        createdByPhotoUrl: "https://example.com/creator1.jpg",
      ),
      Employee(
        employeeId: "12866",
        name: "Nivetha",
        branch: "Tiruppur",
        doj: "16/09/2025",
        department: "HOSPITAL",
        designation: "Receptionist",
        monthlyCTC: "23000",
        payrollCategory: "employee",
        status: "Active",
        recruiterName: "Mike HR",
        recruiterPhotoUrl: "https://example.com/recruiter2.jpg",
        createdByName: "David Admin",
        createdByPhotoUrl: "https://example.com/creator2.jpg",
      ),
      Employee(
        employeeId: "12865",
        name: "Bharath Kumar T R",
        branch: "Tiruppur",
        doj: "16/09/2025",
        department: "HOSPITAL",
        designation: "Jr.Admin",
        monthlyCTC: "19000",
        payrollCategory: "employee",
        status: "Active",
        recruiterName: "Lisa Talent",
        recruiterPhotoUrl: "https://example.com/recruiter3.jpg",
        createdByName: "Emma Lead",
        createdByPhotoUrl: "https://example.com/creator3.jpg",
      ),
      Employee(
        employeeId: "12864",
        name: "Sree Lakshmi K",
        branch: "Tiruppur",
        doj: "15/09/2025",
        department: "LAB",
        designation: "Lab Technician",
        monthlyCTC: "14000",
        payrollCategory: "employee",
        status: "Active",
        recruiterName: "Tom Specialist",
        recruiterPhotoUrl: "https://example.com/recruiter4.jpg",
        createdByName: "Anna Director",
        createdByPhotoUrl: "https://example.com/creator4.jpg",
      ),
      Employee(
        employeeId: "12863",
        name: "Sabitha",
        branch: "Tiruppur",
        doj: "15/09/2025",
        department: "LAB",
        designation: "Lab Technician",
        monthlyCTC: "10000",
        payrollCategory: "student",
        status: "Active",
        recruiterName: "Chris Head",
        recruiterPhotoUrl: "https://example.com/recruiter5.jpg",
        createdByName: "Kelly VP",
        createdByPhotoUrl: "https://example.com/creator5.jpg",
      ),
    ];
    // First time only - set filtered to empty
    _filteredEmployees = [];
    _hasAppliedFilters = false;
    notifyListeners();
  }

  /// Search functionality - only works after filters are applied
  void searchEmployees() {
    if (!areAllFiltersSelected) {
      // Don't search if not all filters are selected
      return;
    }

    _isLoading = true;
    _hasAppliedFilters = true;
    notifyListeners();

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      // Show all employees when filters are applied
      // In a real app, this would be an API call with filter parameters
      _filteredEmployees = List.from(_allEmployees);

      // Apply search text filter if present
      if (searchController.text.isNotEmpty) {
        final query = searchController.text.toLowerCase();
        _filteredEmployees = _filteredEmployees.where((employee) {
          return employee.name.toLowerCase().contains(query) ||
              employee.employeeId.toLowerCase().contains(query) ||
              employee.designation.toLowerCase().contains(query);
        }).toList();
      }

      // Apply CTC filter if selected
      if (_selectedCTC != null && _selectedCTC!.isNotEmpty) {
        _filteredEmployees = _filteredEmployees
            .where((emp) => _filterByCTC(emp.monthlyCTC, _selectedCTC!))
            .toList();
      }

      // Apply date range filter if present
      if (dojFromController.text.isNotEmpty ||
          fojToController.text.isNotEmpty) {
        _filteredEmployees = _filteredEmployees
            .where((emp) => _filterByDateRange(emp.doj))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  bool _filterByCTC(String employeeCTC, String selectedCTC) {
    double ctc = double.tryParse(employeeCTC) ?? 0;
    double monthlyToAnnual = ctc * 12; // Convert monthly to annual

    switch (selectedCTC) {
      case "< 5 LPA":
        return monthlyToAnnual < 500000;
      case "5–10 LPA":
        return monthlyToAnnual >= 500000 && monthlyToAnnual <= 1000000;
      case "> 10 LPA":
        return monthlyToAnnual > 1000000;
      default:
        return true;
    }
  }

  bool _filterByDateRange(String employeeDoj) {
    try {
      // Parse employee DOJ (assuming format: "dd/MM/yyyy")
      List<String> parts = employeeDoj.split('/');
      DateTime empDate = DateTime(
        int.parse(parts[2]), // year
        int.parse(parts[1]), // month
        int.parse(parts[0]), // day
      );

      DateTime? fromDate;
      DateTime? toDate;

      if (dojFromController.text.isNotEmpty) {
        fromDate = DateTime.tryParse(dojFromController.text);
      }

      if (fojToController.text.isNotEmpty) {
        toDate = DateTime.tryParse(fojToController.text);
      }

      if (fromDate != null && empDate.isBefore(fromDate)) {
        return false;
      }

      if (toDate != null && empDate.isAfter(toDate)) {
        return false;
      }

      return true;
    } catch (e) {
      return true; // If parsing fails, include the employee
    }
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCompany = null;
    _selectedZone = null;
    _selectedBranch = null;
    _selectedDesignation = null;
    _selectedCTC = null;
    _dojFrom = null;
    _dojTo = null;
    dojFromController.clear();
    fojToController.clear();
    _filteredEmployees = [];
    _hasAppliedFilters = false;
    notifyListeners();
  }

  /// Setters
  void setSelectedCompany(String? v) {
    _selectedCompany = v;
    notifyListeners();
  }

  void setSelectedZone(String? v) {
    _selectedZone = v;
    notifyListeners();
  }

  void setSelectedBranch(String? v) {
    _selectedBranch = v;
    notifyListeners();
  }

  void setSelectedDesignation(String? v) {
    _selectedDesignation = v;
    notifyListeners();
  }

  void setSelectedCTC(String? v) {
    _selectedCTC = v;
    notifyListeners();
  }

  void setDojFrom(DateTime? date) {
    _dojFrom = date;
    if (date != null) {
      dojFromController.text = "${date.day}/${date.month}/${date.year}";
    }
    notifyListeners();
  }

  void setDojTo(DateTime? date) {
    _dojTo = date;
    if (date != null) {
      fojToController.text = "${date.day}/${date.month}/${date.year}";
    }
    notifyListeners();
  }

  final dojFromController = TextEditingController();
  final fojToController = TextEditingController();

  /// Toggle employee status between active and inactive
  Future<void> toggleEmployeeStatus(String employeeId) async {
    try {
      // Find the employee in the list
      final employeeIndex = _allEmployees.indexWhere(
        (emp) => emp.employeeId == employeeId,
      );

      if (employeeIndex != -1) {
        // Update the status locally first for immediate UI feedback
        final currentEmployee = _allEmployees[employeeIndex];
        final currentStatus = currentEmployee.status.toLowerCase();
        final newStatus = currentStatus == 'active' ? 'Inactive' : 'Active';

        // Create updated employee object
        final updatedEmployee = Employee(
          employeeId: currentEmployee.employeeId,
          name: currentEmployee.name,
          branch: currentEmployee.branch,
          doj: currentEmployee.doj,
          department: currentEmployee.department,
          designation: currentEmployee.designation,
          monthlyCTC: currentEmployee.monthlyCTC,
          payrollCategory: currentEmployee.payrollCategory,
          status: newStatus,
          photoUrl: currentEmployee.photoUrl,
          recruiterName: currentEmployee.recruiterName,
          recruiterPhotoUrl: currentEmployee.recruiterPhotoUrl,
          createdByName: currentEmployee.createdByName,
          createdByPhotoUrl: currentEmployee.createdByPhotoUrl,
        );

        // Update the employee in the list
        _allEmployees[employeeIndex] = updatedEmployee;

        // Update filtered employees as well
        final filteredIndex = _filteredEmployees.indexWhere(
          (emp) => emp.employeeId == employeeId,
        );
        if (filteredIndex != -1) {
          _filteredEmployees[filteredIndex] = updatedEmployee;
        }

        // Notify listeners to update UI
        notifyListeners();

        // Here you would typically make an API call to update the status on the server
        // Example:
        // await _apiService.updateEmployeeStatus(employeeId, newStatus);

        print('Employee $employeeId status changed to: $newStatus');
      }
    } catch (e) {
      print('Error toggling employee status: $e');
      // You might want to revert the local changes and show an error message
      // or handle the error appropriately based on your app's error handling strategy
    }
  }

  @override
  void dispose() {
    dojFromController.dispose();
    fojToController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
