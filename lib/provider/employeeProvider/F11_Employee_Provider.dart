import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/model/AllEmployeeDetailsModel/F11_Employee_Model.dart';

class F11EmployeeProvider extends ChangeNotifier {
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

  /// Check if all required filters are selected (Zone, Branch, Designation)
  bool get areAllFiltersSelected {
    return _selectedZone != null &&
        _selectedBranch != null &&
        _selectedDesignation != null;
  }

  /// Employee basic data
  List<F11EmployeeModel> _f11Employees = [];
  List<F11EmployeeModel> _filteredEmployees = [];

  List<F11EmployeeModel> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  void onSearchChanged(String query) {
    if (!_hasAppliedFilters) return;
    
    if (query.isEmpty) {
      // Reset to all employees when search is cleared
      _filteredEmployees = List.from(_f11Employees);
    } else {
      // Filter from all employees, not just filtered list
      _filteredEmployees = _f11Employees.where((employee) {
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
    if (_f11Employees.isNotEmpty) {
      return;
    }
    
    _f11Employees = [
      F11EmployeeModel(
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
        annualCTC: '566666',
        allowance: '2400',
        pf: '2500',
        esi: '800',
        hra: '3000',
        basic: '5000',
        monthlyTakeHome: '18000',
        annualProfessionalFee: '3,61,200',
        monthlyProfessionalFee: '27,090',
        monthlyProfessionalTds: '3,010',
        annualTravelAllowance: '0',
        monthlyTravelAllowance: '0',
        monthlyTravelTds: '0',
        annualStudentStipend: '24,000',
        monthlyStudentStipend: '2,000',
      ),
      F11EmployeeModel(
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
        annualCTC: '566666',
        allowance: '2400',
        pf: '2500',
        esi: '800',
        hra: '3000',
        basic: '5000',
        monthlyTakeHome: '18000',
        annualProfessionalFee: '3,61,200',
        monthlyProfessionalFee: '27,090',
        monthlyProfessionalTds: '3,010',
        annualTravelAllowance: '0',
        monthlyTravelAllowance: '0',
        monthlyTravelTds: '0',
        annualStudentStipend: '24,000',
        monthlyStudentStipend: '2,000',
      ),
      F11EmployeeModel(
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
        annualCTC: '566666',
        allowance: '2400',
        pf: '2500',
        esi: '800',
        hra: '3000',
        basic: '5000',
        monthlyTakeHome: '18000',
        annualProfessionalFee: '3,61,200',
        monthlyProfessionalFee: '27,090',
        monthlyProfessionalTds: '3,010',
        annualTravelAllowance: '0',
        monthlyTravelAllowance: '0',
        monthlyTravelTds: '0',
        annualStudentStipend: '24,000',
        monthlyStudentStipend: '2,000',
      ),
      F11EmployeeModel(
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
        annualCTC: '566666',
        allowance: '2400',
        pf: '2500',
        esi: '800',
        hra: '3000',
        basic: '5000',
        monthlyTakeHome: '18000',
        annualProfessionalFee: '3,61,200',
        monthlyProfessionalFee: '27,090',
        monthlyProfessionalTds: '3,010',
        annualTravelAllowance: '0',
        monthlyTravelAllowance: '0',
        monthlyTravelTds: '0',
        annualStudentStipend: '24,000',
        monthlyStudentStipend: '2,000',
      ),
      F11EmployeeModel(
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
        annualCTC: '566666',
        allowance: '2400',
        pf: '2500',
        esi: '800',
        hra: '3000',
        basic: '5000',
        monthlyTakeHome: '18000',
        annualProfessionalFee: '3,61,200',
        monthlyProfessionalFee: '27,090',
        monthlyProfessionalTds: '3,010',
        annualTravelAllowance: '0',
        monthlyTravelAllowance: '0',
        monthlyTravelTds: '0',
        annualStudentStipend: '24,000',
        monthlyStudentStipend: '2,000',
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
      _filteredEmployees = List.from(_f11Employees);

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

  @override
  void dispose() {
    dojFromController.dispose();
    fojToController.dispose();
    super.dispose();
  }
}
