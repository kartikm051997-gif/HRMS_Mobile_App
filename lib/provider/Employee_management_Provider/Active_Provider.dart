import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../model/Employee_management/ActiveUserListModel.dart' as models;
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../servicesAPI/ActiveUserService/ActiveUserFilterService.dart';
import '../../servicesAPI/ActiveUserService/ActiveUserService.dart';
import '../../servicesAPI/LogInService/LogIn_Service.dart';

class ActiveProvider extends ChangeNotifier {
  // Services
  final ActiveUserService _activeUserService = ActiveUserService();
  final AuthService _authService = AuthService();
  final FilterService _filterService = FilterService();

  // ═══════════════════════════════════════════════════════════════════════
  // STATE VARIABLES
  // ═══════════════════════════════════════════════════════════════════════

  bool _showFilters = false;
  bool get showFilters => _showFilters;

  int currentPage = 0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingFilters = false;
  bool get isLoadingFilters => _isLoadingFilters;

  bool _initialLoadDone = false;
  bool get initialLoadDone => _initialLoadDone;

  bool _hasAppliedFilters = false;
  bool get hasAppliedFilters => _hasAppliedFilters;

  // API response data
  models.ActiveUserList? _activeUserListResponse;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filter raw data from API

  // ═══════════════════════════════════════════════════════════════════════
  // FILTER DATA STRUCTURES
  // ═══════════════════════════════════════════════════════════════════════

  // Store filter data as List<Map<String, String>> with 'id' and 'name'
  List<Map<String, String>> _companyList = [];
  List<Map<String, String>> _zoneList = [];
  List<Map<String, String>> _branchList = [];
  List<Map<String, String>> _designationList = [];
  List<Map<String, String>> _ctcList = [];

  // Getters that return display names for dropdown
  List<String> get company => _companyList.map((e) => e['name']!).toList();
  List<String> get zone => _zoneList.map((e) => e['name']!).toList();
  List<String> get branch {
    if (_selectedZoneIds.isEmpty) {
      return _branchList.map((e) => e['name']!).toList();
    }

    return _branchList
        .where((b) => _selectedZoneIds.contains(b['zone_id']))
        .map((e) => e['name']!)
        .toList();
  }

  List<String> get designation =>
      _designationList.map((e) => e['name']!).toList();
  List<String> get ctc => _ctcList.map((e) => e['name']!).toList();

  // ═══════════════════════════════════════════════════════════════════════
  // SELECTED VALUES (Store both display name and ID)
  // ═══════════════════════════════════════════════════════════════════════

  String? _selectedCompany;
  String? _selectedCompanyId;

  List<String> _selectedZoneIds = [];
  List<String> _selectedZoneNames = [];

  List<String> _selectedBranchIds = [];
  List<String> _selectedBranchNames = [];

  void toggleZone(String zoneName) {
    final zone = _zoneList.firstWhere((z) => z['name'] == zoneName);

    if (_selectedZoneIds.contains(zone['id'])) {
      _selectedZoneIds.remove(zone['id']);
      _selectedZoneNames.remove(zone['name']);
    } else {
      _selectedZoneIds.add(zone['id']!);
      _selectedZoneNames.add(zone['name']!);
    }

    // Reset branches when zone changes
    _selectedBranchIds.clear();
    _selectedBranchNames.clear();

    notifyListeners();
  }

  void toggleBranch(String branchName) {
    final branch = _branchList.firstWhere((b) => b['name'] == branchName);

    if (_selectedBranchIds.contains(branch['id'])) {
      _selectedBranchIds.remove(branch['id']);
      _selectedBranchNames.remove(branch['name']);
    } else {
      _selectedBranchIds.add(branch['id']!);
      _selectedBranchNames.add(branch['name']!);
    }

    notifyListeners();
  }

  String? _selectedDesignation;
  String? _selectedDesignationId;

  String? _selectedCTC;
  String? _selectedCTCId;

  // Getters
  String? get selectedCompany => _selectedCompany;
  List<String> get selectedZones => _selectedZoneNames;
  List<String> get selectedBranches => _selectedBranchNames;

  String? get selectedDesignation => _selectedDesignation;
  String? get selectedCTC => _selectedCTC;

