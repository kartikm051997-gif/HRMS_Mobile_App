import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../model/Employee_management/ManagementApprovalListModel.dart'
    as models;
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/ActiveUserFilterService.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/ManagementApprovalService.dart';

class ManagementApprovalProvider extends ChangeNotifier {
  final ManagementApprovalService _approvalService =
      ManagementApprovalService();
  final FilterService _filterService = FilterService();

  // State variables
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

  models.ManagementApprovalListModel? _approvalListResponse;
  models.ManagementApprovalListModel? get approvalListResponse =>
      _approvalListResponse;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filter data
  List<Map<String, String>> _companyList = [];
  List<Map<String, String>> _zoneList = [];
  List<Map<String, String>> _branchList = [];
  List<Map<String, String>> _designationList = [];

  List<String> get company => _companyList.map((e) => e['name']!).toList();
  List<String> get zone => _zoneList.map((e) => e['name']!).toList();

  List<String> get branch {
    if (_selectedZoneIds.isEmpty) {
      return _branchList.map((e) => e['name']!).toList();
    }
    return _branchList
        .where((b) => _selectedZoneIds.contains(b['zone_id']))
        .map((e) => e['name']!)
        .toList(); // ✅ Add this
  }

  List<String> get designation =>
      _designationList.map((e) => e['name']!).toList();

  // Selected values
  String? _selectedCompany;
  String? _selectedCompanyId;
  List<String> _selectedZoneIds = [];
  List<String> _selectedZoneNames = [];
  List<String> _selectedBranchIds = [];
  List<String> _selectedBranchNames = [];
  List<String> _selectedDesignationIds = [];
  List<String> _selectedDesignationNames = [];

  String? get selectedCompany => _selectedCompany;
  List<String> get selectedZones => _selectedZoneNames;
  List<String> get selectedBranches => _selectedBranchNames;
  List<String> get selectedDesignations => _selectedDesignationNames;

  bool get areAllFiltersSelected {
    return _selectedZoneIds.isNotEmpty &&
        _selectedBranchIds.isNotEmpty &&
        _selectedDesignationIds.isNotEmpty;
  }

  // Employee data
  List<models.ManagementApprovalUser> _allEmployees = [];
  List<models.ManagementApprovalUser> _filteredEmployees = [];
  List<models.ManagementApprovalUser> get filteredEmployees =>
      _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  Timer? _searchDebounce;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int? _totalRecords;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;

  int get totalPages {
    if (_totalRecords == null || _totalRecords == 0) return 0;
    return ((_totalRecords! / _itemsPerPage).ceil());
  }

  List<models.ManagementApprovalUser> get paginatedEmployees =>
      _filteredEmployees;
  int? get totalRecords => _totalRecords;

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

