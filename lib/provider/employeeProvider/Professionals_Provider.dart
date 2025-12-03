import 'package:flutter/material.dart';

import '../../model/AllEmployeeDetailsModel/Professioal_Model.dart';

class ProfessionalsProvider extends ChangeNotifier {
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
    currentPage = 0; // reset
    notifyListeners();
  }

  /// Clear all filters and reset view
  void clearAllFilters() {
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

  /// Dropdown data
  final List<String> _company = ["Dr.Aravind's", "The MindMax"];
  final List<String> _zone = ["North", "South", "East", "West"];
  final List<String> _branch = ["Chennai", "Bangalore", "Hyderabad", "Tiruppur"];
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

  String? get selectedCompany => _selectedCompany;
  String? get selectedZone => _selectedZone;
  String? get selectedBranch => _selectedBranch;
  String? get selectedDesignation => _selectedDesignation;
  String? get selectedCTC => _selectedCTC;

  /// Check if all required filters are selected (Zone, Branch, Designation)
  bool get areAllFiltersSelected {
    return _selectedZone != null &&
        _selectedBranch != null &&
        _selectedDesignation != null;
  }

  /// Employee data
  List<ProfessionalModel> _allEmployees = [];
  List<ProfessionalModel> _filteredEmployees = [];

  List<ProfessionalModel> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  /// Initialize with sample data (replace with API later)
  /// Only loads data if not already loaded - preserves state when navigating
  void initializeEmployees() {
    // If data is already loaded, don't reset
    if (_allEmployees.isNotEmpty) {
      return;
    }
    
    _allEmployees = [
      ProfessionalModel(
        employeeId: "12867",
        name: "Vimalkumar Palanisamy",
        branch: "Chengalpattu",
        doj: "15/09/2025",
        designation: "Admin",
        monthlyCTC: "23000",
        annualProfessionalFee: "340000",
        monthlyProfessionalFee: "27090",
        monthlyProfessionalTds: "3010",
        annualTravelAllowance: "0",
        monthlyTravelAllowance: "0",
        monthlyTravelTds: "0",
        photoUrl: "https://example.com/photo1.jpg",
      ),
      ProfessionalModel(
        employeeId: "12866",
        name: "Nivetha",
        branch: "Tiruppur",
        doj: "16/09/2025",
        designation: "Receptionist",
        monthlyCTC: "23000",
        annualProfessionalFee: "361200",
        monthlyProfessionalFee: "27090",
        monthlyProfessionalTds: "3010",
        annualTravelAllowance: "0",
        monthlyTravelAllowance: "0",
        monthlyTravelTds: "0",
        photoUrl: "https://example.com/photo1.jpg",

      ),
      ProfessionalModel(
        employeeId: "12865",
        name: "Bharath Kumar T R",
        branch: "Tiruppur",
        doj: "16/09/2025",
        designation: "Jr.Admin",
        monthlyCTC: "19000",
        annualProfessionalFee: "361200",
        monthlyProfessionalFee: "27090",
        monthlyProfessionalTds: "3010",
        annualTravelAllowance: "0",
        monthlyTravelAllowance: "0",
        monthlyTravelTds: "0",
        photoUrl: "https://example.com/photo1.jpg",
      ),
    ];
    // First time only - set filtered to empty
    _filteredEmployees = [];
    _hasAppliedFilters = false;
    notifyListeners();
  }

  /// Search + filter functionality - only works after filters are applied
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

      _isLoading = false;
      notifyListeners();
    });
  }

  bool _filterByCTC(String employeeCTC, String selectedCTC) {
    double ctc = double.tryParse(employeeCTC) ?? 0;
    double monthlyToAnnual = ctc * 12; // monthly → annual

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
      final parts = employeeDoj.split('/');
      final empDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      DateTime? fromDate;
      DateTime? toDate;

      if (dojFromController.text.isNotEmpty) {
        fromDate = _tryParseDate(dojFromController.text);
      }
      if (fojToController.text.isNotEmpty) {
        toDate = _tryParseDate(fojToController.text);
      }

      if (fromDate != null && empDate.isBefore(fromDate)) return false;
      if (toDate != null && empDate.isAfter(toDate)) return false;

      return true;
    } catch (_) {
      return true;
    }
  }

  DateTime? _tryParseDate(String input) {
    try {
      final parts = input.split('/');
      return DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
    } catch (_) {
      return null;
    }
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

  final dojFromController = TextEditingController();
  final fojToController = TextEditingController();

  @override
  void dispose() {
    dojFromController.dispose();
    fojToController.dispose();
    super.dispose();
  }
}
