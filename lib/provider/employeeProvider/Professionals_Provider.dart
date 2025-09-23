import 'package:flutter/material.dart';

import '../../model/AllEmployeeDetailsModel/Professioal_Model.dart';

class ProfessionalsProvider extends ChangeNotifier {
  bool _showFilters = false;
  bool get showFilters => _showFilters;

  int pageSize = 10;
  int currentPage = 0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  void setPageSize(int newSize) {
    pageSize = newSize;
    currentPage = 0; // reset
    notifyListeners();
  }

  void clearAllFilters() {
    dojFromController.clear();
    fojToController.clear();
    searchController.clear();
    searchEmployees();
    notifyListeners();
  }

  void onSearchChanged(String query) {
    // Implement your search logic here
    // Filter employees based on the search query
  }

  void clearSearch() {
    searchController.clear();
    // Reset the employee list to show all employees
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

  /// Employee data
  List<ProfessionalModel> _allEmployees = [];
  List<ProfessionalModel> _filteredEmployees = [];

  List<ProfessionalModel> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  /// Initialize with sample data (replace with API later)
  void initializeEmployees() {
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

    _filteredEmployees = List.from(_allEmployees);
    notifyListeners();
  }

  /// Search + filter functionality
  void searchEmployees() {
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      _filteredEmployees = _allEmployees.where((employee) {
        bool matches = true;

        // Branch
        if (_selectedBranch != null && _selectedBranch!.isNotEmpty) {
          matches = matches &&
              employee.branch.toLowerCase().contains(_selectedBranch!.toLowerCase());
        }

        // Designation
        if (_selectedDesignation != null && _selectedDesignation!.isNotEmpty) {
          matches = matches &&
              employee.designation.toLowerCase().contains(_selectedDesignation!.toLowerCase());
        }

        // CTC
        if (_selectedCTC != null && _selectedCTC!.isNotEmpty) {
          matches = matches && _filterByCTC(employee.monthlyCTC, _selectedCTC!);
        }

        // DOJ Range
        if (dojFromController.text.isNotEmpty || fojToController.text.isNotEmpty) {
          matches = matches && _filterByDateRange(employee.doj);
        }

        return matches;
      }).toList();

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

  /// Clear filters
  void clearFilters() {
    _selectedCompany = null;
    _selectedZone = null;
    _selectedBranch = null;
    _selectedDesignation = null;
    _selectedCTC = null;
    dojFromController.clear();
    fojToController.clear();
    _filteredEmployees = List.from(_allEmployees);
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

  final dojFromController = TextEditingController();
  final fojToController = TextEditingController();

  @override
  void dispose() {
    dojFromController.dispose();
    fojToController.dispose();
    super.dispose();
  }
}