  void _fetchCurrentPage() {
    print("🔄 _fetchCurrentPage called - Page: $_currentPage");
    fetchPendingApprovalList(
      zoneId: _selectedZoneIds.isNotEmpty ? _selectedZoneIds.join(',') : null,
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
  // INITIALIZATION - THIS IS THE KEY PART!
  // ═══════════════════════════════════════════════════════════════════════

  void initializeEmployees() {
    print("🚀 ═══════════════════════════════════════════════════════");
    print("🚀 ManagementApprovalProvider: initializeEmployees() START");
    print("🚀 ═══════════════════════════════════════════════════════");

    if (_initialLoadDone) {
      print("⚠️ Already initialized, skipping...");
      return;
    }

    _isLoadingFilters = true;
    _initialLoadDone = false;
    notifyListeners();

    print("✅ Set _isLoadingFilters = true");
    print("✅ Set _initialLoadDone = false");
    print("📡 Calling loadAllFilters()...");

    loadAllFilters();
  }

  Future<void> loadAllFilters() async {
    print("\n📡 ═══════════════════════════════════════════════════════");
    print("📡 loadAllFilters() START");
    print("📡 ═══════════════════════════════════════════════════════");

    _isLoadingFilters = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print("📡 Fetching filters from API...");
      final response = await _filterService.getAllFilters();
      print("📡 API Response received: ${response?.status}");

      if (response != null &&
          response.status == "success" &&
          response.data != null) {
        print("✅ Filters API Success!");

        _processFilterData(response);
        print("✅ Filter data processed");
        print("   - Zones: ${_zoneList.length}");
        print("   - Branches: ${_branchList.length}");
        print("   - Designations: ${_designationList.length}");

        // ✅ CRITICAL: Apply default filters
        print("\n🎯 Applying default filters...");
        _applyDefaultFilters();

        _isLoadingFilters = false;
        notifyListeners();
        print("✅ Set _isLoadingFilters = false");

        // ✅ CRITICAL: Fetch default data
        print("\n📊 ═══════════════════════════════════════════════════════");
        print("📊 FETCHING DEFAULT 10 RECORDS");
        print("📊 ═══════════════════════════════════════════════════════");
        print("📊 Zone IDs: ${_selectedZoneIds.join(', ')}");
        print("📊 Branch IDs: ${_selectedBranchIds.join(', ')}");
        print("📊 Designation IDs: ${_selectedDesignationIds.join(', ')}");

        await fetchPendingApprovalList(
          zoneId:
              _selectedZoneIds.isNotEmpty ? _selectedZoneIds.join(',') : null,
          locationsId:
              _selectedBranchIds.isNotEmpty
                  ? _selectedBranchIds.join(',')
                  : null,
          designationsId:
              _selectedDesignationIds.isNotEmpty
                  ? _selectedDesignationIds.join(',')
                  : null,
          page: 1,
          perPage: 10,
        );

        // ✅ CRITICAL: Mark as done AFTER data fetch
        _initialLoadDone = true;
        notifyListeners();

        print("\n🎉 ═══════════════════════════════════════════════════════");
        print("🎉 INITIALIZATION COMPLETE!");
        print("🎉 Records loaded: ${_filteredEmployees.length}");
        print("🎉 Total records: $_totalRecords");
        print("🎉 _initialLoadDone = true");
        print("🎉 ═══════════════════════════════════════════════════════\n");
      } else {
        print("❌ Filter API failed: ${response?.message}");
        _errorMessage = response?.message ?? "Failed to load filters";
        _isLoadingFilters = false;
        _initialLoadDone = true;
        notifyListeners();
      }
    } catch (e) {
      print("❌ ═══════════════════════════════════════════════════════");
      print("❌ ERROR in loadAllFilters: $e");
      print("❌ ═══════════════════════════════════════════════════════");

      if (e.toString().contains("401") ||
          e.toString().contains("UNAUTHORIZED")) {
        _isTokenExpired = true;
        _errorMessage = "Your session has expired. Please login again.";
      } else {
        _errorMessage = "Error loading filters: ${e.toString()}";
      }

      _isLoadingFilters = false;
      _initialLoadDone = true;
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
            ?.map(
              (z) => {
                'id': z.id ?? '',
                'name': z.name ?? '',
                'zone_id': z.id ?? '',
              },
            )
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
  }

  void _applyDefaultFilters() {
    print("\n🎯 _applyDefaultFilters() START");

    // ✅ NEW APPROACH: Select ALL zones, ALL branches, ALL designations
    // This way we fetch ALL pending approvals, not filtered ones

    if (_zoneList.isEmpty) {
      print("❌ No zones available! Cannot apply defaults.");
      return;
    }

    // ✅ Select ALL zones
    _selectedZoneIds = _zoneList.map((z) => z['id']!).toList();
    _selectedZoneNames = _zoneList.map((z) => z['name']!).toList();
    print(
      "✅ Selected ALL Zones (${_selectedZoneIds.length}): ${_selectedZoneNames.join(', ')}",
    );

    // ✅ Select ALL branches
    _selectedBranchIds = _branchList.map((b) => b['id']!).toList();
    _selectedBranchNames = _branchList.map((b) => b['name']!).toList();
    print(
      "✅ Selected ALL Branches (${_selectedBranchIds.length}): ${_selectedBranchNames.join(', ')}",
    );

    // ✅ Select ALL designations
    _selectedDesignationIds = _designationList.map((d) => d['id']!).toList();
    _selectedDesignationNames =
        _designationList.map((d) => d['name']!).toList();
    print(
      "✅ Selected ALL Designations (${_selectedDesignationIds.length}): ${_selectedDesignationNames.join(', ')}",
    );

    print("🎯 Default filters applied successfully!");
    print("🎯 This will fetch ALL pending approvals (no filtering)");
    print("🎯 areAllFiltersSelected: $areAllFiltersSelected");
  }

  Future<void> fetchPendingApprovalList({
    String? zoneId,
    String? locationsId,
    String? designationsId,
    int? page,
    int? perPage,
    String? search,
  }) async {
    print("\n📊 ═══════════════════════════════════════════════════════");
    print("📊 fetchPendingApprovalList() START");
    print("📊 ═══════════════════════════════════════════════════════");
    print("📊 Parameters:");
    print("   - zoneId: $zoneId");
    print("   - locationsId: $locationsId");
    print("   - designationsId: $designationsId");
    print("   - page: ${page ?? _currentPage}");
    print("   - perPage: ${perPage ?? _itemsPerPage}");
    print("   - search: $search");

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    print("✅ Set _isLoading = true");

    try {
      print("📡 Calling API...");
      final response = await _approvalService.getPendingApprovalList(
        zoneId: zoneId,
        locationsId: locationsId,
        designationsId: designationsId,
        page: page ?? _currentPage,
        perPage: perPage ?? _itemsPerPage,
        search: search,
      );

      print("📡 API Response received");
      print("   - Status: ${response?.status}");
      print("   - Data count: ${response?.data?.length}");
      print("   - Total: ${response?.total}");

      if (response != null && response.status == "success") {
        _approvalListResponse = response;
        _allEmployees = response.data ?? [];
        _filteredEmployees = List.from(_allEmployees);
        _totalRecords = response.total ?? 0;
        _currentPage = page ?? _currentPage;
        _hasAppliedFilters = true;
        _isLoading = false;
        notifyListeners();

        print("✅ Data loaded successfully!");
        print("   - Employees: ${_filteredEmployees.length}");
        print("   - Total records: $_totalRecords");
        print("   - Current page: $_currentPage");
        print("   - Total pages: $totalPages");
      } else {
        print("❌ API returned error: ${response?.status}");
        _errorMessage = response?.status ?? "Failed to fetch approval list";
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print("❌ Exception in fetchPendingApprovalList: $e");
      _errorMessage = "Error: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
    }

    print("📊 fetchPendingApprovalList() END");
    print("📊 ═══════════════════════════════════════════════════════\n");
  }

  // Filter methods
  void toggleFilters() {
    _showFilters = !_showFilters;

    // ✅ When user opens filters manually, clear selections so they can choose fresh
    if (_showFilters && _hasAppliedFilters) {
      print("🔄 User opened filters - clearing selections for fresh choice");
      _selectedZoneIds = [];
      _selectedZoneNames = [];
      _selectedBranchIds = [];
      _selectedBranchNames = [];
      _selectedDesignationIds = [];
      _selectedDesignationNames = [];
    }

    notifyListeners();
  }

  void setSelectedCompany(String? name) {
    _selectedCompany = name;
    _selectedCompanyId =
        _companyList.firstWhere(
          (c) => c['name'] == name,
          orElse: () => {},
        )['id'];
    notifyListeners();
  }

  void setSelectedZones(List<String> names) {
    _selectedZoneNames = names;
    _selectedZoneIds =
        _zoneList
            .where((z) => names.contains(z['name']))
            .map((z) => z['id']!)
            .toList();
    _selectedBranchNames.clear();
    _selectedBranchIds.clear();
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

  void searchEmployees() {
    if (!areAllFiltersSelected) return;
    _currentPage = 1;
    _fetchCurrentPage();
  }

  /// Server-side search: fetch page 1 with search query (same as Active screen).
  /// Shows matching cards for name or ID; debounced so one request with full term.
  void onSearchChanged(String query) {
    if (!_initialLoadDone) return;
    _searchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _currentPage = 1;
      _fetchCurrentPageWithSearch('');
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _currentPage = 1;
      _fetchCurrentPageWithSearch(trimmed);
    });
  }

  void _fetchCurrentPageWithSearch(String searchQuery) {
    fetchPendingApprovalList(
      zoneId: _selectedZoneIds.isNotEmpty ? _selectedZoneIds.join(',') : null,
      locationsId:
          _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId:
          _selectedDesignationIds.isNotEmpty
              ? _selectedDesignationIds.join(',')
              : null,
      page: 1,
      perPage: _itemsPerPage,
      search: searchQuery.isNotEmpty ? searchQuery : null,
    );
  }

  /// Run search immediately with given query (e.g. on Submit/Enter) — same as Active screen.
  void performSearchWithQuery(String query) {
    if (!_initialLoadDone) return;
    _searchDebounce?.cancel();
    _currentPage = 1;
    _fetchCurrentPageWithSearch(query.trim());
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    searchController.clear();
    _currentPage = 1;
    _fetchCurrentPageWithSearch('');
    notifyListeners();
  }

  void performSearch() {
    print("🔍 performSearch() called");
    print("🔍 Search term: '${searchController.text}'");

    if (_hasAppliedFilters) {
      _currentPage = 1; // ✅ Always reset to page 1 for new search
      print("🔍 Reset to page 1, fetching with search term...");
      _fetchCurrentPage();
    }
  }

  /// Clear all filter selections (dropdowns empty) and fetch first page with no filters — same as Active screen.
  void clearAllFilters() {
    print("\n🧹 clearAllFilters() called");

    _selectedCompany = null;
    _selectedCompanyId = null;
    _selectedZoneIds = [];
    _selectedZoneNames = [];
    _selectedBranchIds = [];
    _selectedBranchNames = [];
    _selectedDesignationIds = [];
    _selectedDesignationNames = [];
    searchController.clear();

    _currentPage = 1;
    _hasAppliedFilters = false;
    notifyListeners();

    print(
      "✅ Filters cleared (dropdowns empty), fetching first page with no filters...",
    );
    fetchPendingApprovalList(
      zoneId: null,
      locationsId: null,
      designationsId: null,
      page: 1,
      perPage: _itemsPerPage,
    );
  }

  void refreshCurrentPage() {
    print("🔄 refreshCurrentPage() called");
    _fetchCurrentPage();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
