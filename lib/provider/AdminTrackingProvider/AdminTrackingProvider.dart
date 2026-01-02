// File: lib/provider/AdminTrackingProvider/AdminTrackingProvider.dart

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../model/Employee_management/getAllFiltersModel.dart'; // ✅ YOUR MODEL
import '../../model/UserTrackingModel/GetLocationHistoryModel.dart'; // ✅ YOUR MODEL
import '../../servicesAPI/AdminTrackingService/AdminTrackingService.dart';
import '../../servicesAPI/LogInService/LogIn_Service.dart';

class AdminTrackingProvider with ChangeNotifier {
  // Services
  final AdminTrackingService _adminService = AdminTrackingService();
  final AuthService _authService = AuthService();

  // ═══════════════════════════════════════════════════════════════════════
  // FILTER DATA (FROM API)
  // ═══════════════════════════════════════════════════════════════════════

  List<Employees> _employees = [];
  List<Branches> _branches = [];
  List<Designations> _designations = [];

  bool _isLoadingFilters = false;
  String? _filterErrorMessage;

  // ═══════════════════════════════════════════════════════════════════════
  // FILTER VALUES (USER SELECTIONS)
  // ═══════════════════════════════════════════════════════════════════════

  String? _selectedEmployeeId;
  String? _selectedBranch;
  String? _selectedDesignation;
  DateTime? _selectedDate;

  bool _isFilterExpanded = false;
  final adminDateController = TextEditingController();

  // ═══════════════════════════════════════════════════════════════════════
  // TRACKING DATA
  // ═══════════════════════════════════════════════════════════════════════

  bool _hasSearched = false;
  bool _isLoading = false;
  List<TrackingRecord> _trackingRecords = [];
  String? _errorMessage;

  // ═══════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════

  String? get selectedEmployeeId => _selectedEmployeeId;
  String? get selectedBranch => _selectedBranch;
  String? get selectedDesignation => _selectedDesignation;
  DateTime? get selectedDate => _selectedDate;
  bool get isFilterExpanded => _isFilterExpanded;
  bool get hasSearched => _hasSearched;
  bool get isLoading => _isLoading;
  bool get isLoadingFilters => _isLoadingFilters;
  List<TrackingRecord> get trackingRecords => _trackingRecords;
  List<String> get branchNames => _branches.map((b) => b.name ?? '').toList();
  List<String> get roles =>
      _designations.map((d) => d.designations ?? '').toList();
  String? get errorMessage => _errorMessage;
  String? get filterErrorMessage => _filterErrorMessage;

  bool get isFiltersValid =>
      _selectedEmployeeId != null &&
      _selectedBranch != null &&
      _selectedDesignation != null &&
      _selectedDate != null;

  // ═══════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════

  /// Initialize - Load filter data from API
  Future<void> initialize() async {
    await loadFilterData();
  }

