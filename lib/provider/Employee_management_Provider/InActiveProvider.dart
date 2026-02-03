import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/Employee_management/InActiveUserListModelClass.dart'
    as models;
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/ActiveUserFilterService.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/InActiveuserListService.dart';
import '../../core/utils/helper_utils.dart';

class InActiveProvider extends ChangeNotifier {
  // Services
  final InActiveUserService _inActiveUserService = InActiveUserService();
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

  // API response data (full response for message/total if needed)
  models.InActiveUserListModelClass? _inActiveUserListResponse;
  models.InActiveUserListModelClass? get inActiveListResponse =>
      _inActiveUserListResponse;
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
    if (_selectedZoneId == null) {
      return _branchList.map((e) => e['name']!).toList();
    }
    return _branchList
        .where((b) => b['zone_id'] == _selectedZoneId)
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

  String? _selectedZoneId;
  String? _selectedZoneName;

  List<String> _selectedBranchIds = [];
  List<String> _selectedBranchNames = [];

  String? _selectedCTC;
  String? _selectedCTCId;

  List<String> _selectedDesignationIds = [];
  List<String> _selectedDesignationNames = [];

  // Getters
  String? get selectedCompany => _selectedCompany;
  String? get selectedZone => _selectedZoneName;
  List<String> get selectedBranches => _selectedBranchNames;
  List<String> get selectedDesignations => _selectedDesignationNames;
  String? get selectedCTC => _selectedCTC;

  bool get areAllFiltersSelected {
    return _selectedZoneId != null &&
        _selectedBranchIds.isNotEmpty &&
        _selectedDesignationIds.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // EMPLOYEE DATA
  // ═══════════════════════════════════════════════════════════════════════

  List<models.InActiveUser> _allEmployees = [];
  List<models.InActiveUser> _filteredEmployees = [];
  List<models.InActiveUser> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();
  final TextEditingController dojFromController = TextEditingController();
  final TextEditingController fojToController = TextEditingController();

  // ═══════════════════════════════════════════════════════════════════════
  // PAGINATION (SERVER-SIDE)
  // ═══════════════════════════════════════════════════════════════════════

  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int? _totalRecords; // Total records from server
  int? _totalPagesFromServer; // Total pages from server

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  int get totalPages {
    // Use server pagination info if available, otherwise fallback to client-side
    if (_totalPagesFromServer != null) {
      return _totalPagesFromServer!;
    }
    if (_filteredEmployees.isEmpty) return 0;
    return (_filteredEmployees.length / _itemsPerPage).ceil();
  }

  // ✅ SERVER-SIDE PAGINATION: Return current page data directly (already paginated from server)
  List<models.InActiveUser> get paginatedEmployees {
    // Server already returns paginated data, so return filteredEmployees directly
    return _filteredEmployees;
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      // ✅ Fetch next page from server
      _fetchCurrentPage();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      // ✅ Fetch previous page from server
      _fetchCurrentPage();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      // ✅ Fetch requested page from server
      _fetchCurrentPage();
    }
  }

