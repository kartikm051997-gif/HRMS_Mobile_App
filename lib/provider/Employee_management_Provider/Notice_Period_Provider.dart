import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/Employee_management/NoticePeriodUserListModel.dart';
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/ActiveUserFilterService.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/NoticePeriodUserService.dart';

class NoticePeriodProvider extends ChangeNotifier {
  final NoticePeriodUserService _noticePeriodUserService =
      NoticePeriodUserService();
  final FilterService _filterService = FilterService();

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

  List<Map<String, String>> _zoneList = [];
  List<Map<String, String>> _branchList = [];
  List<Map<String, String>> _designationList = [];

  List<String> get zone => _zoneList.map((e) => e['name']!).toList();
  List<String> get branch {
    if (_selectedZoneId == null)
      return _branchList.map((e) => e['name']!).toList();
    return _branchList
        .where((b) => b['zone_id'] == _selectedZoneId)
        .map((e) => e['name']!)
        .toList();
  }

  List<String> get designation =>
      _designationList.map((e) => e['name']!).toList();

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

  List<NoticePeriodUser> _allEmployees = [];
  List<NoticePeriodUser> _filteredEmployees = [];
  List<NoticePeriodUser> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int? _totalRecords;
  int? _totalPagesFromServer;

  int get currentPage => _currentPage;
  int get pageSize => _itemsPerPage;

  int get totalPages {
    if (_totalPagesFromServer != null) return _totalPagesFromServer!;
    if (_filteredEmployees.isEmpty) return 0;
    return (_filteredEmployees.length / _itemsPerPage).ceil();
  }

  List<NoticePeriodUser> get paginatedEmployees => _filteredEmployees;

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
    fetchNoticePeriodUsers(
      zoneId: _selectedZoneId,
      locationsId: _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId: _selectedDesignationIds.isNotEmpty ? _selectedDesignationIds.join(',') : null,
      page: _currentPage,
      perPage: _itemsPerPage,
      search: searchController.text.isNotEmpty ? searchController.text : null,
    );
  }

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  void setPageSize(int newSize) {
    _currentPage = 1;
    fetchNoticePeriodUsers(
      zoneId: _selectedZoneId,
      locationsId: _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId: _selectedDesignationIds.isNotEmpty ? _selectedDesignationIds.join(',') : null,
      page: 1,
      perPage: newSize,
      search: searchController.text.isNotEmpty ? searchController.text : null,
    );
    notifyListeners();
  }

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

  void initializeEmployees() {
    if (_initialLoadDone) return;
    _isLoading = true;
    _initialLoadDone = false;
    notifyListeners();
    if (kDebugMode) print("🚀 NoticePeriodProvider: Initializing...");
    loadAllFilters();
  }

  Future<void> loadAllFilters() async {
    try {
      _isLoadingFilters = true;
      _isLoading = true;
      _errorMessage = null;
      _isTokenExpired = false;
      notifyListeners();
      _currentPage = 1;

      final filtersData = await _filterService.getAllFilters();
      if (filtersData == null || filtersData.data == null) {
        throw Exception('Invalid filter response from server');
      }
      _processFilterData(filtersData);

      await fetchNoticePeriodUsers(page: 1, perPage: _itemsPerPage);
      _initialLoadDone = true;
      _hasAppliedFilters = true;
      notifyListeners();
    } catch (e) {
      if (e.toString().contains("401") ||
          e.toString().contains("UNAUTHORIZED") ||
          e.toString().contains("TOKEN_EXPIRED")) {
        _isTokenExpired = true;
        _errorMessage = "Your session has expired. Please login again.";
        await _clearAuthSession();
      } else {
        _errorMessage = "Error loading filters: $e";
      }
      _initialLoadDone = true;
    } finally {
      _isLoadingFilters = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNoticePeriodUsers({
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

      final response = await _noticePeriodUserService.getNoticePeriodUsers(
        zoneId: zoneId ?? _selectedZoneId,
        locationsId: locationsId ?? (_selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null),
        designationsId: designationsId ?? (_selectedDesignationIds.isNotEmpty ? _selectedDesignationIds.join(',') : null),
        page: page ?? _currentPage,
        perPage: perPage ?? _itemsPerPage,
        search: search ?? searchController.text,
      );

      if (response != null && response.status == 'success') {
        _allEmployees = response.data?.users ?? [];
        _filteredEmployees = List.from(_allEmployees);

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
            "✅ NoticePeriodProvider: Loaded ${_allEmployees.length} (Page $_currentPage of $totalPages)",
          );
        }
      } else {
        _errorMessage =
            response?.message ?? "Failed to load notice period employees";
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
    _selectedBranchIds = _branchList
        .where((b) => names.contains(b['name']))
        .map((b) => b['id']!)
        .toList();
    notifyListeners();
  }

  void setSelectedDesignations(List<String> names) {
    _selectedDesignationNames = names;
    _selectedDesignationIds = _designationList
        .where((d) => names.contains(d['name']))
        .map((d) => d['id']!)
        .toList();
    notifyListeners();
  }

  void searchEmployees() {
    if (!areAllFiltersSelected) return;
    _currentPage = 1;
    fetchNoticePeriodUsers(
      zoneId: _selectedZoneId,
      locationsId: _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId: _selectedDesignationIds.isNotEmpty ? _selectedDesignationIds.join(',') : null,
      page: 1,
      perPage: _itemsPerPage,
      search: searchController.text.isNotEmpty ? searchController.text : null,
    );
  }

  void onSearchChanged(String query) {
    if (!_initialLoadDone) return;
    _currentPage = 1;
    fetchNoticePeriodUsers(
      zoneId: _selectedZoneId,
      locationsId: _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId: _selectedDesignationIds.isNotEmpty ? _selectedDesignationIds.join(',') : null,
      page: 1,
      perPage: _itemsPerPage,
      search: query.isNotEmpty ? query : null,
    );
  }

  void clearSearch() {
    searchController.clear();
    _currentPage = 1;
    fetchNoticePeriodUsers(
      zoneId: _selectedZoneId,
      locationsId: _selectedBranchIds.isNotEmpty ? _selectedBranchIds.join(',') : null,
      designationsId: _selectedDesignationIds.isNotEmpty ? _selectedDesignationIds.join(',') : null,
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
    notifyListeners();
    fetchNoticePeriodUsers(page: 1, perPage: _itemsPerPage);
  }

  Future<bool> updateEmployeeStatus(
    String employeeId,
    String status,
    DateTime date,
  ) async {
    try {
      // TODO: Call API when backend is ready
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
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
