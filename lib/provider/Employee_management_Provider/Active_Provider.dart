import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/Employee_management/ActiveUserListModel.dart' as models;
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../servicesAPI/ActiveUserService/ActiveUserFilterService.dart';
import '../../servicesAPI/ActiveUserService/ActiveUserService.dart';

class ActiveProvider extends ChangeNotifier {
  // Services
  final ActiveUserService _activeUserService = ActiveUserService();
  final FilterService _filterService = FilterService();

  // ═══════════════════════════════════════════════════════════════════════
  // STATE VARIABLES
  // ═══════════════════════════════════════════════════════════════════════

  bool _showFilters = false;
  bool get showFilters => _showFilters;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingFilters = false;
  bool get isLoadingFilters => _isLoadingFilters;

  bool _initialLoadDone = false;
  bool get initialLoadDone => _initialLoadDone;

  bool _hasAppliedFilters = false;
  bool get hasAppliedFilters => _hasAppliedFilters;

  // ✅ TOKEN EXPIRATION FLAG
  bool _isTokenExpired = false;
  bool get isTokenExpired => _isTokenExpired;

  // API response data
  models.ActiveUserList? _activeUserListResponse;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ═══════════════════════════════════════════════════════════════════════
  // FILTER DATA STRUCTURES
  // ═══════════════════════════════════════════════════════════════════════

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
  // SELECTED VALUES
  // ═══════════════════════════════════════════════════════════════════════

  String? _selectedCompany;
  String? _selectedCompanyId;

  List<String> _selectedZoneIds = [];
  List<String> _selectedZoneNames = [];

  List<String> _selectedBranchIds = [];
  List<String> _selectedBranchNames = [];

  String? _selectedCTC;
  String? _selectedCTCId;

  List<String> _selectedDesignationIds = [];
  List<String> _selectedDesignationNames = [];

  // Getters
  String? get selectedCompany => _selectedCompany;
  List<String> get selectedZones => _selectedZoneNames;
  List<String> get selectedBranches => _selectedBranchNames;
  List<String> get selectedDesignations => _selectedDesignationNames;
  String? get selectedCTC => _selectedCTC;

