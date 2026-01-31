import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/Employee_management/AbscondUserListModelClass.dart';
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/ActiveUserFilterService.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/AbscondUserService.dart';

class AbscondProvider extends ChangeNotifier {
  final AbscondUserService _abscondUserService = AbscondUserService();
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

  bool _isTokenExpired = false;
  bool get isTokenExpired => _isTokenExpired;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ═══════════════════════════════════════════════════════════════════════
  // FILTER DATA STRUCTURES (same as InActive pattern)
  // ═══════════════════════════════════════════════════════════════════════

  List<Map<String, String>> _zoneList = [];
  List<Map<String, String>> _branchList = [];
  List<Map<String, String>> _designationList = [];

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

  // ═══════════════════════════════════════════════════════════════════════
  // SELECTED FILTER VALUES
  // ═══════════════════════════════════════════════════════════════════════

  String? _selectedZoneId;
  String? _selectedZoneName;
  List<String> _selectedBranchIds = [];
  List<String> _selectedBranchNames = [];
  List<String> _selectedDesignationIds = [];
  List<String> _selectedDesignationNames = [];

  String? get selectedZone => _selectedZoneName;
  List<String> get selectedBranches => _selectedBranchNames;
  List<String> get selectedDesignations => _selectedDesignationNames;

  bool get areAllFiltersSelected {
    return _selectedZoneId != null &&
        _selectedBranchIds.isNotEmpty &&
        _selectedDesignationIds.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // EMPLOYEE DATA & PAGINATION
  // ═══════════════════════════════════════════════════════════════════════

  List<AbscondUser> _allEmployees = [];
  List<AbscondUser> _filteredEmployees = [];
  List<AbscondUser> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  int _currentPage = 1;
  int _itemsPerPage = 10; // Default page size
  int? _totalRecords;
  int? _totalPagesFromServer;

  int get currentPage => _currentPage;
  int get pageSize => _itemsPerPage;

  int get totalPages {
    if (_totalPagesFromServer != null) return _totalPagesFromServer!;
    if (_filteredEmployees.isEmpty) return 0;
    return (_filteredEmployees.length / _itemsPerPage).ceil();
  }

  // ✅ SERVER-SIDE PAGINATION: Return current page data directly
  List<AbscondUser> get paginatedEmployees => _filteredEmployees;

  // ═══════════════════════════════════════════════════════════════════════
  // PAGINATION METHODS
  // ═══════════════════════════════════════════════════════════════════════

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      _fetchCurrentPage();
    }
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      _fetchCurrentPage();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      _fetchCurrentPage();
    }
  }

  void setPageSize(int newSize) {
    _itemsPerPage = newSize;
    _currentPage = 1;
    _fetchCurrentPage();
  }

  // ✅ Helper method to fetch current page from server
  void _fetchCurrentPage() {
    fetchAbscondUsers(
      zoneId: _selectedZoneId,
      locationsId:
          _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId:
          _selectedDesignationIds.isNotEmpty
              ? _selectedDesignationIds.join(',')
              : null,
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

    if (kDebugMode) print("🚀 AbscondProvider: Initializing...");
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
  // PROCESS FILTER DATA
  // ═══════════════════════════════════════════════════════════════════════

  void _processFilterData(GetAllFilters filters) {
    final data = filters.data!;

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
              });
            }
          }
        }
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LOAD FILTERS & DEFAULT DATA
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> loadAllFilters() async {
    try {
      _isLoadingFilters = true;
      _isLoading = true;
      _errorMessage = null;
      _isTokenExpired = false;
      notifyListeners();
      _currentPage = 1;

      if (kDebugMode) print("🔄 AbscondProvider: Loading filters...");

      final filtersData = await _filterService.getAllFilters();
      if (filtersData == null || filtersData.data == null) {
        throw Exception('Invalid filter response from server');
      }

      // ✅ Process filters
      _processFilterData(filtersData);

      if (kDebugMode) {
        print("✅ AbscondProvider: Filters loaded successfully");
        print("📊 Zones: ${_zoneList.length}");
        print("📊 Branches: ${_branchList.length}");
        print("📊 Designations: ${_designationList.length}");
      }

      // ✅ LOAD DEFAULT DATA with auto-selected filters
      if (_selectedZoneId != null &&
          _selectedBranchIds.isNotEmpty &&
          _selectedDesignationIds.isNotEmpty) {
        await fetchAbscondUsers(
          zoneId: _selectedZoneId,
          locationsId: _selectedBranchIds.join(','),
          designationsId: _selectedDesignationIds.join(','),
          page: 1,
          perPage: 10,
        );
        _hasAppliedFilters = true;
      }

      _initialLoadDone = true;
      notifyListeners();
    } catch (e) {
      if (e.toString().contains("401") ||
          e.toString().contains("UNAUTHORIZED") ||
          e.toString().contains("TOKEN_EXPIRED")) {
        _isTokenExpired = true;
        _errorMessage = "Your session has expired. Please login again.";
        if (kDebugMode) print("⛔ Token expired – clearing session");
        await _clearAuthSession();
      } else {
        _errorMessage = "Error loading filters: $e";
      }
      if (kDebugMode) print("❌ AbscondProvider: $_errorMessage");
      _initialLoadDone = true;
    } finally {
      _isLoadingFilters = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FETCH ABSCOND USERS FROM SERVER
  // ═══════════════════════════════════════════════════════════════════════

  Future<void> fetchAbscondUsers({
    String? zoneId,
    String? locationsId,
    String? designationsId,
    int? page,
    int? perPage,
    String? search,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _isTokenExpired = false;
      notifyListeners();

      if (kDebugMode) print("🔄 AbscondProvider: Fetching abscond users...");

      final response = await _abscondUserService.getAbscondUsers(
        zoneId: zoneId ?? _selectedZoneId,
        locationsId:
            locationsId ??
            (_selectedBranchIds.isNotEmpty
                ? _selectedBranchIds.join(',')
                : null),
        designationsId:
            designationsId ??
            (_selectedDesignationIds.isNotEmpty
                ? _selectedDesignationIds.join(',')
                : null),
        page: page ?? _currentPage,
        perPage: perPage ?? _itemsPerPage,
        search: search ?? searchController.text,
      );

      if (response != null && response.status == 'success') {
        // ✅ SERVER-SIDE PAGINATION: Store only current page data
        _allEmployees = response.data?.users ?? [];
        _filteredEmployees = List.from(_allEmployees);

        // ✅ Update pagination info from server response
        if (response.data?.pagination != null) {
          final p = response.data!.pagination!;
          _totalRecords = p.total;
          _totalPagesFromServer =
              p.lastPage ??
              (p.total != null ? (p.total! / _itemsPerPage).ceil() : null);
          _currentPage = p.currentPage ?? _currentPage;
        }

        if (kDebugMode) {
          print(
            "✅ AbscondProvider: Loaded ${_allEmployees.length} employees (Page $_currentPage of $totalPages)",
          );
          print(
            "📊 Total Records: $_totalRecords, Total Pages: $_totalPagesFromServer",
          );
        }
      } else {
        _errorMessage =
            response?.message ?? "Failed to load absconded employees";
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
      if (kDebugMode) print("❌ AbscondProvider: $_errorMessage");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FILTER SETTERS
  // ═══════════════════════════════════════════════════════════════════════

  void setSelectedZone(String? displayName) {
    _selectedZoneName = displayName;
    if (displayName != null) {
      final list = _zoneList.where((e) => e['name'] == displayName).toList();
      _selectedZoneId = list.isNotEmpty ? list.first['id'] : null;
    } else {
      _selectedZoneId = null;
    }
    // Clear branch selection when zone changes
    _selectedBranchIds.clear();
    _selectedBranchNames.clear();
    notifyListeners();
  }

  void setSelectedBranches(List<String> names) {
    _selectedBranchNames = names;
    _selectedBranchIds =
        _branchList
            .where((b) => names.contains(b['name']))
            .map((b) => b['id']!)
            .toList();
    notifyListeners();
  }

  void setSelectedDesignations(List<String> names) {
    _selectedDesignationNames = names;
    _selectedDesignationIds =
        _designationList
            .where((d) => names.contains(d['name']))
            .map((d) => d['id']!)
            .toList();
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SEARCH & FILTER ACTIONS
  // ═══════════════════════════════════════════════════════════════════════

  void searchEmployees() {
    if (!areAllFiltersSelected) {
      if (kDebugMode) print("⚠️ Not all required filters selected");
      return;
    }

    _currentPage = 1; // ✅ Reset to first page
    _hasAppliedFilters = true;

    // ✅ Fetch first page with filters
    fetchAbscondUsers(
      zoneId: _selectedZoneId,
      locationsId:
          _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId:
          _selectedDesignationIds.isNotEmpty
              ? _selectedDesignationIds.join(',')
              : null,
      page: 1,
      perPage: _itemsPerPage,
      search: searchController.text.isNotEmpty ? searchController.text : null,
    );
  }

  void onSearchChanged(String query) {
    if (!_initialLoadDone) return;

    _currentPage = 1; // ✅ Reset to first page

    // ✅ SERVER-SIDE SEARCH: Fetch from server with search query
    fetchAbscondUsers(
      zoneId: _selectedZoneId,
      locationsId:
          _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId:
          _selectedDesignationIds.isNotEmpty
              ? _selectedDesignationIds.join(',')
              : null,
      page: 1,
      perPage: _itemsPerPage,
      search: query.isNotEmpty ? query : null,
    );
  }

  void clearSearch() {
    searchController.clear();
    _currentPage = 1;

    // ✅ Fetch first page without search
    fetchAbscondUsers(
      zoneId: _selectedZoneId,
      locationsId:
          _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId:
          _selectedDesignationIds.isNotEmpty
              ? _selectedDesignationIds.join(',')
              : null,
      page: 1,
      perPage: _itemsPerPage,
    );
  }

  void clearAllFilters() {
    _selectedZoneId = null;
    _selectedZoneName = null;
    _selectedBranchIds.clear();
    _selectedBranchNames.clear();
    _selectedDesignationIds.clear();
    _selectedDesignationNames.clear();
    searchController.clear();
    _errorMessage = null;
    _currentPage = 1;
    _totalRecords = null;
    _totalPagesFromServer = null;
    _hasAppliedFilters = false;
    notifyListeners();

    // ✅ Fetch first page (default 10 records) without filters
    fetchAbscondUsers(page: 1, perPage: _itemsPerPage);
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
        print("🔄 AbscondProvider: Activating employee $employeeId...");
      }

      // TODO: Call activate abscond employee API when backend is ready
      await Future.delayed(const Duration(milliseconds: 300));

      // Remove from current list
      _allEmployees.removeWhere(
        (emp) => (emp.employmentId ?? emp.userId ?? '') == employeeId,
      );
      _filteredEmployees.removeWhere(
        (emp) => (emp.employmentId ?? emp.userId ?? '') == employeeId,
      );

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print("✅ AbscondProvider: Employee $employeeId activated");
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print("❌ AbscondProvider: Error activating employee: $e");
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void refreshCurrentPage() {
    _fetchCurrentPage();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
