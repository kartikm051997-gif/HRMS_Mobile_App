import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../model/Employee_management/ActiveUserListModel.dart' as models;

import '../../servicesAPI/ActiveUserService.dart';
import '../../servicesAPI/LogIn_Service.dart';

class ActiveProvider extends ChangeNotifier {
  // Services
  final ActiveUserService _activeUserService = ActiveUserService();
  final AuthService _authService = AuthService();

  /// Toggle filter section
  bool _showFilters = false;
  bool get showFilters => _showFilters;
  int pageSize = 10;
  int currentPage = 0;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // API response data
  models.ActiveUserList? _activeUserListResponse;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Get summary data from API response
  models.Summary? get summary => _activeUserListResponse?.data?.summary;

  /// Flag to control whether to show employee cards
  /// Now shows default data on load
  bool _hasAppliedFilters = false;
  bool get hasAppliedFilters => _hasAppliedFilters;

  /// Flag to track if initial load is done
  bool _initialLoadDone = false;
  bool get initialLoadDone => _initialLoadDone;

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  void setPageSize(int newSize) {
    pageSize = newSize;
    currentPage = 0; // reset when changed
    notifyListeners();
  }

  /// Clear all filters and reload default data
  void clearAllFilters() {
    _selectedCompany = null;
    _selectedZone = null;
    _selectedBranch = null;
    _selectedDesignation = null;
    _selectedCTC = null;
    dojFromController.clear();
    fojToController.clear();
    searchController.clear();
    _errorMessage = null;
    notifyListeners();

    // Reload default data
    fetchActiveUsers();
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

  /// Employee data - Use Users model directly from API
  List<models.Users> _allEmployees = [];
  List<models.Users> _filteredEmployees = [];

  List<models.Users> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  // =======================
  // CTC SUMMARY VALUES
  // =======================
  int grandTotalCTC = 0;
  int totalEmployeeCTC = 0;
  int totalF11CTC = 0;
  int totalProfessionalFee = 0;
  int totalStudentCTC = 0;

  void onSearchChanged(String query) {
    // Perform client-side filtering for instant feedback
    if (!_initialLoadDone) return;

    if (query.isEmpty) {
      // Reset to all employees when search is cleared
      _filteredEmployees = List.from(_allEmployees);
    } else {
      // Filter from all employees, not just filtered list
      _filteredEmployees =
          _allEmployees.where((user) {
            return (user.fullname ?? "").toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                (user.employmentId ?? user.userId ?? "").toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                (user.designation ?? "").toLowerCase().contains(
                  query.toLowerCase(),
                );
          }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    // Reset to full list
    _filteredEmployees = List.from(_allEmployees);
    notifyListeners();
  }

  /// Initialize with API data - loads default data on first load
  void initializeEmployees() {
    // If data is already loaded, don't reset
    if (_initialLoadDone) {
      return;
    }

    // Load default data from API
    fetchActiveUsers();
  }

  /// Fetch active users from API
  Future<void> fetchActiveUsers({
    String? cmpid,
    String? zoneId,
    String? locationsId,
    String? designationsId,
    String? ctcRange,
    String? punch,
    String? dolpFromdate,
    String? dolpTodate,
    String? fromdate,
    String? todate,
    int? page,
    int? perPage,
    String? search,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get bearer token
      final token = await _authService.getAuthToken();
      if (token == null || token.isEmpty) {
        _errorMessage = "Authentication token not found. Please login again.";
        _isLoading = false;
        notifyListeners();
        if (kDebugMode) print("❌ ActiveProvider: No auth token found");
        return;
      }

      if (kDebugMode) print("🔄 ActiveProvider: Fetching active users...");

      // Call API
      final models.ActiveUserList? response = await _activeUserService
          .getActiveUsers(
            token: token,
            cmpid: cmpid,
            zoneId: zoneId,
            locationsId: locationsId,
            designationsId: designationsId,
            ctcRange: ctcRange,
            punch: punch,
            dolpFromdate: dolpFromdate,
            dolpTodate: dolpTodate,
            fromdate: fromdate,
            todate: todate,
            page: page ?? currentPage,
            perPage: perPage ?? pageSize,
            search: search ?? searchController.text,
          );

      if (response != null && response.status == 'success') {
        _activeUserListResponse = response;

        // Use Users directly from API response - no conversion needed
        _allEmployees = response.data?.users ?? [];
        _filteredEmployees = List.from(_allEmployees);

        // Extract and assign summary data from API response
        if (response.data?.summary != null) {
          final summary = response.data!.summary!;
          grandTotalCTC = _parseIntFromString(summary.grandTotal) ?? 0;
          totalEmployeeCTC = _parseIntFromString(summary.totalMonthlyCtc) ?? 0;
          totalF11CTC = _parseIntFromString(summary.f11Employees) ?? 0;
          totalProfessionalFee =
              _parseIntFromString(summary.professionalFee) ?? 0;
          totalStudentCTC = _parseIntFromString(summary.studentCtc) ?? 0;

          if (kDebugMode) {
            print(
              "✅ ActiveProvider: Summary loaded - Grand Total: $grandTotalCTC, Employee CTC: $totalEmployeeCTC",
            );
          }
        } else {
          // Reset summary values if no summary data available
          grandTotalCTC = 0;
          totalEmployeeCTC = 0;
          totalF11CTC = 0;
          totalProfessionalFee = 0;
          totalStudentCTC = 0;
          if (kDebugMode) {
            print("⚠️ ActiveProvider: No summary data in API response");
          }
        }

        _hasAppliedFilters = true;
        _initialLoadDone = true;

        if (kDebugMode) {
          print("✅ ActiveProvider: Loaded ${_allEmployees.length} employees");
          print("📊 Summary exists: ${response.data?.summary != null}");
          if (response.data?.summary != null) {
            final s = response.data!.summary!;
            print("📊 Grand Total: ${s.grandTotal}");
            print("📊 Total Monthly CTC: ${s.totalMonthlyCtc}");
            print("📊 F11 Employees: ${s.f11Employees}");
            print("📊 Professional Fee: ${s.professionalFee}");
            print("📊 Student CTC: ${s.studentCtc}");
            print("📊 Full Summary Object: ${s.toJson()}");
          } else {
            print("❌ Summary is NULL in API response");
          }
        }
      } else {
        _errorMessage = response?.message ?? "Failed to load employees";
        if (kDebugMode) print("❌ ActiveProvider: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = "Error loading employees: ${e.toString()}";
      if (kDebugMode) print("❌ ActiveProvider: Exception - $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper method to parse integer from string (handles null/empty strings)
  int? _parseIntFromString(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      // Remove any formatting (commas, currency symbols, etc.)
      final cleanedValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanedValue)?.toInt();
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ ActiveProvider: Error parsing summary value '$value': $e");
      }
      return null;
    }
  }

  /// Search functionality - calls API with filters
  void searchEmployees() {
    if (!areAllFiltersSelected) {
      // Don't search if not all filters are selected
      return;
    }

    // Call API with filter parameters
    fetchActiveUsers(
      cmpid: _selectedCompany,
      zoneId: _selectedZone,
      locationsId: _selectedBranch,
      designationsId: _selectedDesignation,
      ctcRange: _selectedCTC,
      fromdate:
          dojFromController.text.isNotEmpty ? dojFromController.text : null,
      todate: fojToController.text.isNotEmpty ? fojToController.text : null,
      search: searchController.text.isNotEmpty ? searchController.text : null,
    );
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
      // Find the user in the list
      final userIndex = _allEmployees.indexWhere(
        (user) => (user.employmentId ?? user.userId ?? "") == employeeId,
      );

      if (userIndex != -1) {
        // Update the status locally first for immediate UI feedback
        final currentUser = _allEmployees[userIndex];
        final currentStatus = (currentUser.status ?? "").toLowerCase();
        final newStatus = currentStatus == 'active' ? 'Inactive' : 'Active';

        // Create updated user object
        final updatedUser = models.Users(
          userId: currentUser.userId,
          employmentId: currentUser.employmentId,
          username: currentUser.username,
          fullname: currentUser.fullname,
          mobile: currentUser.mobile,
          email: currentUser.email,
          avatar: currentUser.avatar,
          locationName: currentUser.locationName,
          zoneId: currentUser.zoneId,
          designation: currentUser.designation,
          department: currentUser.department,
          joiningDate: currentUser.joiningDate,
          monthlyCtc: currentUser.monthlyCtc,
          annualCtc: currentUser.annualCtc,
          recentPunchDate: currentUser.recentPunchDate,
          payrollCategory: currentUser.payrollCategory,
          status: newStatus,
        );

        // Update the user in the list
        _allEmployees[userIndex] = updatedUser;

        // Update filtered users as well
        final filteredIndex = _filteredEmployees.indexWhere(
          (user) => (user.employmentId ?? user.userId ?? "") == employeeId,
        );
        if (filteredIndex != -1) {
          _filteredEmployees[filteredIndex] = updatedUser;
        }

        // Notify listeners to update UI
        notifyListeners();

        if (kDebugMode) {
          print('User $employeeId status changed to: $newStatus');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling user status: $e');
      }
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
