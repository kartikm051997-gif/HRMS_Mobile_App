// File: lib/provider/AdminTrackingProvider/AdminTrackingProvider.dart

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../model/Employee_management/getAllFiltersModel.dart';
import '../../model/UserTrackingModel/GetLocationHistoryModel.dart';
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
  List<Branches> _branchesData = [];
  List<Zones> _zonesData = [];
  List<Designations> _designations = [];

  bool _isLoadingFilters = false;
  String? _filterErrorMessage;

  //filter for zone
  List<Branches> _filteredBranches = [];

  // ═══════════════════════════════════════════════════════════════════════
  // FILTER VALUES (USER SELECTIONS)
  // ═══════════════════════════════════════════════════════════════════════

  String? _selectedEmployeeId;
  List<String> _selectedZones = [];
  List<String> _selectedBranches = [];
  String? _selectedDesignation;
  DateTime? _selectedDate;

  bool _isFilterExpanded = false;
  final adminDateController = TextEditingController();

  void clearFilters() {
    _selectedEmployeeId = null;
    _selectedZones = [];
    _selectedBranches = [];
    _selectedDesignation = null;
    _selectedDate = null;

    _trackingRecords.clear();
    _hasSearched = false;
    _isFilterExpanded = false;

    notifyListeners();
  }

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
  List<String> get selectedZones => _selectedZones;
  List<String> get selectedBranches => _selectedBranches;
  String? get selectedDesignation => _selectedDesignation;
  DateTime? get selectedDate => _selectedDate;
  bool get isFilterExpanded => _isFilterExpanded;
  bool get hasSearched => _hasSearched;
  bool get isLoading => _isLoading;
  bool get isLoadingFilters => _isLoadingFilters;
  List<TrackingRecord> get trackingRecords => _trackingRecords;

  List<String> get zoneNames =>
      _zonesData.map((z) => z.name ?? '').where((n) => n.isNotEmpty).toList();

  List<String> get branchNames {
    final source = _selectedZones.isEmpty ? _branchesData : _filteredBranches;

    return source.map((b) => b.name ?? '').where((n) => n.isNotEmpty).toList();
  }

  List<String> get roles =>
      _designations
          .map((d) => d.designations ?? '')
          .where((r) => r.isNotEmpty)
          .toList();

  String? get errorMessage => _errorMessage;
  String? get filterErrorMessage => _filterErrorMessage;

  bool get isFiltersValid =>
      _selectedEmployeeId != null &&
      _selectedZones.isNotEmpty &&
      _selectedBranches.isNotEmpty &&
      _selectedDesignation != null &&
      _selectedDate != null;

  // ═══════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════

  /// Initialize - Load filter data from API
  Future<void> initialize() async {
    await loadFilterData();
  }

  /// Load all filter data (employees, zones, branches, designations)
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
        _branchesData = filterData.data!.branches ?? [];
        _zonesData = filterData.data!.zones ?? [];

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
          print("   - Zones: ${_zonesData.length}");
          print("   - Branches: ${_branchesData.length}");
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

  void setZones(List<String> values) {
    _selectedZones = values;

    // 1️⃣ Convert selected zone NAMES → IDs
    final selectedZoneIds =
        _zonesData
            .where((z) => values.contains(z.name))
            .map((z) => z.id)
            .whereType<String>()
            .toList();

    // 2️⃣ Filter branches using zoneId
    _filteredBranches =
        _branchesData.where((b) => selectedZoneIds.contains(b.zoneId)).toList();

    // 3️⃣ Remove invalid selected branches
    _selectedBranches =
        _selectedBranches
            .where((b) => _filteredBranches.any((fb) => fb.name == b))
            .toList();

    if (kDebugMode) {
      print("🟣 Selected Zones: $values");
      print("🟣 Zone IDs: $selectedZoneIds");
      print(
        "🟣 Filtered Branches: ${_filteredBranches.map((e) => e.name).toList()}",
      );
    }

    notifyListeners();
  }

  void setBranches(List<String> values) {
    _selectedBranches = values;
    if (kDebugMode) {
      print("📝 Selected Branches: ${values.join(', ')}");
    }
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
        print("   - Zones: ${_selectedZones.join(', ')}");
        print("   - Branches: ${_selectedBranches.join(', ')}");
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

      // 🔥 GET LOGGED-IN USER INFO
      final loggedInUserId = await _authService.getUserId();
      final loggedInRoleId = await _authService.getRoleId();

      if (kDebugMode) {
        print("👤 Logged-in User ID: $loggedInUserId");
        print("👤 Logged-in Role ID: $loggedInRoleId");
      }

      if (loggedInUserId == null || loggedInUserId.isEmpty) {
        throw Exception('User ID not found. Please login again.');
      }

      if (loggedInRoleId == null || loggedInRoleId.isEmpty) {
        throw Exception('Role ID not found. Please login again.');
      }

      // Fetch history for selected employee with filters
      final DateTime dateToUse = _selectedDate ?? DateTime.now();
      final String apiDate = AdminTrackingService.formatDateForApi(dateToUse);

      // Always send safe string values
      final String employeeIdToSend = _selectedEmployeeId ?? "";

      final historyData = await _adminService.getEmployeeLocationHistory(
        token: token,
        userId: loggedInUserId, // Logged-in admin ID
        roleId: loggedInRoleId, // Admin role ID
        employeeId: employeeIdToSend, // Employee being tracked
        fromDate: apiDate, // ✅ REQUIRED
        toDate: apiDate, // ✅ REQUIRED
        zone: _selectedZones.isNotEmpty ? _selectedZones.join(',') : "",
        branch: _selectedBranches.isNotEmpty ? _selectedBranches.join(',') : "",
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

  /// Build sessions from locations (CHECK_IN to CHECK_OUT)
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

  /// Convert API response to TrackingRecord list
  List<TrackingRecord> _convertApiResponseToRecords(
    GetLocationHistoryModel historyData,
  ) {
    final allLocations = historyData.data!.locations!;

    // Filter by selected date
    final selectedDay = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final filteredLocations =
        allLocations.where((loc) {
          if (loc.capturedAt == null) return false;
          final locDay = loc.capturedAt!.split(" ").first;
          return locDay == selectedDay;
        }).toList();

    if (kDebugMode) {
      print("📅 Selected Date: $selectedDay");
      print("📍 Locations after date filter: ${filteredLocations.length}");
    }

    // Convert to sessions
    return _buildSessionsFromLocations(filteredLocations);
  }

  /// Create a single TrackingRecord from locations
  TrackingRecord _createTrackingRecordFromLocations(List<Locations> locations) {
    final checkInLoc = locations.firstWhere(
      (l) => l.activityType == "CHECK_IN",
    );
    final checkOutLoc = locations.lastWhere(
      (l) => l.activityType == "CHECK_OUT",
    );

    final checkInTime = DateTime.parse(checkInLoc.capturedAt!);
    final checkOutTime = DateTime.parse(checkOutLoc.capturedAt!);

    // Create tracking points with distance & wait time
    final List<TrackingPoint> points = [];
    for (int i = 0; i < locations.length; i++) {
      final current = locations[i];
      final previous = i == 0 ? null : locations[i - 1];
      points.add(TrackingPoint.fromLocation(current, previous));
    }

    double distance = 0;
    for (int i = 0; i < locations.length - 1; i++) {
      distance += _calculateDistance(locations[i], locations[i + 1]);
    }

    return TrackingRecord(
      employeeId: checkInLoc.userId ?? "",
      employeeName: checkInLoc.fullname ?? "Unknown",
      date: DateTime(checkInTime.year, checkInTime.month, checkInTime.day),
      checkIn: checkInTime,
      checkOut: checkOutTime,
      trackingPoints: points,
      totalDistance: distance,
      totalDuration: checkOutTime.difference(checkInTime),
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
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════

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

  void resetFilters() {
    _selectedEmployeeId = null;
    _selectedZones = [];
    _selectedBranches = [];
    _selectedDesignation = null;
    _selectedDate = DateTime.now();
    _hasSearched = false;
    _trackingRecords = [];
    _errorMessage = null;
    notifyListeners();
  }
}

// ═══════════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════════

class EmployeeModel {
  final String id;
  final String name;
  EmployeeModel({required this.id, required this.name});
}

class TrackingRecord {
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final DateTime checkIn;
  final DateTime? checkOut;
  final List<TrackingPoint> trackingPoints;
  final double totalDistance;
  final Duration totalDuration;

  TrackingRecord({
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.trackingPoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  String get checkInTime => DateFormat('hh:mm a').format(checkIn);
  String get checkOutTime =>
      checkOut == null
          ? 'Not checked out'
          : DateFormat('hh:mm a').format(checkOut!);
}

class TrackingPoint {
  final LatLng location;
  final String address;
  final String time;
  final double distanceFromPrevious;
  final Duration? waitTime;

  TrackingPoint({
    required this.location,
    required this.address,
    required this.time,
    required this.distanceFromPrevious,
    this.waitTime,
  });

  factory TrackingPoint.fromLocation(Locations loc, Locations? previous) {
    final lat = double.tryParse(loc.latitude ?? "0") ?? 0;
    final lng = double.tryParse(loc.longitude ?? "0") ?? 0;

    double distance = 0;
    Duration? wait;

    if (previous != null) {
      final prevLat = double.tryParse(previous.latitude ?? "0") ?? 0;
      final prevLng = double.tryParse(previous.longitude ?? "0") ?? 0;

      distance = Geolocator.distanceBetween(prevLat, prevLng, lat, lng);

      if (previous.capturedAt != null && loc.capturedAt != null) {
        wait = DateTime.parse(
          loc.capturedAt!,
        ).difference(DateTime.parse(previous.capturedAt!));
      }
    }

    return TrackingPoint(
      location: LatLng(lat, lng),
      address: loc.locationAddress ?? "Unknown location",
      time: _formatTime(loc.capturedAt),
      distanceFromPrevious: distance,
      waitTime: wait,
    );
  }

  static String _formatTime(String? value) {
    if (value == null) return "";
    final dt = DateTime.parse(value);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