  /// Check if all required filters are selected
  bool get areAllFiltersSelected {
    return _selectedCompanyId != null &&
        _selectedZoneIds.isNotEmpty &&
        _selectedBranchIds.isNotEmpty &&
        _selectedDesignationId != null;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // EMPLOYEE DATA
  // ═══════════════════════════════════════════════════════════════════════

  List<models.Users> _allEmployees = [];
  List<models.Users> _filteredEmployees = [];
  List<models.Users> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();
  final TextEditingController dojFromController = TextEditingController();
  final TextEditingController fojToController = TextEditingController();

  // ═══════════════════════════════════════════════════════════════════════
  // SUMMARY DATA
  // ═══════════════════════════════════════════════════════════════════════

  models.Summary? get summary => _activeUserListResponse?.data?.summary;

  int grandTotalCTC = 0;
  int totalEmployeeCTC = 0;
  int totalF11CTC = 0;
  int totalProfessionalFee = 0;
  int totalStudentCTC = 0;

  // ═══════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════

  /// Initialize - Load filters first, then default employee data
  void initializeEmployees() {
    if (_initialLoadDone) return;

    if (kDebugMode) print("🚀 ActiveProvider: Initializing...");

    // Load filters first
    loadAllFilters();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LOAD FILTERS FROM API
  // ═══════════════════════════════════════════════════════════════════════

  /// Load all filters from API
  Future<void> loadAllFilters() async {
    try {
      _isLoadingFilters = true;
      _errorMessage = null;
      notifyListeners();

      if (kDebugMode) print("🔄 ActiveProvider: Loading filters...");

      // Get auth token
      final token = await _authService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Fetch filters from API
      final filtersData = await _filterService.getAllFilters(token: token);

      if (filtersData == null || filtersData.data == null) {
        throw Exception('Failed to load filter options');
      }

      _processFilterData(filtersData);

      if (kDebugMode) {
        print("✅ ActiveProvider: Filters loaded successfully");
        print("📊 Companies: ${_companyList.length}");
        print("📊 Zones: ${_zoneList.length}");
        print("📊 Branches: ${_branchList.length}");
        print("📊 Designations: ${_designationList.length}");
        print("📊 CTC Ranges: ${_ctcList.length}");
      }

      // After filters loaded, fetch default employee data
      await fetchActiveUsers();

      _initialLoadDone = true;
    } catch (e) {
      _errorMessage = "Error loading filters: ${e.toString()}";
      if (kDebugMode) print("❌ ActiveProvider: $_errorMessage");
      _initialLoadDone = true;
    } finally {
      _isLoadingFilters = false;
      notifyListeners();
    }
  }

  /// Process filter data from API response
  void _processFilterData(GetAllFilters filters) {
    final data = filters.data!;

    // Process Companies
    _companyList =
        data.companies
            ?.map((c) => {'id': c.cmpid ?? '', 'name': c.cmpname ?? ''})
            .where((c) => c['id']!.isNotEmpty && c['name']!.isNotEmpty)
            .toList() ??
        [];

    // Process Zones
    _zoneList =
        data.zones
            ?.map((z) => {'id': z.id ?? '', 'name': z.name ?? ''})
            .where((z) => z['id']!.isNotEmpty && z['name']!.isNotEmpty)
            .toList() ??
        [];

    // Process Branches (with zone_id for filtering)
    _branchList =
        data.branches
            ?.map(
              (b) => {
                'id': b.id ?? '',
                'name': b.name ?? '',
                'zone_id': b.zoneId ?? '',
              },
            )
            .where((b) => b['id']!.isNotEmpty && b['name']!.isNotEmpty)
            .toList() ??
        [];

    // Process Designations (flatten from departments)
    _designationList = [];
    if (data.departments != null) {
      for (var dept in data.departments!) {
        if (dept.designations != null) {
          for (var desig in dept.designations!) {
            if (desig.designationsId != null && desig.designations != null) {
              _designationList.add({
                'id': desig.designationsId!,
                'name': desig.designations!,
                'department_id': dept.departmentId ?? '',
              });
            }
          }
        }
      }
    }

    // Process CTC Ranges
    _ctcList =
        data.ctcRanges
            ?.map((c) => {'id': c.value ?? '', 'name': c.label ?? ''})
            .where((c) => c['id']!.isNotEmpty && c['name']!.isNotEmpty)
            .toList() ??
        [];

    if (kDebugMode) {
      print("📊 Processed ${_companyList.length} companies");
      print("📊 Processed ${_zoneList.length} zones");
      print("📊 Processed ${_branchList.length} branches");
      print("📊 Processed ${_designationList.length} designations");
      print("📊 Processed ${_ctcList.length} CTC ranges");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FETCH ACTIVE USERS
  // ═══════════════════════════════════════════════════════════════════════

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
            search: search ?? searchController.text,
          );

      if (response != null && response.status == 'success') {
        _activeUserListResponse = response;

        // Update employee list
        _allEmployees = response.data?.users ?? [];
        _filteredEmployees = List.from(_allEmployees);

        // Update summary data
        if (response.data?.summary != null) {
          final summary = response.data!.summary!;
          grandTotalCTC = _parseIntFromString(summary.grandTotal) ?? 0;
          totalEmployeeCTC = _parseIntFromString(summary.totalMonthlyCtc) ?? 0;
          totalF11CTC = _parseIntFromString(summary.f11Employees) ?? 0;
          totalProfessionalFee =
              _parseIntFromString(summary.professionalFee) ?? 0;
          totalStudentCTC = _parseIntFromString(summary.studentCtc) ?? 0;

          if (kDebugMode) {
            print("✅ Summary - Grand Total: $grandTotalCTC");
          }
        } else {
          // Reset if no summary
          grandTotalCTC = 0;
          totalEmployeeCTC = 0;
          totalF11CTC = 0;
          totalProfessionalFee = 0;
          totalStudentCTC = 0;
        }

        _hasAppliedFilters = true;

        if (kDebugMode) {
          print("✅ ActiveProvider: Loaded ${_allEmployees.length} employees");
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

  /// Helper to parse integers from strings
  int? _parseIntFromString(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final cleanedValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanedValue)?.toInt();
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FILTER SETTERS
  // ═══════════════════════════════════════════════════════════════════════

  void setSelectedCompany(String? displayName) {
    _selectedCompany = displayName;
    if (displayName != null) {
      final item = _companyList.firstWhere(
        (c) => c['name'] == displayName,
        orElse: () => {},
      );
      _selectedCompanyId = item['id'];
    } else {
      _selectedCompanyId = null;
    }
    notifyListeners();
  }

  void setZones(List<String> zoneNames) {
    _selectedZoneNames = zoneNames;

    _selectedZoneIds =
        _zoneList
            .where((z) => zoneNames.contains(z['name']))
            .map((z) => z['id']!)
            .toList();

    // Clear branch when zone changes
    _selectedBranchNames.clear();
    _selectedBranchIds.clear();

    notifyListeners();
  }

  void setBranches(List<String> branchNames) {
    _selectedBranchNames = branchNames;

    _selectedBranchIds =
        _branchList
            .where((b) => branchNames.contains(b['name']))
            .map((b) => b['id']!)
            .toList();

    notifyListeners();
  }

  void setSelectedDesignation(String? displayName) {
    _selectedDesignation = displayName;
    if (displayName != null) {
      final item = _designationList.firstWhere(
        (d) => d['name'] == displayName,
        orElse: () => {},
      );
      _selectedDesignationId = item['id'];
    } else {
      _selectedDesignationId = null;
    }
    notifyListeners();
  }

  void setSelectedCTC(String? displayName) {
    _selectedCTC = displayName;
    if (displayName != null) {
      final item = _ctcList.firstWhere(
        (c) => c['name'] == displayName,
        orElse: () => {},
      );
      _selectedCTCId = item['id'];
    } else {
      _selectedCTCId = null;
    }
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SEARCH & ACTIONS
  // ═══════════════════════════════════════════════════════════════════════

  /// Search employees with filters
  void searchEmployees() {
    if (!areAllFiltersSelected) {
      if (kDebugMode) print("⚠️ Not all required filters selected");
      return;
    }

    fetchActiveUsers(
      cmpid: _selectedCompanyId,
      zoneId: _selectedZoneIds.join(','),
      locationsId: _selectedBranchIds.join(','),
      designationsId: _selectedDesignationId,
      ctcRange: _selectedCTCId,
      fromdate:
          dojFromController.text.isNotEmpty ? dojFromController.text : null,
      todate: fojToController.text.isNotEmpty ? fojToController.text : null,
      search: searchController.text.isNotEmpty ? searchController.text : null,
    );
  }

  /// Client-side search filtering
  void onSearchChanged(String query) {
    if (!_initialLoadDone) return;

    if (query.isEmpty) {
      _filteredEmployees = List.from(_allEmployees);
    } else {
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
    _filteredEmployees = List.from(_allEmployees);
    notifyListeners();
  }

  /// Clear all filters
  void clearAllFilters() {
    _selectedCompany = null;
    _selectedCompanyId = null;

    _selectedZoneIds.clear();
    _selectedZoneNames.clear();

    _selectedBranchIds.clear();
    _selectedBranchNames.clear();

    _selectedDesignation = null;
    _selectedDesignationId = null;

    _selectedCTC = null;
    _selectedCTCId = null;

    dojFromController.clear();
    fojToController.clear();
    searchController.clear();

    _errorMessage = null;
    notifyListeners();

    fetchActiveUsers();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // UI HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  /// Toggle employee status
  Future<void> toggleEmployeeStatus(String employeeId) async {
    try {
      final userIndex = _allEmployees.indexWhere(
        (user) => (user.employmentId ?? user.userId ?? "") == employeeId,
      );

      if (userIndex != -1) {
        final currentUser = _allEmployees[userIndex];
        final currentStatus = (currentUser.status ?? "").toLowerCase();
        final newStatus = currentStatus == 'active' ? 'Inactive' : 'Active';

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

        _allEmployees[userIndex] = updatedUser;

        final filteredIndex = _filteredEmployees.indexWhere(
          (user) => (user.employmentId ?? user.userId ?? "") == employeeId,
        );
        if (filteredIndex != -1) {
          _filteredEmployees[filteredIndex] = updatedUser;
        }

        notifyListeners();

        if (kDebugMode) print('✅ User $employeeId status: $newStatus');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error toggling status: $e');
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
