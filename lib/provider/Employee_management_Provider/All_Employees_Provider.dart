import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../model/Employee_management/AllEmployeeListModelClass.dart';
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../model/Employee_management/Employee_management.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/ActiveUserFilterService.dart';
import '../../servicesAPI/EmployeeManagementServiceScreens/ActiveUserService/AllEmployeeService.dart';
import '../../core/utils/helper_utils.dart';
import '../../servicesAPI/LogInService/LogIn_Service.dart';
import '../../apibaseScreen/Api_Base_Screens.dart';

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

  Timer? _searchDebounce;

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
        
        // ✅ CRITICAL: Fetch default data WITHOUT selecting filters in UI
        // Filters remain unselected, but we fetch default data (all data)
        if (kDebugMode) {
          print("📊 Fetching default data without filters...");
        }
        await fetchAllEmployees(page: 1, perPage: _itemsPerPage);
        _hasAppliedFilters = false; // Keep filters unselected
        _initialLoadDone = true;
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
        // Clear session and navigate to login
        final authService = LoginService();
        await authService.clearSession();
        HelperUtil.navigateToLoginOnTokenExpiry();
      } else {
        _errorMessage = "Error loading filters: ${e.toString()}";
      }

      _isLoadingFilters = false;
      _initialLoadDone = true;

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

      if (response != null) {
        // Check if response has data (some APIs might return success without status field)
        if (response.status == "success" || response.data != null) {
          // Convert AllEmployeeUser to Employee
          final users = response.data?.users ?? [];
          
          if (kDebugMode) {
            print("✅ AllEmployeesProvider: Response received");
            print("   Status: ${response.status}");
            print("   Users count: ${users.length}");
            print("   Data: ${response.data != null}");
            print("   Pagination: ${response.data?.pagination != null}");
            if (users.isEmpty) {
              print("⚠️ Users list is empty!");
            }
          }
          
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
                      photoUrl: _getAvatarUrl(user.avatar),
                      recruiterName: user.recruiterName,
                      recruiterPhotoUrl: user.recruiterPhotoUrl,
                      createdByName: user.createdByName,
                      createdByPhotoUrl: user.createdByPhotoUrl,
                    ),
                  )
                  .toList();
          
          if (kDebugMode) {
            print("📊 Converted ${_allEmployees.length} employees");
          }

          if (response.data?.pagination != null) {
            _paginationFromServer = true;
            _totalPagesFromServer = response.data!.pagination!.lastPage;
            _totalRecords = response.data!.pagination!.total ?? _allEmployees.length;
            // ✅ If search is active, filter results; otherwise show all
            if (search != null && search.isNotEmpty) {
              final searchLower = search.toLowerCase();
              _filteredEmployees = _allEmployees.where((employee) {
                final name = (employee.name ?? employee.username ?? '').toLowerCase();
                final empId = (employee.employeeId ?? '').toLowerCase();
                return name.contains(searchLower) || empId.contains(searchLower);
              }).toList();
            } else {
              _filteredEmployees = List.from(_allEmployees);
            }
            if (kDebugMode) {
              print("📊 Server-side pagination: Total=$_totalRecords, LastPage=$_totalPagesFromServer");
            }
          } else {
            // Client-side pagination fallback
            _paginationFromServer = false;
            _totalRecords = _allEmployees.length;
            // ✅ If search is active, filter results; otherwise apply pagination
            if (search != null && search.isNotEmpty) {
              final searchLower = search.toLowerCase();
              _filteredEmployees = _allEmployees.where((employee) {
                final name = (employee.name ?? employee.username ?? '').toLowerCase();
                final empId = (employee.employeeId ?? '').toLowerCase();
                return name.contains(searchLower) || empId.contains(searchLower);
              }).toList();
            } else {
              if (_allEmployees.isNotEmpty) {
                _applyClientSidePage();
              } else {
                _filteredEmployees = List.from(_allEmployees);
              }
            }
            if (kDebugMode) {
              print("📊 Client-side pagination: Total=$_totalRecords");
            }
          }

          // Ensure _totalRecords is set even when 0
          if (_totalRecords == null) {
            _totalRecords = _allEmployees.length;
          }

          _currentPage = page ?? _currentPage;
          // Set hasAppliedFilters = true if we have data (even without filters selected)
          // This allows the UI to show the data instead of "Select Filters" message
          _hasAppliedFilters = _allEmployees.isNotEmpty;
          _initialLoadDone = true;
          _isLoading = false;
          
          if (kDebugMode) {
            print("✅ AllEmployeesProvider: Loaded ${_allEmployees.length} employees");
            print("📊 Total Records: $_totalRecords, Total Pages: $_totalPagesFromServer");
            print("📊 Filtered Employees: ${_filteredEmployees.length}");
            print("📊 Has Applied Filters: $_hasAppliedFilters");
          }
          
          notifyListeners();
        } else {
          _errorMessage = response?.message ?? "Failed to fetch employees";
          if (kDebugMode) {
            print("❌ AllEmployeesProvider: Response status not success");
            print("   Status: ${response.status}");
            print("   Message: ${response.message}");
          }
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _errorMessage = "No response from server";
        if (kDebugMode) print("❌ AllEmployeesProvider: Response is null");
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      if (e.toString().contains("401") ||
          e.toString().contains("UNAUTHORIZED")) {
        _isTokenExpired = true;
        _errorMessage = "Your session has expired. Please login again.";
        // Clear session and navigate to login
        final authService = LoginService();
        await authService.clearSession();
        HelperUtil.navigateToLoginOnTokenExpiry();
      } else {
        _errorMessage = "Error: ${e.toString()}";
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // APPLY DEFAULT FILTERS (Select first zone, first branch, first designation)
  // ═══════════════════════════════════════════════════════════════════════

  void _applyDefaultFilters() {
    if (_zoneList.isEmpty) {
      return;
    }

    // ✅ Select first zone
    if (_zoneList.isNotEmpty) {
      _selectedZone = _zoneList.first['name'];
      _selectedZoneId = _zoneList.first['id'];
      _selectedZoneIds = [_zoneList.first['id']!];
      _selectedZoneNames = [_zoneList.first['name']!];
    }

    // ✅ Select first branch (filtered by selected zone)
    if (_selectedZoneId != null) {
      final zoneBranches = _branchList
          .where((b) => b['zone_id'] == _selectedZoneId)
          .toList();
      if (zoneBranches.isNotEmpty) {
        _selectedBranchIds = [zoneBranches.first['id']!];
        _selectedBranchNames = [zoneBranches.first['name']!];
      }
    }

    // ✅ Select first designation
    if (_designationList.isNotEmpty) {
      _selectedDesignationIds = [_designationList.first['id']!];
      _selectedDesignationNames = [_designationList.first['name']!];
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
      final name = (employee.name ?? employee.username ?? '').toLowerCase();
      final empId = (employee.employeeId ?? '').toLowerCase();
      return name.contains(searchLower) || empId.contains(searchLower);
    }).toList();
    
    _currentPage = 1;
    notifyListeners();
    
    // Also do server-side search with debounce for fresh data
    _searchDebounce = Timer(const Duration(milliseconds: 800), () {
      _currentPage = 1;
      _fetchCurrentPage();
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
      final name = (employee.name ?? employee.username ?? '').toLowerCase();
      final empId = (employee.employeeId ?? '').toLowerCase();
      return name.contains(searchLower) || empId.contains(searchLower);
    }).toList();
    
    _currentPage = 1;
    notifyListeners();
    
    // Then fetch fresh data from server
    _fetchCurrentPage();
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    searchController.clear();
    _currentPage = 1;
    // Show all employees immediately
    _filteredEmployees = List.from(_allEmployees);
    notifyListeners();
    // Then fetch fresh data
    if (_hasAppliedFilters) {
      _fetchCurrentPage();
    }
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
    _searchDebounce?.cancel();
    dojFromController.dispose();
    fojToController.dispose();
    searchController.dispose();
    super.dispose();
  }

  /// Helper method to construct full avatar URL from relative path
  String _getAvatarUrl(String? avatar) {
    if (avatar == null || avatar.isEmpty || avatar == 'null') {
      return '';
    }
    final avatarStr = avatar.toString().trim();
    if (avatarStr.isEmpty) {
      return '';
    }
    if (avatarStr.startsWith('http://') || avatarStr.startsWith('https://')) {
      return avatarStr;
    }
    final cleanPath = avatarStr.startsWith('/') ? avatarStr.substring(1) : avatarStr;
    return '${ApiBase.baseUrl}$cleanPath';
  }
}