  // ✅ Helper method to fetch current page from server
  void _fetchCurrentPage() {
    fetchInActiveUsers(
      cmpid: _selectedCompanyId,
      zoneId: _selectedZoneId,
      locationsId:
          _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId:
          _selectedDesignationIds.isNotEmpty
              ? _selectedDesignationIds.join(',')
              : null,
      ctcRange: _selectedCTCId,
      fromdate:
          dojFromController.text.isNotEmpty ? dojFromController.text : null,
      todate: fojToController.text.isNotEmpty ? fojToController.text : null,
      page: _currentPage,
      perPage: _itemsPerPage,
      search: searchController.text.isNotEmpty ? searchController.text : null,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════

  void initializeEmployees() {
    if (_initialLoadDone) return;

    _isLoading = true;
    _initialLoadDone = false;
    notifyListeners();

    if (kDebugMode) print("🚀 InActiveProvider: Initializing...");
    loadAllFilters();
  }

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
      _currentPage = 1;

      if (kDebugMode) {
        print("🔄 InActiveProvider: Loading filters...");
      }

      final filtersData = await _filterService.getAllFilters();

      if (filtersData == null || filtersData.data == null) {
        throw Exception('Invalid filter response from server');
      }

      // ✅ Process filters
      _processFilterData(filtersData);

      if (kDebugMode) {
        print("✅ InActiveProvider: Filters loaded successfully");
        print("📊 Companies: ${_companyList.length}");
        print("📊 Zones: ${_zoneList.length}");
        print("📊 Branches: ${_branchList.length}");
        print("📊 Designations: ${_designationList.length}");
        print("📊 CTC Ranges: ${_ctcList.length}");
      }

      // ✅ CRITICAL: Fetch default data WITHOUT selecting filters in UI
      // Filters remain unselected, but we fetch default data (all data)
      if (kDebugMode) {
        print("📊 Fetching default data without filters...");
      }
      await fetchInActiveUsers(page: 1, perPage: 10);
      _hasAppliedFilters = false; // Keep filters unselected

      // ✅ MARK INITIAL LOAD COMPLETE ONLY NOW
      _initialLoadDone = true;

      notifyListeners();

      _initialLoadDone = true;
    } catch (e) {
      // 🚨 Handle auth issues - navigate to login on token expiration
      if (e.toString().contains("401") ||
          e.toString().contains("UNAUTHORIZED") ||
          e.toString().contains("TOKEN_EXPIRED")) {
        _isTokenExpired = true;
        _errorMessage = "Your session has expired. Please login again.";

        if (kDebugMode) {
          print("⛔ Token expired – clearing session and navigating to login");
        }

        await _clearAuthSession();
        HelperUtil.navigateToLoginOnTokenExpiry();
      } else {
        _errorMessage = "Error loading filters: $e";
      }

      if (kDebugMode) {
        print("❌ InActiveProvider: $_errorMessage");
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
  // FETCH INACTIVE USERS
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> fetchInActiveUsers({
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

      if (kDebugMode) print("🔄 InActiveProvider: Fetching inactive users...");

      final response = await _inActiveUserService.getInActiveUsers(
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
        page: page ?? _currentPage, // ✅ Pass page parameter
        perPage:
            perPage ?? _itemsPerPage, // ✅ Pass perPage parameter (default 10)
        search: search ?? searchController.text,
      );

      if (response != null) {
        // Check if response has data (some APIs might return success without status field)
        if (response.status == 'success' || response.data != null) {
          _inActiveUserListResponse = response;

          // ✅ SERVER-SIDE PAGINATION: Store only current page data
          _allEmployees = response.data?.users ?? [];
          // ✅ If search is active, filter results; otherwise show all
          if (search != null && search.isNotEmpty) {
            final searchLower = search.toLowerCase();
            _filteredEmployees = _allEmployees.where((employee) {
              final name = (employee.fullname ?? employee.username ?? '').toLowerCase();
              final empId = (employee.employmentId ?? employee.userId ?? '').toLowerCase();
              return name.contains(searchLower) || empId.contains(searchLower);
            }).toList();
          } else {
            _filteredEmployees = List.from(_allEmployees);
          }

          if (kDebugMode) {
            print("✅ InActiveProvider: Response received");
            print("   Status: ${response.status}");
            print("   Users count: ${_allEmployees.length}");
            print("   Data: ${response.data != null}");
          }

          // ✅ Update pagination info from server response
          if (response.data?.pagination != null) {
            final pagination = response.data!.pagination!;
            _totalRecords = pagination.total;
            _totalPagesFromServer =
                pagination.lastPage ??
                (pagination.total != null
                    ? ((pagination.total! / _itemsPerPage).ceil())
                    : null);
            _currentPage = pagination.currentPage ?? _currentPage;
          } else if (_allEmployees.isNotEmpty) {
            // If no pagination but we have data, set defaults
            _totalRecords = _allEmployees.length;
            _totalPagesFromServer = 1;
          }

          _hasAppliedFilters = false;

          if (kDebugMode) {
            print(
              "✅ InActiveProvider: Loaded ${_allEmployees.length} employees (Page $_currentPage of $totalPages)",
            );
            print(
              "📊 Total Records: $_totalRecords, Total Pages: $_totalPagesFromServer",
            );
          }
        } else {
          _errorMessage = response?.message ?? "Failed to load employees";
          if (kDebugMode) {
            print("❌ InActiveProvider: Response status not success");
            print("   Status: ${response.status}");
            print("   Message: ${response.message}");
          }
        }
      } else {
        _errorMessage = "No response from server";
        if (kDebugMode) print("❌ InActiveProvider: Response is null");
      }
    } catch (e) {
      if (e.toString().contains("401") ||
          e.toString().contains("UNAUTHORIZED")) {
        _isTokenExpired = true;
        _errorMessage = "Your session has expired. Please login again.";
        if (kDebugMode) {
          print("⛔ Token expired – clearing session and navigating to login");
        }
        await _clearAuthSession();
        HelperUtil.navigateToLoginOnTokenExpiry();
      } else {
        _errorMessage = "Error loading employees: $e";
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FILTER SETTERS
  // ═══════════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════════════
  // APPLY DEFAULT FILTERS (Select first company, first zone, first branch, first designation)
  // ═══════════════════════════════════════════════════════════════════════

  void _applyDefaultFilters() {
    if (kDebugMode) print("🎯 InActiveProvider: Applying default filters...");

    // ✅ Select first company (if available)
    if (_companyList.isNotEmpty) {
      _selectedCompany = _companyList.first['name'];
      _selectedCompanyId = _companyList.first['id'];
      if (kDebugMode) print("✅ Selected first Company: $_selectedCompany");
    }

    // ✅ Select first zone
    if (_zoneList.isNotEmpty) {
      _selectedZoneId = _zoneList.first['id'];
      _selectedZoneName = _zoneList.first['name'];
      if (kDebugMode) print("✅ Selected first Zone: $_selectedZoneName");
    }

    // ✅ Select first branch (filtered by selected zone)
    if (_selectedZoneId != null) {
      final zoneBranches = _branchList
          .where((b) => b['zone_id'] == _selectedZoneId)
          .toList();
      if (zoneBranches.isNotEmpty) {
        _selectedBranchIds = [zoneBranches.first['id']!];
        _selectedBranchNames = [zoneBranches.first['name']!];
        if (kDebugMode) print("✅ Selected first Branch: ${_selectedBranchNames.first}");
      }
    }

    // ✅ Select first designation
    if (_designationList.isNotEmpty) {
      _selectedDesignationIds = [_designationList.first['id']!];
      _selectedDesignationNames = [_designationList.first['name']!];
      if (kDebugMode) print("✅ Selected first Designation: ${_selectedDesignationNames.first}");
    }

    if (kDebugMode) print("🎯 Default filters applied successfully!");
  }

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

  void setSelectedZone(String? displayName) {
    _selectedZoneName = displayName;
    if (displayName != null) {
      final list = _zoneList.where((e) => e['name'] == displayName).toList();
      _selectedZoneId = list.isNotEmpty ? list.first['id'] : null;
    } else {
      _selectedZoneId = null;
    }
    // Clear branch selection when zone changes
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

    // ✅ Request first page (10 records) from server
    fetchInActiveUsers(
      cmpid: _selectedCompanyId,
      zoneId: _selectedZoneId,
      locationsId:
          _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId:
          _selectedDesignationIds.isNotEmpty
              ? _selectedDesignationIds.join(',')
              : null,
      ctcRange: _selectedCTCId,
      fromdate:
          dojFromController.text.isNotEmpty ? dojFromController.text : null,
      todate: fojToController.text.isNotEmpty ? fojToController.text : null,
      page: 1,
      perPage: _itemsPerPage,
      search: searchController.text.isNotEmpty ? searchController.text : null,
    );
  }

  Timer? _searchDebounce;

  /// Real-time search: filter cards as user types (like Active screen)
  void onSearchChanged(String query) {
    if (!_initialLoadDone) return;
    _searchDebounce?.cancel();
    
    final trimmedQuery = query.trim();
    
    // If search is cleared, show all employees
    if (trimmedQuery.isEmpty) {
      _filteredEmployees = List.from(_allEmployees);
      _currentPage = 1;
      notifyListeners();
      return;
    }
    
    // Client-side filtering for instant results as user types
    final searchLower = trimmedQuery.toLowerCase();
    _filteredEmployees = _allEmployees.where((employee) {
      final name = (employee.fullname ?? employee.username ?? '').toLowerCase();
      final empId = (employee.employmentId ?? employee.userId ?? '').toLowerCase();
      return name.contains(searchLower) || empId.contains(searchLower);
    }).toList();
    
    _currentPage = 1;
    notifyListeners();
    
    // Also do server-side search with debounce for fresh data
    _searchDebounce = Timer(const Duration(milliseconds: 800), () {
      _currentPage = 1;
      fetchInActiveUsers(
        cmpid: _selectedCompanyId,
        zoneId: _selectedZoneId,
        locationsId:
            _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
        designationsId:
            _selectedDesignationIds.isNotEmpty
                ? _selectedDesignationIds.join(',')
                : null,
        ctcRange: _selectedCTCId,
        fromdate:
            dojFromController.text.isNotEmpty ? dojFromController.text : null,
        todate: fojToController.text.isNotEmpty ? fojToController.text : null,
        page: 1,
        perPage: _itemsPerPage,
        search: trimmedQuery.isNotEmpty ? trimmedQuery : null,
      );
    });
  }

  /// Perform immediate search (called on Enter key)
  void performSearchWithQuery(String query) {
    if (!_initialLoadDone) return;
    _searchDebounce?.cancel();
    final trimmedQuery = query.trim();
    
    if (trimmedQuery.isEmpty) {
      _filteredEmployees = List.from(_allEmployees);
      _currentPage = 1;
      notifyListeners();
      return;
    }
    
    // Client-side filter first for instant results
    final searchLower = trimmedQuery.toLowerCase();
    _filteredEmployees = _allEmployees.where((employee) {
      final name = (employee.fullname ?? employee.username ?? '').toLowerCase();
      final empId = (employee.employmentId ?? employee.userId ?? '').toLowerCase();
      return name.contains(searchLower) || empId.contains(searchLower);
    }).toList();
    
    _currentPage = 1;
    notifyListeners();
    
    // Then fetch fresh data from server
    fetchInActiveUsers(
      cmpid: _selectedCompanyId,
      zoneId: _selectedZoneId,
      locationsId:
          _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId:
          _selectedDesignationIds.isNotEmpty
              ? _selectedDesignationIds.join(',')
              : null,
      ctcRange: _selectedCTCId,
      fromdate:
          dojFromController.text.isNotEmpty ? dojFromController.text : null,
      todate: fojToController.text.isNotEmpty ? fojToController.text : null,
      page: 1,
      perPage: _itemsPerPage,
      search: trimmedQuery.isNotEmpty ? trimmedQuery : null,
    );
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    searchController.clear();
    _currentPage = 1;
    // Show all employees immediately
    _filteredEmployees = List.from(_allEmployees);
    notifyListeners();
    // Then fetch fresh data
    fetchInActiveUsers(
      cmpid: _selectedCompanyId,
      zoneId: _selectedZoneId,
      locationsId:
          _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId:
          _selectedDesignationIds.isNotEmpty
              ? _selectedDesignationIds.join(',')
              : null,
      ctcRange: _selectedCTCId,
      fromdate:
          dojFromController.text.isNotEmpty ? dojFromController.text : null,
      todate: fojToController.text.isNotEmpty ? fojToController.text : null,
      page: 1,
      perPage: _itemsPerPage,
    );
  }

  void clearAllFilters() {
    _selectedCompany = null;
    _selectedCompanyId = null;
    _selectedZoneId = null;
    _selectedZoneName = null;
    _selectedBranchIds.clear();
    _selectedBranchNames.clear();
    _selectedDesignationIds.clear();
    _selectedDesignationNames.clear();
    _selectedCTC = null;
    _selectedCTCId = null;
    dojFromController.clear();
    fojToController.clear();
    searchController.clear();
    _errorMessage = null;
    _currentPage = 1;
    _totalRecords = null;
    _totalPagesFromServer = null;
    notifyListeners();
    // ✅ Fetch first page (10 records) from server without filters
    fetchInActiveUsers(page: 1, perPage: _itemsPerPage);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // UI HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  Future<bool> activateEmployee(String employeeId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (kDebugMode) {
        print("🔄 InActiveProvider: Activating employee $employeeId...");
      }

      // TODO: Call your activate employee API here
      // Example:
      // final response = await _inActiveUserService.activateEmployee(employeeId);
      // if (response != null && response.status == 'success') {
      //   // Remove from list
      //   _allEmployees.removeWhere(
      //     (emp) => (emp.employmentId ?? emp.userId ?? '') == employeeId,
      //   );
      //   _filteredEmployees.removeWhere(
      //     (emp) => (emp.employmentId ?? emp.userId ?? '') == employeeId,
      //   );
      //   _isLoading = false;
      //   notifyListeners();
      //   return true;
      // }

      // For now, remove from list (temporary until API is ready)
      _allEmployees.removeWhere(
        (emp) => (emp.employmentId ?? emp.userId ?? '') == employeeId,
      );
      _filteredEmployees.removeWhere(
        (emp) => (emp.employmentId ?? emp.userId ?? '') == employeeId,
      );

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print(
          "✅ InActiveProvider: Employee $employeeId activated successfully",
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("❌ InActiveProvider: Error activating employee: $e");
      }
      _isLoading = false;
      notifyListeners();
      return false;
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
