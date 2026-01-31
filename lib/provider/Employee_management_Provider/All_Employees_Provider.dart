import 'package:flutter/material.dart';
import '../../model/Employee_management/AllEmployeeListModelClass.dart';
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../model/Employee_management/Employee_management.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/ActiveUserFilterService.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/AllEmployeeService.dart';

class AllEmployeesProvider extends ChangeNotifier {
  final AllEmployeeService _allEmployeeService = AllEmployeeService();
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

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filter data
  List<Map<String, String>> _zoneList = [];
  List<Map<String, String>> _branchList = [];
  List<Map<String, String>> _designationList = [];

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

  // Selected values - Zone is single select, Branch and Designation are multiselect
  String? _selectedZone;
  String? _selectedZoneId;
  List<String> _selectedZoneIds = [];
  List<String> _selectedZoneNames = [];
  List<String> _selectedBranchIds = [];
  List<String> _selectedBranchNames = [];
  List<String> _selectedDesignationIds = [];
  List<String> _selectedDesignationNames = [];

  String? get selectedZone => _selectedZone;
  List<String> get selectedBranches => _selectedBranchNames;
  List<String> get selectedDesignations => _selectedDesignationNames;

  bool get areAllFiltersSelected {
    return _selectedZoneId != null &&
        _selectedBranchIds.isNotEmpty &&
        _selectedDesignationIds.isNotEmpty;
  }

  // Employee data
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  List<Employee> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();
  final TextEditingController dojFromController = TextEditingController();
  final TextEditingController fojToController = TextEditingController();

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  int? _totalRecords;
  int? _totalPagesFromServer;
  bool _paginationFromServer = false;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get pageSize => _itemsPerPage;

  int get totalPages {
    if (_totalPagesFromServer != null) return _totalPagesFromServer!;
    if (_totalRecords != null)
      return ((_totalRecords! / _itemsPerPage).ceil()).clamp(1, 999999);
    if (_filteredEmployees.isEmpty) return 0;
    return (_filteredEmployees.length / _itemsPerPage).ceil();
  }

  List<Employee> get paginatedEmployees => _filteredEmployees;

  void setPageSize(int newSize) {
    _currentPage = 1;
    _fetchCurrentPage();
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage >= totalPages) return;
    _currentPage++;
    if (_paginationFromServer) {
      _fetchCurrentPage();
    } else {
      _applyClientSidePage();
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage <= 1) return;
    _currentPage--;
    if (_paginationFromServer) {
      _fetchCurrentPage();
    } else {
      _applyClientSidePage();
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    if (_paginationFromServer) {
      _fetchCurrentPage();
    } else {
      _applyClientSidePage();
      notifyListeners();
    }
  }

  void _applyClientSidePage() {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, _allEmployees.length);
    _filteredEmployees =
        start < _allEmployees.length ? _allEmployees.sublist(start, end) : [];
  }

  void _fetchCurrentPage() {
    fetchAllEmployees(
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
    if (_initialLoadDone) {
      return;
    }

    _isLoadingFilters = true;
    _initialLoadDone = false;
    notifyListeners();

    loadAllFilters();
  }

  Future<void> loadAllFilters() async {
    _isLoadingFilters = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _filterService.getAllFilters();

      if (response != null &&
          response.status == "success" &&
          response.data != null) {
        _processFilterData(response);
        _isLoadingFilters = false;
        notifyListeners();
      } else {
        _errorMessage = response?.message ?? "Failed to load filters";
        _isLoadingFilters = false;
        _initialLoadDone = true;
        notifyListeners();
      }
    } catch (e) {
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

  Future<void> fetchAllEmployees({
    String? zoneId,
    String? locationsId,
    String? designationsId,
    int? page,
    int? perPage,
    String? search,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _allEmployeeService.getAllEmployees(
        zoneId: zoneId,
        locationsId: locationsId,
        designationsId: designationsId,
        page: page ?? _currentPage,
        perPage: perPage ?? _itemsPerPage,
        search: search,
      );

      if (response != null && response.status == "success") {
        // Convert AllEmployeeUser to Employee
        final users = response.data?.users ?? [];
        _allEmployees =
            users
                .map(
                  (user) => Employee(
                    employeeId: user.employmentId ?? user.userId ?? '',
                    name: user.fullname ?? '',
                    branch: user.locationName ?? user.location ?? '',
                    doj: user.joiningDate ?? '',
                    department: user.department ?? '',
                    designation: user.designation ?? '',
                    monthlyCTC: user.monthlyCTC ?? '',
                    payrollCategory: user.payrollCategory ?? '',
                    status: user.status ?? '',
                    photoUrl: user.avatar,
                    recruiterName: user.recruiterName,
                    recruiterPhotoUrl: user.recruiterPhotoUrl,
                    createdByName: user.createdByName,
                    createdByPhotoUrl: user.createdByPhotoUrl,
                  ),
                )
                .toList();

        // Check if API returned pagination
        if (response.data?.pagination != null) {
          _paginationFromServer = true;
          _totalPagesFromServer = response.data!.pagination!.lastPage;
          _totalRecords = response.data!.pagination!.total;
          _filteredEmployees = List.from(_allEmployees);
        } else {
          // Client-side pagination fallback
          _paginationFromServer = false;
          _totalRecords = _allEmployees.length;
          _applyClientSidePage();
        }

        _currentPage = page ?? _currentPage;
        _hasAppliedFilters = true;
        _initialLoadDone = true;
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = response?.message ?? "Failed to fetch employees";
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = "Error: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter methods
  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  void setSelectedZone(String? name) {
    _selectedZone = name;
    if (name != null) {
      final zone = _zoneList.firstWhere(
        (z) => z['name'] == name,
        orElse: () => {},
      );
      _selectedZoneId = zone['id'];
      _selectedZoneIds = [zone['id']!];
      _selectedZoneNames = [name];
      // Clear branch selection when zone changes
      _selectedBranchIds.clear();
      _selectedBranchNames.clear();
    } else {
      _selectedZoneId = null;
      _selectedZoneIds.clear();
      _selectedZoneNames.clear();
    }
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

  void setDojFrom(DateTime? date) {
    if (date != null) {
      dojFromController.text = "${date.day}/${date.month}/${date.year}";
    } else {
      dojFromController.clear();
    }
    notifyListeners();
  }

  void setDojTo(DateTime? date) {
    if (date != null) {
      fojToController.text = "${date.day}/${date.month}/${date.year}";
    } else {
      fojToController.clear();
    }
    notifyListeners();
  }

  void searchEmployees() {
    if (!areAllFiltersSelected) return;
    _currentPage = 1;
    _fetchCurrentPage();
  }

  void onSearchChanged(String query) {
    if (!_initialLoadDone) return;
    _currentPage = 1;
    _fetchCurrentPage();
  }

  void clearSearch() {
    searchController.clear();
    if (_hasAppliedFilters) {
      _currentPage = 1;
      _fetchCurrentPage();
    }
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedZone = null;
    _selectedZoneId = null;
    _selectedZoneIds.clear();
    _selectedZoneNames.clear();
    _selectedBranchIds.clear();
    _selectedBranchNames.clear();
    _selectedDesignationIds.clear();
    _selectedDesignationNames.clear();
    dojFromController.clear();
    fojToController.clear();
    searchController.clear();
    _filteredEmployees = [];
    _hasAppliedFilters = false;
    _currentPage = 1;
    notifyListeners();
  }

  Future<bool> updateEmployeeStatus(
    String employeeId,
    String status,
    DateTime date,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
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