  bool get areAllFiltersSelected {
    return _selectedCompanyId != null &&
        _selectedZoneIds.isNotEmpty &&
        _selectedBranchIds.isNotEmpty &&
        _selectedDesignationIds.isNotEmpty; // ✅ Changed
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
  // PAGINATION
  // ═══════════════════════════════════════════════════════════════════════

  int _currentPage = 1;
  final int _itemsPerPage = 10;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  int get totalPages {
    if (_filteredEmployees.isEmpty) return 0;
    return (_filteredEmployees.length / _itemsPerPage).ceil();
  }

  List<models.Users> get paginatedEmployees {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= _filteredEmployees.length) {
      return [];
    }

    return _filteredEmployees.sublist(
      startIndex,
      endIndex > _filteredEmployees.length
          ? _filteredEmployees.length
          : endIndex,
    );
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

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

  void initializeEmployees() {
    if (_initialLoadDone) return;

    _isLoading = true; // 🔥 START SHIMMER
    _initialLoadDone = false;
    notifyListeners();

    if (kDebugMode) print("🚀 ActiveProvider: Initializing...");
    loadAllFilters();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PAGE-SPECIFIC SUMMARY DATA
  // ═══════════════════════════════════════════════════════════════════════

  /// Calculate summary for current page employees only
  Map<String, int> get currentPageSummary {
    int pageGrandTotal = 0;
    int pageEmployeeCTC = 0;
    int pageF11CTC = 0;
    int pageProfessionalFee = 0;
    int pageStudentCTC = 0;

    for (var employee in paginatedEmployees) {
      // Parse monthly CTC
      final monthlyCtc = _parseIntFromString(employee.monthlyCtc) ?? 0;

      // Add to appropriate category based on payroll category
      final payrollCategory = (employee.payrollCategory ?? '').toLowerCase();

      if (payrollCategory.contains('employee')) {
        pageEmployeeCTC += monthlyCtc;
      } else if (payrollCategory.contains('f11') ||
          payrollCategory.contains('f-11')) {
        pageF11CTC += monthlyCtc;
      } else if (payrollCategory.contains('professional')) {
        pageProfessionalFee += monthlyCtc;
      } else if (payrollCategory.contains('student')) {
        pageStudentCTC += monthlyCtc;
      }

      // Add to grand total
      pageGrandTotal += monthlyCtc;
    }

    return {
      'grandTotal': pageGrandTotal,
      'employeeCTC': pageEmployeeCTC,
      'f11CTC': pageF11CTC,
      'professionalFee': pageProfessionalFee,
      'studentCTC': pageStudentCTC,
    };
  }

  // Helper getters for easy access
  int get currentPageGrandTotal => currentPageSummary['grandTotal'] ?? 0;
  int get currentPageEmployeeCTC => currentPageSummary['employeeCTC'] ?? 0;
  int get currentPageF11CTC => currentPageSummary['f11CTC'] ?? 0;
  int get currentPageProfessionalFee =>
      currentPageSummary['professionalFee'] ?? 0;
  int get currentPageStudentCTC => currentPageSummary['studentCTC'] ?? 0;

  // ═══════════════════════════════════════════════════════════════════════
  // HELPER: CLEAR AUTH SESSION
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> _clearAuthSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('role_id');
      await prefs.remove('logged_in_emp_id');
      await prefs.remove('employeeId');
      if (kDebugMode) print("✅ Auth session cleared");
    } catch (e) {
      if (kDebugMode) print("❌ Error clearing session: $e");
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LOAD FILTERS FROM API
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> loadAllFilters() async {
    try {
      _isLoadingFilters = true;
      _isLoading = true;
      _errorMessage = null;
      _isTokenExpired = false;
      notifyListeners();

      if (kDebugMode) {
        print("🔄 ActiveProvider: Loading filters...");
      }

      // 🔥 DO NOT fetch token here anymore
      // ApiHelper will attach token automatically

      final filtersData = await _filterService.getAllFilters();

      if (filtersData == null || filtersData.data == null) {
        throw Exception('Invalid filter response from server');
      }

      // ✅ Process filters
      _processFilterData(filtersData);

      if (kDebugMode) {
        print("✅ ActiveProvider: Filters loaded successfully");
        print("📊 Companies: ${_companyList.length}");
        print("📊 Zones: ${_zoneList.length}");
        print("📊 Branches: ${_branchList.length}");
        print("📊 Designations: ${_designationList.length}");
        print("📊 CTC Ranges: ${_ctcList.length}");
      }

      // 🔥 Load users after filters
      await fetchActiveUsers();

      _initialLoadDone = true;
    } catch (e) {
      // 🚨 Handle auth issues
      if (e.toString().contains("401") ||
          e.toString().contains("UNAUTHORIZED") ||
          e.toString().contains("TOKEN_EXPIRED")) {
        _isTokenExpired = true;
        _errorMessage = "Your session has expired. Please login again.";

        if (kDebugMode) {
          print("⛔ Token expired – clearing session");
        }

        await _clearAuthSession();
      } else {
        _errorMessage = "Error loading filters: $e";
      }

      if (kDebugMode) {
        print("❌ ActiveProvider: $_errorMessage");
      }

      _initialLoadDone = true;
    } finally {
      _isLoadingFilters = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processFilterData(GetAllFilters filters) {
    final data = filters.data!;

    _companyList =
        data.companies
            ?.map((c) => {'id': c.cmpid ?? '', 'name': c.cmpname ?? ''})
            .where((c) => c['id']!.isNotEmpty && c['name']!.isNotEmpty)
            .toList() ??
        [];

    _zoneList =
        data.zones
            ?.map((z) => {'id': z.id ?? '', 'name': z.name ?? ''})
            .where((z) => z['id']!.isNotEmpty && z['name']!.isNotEmpty)
            .toList() ??
        [];

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

    _ctcList =
        data.ctcRanges
            ?.map((c) => {'id': c.value ?? '', 'name': c.label ?? ''})
            .where((c) => c['id']!.isNotEmpty && c['name']!.isNotEmpty)
            .toList() ??
        [];
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FETCH ACTIVE USERS
  // ═══════════════════════════════════════════════════════════════════════

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
      _isTokenExpired = false;
      notifyListeners();

      if (kDebugMode) print("🔄 ActiveProvider: Fetching active users...");

      // 🔥 ApiHelper will attach token automatically
      final response = await _activeUserService.getActiveUsers(
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
        _allEmployees = response.data?.users ?? [];
        _filteredEmployees = List.from(_allEmployees);

        final summary = response.data?.summary;
        if (summary != null) {
          grandTotalCTC = _parseIntFromString(summary.grandTotal) ?? 0;
          totalEmployeeCTC = _parseIntFromString(summary.totalMonthlyCtc) ?? 0;
          totalF11CTC = _parseIntFromString(summary.f11Employees) ?? 0;
          totalProfessionalFee =
              _parseIntFromString(summary.professionalFee) ?? 0;
          totalStudentCTC = _parseIntFromString(summary.studentCtc) ?? 0;
        }

        _hasAppliedFilters = true;

        if (kDebugMode) {
          print("✅ ActiveProvider: Loaded ${_allEmployees.length} employees");
        }
      } else {
        _errorMessage = response?.message ?? "Failed to load employees";
      }
    } catch (e) {
      if (e.toString().contains("401") ||
          e.toString().contains("UNAUTHORIZED")) {
        _isTokenExpired = true;
        _errorMessage = "Your session has expired. Please login again.";
        await _clearAuthSession();
      } else {
        _errorMessage = "Error loading employees: $e";
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  void setSelectedZones(List<String> zoneNames) {
    _selectedZoneNames = zoneNames;
    _selectedZoneIds =
        _zoneList
            .where((z) => zoneNames.contains(z['name']))
            .map((z) => z['id']!)
            .toList();

    _selectedBranchNames.clear();
    _selectedBranchIds.clear();
    notifyListeners();
  }

  void setSelectedBranches(List<String> branchNames) {
    _selectedBranchNames = branchNames;
    _selectedBranchIds =
        _branchList
            .where((b) => branchNames.contains(b['name']))
            .map((b) => b['id']!)
            .toList();
    notifyListeners();
  }

  void setSelectedDesignations(List<String> designationNames) {
    _selectedDesignationNames = designationNames;
    _selectedDesignationIds =
        _designationList
            .where((d) => designationNames.contains(d['name']))
            .map((d) => d['id']!)
            .toList();
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

  void searchEmployees() {
    if (!areAllFiltersSelected) {
      if (kDebugMode) print("⚠️ Not all required filters selected");
      return;
    }

    _currentPage = 1; // ✅ Reset to first page

    fetchActiveUsers(
      cmpid: _selectedCompanyId,
      zoneId: _selectedZoneIds.join(','),
      locationsId: _selectedBranchIds.join(','),
      designationsId: _selectedDesignationIds.join(','), // ✅ Changed
      ctcRange: _selectedCTCId,
      fromdate:
          dojFromController.text.isNotEmpty ? dojFromController.text : null,
      todate: fojToController.text.isNotEmpty ? fojToController.text : null,
      search: searchController.text.isNotEmpty ? searchController.text : null,
    );
  }

  void onSearchChanged(String query) {
    if (!_initialLoadDone) return;

    _currentPage = 1; // ✅ Reset to first page when searching

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
    _currentPage = 1;
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedCompany = null;
    _selectedCompanyId = null;
    _selectedZoneIds.clear();
    _selectedZoneNames.clear();
    _selectedBranchIds.clear();
    _selectedBranchNames.clear();
    _selectedDesignationIds.clear(); // ✅ Changed
    _selectedDesignationNames.clear(); // ✅ Changed
    _selectedCTC = null;
    _selectedCTCId = null;
    dojFromController.clear();
    fojToController.clear();
    searchController.clear();
    _errorMessage = null;
    _currentPage = 1;
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
