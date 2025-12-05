import 'package:flutter/material.dart';
import '../../model/RecruitmentModel/Resume_Management_Model.dart';

class ResumeManagementProvider extends ChangeNotifier {
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

  void clearAllFilters() {
    searchController.clear();
    _selectedPrimaryBranch = null;
    _selectedJobTitle = null;
    _selectedUploadedBy = null;
    _filteredEmployees = [];
    _hasAppliedFilters = false;
    notifyListeners();
  }

  /// Dropdown data
  final List<String> _primaryBranch = [
    "Aathur",
    "Aasam",
    "Nagapattinam",
    "Bengaluru - Hebbal",
  ];
  final List<String> _jobTitle = [
    "Softawre Developer",
    "Accountant",
    "Hr",
    "Tele Calling",
    "Lab Technician",
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
  List<ResumeManagementModel> _allRecruitment = [];
  List<ResumeManagementModel> _filteredEmployees = [];

  List<ResumeManagementModel> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  void onSearchChanged(String query) {
    if (!_hasAppliedFilters) return;
    
    if (query.isEmpty) {
      // Reset to all employees when search is cleared
      _filteredEmployees = List.from(_allRecruitment);
    } else {
      // Filter from all employees, not just filtered list
      final searchQuery = query.toLowerCase();
      _filteredEmployees = _allRecruitment.where((employee) {
        return employee.name.toLowerCase().contains(searchQuery) ||
            employee.cvId.toLowerCase().contains(searchQuery) ||
            employee.jobTitle.toLowerCase().contains(searchQuery) ||
            employee.primaryLocation.toLowerCase().contains(searchQuery);
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
  void initializeEmployees() {
    _allRecruitment = [
      ResumeManagementModel(
        cvId: "RA232",
        name: "MANOJKUMAR DHAMODARAN",
        phone: "95******41",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        uploadedBy: "https://example.com/recruiter2.jpg",
        createdDate: "16/09/2025",
      ),
      ResumeManagementModel(
        cvId: "RA231",
        name: "Sanjay E",
        phone: "70******96",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        uploadedBy: "https://example.com/recruiter2.jpg",
        createdDate: "16/09/2025",
      ),
      ResumeManagementModel(
        cvId: "RA230",
        name: "	Divya",
        phone: "91******47",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        uploadedBy: "https://example.com/recruiter2.jpg",
        createdDate: "16/09/2025",
      ),
      ResumeManagementModel(
        cvId: "RA229",
        name: "sadesh kumar",
        phone: "9*******30",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        uploadedBy: "https://example.com/recruiter2.jpg",
        createdDate: "16/09/2025",
      ),
      ResumeManagementModel(
        cvId: "RA228",
        name: "Sriram Kunjithapadam",
        phone: "80******29",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        uploadedBy: "https://example.com/recruiter2.jpg",
        createdDate: "16/09/2025",
      ),
    ];
    // First time only - set filtered to empty
    _filteredEmployees = [];
    _hasAppliedFilters = false;
    notifyListeners();
  }

  /// Check if all required filters are selected (Primary Branch, Job Title, Designation)
  bool get areAllFiltersSelected {
    return _selectedPrimaryBranch != null &&
        _selectedJobTitle != null &&
        _selectedUploadedBy != null;
  }

  /// Search functionality - only works after all filters are applied
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
      _filteredEmployees = List.from(_allRecruitment);

      // Apply search text filter if present
      if (searchController.text.isNotEmpty) {
        final query = searchController.text.toLowerCase();
        _filteredEmployees = _filteredEmployees.where((employee) {
          return employee.name.toLowerCase().contains(query) ||
              employee.cvId.toLowerCase().contains(query) ||
              employee.jobTitle.toLowerCase().contains(query) ||
              employee.primaryLocation.toLowerCase().contains(query);
        }).toList();
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
    searchController.clear();
    _filteredEmployees = [];
    _hasAppliedFilters = false;
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
