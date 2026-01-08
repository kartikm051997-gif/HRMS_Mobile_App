import 'package:flutter/material.dart';

import '../../model/Employee_management/Employee_management.dart';

class ManagementApprovalProvider extends ChangeNotifier {
  /// Toggle filter section
  bool _showFilters = false;
  bool get showFilters => _showFilters;
  int pageSize = 10;
  int currentPage = 0;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Flag to control whether to show employee cards
  bool _hasAppliedFilters = false;
  bool get hasAppliedFilters => _hasAppliedFilters;

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  void setPageSize(int newSize) {
    pageSize = newSize;
    currentPage = 0;
    notifyListeners();
  }

  /// Clear all filters and reset view
  void clearAllFilters() {
    _selectedZone = null;
    _selectedBranch = null;
    _selectedDesignation = null;
    searchController.clear();
    _filteredEmployees = [];
    _hasAppliedFilters = false;
    notifyListeners();
  }

  /// Dropdown data
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

  List<String> get zone => _zone;
  List<String> get branch => _branch;
  List<String> get designation => _designation;

  /// Selected values
  String? _selectedZone;
  String? _selectedBranch;
  String? _selectedDesignation;

  String? get selectedZone => _selectedZone;
  String? get selectedBranch => _selectedBranch;
  String? get selectedDesignation => _selectedDesignation;

  /// Check if all required filters are selected
  bool get areAllFiltersSelected {
    return _selectedZone != null &&
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
      _filteredEmployees = List.from(_allEmployees);
    } else {
      _filteredEmployees =
          _allEmployees.where((employee) {
            return employee.name.toLowerCase().contains(query.toLowerCase()) ||
                employee.employeeId.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                employee.designation.toLowerCase().contains(
                  query.toLowerCase(),
                );
          }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    if (_hasAppliedFilters) {
      _filteredEmployees = List.from(_allEmployees);
      notifyListeners();
    }
  }

  /// Initialize with sample data - preserves state when navigating
  void initializeEmployees() {
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
        status: "Pending",
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
        status: "Pending",
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
        status: "Pending",
        recruiterName: "Lisa Talent",
        recruiterPhotoUrl: "https://example.com/recruiter3.jpg",
        createdByName: "Emma Lead",
        createdByPhotoUrl: "https://example.com/creator3.jpg",
      ),
    ];
    _filteredEmployees = [];
    _hasAppliedFilters = false;
    notifyListeners();
  }

  /// Search functionality
  void searchEmployees() {
    if (!areAllFiltersSelected) {
      return;
    }

    _isLoading = true;
    _hasAppliedFilters = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 500), () {
      _filteredEmployees = List.from(_allEmployees);

      if (searchController.text.isNotEmpty) {
        final query = searchController.text.toLowerCase();
        _filteredEmployees =
            _filteredEmployees.where((employee) {
              return employee.name.toLowerCase().contains(query) ||
                  employee.employeeId.toLowerCase().contains(query) ||
                  employee.designation.toLowerCase().contains(query);
            }).toList();
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  /// Setters
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
