import 'package:flutter/material.dart';

import '../../model/RecruitmentModel/Semi_Filled_Application_Model.dart';

class SemiFilledApplicationProvider extends ChangeNotifier {
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
    currentPage = 0; // reset when changed
    notifyListeners();
  }

  void clearAllFilters() {
    searchController.clear();

    // Refresh the employee list
    searchEmployees();
    notifyListeners();
  }

  /// Dropdown data
  final List<String> _primaryBranch = ["Aathur", "Aasam"];
  final List<String> _jobTitle = [
    "Softawre Developer",
    "Accountant",
    "Hr",
    "Tele Calling",
  ];
  final List<String> _uploadedBy = [
    "Durga Prakash - 10876",
    "Karthick - 7866",
    "Abi - 8764",
    "Viki - 8754",
  ];

  List<String> get primaryBranch => _primaryBranch;
  List<String> get jobTitle => _jobTitle;
  List<String> get uploadedBy => _uploadedBy;

  /// Selected values
  String? _selectedPrimaryBranch;
  String? _selectedJobTitle;
  String? _selectedUploadedBy;

  String? get selectedPrimaryBranch => _selectedPrimaryBranch;
  String? get selectedJobTitle => _selectedJobTitle;
  String? get selectedUploadedBy => _selectedUploadedBy;

  /// Employee data
  List<SemiFilledApplicationModel> _allSemiApplication = [];
  List<SemiFilledApplicationModel> _filteredEmployees = [];

  List<SemiFilledApplicationModel> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  void onSearchChanged(String query) {
    // Implement your search logic here
    // Filter employees based on the search query
  }

  void clearSearch() {
    searchController.clear();
    // Reset the employee list to show all employees
  }

  /// Initialize with sample data (replace with API call)
  void initializeEmployees() {
    _allSemiApplication = [
      SemiFilledApplicationModel(
        name: "MANOJKUMAR DHAMODARAN",
        phone: "95******41",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        access: "-",
        appliedOn: "12/05/2025",
        email: "karthickboy@gmail.com",
      ),
      SemiFilledApplicationModel(
        name: "Sanjay E",
        phone: "70******96",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        access: "-",
        appliedOn: "12/05/2025",
        email: "karthickboy@gmail.com",
      ),
      SemiFilledApplicationModel(
        name: "	Divya",
        phone: "91******47",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        access: "-",
        appliedOn: "12/05/2025",
        email: "karthickboy@gmail.com",
      ),
      SemiFilledApplicationModel(
        name: "sadesh kumar",
        phone: "9*******30",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        access: "-",
        appliedOn: "12/05/2025",
        email: "karthickboy@gmail.com",
      ),
      SemiFilledApplicationModel(
        name: "Sriram Kunjithapadam",
        phone: "80******29",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        access: "-",
        appliedOn: "12/05/2025",
        email: "karthickboy@gmail.com",
      ),
    ];
    _filteredEmployees = List.from(_allSemiApplication);
    notifyListeners();
  }

  /// Search functionality
  void searchEmployees() {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _filteredEmployees =
          _allSemiApplication.where((employee) {
            bool matches = true;

            // Filter by company (if selected)
            if (_selectedPrimaryBranch != null &&
                _selectedPrimaryBranch!.isNotEmpty) {
              // Add company filtering logic when you have company data in Employee model
            }

            // Filter by zone (if selected)
            if (_selectedJobTitle != null && _selectedJobTitle!.isNotEmpty) {
              // Add zone filtering logic when you have zone data in Employee model
            }
            if (_selectedUploadedBy != null &&
                _selectedUploadedBy!.isNotEmpty) {
              // Add zone filtering logic when you have zone data in Employee model
            }

            // Filter by branch (if selected)

            return matches;
          }).toList();

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
    _selectedPrimaryBranch = null;
    _selectedJobTitle = null;
    _selectedUploadedBy = null;

    _filteredEmployees = List.from(_allSemiApplication);
    notifyListeners();
  }

  /// Setters
  void setSelectedPrimaryBranch(String? v) {
    _selectedPrimaryBranch = v;
    notifyListeners();
  }

  void setSelectedJobTitle(String? v) {
    _selectedJobTitle = v;
    notifyListeners();
  }

  void setSelectedUploadedBy(String? v) {
    _selectedUploadedBy = v;
    notifyListeners();
  }
}
