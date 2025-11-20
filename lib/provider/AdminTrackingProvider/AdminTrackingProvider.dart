import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminTrackingProvider with ChangeNotifier {
  // Filter values
  String? _selectedEmployeeId;
  String? _selectedBranch;
  String? _selectedDesignation;
  DateTime? _selectedDate;

  // Filter expansion
  bool _isFilterExpanded = false;




  // Search results
  bool _hasSearched = false;
  bool _isLoading = false;
  List<TrackingRecord> _trackingRecords = [];

  // Dummy data
  final List<EmployeeModel> _employees = [
    EmployeeModel(id: 'EMP001', name: 'Rajesh Kumar'),
    EmployeeModel(id: 'EMP002', name: 'Priya Sharma'),
    EmployeeModel(id: 'EMP003', name: 'Amit Patel'),
    EmployeeModel(id: 'EMP004', name: 'Sneha Reddy'),
    EmployeeModel(id: 'EMP005', name: 'Vijay Singh'),
    EmployeeModel(id: 'EMP005', name: 'g Singh'),
    EmployeeModel(id: 'EMP005', name: 'h h'),
    EmployeeModel(id: 'EMP005', name: 't h'),
    EmployeeModel(id: 'EMP005', name: 't f'),
    EmployeeModel(id: 'EMP005', name: 'e h'),
    EmployeeModel(id: 'EMP005', name: 'w k'),
    EmployeeModel(id: 'EMP005', name: 'h j'),
    EmployeeModel(id: 'EMP005', name: 'r o'),
    EmployeeModel(id: 'EMP005', name: 'e j'),
    EmployeeModel(id: 'EMP005', name: 'w yi'),
  ];

  final List<String> _branches = [
    'Chennai',
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Pune',
  ];

  final List<String> _designation = [
    'Sales Executive',
    'Manager',
    'Team Lead',
    'Admin',
    'HR',
    'Finance',
  ];

  final adminDateController = TextEditingController();


  // Getters
  String? get selectedEmployeeId => _selectedEmployeeId;
  String? get selectedBranch => _selectedBranch;
  String? get selectedDesignation => _selectedDesignation;
  DateTime? get selectedDate => _selectedDate;
  bool get isFilterExpanded => _isFilterExpanded;
  bool get hasSearched => _hasSearched;
  bool get isLoading => _isLoading;
  List<TrackingRecord> get trackingRecords => _trackingRecords;
  List<EmployeeModel> get employees => _employees;
  List<String> get branches => _branches;
  List<String> get roles => _designation;

  // Check if all filters are selected
  bool get isFiltersValid =>
      _selectedEmployeeId != null &&
          _selectedBranch != null &&
          _selectedDesignation != null &&
          _selectedDate != null;

  // Set filter values
  void setEmployeeId(String? value) {
    _selectedEmployeeId = value;
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

  // Search functionality
  Future<void> performSearch() async {
    if (!isFiltersValid) return;

    _isLoading = true;
    _hasSearched = false;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Generate dummy tracking data with multiple sessions for history
    _trackingRecords = _generateDummyTrackingData();
    _hasSearched = true;
    _isLoading = false;
    _isFilterExpanded = false; // Collapse filter after search

    notifyListeners();
  }

  // ✅ UPDATED: Generate multiple sessions for history view
  List<TrackingRecord> _generateDummyTrackingData() {
    final selectedEmployee = _employees.firstWhere(
          (e) => e.id == _selectedEmployeeId,
      orElse: () => _employees.first,
    );

    return [
      // Today's session
      TrackingRecord(
        sessionId: 'SESSION_${DateTime.now().millisecondsSinceEpoch}',
        employeeId: _selectedEmployeeId!,
        employeeName: selectedEmployee.name,
        date: _selectedDate!,
        checkInTime: '09:00 AM',
        checkOutTime: '06:00 PM',
        checkInLocation: const LatLng(13.0827, 80.2707),
        checkInAddress: '119, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
        checkOutLocation: const LatLng(13.0358, 80.2298),
        checkOutAddress: '18, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
        trackingPoints: [
          TrackingPoint(
            location: const LatLng(13.0827, 80.2707),
            address: '119, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
            time: '09:00 AM',
            distanceFromPrevious: 0,
            waitTime: null,
            isCheckpoint: true,
          ),
          TrackingPoint(
            location: const LatLng(13.0878, 80.2785),
            address: '1, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
            time: '10:30 AM',
            distanceFromPrevious: 377,
            waitTime: const Duration(minutes: 15),
            isCheckpoint: false,
          ),
          TrackingPoint(
            location: const LatLng(13.0569, 80.2425),
            address: '60A, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
            time: '12:45 PM',
            distanceFromPrevious: 178,
            waitTime: const Duration(minutes: 30),
            isCheckpoint: false,
          ),
          TrackingPoint(
            location: const LatLng(13.0475, 80.2380),
            address: '14, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
            time: '03:20 PM',
            distanceFromPrevious: 231,
            waitTime: const Duration(minutes: 20),
            isCheckpoint: false,
          ),
          TrackingPoint(
            location: const LatLng(13.0358, 80.2298),
            address: '18, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
            time: '06:00 PM',
            distanceFromPrevious: 450,
            waitTime: null,
            isCheckpoint: true,
          ),
        ],
      ),

      // Yesterday's session
      TrackingRecord(
        sessionId: 'SESSION_${DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch}',
        employeeId: _selectedEmployeeId!,
        employeeName: selectedEmployee.name,
        date: _selectedDate!.subtract(const Duration(days: 1)),
        checkInTime: '09:15 AM',
        checkOutTime: '05:45 PM',
        checkInLocation: const LatLng(13.0827, 80.2707),
        checkInAddress: '119, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
        checkOutLocation: const LatLng(13.0569, 80.2425),
        checkOutAddress: '60A, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
        trackingPoints: [
          TrackingPoint(
            location: const LatLng(13.0827, 80.2707),
            address: '119, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
            time: '09:15 AM',
            distanceFromPrevious: 0,
            waitTime: null,
            isCheckpoint: true,
          ),
          TrackingPoint(
            location: const LatLng(13.0678, 80.2485),
            address: 'Saidapet, Chennai, Tamil Nadu, India',
            time: '11:00 AM',
            distanceFromPrevious: 520,
            waitTime: const Duration(minutes: 25),
            isCheckpoint: false,
          ),
          TrackingPoint(
            location: const LatLng(13.0569, 80.2425),
            address: '60A, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
            time: '05:45 PM',
            distanceFromPrevious: 380,
            waitTime: null,
            isCheckpoint: true,
          ),
        ],
      ),

      // 2 days ago - Not checked out yet
      TrackingRecord(
        sessionId: 'SESSION_${DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch}',
        employeeId: _selectedEmployeeId!,
        employeeName: selectedEmployee.name,
        date: _selectedDate!.subtract(const Duration(days: 2)),
        checkInTime: '09:05 AM',
        checkOutTime: '06:30 PM',
        checkInLocation: const LatLng(13.0827, 80.2707),
        checkInAddress: '119, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
        checkOutLocation: const LatLng(13.0878, 80.2785),
        checkOutAddress: '1, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
        trackingPoints: [
          TrackingPoint(
            location: const LatLng(13.0827, 80.2707),
            address: '119, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
            time: '09:05 AM',
            distanceFromPrevious: 0,
            waitTime: null,
            isCheckpoint: true,
          ),
          TrackingPoint(
            location: const LatLng(13.0878, 80.2785),
            address: '1, Pallikaranai, Chennai, Tamil Nadu, 600100, India',
            time: '06:30 PM',
            distanceFromPrevious: 377,
            waitTime: null,
            isCheckpoint: true,
          ),
        ],
      ),
    ];
  }

  // Fetch history for date range
  Future<void> fetchHistory() async {
    if (_selectedEmployeeId == null) return;

    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Generate history data
    _trackingRecords = _generateDummyTrackingData();
    _hasSearched = true;
    _isLoading = false;

    notifyListeners();
  }

  // Reset filters
  void resetFilters() {
    _selectedEmployeeId = null;
    _selectedBranch = null;
    _selectedDesignation = null;
    _selectedDate = DateTime.now();
    _hasSearched = false;
    _trackingRecords = [];
    notifyListeners();
  }

  // Get filtered employees by search query
  List<EmployeeModel> getFilteredEmployees(String query) {
    if (query.isEmpty) return _employees;
    return _employees
        .where(
          (emp) =>
      emp.id.toLowerCase().contains(query.toLowerCase()) ||
          emp.name.toLowerCase().contains(query.toLowerCase()),
    )
        .toList();
  }

  // Get filtered branches by search query
  List<String> getFilteredBranches(String query) {
    if (query.isEmpty) return _branches;
    return _branches
        .where((branch) => branch.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get filtered roles by search query
  List<String> getFilteredRoles(String query) {
    if (query.isEmpty) return _designation;
    return _designation
        .where((role) => role.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

// Models
class EmployeeModel {
  final String id;
  final String name;

  EmployeeModel({required this.id, required this.name});
}

// ✅ UPDATED: Added sessionId field
class TrackingRecord {
  final String sessionId; // ✅ NEW FIELD
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
    required this.sessionId, // ✅ NEW FIELD
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

    // Parse check-in and check-out times to calculate duration
    try {
      // For proper calculation, you'd parse the actual times
      // For now, using a simple calculation based on number of points
      final hours = (trackingPoints.length - 1) * 2; // Rough estimate
      return Duration(hours: hours.clamp(0, 10));
    } catch (e) {
      return const Duration(hours: 9); // Default 9 hours
    }
  }

  // ✅ Optional: Add fromJson for API integration
  factory TrackingRecord.fromJson(Map<String, dynamic> json) {
    return TrackingRecord(
      sessionId: json['sessionId'] ?? json['session_id'] ?? '',
      employeeId: json['employeeId'] ?? json['employee_id'] ?? '',
      employeeName: json['employeeName'] ?? json['employee_name'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      checkInTime: json['checkInTime'] ?? json['check_in_time'] ?? '',
      checkOutTime: json['checkOutTime'] ?? json['check_out_time'] ?? '',
      checkInLocation: LatLng(
        json['checkInLocation']?['latitude'] ?? 0.0,
        json['checkInLocation']?['longitude'] ?? 0.0,
      ),
      checkInAddress: json['checkInAddress'] ?? json['check_in_address'] ?? '',
      checkOutLocation: LatLng(
        json['checkOutLocation']?['latitude'] ?? 0.0,
        json['checkOutLocation']?['longitude'] ?? 0.0,
      ),
      checkOutAddress: json['checkOutAddress'] ?? json['check_out_address'] ?? '',
      trackingPoints: (json['trackingPoints'] as List?)
          ?.map((e) => TrackingPoint.fromJson(e))
          .toList() ?? [],
    );
  }
}

class TrackingPoint {
  final LatLng location;
  final String address;
  final String time;
  final double distanceFromPrevious; // in meters
  final Duration? waitTime;
  final bool isCheckpoint; // true for check-in/check-out

  TrackingPoint({
    required this.location,
    required this.address,
    required this.time,
    required this.distanceFromPrevious,
    this.waitTime,
    this.isCheckpoint = false,
  });

  // ✅ Optional: Add fromJson for API integration
  factory TrackingPoint.fromJson(Map<String, dynamic> json) {
    return TrackingPoint(
      location: LatLng(
        json['latitude'] ?? 0.0,
        json['longitude'] ?? 0.0,
      ),
      address: json['address'] ?? '',
      time: json['time'] ?? '',
      distanceFromPrevious: (json['distanceFromPrevious'] ??
          json['distance_from_previous'] ?? 0).toDouble(),
      waitTime: json['waitTime'] != null || json['wait_time'] != null
          ? Duration(minutes: json['waitTime'] ?? json['wait_time'] ?? 0)
          : null,
      isCheckpoint: json['isCheckpoint'] ?? json['is_checkpoint'] ?? false,
    );
  }
}