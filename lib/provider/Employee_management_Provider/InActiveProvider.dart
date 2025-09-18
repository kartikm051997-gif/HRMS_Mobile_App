import 'package:flutter/material.dart';

import '../../model/Employee_management/Employee_management.dart';

class InActiveProvider extends ChangeNotifier{
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
    dojFromController.clear();
    fojToController.clear();
    searchController.clear();

    // Refresh the employee list
    searchEmployees();
    notifyListeners();
  }

  Future<bool> activateEmployee(String employeeId) async {
    try {
      // Replace with your actual API call
      // Example:
      // final response = await http.post('/activate-employee', body: {'id': employeeId});
      // return response.statusCode == 200;

      return true; // Temporary - replace with actual API call
    } catch (e) {
      return false;
    }
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

  /// Employee data
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];

  List<Employee> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  void onSearchChanged(String query) {
    // Implement your search logic here
    // Filter employees based on the search query
  }

  void clearSearch() {
    searchController.clear();
    // Reset the employee list to show all employees
  }

  Future<bool> updateEmployeeStatus(String employeeId, String status, DateTime date) async {
    try {
      // Your API call here
      // Send employeeId, status, and date to backend
      return true; // Replace with actual API result
    } catch (e) {
      return false;
    }
  }

  /// Initialize with sample data (replace with API call)
  void initializeEmployees() {
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
    _filteredEmployees = List.from(_allEmployees);
    notifyListeners();
  }

  /// Search functionality
  void searchEmployees() {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _filteredEmployees =
          _allEmployees.where((employee) {
            bool matches = true;

            // Filter by company (if selected)
            if (_selectedCompany != null && _selectedCompany!.isNotEmpty) {
              // Add company filtering logic when you have company data in Employee model
            }

            // Filter by zone (if selected)
            if (_selectedZone != null && _selectedZone!.isNotEmpty) {
              // Add zone filtering logic when you have zone data in Employee model
            }

            // Filter by branch (if selected)
            if (_selectedBranch != null && _selectedBranch!.isNotEmpty) {
              matches =
                  matches &&
                      employee.branch.toLowerCase().contains(
                        _selectedBranch!.toLowerCase(),
                      );
            }

            // Filter by designation (if selected)
            if (_selectedDesignation != null &&
                _selectedDesignation!.isNotEmpty) {
              matches =
                  matches &&
                      employee.designation.toLowerCase().contains(
                        _selectedDesignation!.toLowerCase(),
                      );
            }

            // Filter by CTC (if selected)
            if (_selectedCTC != null && _selectedCTC!.isNotEmpty) {
              matches =
                  matches && _filterByCTC(employee.monthlyCTC, _selectedCTC!);
            }

            // Filter by date range
            if (dojFromController.text.isNotEmpty ||
                fojToController.text.isNotEmpty) {
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
  final dateController = TextEditingController();

  /// Toggle employee status between active and inactive

  @override
  void dispose() {
    dojFromController.dispose();
    fojToController.dispose();
    super.dispose();
  }
}