  /// Load all filter data (employees, branches, designations)
  Future<void> loadFilterData() async {
    try {
      _isLoadingFilters = true;
      _filterErrorMessage = null;
      notifyListeners();

      if (kDebugMode) print("🔄 Loading admin filter data...");

      // Get auth token
      final token = await _authService.getAuthToken();
      if (token == null || token.isEmpty) {
        _filterErrorMessage = 'Please login again - Session expired';
        _isLoadingFilters = false;
        notifyListeners();
        return;
      }

      // Fetch filter data from API
      final filterData = await _adminService.getAllEmployees(token: token);

      if (filterData?.data != null) {
        _employees = filterData!.data!.employees ?? [];
        _branches = filterData.data!.branches ?? [];

        // Extract designations from departments
        _designations = [];
        if (filterData.data!.departments != null) {
          for (var dept in filterData.data!.departments!) {
            if (dept.designations != null) {
              _designations.addAll(dept.designations!);
            }
          }
        }

        if (kDebugMode) {
          print("✅ Filter data loaded:");
          print("   - Employees: ${_employees.length}");
          print("   - Branches: ${_branches.length}");
          print("   - Designations: ${_designations.length}");
        }
      } else {
        _filterErrorMessage = 'No filter data available';
      }
    } catch (e) {
      _filterErrorMessage = "Error loading filters: ${e.toString()}";
      if (kDebugMode) print("❌ Error loading filters: $e");
    } finally {
      _isLoadingFilters = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FILTER SETTERS
  // ═══════════════════════════════════════════════════════════════════════

  void setEmployeeId(String? value) {
    _selectedEmployeeId = value;

    if (kDebugMode && value != null) {
      print("📝 Selected Employee ID: $value");
    }

    notifyListeners();
  }

  void setBranch(String? value) {
    _selectedBranch = value;
    notifyListeners();
  }

  void setRole(String? value) {
    _selectedDesignation = value;
    notifyListeners();
  }

  void setDate(DateTime? value) {
    _selectedDate = value;
    notifyListeners();
  }

  void toggleFilter() {
    _isFilterExpanded = !_isFilterExpanded;
    notifyListeners();
  }

  void collapseFilter() {
    _isFilterExpanded = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SEARCH / FETCH TRACKING DATA
  // ═══════════════════════════════════════════════════════════════════════

  /// Perform search with selected filters
  Future<void> performSearch() async {
    if (!isFiltersValid) {
      _errorMessage = 'Please select all filters';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _hasSearched = false;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print("═══════════════════════════════════════");
        print("🔍 Performing search with filters:");
        print("   - Employee ID: $_selectedEmployeeId");
        print("   - Branch: $_selectedBranch");
        print("   - Designation: $_selectedDesignation");
        print(
          "   - Date: ${_selectedDate != null ? AdminTrackingService.formatDateForApi(_selectedDate!) : 'N/A'}",
        );
        print("═══════════════════════════════════════");
      }

      // Get auth token
      final token = await _authService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login again - Session expired');
      }

      // ✅ Use employment_id as user_id for API call
      final historyData = await _adminService.getEmployeeLocationHistory(
        token: token,
        userId: _selectedEmployeeId!, // Using employment_id
        employeeId: _selectedEmployeeId,
        branch: _selectedBranch,
        designation: _selectedDesignation,
        date:
            _selectedDate != null
                ? AdminTrackingService.formatDateForApi(_selectedDate!)
                : null,
      );

      // Convert API response to TrackingRecords
      if (historyData?.data?.locations != null &&
          historyData!.data!.locations!.isNotEmpty) {
        _trackingRecords = _convertApiResponseToRecords(historyData);

        if (kDebugMode) {
          print("✅ Search completed successfully");
          print("📊 Results: ${_trackingRecords.length} sessions found");
        }
      } else {
        _trackingRecords = [];
        if (kDebugMode) print("⚠️ No tracking data found");
      }

      _hasSearched = true;
      _isFilterExpanded = false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) print("❌ Search failed: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DATA CONVERSION (API Response → TrackingRecord)
  // ═══════════════════════════════════════════════════════════════════════

  /// Convert API response to TrackingRecord list
  List<TrackingRecord> _buildSessionsFromLocations(List<Locations> locations) {
    final List<TrackingRecord> sessions = [];

    locations.sort(
      (a, b) => DateTime.parse(
        a.capturedAt!,
      ).compareTo(DateTime.parse(b.capturedAt!)),
    );

    List<Locations> currentSession = [];

    for (final loc in locations) {
      if (loc.activityType == "CHECK_IN") {
        currentSession = [];
        currentSession.add(loc);
      } else if (loc.activityType == "CHECK_OUT") {
        currentSession.add(loc);
        sessions.add(_createTrackingRecordFromLocations(currentSession));
        currentSession = [];
      } else {
        currentSession.add(loc);
      }
    }

    return sessions;
  }

  List<TrackingRecord> _convertApiResponseToRecords(
    GetLocationHistoryModel historyData,
  ) {
    final locations = historyData.data!.locations!;
    return _buildSessionsFromLocations(locations);

    // Sort by time
  }

  /// Create a single TrackingRecord from locations
  TrackingRecord _createTrackingRecordFromLocations(List<Locations> locations) {
    final firstLocation = locations.first;
    final date = DateTime.parse(firstLocation.capturedAt!);

    // Find check-in and check-out
    final checkInLoc = locations.firstWhere(
      (l) => l.activityType == 'CHECK_IN',
      orElse: () => locations.first,
    );

    final checkOutLoc = locations.lastWhere(
      (l) => l.activityType == 'CHECK_OUT',
      orElse: () => locations.last,
    );

    // Create tracking points
    List<TrackingPoint> trackingPoints = [];

    for (int i = 0; i < locations.length; i++) {
      final loc = locations[i];
      final dt = DateTime.parse(loc.capturedAt!);

      double distance = 0;
      if (i > 0) {
        distance = _calculateDistance(locations[i - 1], loc);
      }

      trackingPoints.add(
        TrackingPoint(
          location: LatLng(
            double.parse(loc.latitude ?? '0'),
            double.parse(loc.longitude ?? '0'),
          ),
          address: loc.locationAddress ?? 'Unknown location',
          time: DateFormat('hh:mm a').format(dt),
          distanceFromPrevious: distance,
          waitTime: null,
          isCheckpoint:
              loc.activityType == 'CHECK_IN' || loc.activityType == 'CHECK_OUT',
        ),
      );
    }

    // Get employee name from first location
    final employeeName = firstLocation.fullname ?? 'Unknown Employee';

    return TrackingRecord(
      sessionId: 'session_${date.millisecondsSinceEpoch}',
      employeeId: _selectedEmployeeId ?? '',
      employeeName: employeeName,
      date: date,
      checkInTime: DateFormat(
        'hh:mm a',
      ).format(DateTime.parse(checkInLoc.capturedAt!)),
      checkOutTime:
          checkOutLoc.activityType == 'CHECK_OUT'
              ? DateFormat(
                'hh:mm a',
              ).format(DateTime.parse(checkOutLoc.capturedAt!))
              : '--:--',
      checkInLocation: LatLng(
        double.parse(checkInLoc.latitude ?? '0'),
        double.parse(checkInLoc.longitude ?? '0'),
      ),
      checkInAddress: checkInLoc.locationAddress ?? 'Unknown',
      checkOutLocation: LatLng(
        double.parse(checkOutLoc.latitude ?? '0'),
        double.parse(checkOutLoc.longitude ?? '0'),
      ),
      checkOutAddress: checkOutLoc.locationAddress ?? 'Unknown',
      trackingPoints: trackingPoints,
    );
  }

  /// Calculate distance between two locations (in meters)
  double _calculateDistance(Locations start, Locations end) {
    try {
      final lat1 = double.parse(start.latitude ?? '0') * (math.pi / 180);
      final lon1 = double.parse(start.longitude ?? '0') * (math.pi / 180);
      final lat2 = double.parse(end.latitude ?? '0') * (math.pi / 180);
      final lon2 = double.parse(end.longitude ?? '0') * (math.pi / 180);

      const earthRadius = 6371000;
      final dLat = lat2 - lat1;
      final dLon = lon2 - lon1;

      final a =
          math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(lat1) *
              math.cos(lat2) *
              math.sin(dLon / 2) *
              math.sin(dLon / 2);
      final c = 2 * math.asin(math.sqrt(a));

      return earthRadius * c;
    } catch (e) {
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FILTER SEARCH HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  List<EmployeeModel> getFilteredEmployees(String query) {
    final filtered =
        _employees.where((emp) {
          final id = (emp.employmentId ?? '').toLowerCase();
          final name = (emp.fullname ?? '').toLowerCase();
          final q = query.toLowerCase();
          return id.contains(q) || name.contains(q);
        }).toList();

    return filtered
        .map(
          (e) => EmployeeModel(
            id: e.employmentId ?? '',
            name: e.fullname ?? 'Unknown',
          ),
        )
        .toList();
  }

  List<String> getFilteredBranches(String query) {
    if (query.isEmpty) return branchNames;
    return branchNames
        .where((branch) => branch.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<String> getFilteredRoles(String query) {
    if (query.isEmpty) return roles;
    return roles
        .where((role) => role.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // RESET
  // ═══════════════════════════════════════════════════════════════════════

  void resetFilters() {
    _selectedEmployeeId = null;
    _selectedBranch = null;
    _selectedDesignation = null;
    _selectedDate = DateTime.now();
    _hasSearched = false;
    _trackingRecords = [];
    _errorMessage = null;
    notifyListeners();
  }

  List<EmployeeModel> get employees {
    return _employees
        .map(
          (e) => EmployeeModel(
            id: e.employmentId ?? '',
            name: e.fullname ?? 'Unknown',
          ),
        )
        .toList();
  }
}

// ═══════════════════════════════════════════════════════════════════════
// MODELS (Keep existing TrackingRecord, TrackingPoint, EmployeeModel)
// ═══════════════════════════════════════════════════════════════════════

class EmployeeModel {
  final String id;
  final String name;
  EmployeeModel({required this.id, required this.name});
}

class TrackingRecord {
  final String sessionId;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final String checkInTime;
  final String checkOutTime;
  final LatLng checkInLocation;
  final String checkInAddress;
  final LatLng checkOutLocation;
  final String checkOutAddress;
  final List<TrackingPoint> trackingPoints;

  TrackingRecord({
    required this.sessionId,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInLocation,
    required this.checkInAddress,
    required this.checkOutLocation,
    required this.checkOutAddress,
    required this.trackingPoints,
  });

  double get totalDistance {
    return trackingPoints.fold(
      0.0,
      (sum, point) => sum + point.distanceFromPrevious,
    );
  }

  Duration get totalDuration {
    if (trackingPoints.length < 2) return Duration.zero;
    return const Duration(hours: 9);
  }
}

class TrackingPoint {
  final LatLng location;
  final String address;
  final String time;
  final double distanceFromPrevious;
  final Duration? waitTime;
  final bool isCheckpoint;

  TrackingPoint({
    required this.location,
    required this.address,
    required this.time,
    required this.distanceFromPrevious,
    this.waitTime,
    this.isCheckpoint = false,
  });
}
