import 'dart:async';
import 'dart:convert';
import 'package:flutter/Material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Service/BackgroundTrackingScreen.dart';
import '../../Service/LocationServiceScreen.dart';
import '../../servicesAPI/UserTrackingService/UserTrackingService.dart';
import '../../model/UserTrackingModel/UserTrackingModel.dart';

class UserTrackingProvider extends ChangeNotifier {
  // Services
  final LocationService _locationService = LocationService();
  final BackgroundTrackingService _backgroundService =
      BackgroundTrackingService();

  // State
  List<UserTrackingRecordModel> _trackingRecords = [];
  bool _isCheckedIn = false;
  bool _isLoading = false;
  String? _currentCheckInTime;
  LatLng? _currentCheckInLocation;
  String? _currentCheckInAddress;
  List<LatLng> _currentRoutePoints = [];
  List<AddressCheckpoint> _currentAddressCheckpoints = [];
  String? _currentUserId;
  Timer? _syncTimer;
  Timer? _apiSyncTimer; // ✅ NEW: Periodic API sync
  bool _isInitialized = false;

  // ✅ API Status tracking
  bool _isApiConnected = false;
  String? _lastApiSyncTime;
  int _failedApiCallsCount = 0;

  // ✅ User info for API
  String? _roleId;
  String? _username;
  String? _email;
  String? _fullname;
  String? _avatar;
  String? _designationsId;
  String? _zoneId;
  String? _branchId;

  // Getters
  List<UserTrackingRecordModel> get trackingRecords => _trackingRecords;
  bool get isCheckedIn => _isCheckedIn;
  bool get isLoading => _isLoading;
  String? get currentCheckInTime => _currentCheckInTime;
  LatLng? get currentCheckInLocation => _currentCheckInLocation;
  String? get currentCheckInAddress => _currentCheckInAddress;
  List<LatLng> get currentRoutePoints => _currentRoutePoints;
  List<AddressCheckpoint> get currentAddressCheckpoints =>
      _currentAddressCheckpoints;
  LatLng? get currentLocation => _locationService.currentLocation;
  bool get isInitialized => _isInitialized;
  String? get currentUserId => _currentUserId;
  bool get isApiConnected => _isApiConnected;
  String? get lastApiSyncTime => _lastApiSyncTime;
  int get failedApiCallsCount => _failedApiCallsCount;

  // Constants
  static const double minDistanceMeters = 100.0;
  static const double minPointDistance = 20.0;

  final adminDateController = TextEditingController();

  // ✅ API Status methods
  void updateApiStatus({bool? isConnected, String? lastSyncTime}) {
    if (isConnected != null) _isApiConnected = isConnected;
    if (lastSyncTime != null) _lastApiSyncTime = lastSyncTime;
    notifyListeners();
  }

  void incrementFailedApiCalls() {
    _failedApiCallsCount++;
    notifyListeners();
  }

  void resetFailedApiCalls() {
    _failedApiCallsCount = 0;
    notifyListeners();
  }

  // ✅ Load user info from SharedPreferences
  // ✅ Load user info from SharedPreferences
  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _currentUserId =
          prefs.getString('logged_in_emp_id') ??
          prefs.getString('employeeId') ??
          prefs.getString('user_id');

      _roleId = prefs.getString('role_id') ?? '1';
      _username =
          prefs.getString('username') ?? prefs.getString('emp_name') ?? 'User';
      _email =
          prefs.getString('email') ??
          prefs.getString('emp_email') ??
          'user@example.com';
      _fullname =
          prefs.getString('fullname') ??
          prefs.getString('emp_fullname') ??
          _username;
      _avatar =
          prefs.getString('avatar') ?? prefs.getString('profile_pic') ?? '';
      _designationsId =
          prefs.getString('designation_id') ??
          prefs.getString('designations_id') ??
          '1';

      // ✅ FIX: Ensure zone_id and branch_id are not null
      _zoneId = prefs.getString('zone_id') ?? 'DEFAULT_ZONE';
      _branchId = prefs.getString('branch_id') ?? 'DEFAULT_BRANCH';

      if (kDebugMode) {
        print('✅ User info loaded:');
        print('   User ID: $_currentUserId');
        print('   Username: $_username');
        print('   Email: $_email');
        print('   Role ID: $_roleId');
        print('   Zone ID: $_zoneId');
        print('   Branch ID: $_branchId');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error loading user info: $e');
    }
  }

  // ✅ Manual sync with API
  Future<void> manualSyncWithApi() async {
    if (_currentUserId == null) {
      throw Exception('User ID not found. Please login again.');
    }

    try {
      if (kDebugMode) print('🔄 Starting manual API sync...');

      // Sync route points if checked in
      if (_isCheckedIn && _currentRoutePoints.isNotEmpty) {
        final locations =
            _currentRoutePoints.asMap().entries.map((entry) {
              return {
                'activity_type': 'ROUTE_POINT',
                'latitude': entry.value.latitude,
                'longitude': entry.value.longitude,
                'accuracy': 10.0,
                'location_address': 'Tracking point ${entry.key + 1}',
                'remarks': 'Synced manually',
              };
            }).toList();

        final result = await TrackingApiService.saveBatchLocations(
          userId: _currentUserId!,
          roleId: _roleId ?? '1',
          username: _username ?? 'User',
          email: _email ?? 'user@example.com',
          fullname: _fullname ?? _username ?? 'User',
          avatar: _avatar ?? '',
          designationsId: _designationsId ?? '1',
          locations: locations,
          zoneId: _zoneId,
          branchId: _branchId,
        );

        if (kDebugMode) {
          print('✅ Batch sync result:');
          print('   Success: ${result['successCount']}');
          print('   Failed: ${result['failCount']}');
        }
      }

      _lastApiSyncTime = DateTime.now().toIso8601String();
      _isApiConnected = true;
      _failedApiCallsCount = 0;
      notifyListeners();

      if (kDebugMode) print('✅ Manual API sync successful');
    } catch (e) {
      _failedApiCallsCount++;
      _isApiConnected = false;
      notifyListeners();
      if (kDebugMode) print('❌ Manual API sync failed: $e');
      rethrow;
    }
  }

  // Initialize
  Future<void> initialize() async {
    try {
      await _backgroundService.initializeService();
      await _loadUserInfo(); // ✅ Load user info first

      final prefs = await SharedPreferences.getInstance();
      final empId = _currentUserId;

      // Check if user has changed and clear old data
      final previousUserId = _currentUserId;
      if (previousUserId != null && previousUserId != empId && empId != null) {
        if (kDebugMode) {
          print('🔄 USER CHANGE DETECTED: $previousUserId → $empId');
          print('🧹 Clearing all data for previous user: $previousUserId');
        }
        await _clearUserData();
        _trackingRecords.clear();
        _currentUserId = null;
        await _loadUserInfo(); // Reload user info
      }

      if (kDebugMode) {
        print('🔄 UserTrackingProvider.initialize() called');
        print('   Current user ID: $_currentUserId');
      }

      await _forceLoadFromStorage();

      bool success = await _locationService.initLocationService();

      if (success) {
        _setupLocationCallbacks();
        _startSyncTimer();
        _startApiSyncTimer(); // ✅ NEW: Start periodic API sync
      }

      if (_isCheckedIn) {
        await _syncWithBackgroundServiceData();
        if (kDebugMode) print('🔄 Synced with background service on init');
      }

      // ✅ Check API connection on init
      _checkApiConnection();

      _isInitialized = true;
      notifyListeners();

      if (kDebugMode) print('✅ Provider initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Provider initialization error: $e');
    }
  }

  // ✅ NEW: Check API connection
  Future<void> _checkApiConnection() async {
    try {
      final isConnected = await TrackingApiService.testConnection();
      _isApiConnected = isConnected;
      notifyListeners();

      if (kDebugMode) {
        print(isConnected ? '✅ API connected' : '❌ API not reachable');
      }
    } catch (e) {
      _isApiConnected = false;
      notifyListeners();
      if (kDebugMode) print('❌ API connection check failed: $e');
    }
  }

  // ✅ NEW: Start periodic API sync (every 5 minutes)
  void _startApiSyncTimer() {
    _apiSyncTimer?.cancel();
    _apiSyncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_isCheckedIn && _currentRoutePoints.isNotEmpty) {
        try {
          if (kDebugMode) print('🔄 Periodic API sync triggered...');

          // Get current location
          final currentPos = await _locationService.getLocationOnce();
          if (currentPos != null) {
            await _sendLocationToApi(
              location: currentPos,
              activityType: 'ROUTE_POINT',
              address: _locationService.lastFetchedAddress ?? 'Unknown',
            );
          }

          _lastApiSyncTime = DateTime.now().toIso8601String();
          _isApiConnected = true;
          notifyListeners();
        } catch (e) {
          if (kDebugMode) print('❌ Periodic API sync failed: $e');
          _failedApiCallsCount++;
          _isApiConnected = false;
          notifyListeners();
        }
      }
    });
  }

  // ✅ NEW: Send location to API
  Future<void> _sendLocationToApi({
    required LatLng location,
    required String activityType,
    required String address,
    String? remarks,
  }) async {
    if (_currentUserId == null) {
      if (kDebugMode) print('⚠️ Cannot send to API: User ID is null');
      return;
    }

    try {
      if (kDebugMode) {
        print('📤 Sending to API:');
        print('   Activity: $activityType');
        print('   Location: ${location.latitude}, ${location.longitude}');
        print('   Address: $address');
      }

      final model = await TrackingApiService.saveLocation(
        userId: _currentUserId!,
        roleId: _roleId ?? '1',
        username: _username ?? 'User',
        email: _email ?? 'user@example.com',
        fullname: _fullname ?? _username ?? 'User',
        avatar: _avatar ?? '',
        designationsId: _designationsId ?? '1',
        activityType: activityType,
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: await _locationService.getCurrentAccuracy() ?? 10.0,
        locationAddress: address,
        zoneId: _zoneId,
        branchId: _branchId,
        remarks: remarks,
      );

      if (model.status == 'success' || model.status == 'created') {
        _lastApiSyncTime = DateTime.now().toIso8601String();
        _isApiConnected = true;
        _failedApiCallsCount = 0;

        if (kDebugMode) {
          print('✅ API Success:');
          print('   Tracking ID: ${model.data?.trackingId}');
          print('   Saved at: ${model.data?.savedAt}');
        }
      } else {
        throw Exception('API returned status: ${model.status}');
      }

      notifyListeners();
    } catch (e) {
      _failedApiCallsCount++;
      _isApiConnected = false;
      notifyListeners();

      if (kDebugMode) print('❌ API call failed: $e');
      rethrow;
    }
  }

  Future<void> _forceLoadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_currentUserId == null) {
        _currentUserId =
            prefs.getString('employeeId') ??
            prefs.getString('logged_in_emp_id');
      }

      if (_currentUserId == null) {
        if (kDebugMode) print('⚠️ No user ID found, cannot load data');
        return;
      }

      final providerCheckedIn =
          prefs.getBool(_getKey('is_checked_in')) ?? false;
      final bgServiceCheckedIn =
          prefs.getBool('is_checked_in_$_currentUserId') ?? false;
      _isCheckedIn = providerCheckedIn || bgServiceCheckedIn;

      _currentCheckInTime = prefs.getString(_getKey('check_in_time'));
      if (_currentCheckInTime?.isEmpty ?? true) _currentCheckInTime = null;

      _currentCheckInAddress = prefs.getString(_getKey('check_in_address'));
      if (_currentCheckInAddress?.isEmpty ?? true)
        _currentCheckInAddress = null;

      final lat = prefs.getDouble(_getKey('check_in_lat'));
      final lng = prefs.getDouble(_getKey('check_in_lng'));
      if (lat != null && lng != null) {
        _currentCheckInLocation = LatLng(lat, lng);
      } else {
        _currentCheckInLocation = null;
      }

      await _loadRoutePointsFromStorage(prefs);
      await _loadCheckpointsFromStorage(prefs);

      final recordsJson = prefs.getString(_getKey('tracking_records'));
      if (recordsJson != null && recordsJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(recordsJson);
          _trackingRecords =
              decoded
                  .map((item) => UserTrackingRecordModel.fromJson(item))
                  .toList();
        } catch (e) {
          if (kDebugMode) print('⚠️ Error decoding records: $e');
          _trackingRecords = [];
        }
      }

      if (kDebugMode) {
        print('✅ Force loaded data for user: $_currentUserId');
        print('   - Route points: ${_currentRoutePoints.length}');
        print('   - Checkpoints: ${_currentAddressCheckpoints.length}');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error force loading data: $e');
    }
  }

  Future<void> _loadRoutePointsFromStorage(SharedPreferences prefs) async {
    List<LatLng> providerPoints = [];
    List<LatLng> bgPoints = [];

    String? providerRouteJson = prefs.getString(_getKey('route_points'));
    if (providerRouteJson != null && providerRouteJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(providerRouteJson);
        providerPoints =
            decoded
                .map(
                  (point) => LatLng(
                    (point['lat'] as num).toDouble(),
                    (point['lng'] as num).toDouble(),
                  ),
                )
                .toList();
      } catch (e) {
        if (kDebugMode) print('⚠️ Error decoding provider route points: $e');
      }
    }

    String? bgRouteJson = prefs.getString('route_points_$_currentUserId');
    if (bgRouteJson != null && bgRouteJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(bgRouteJson);
        bgPoints =
            decoded
                .map(
                  (point) => LatLng(
                    (point['lat'] as num).toDouble(),
                    (point['lng'] as num).toDouble(),
                  ),
                )
                .toList();
      } catch (e) {
        if (kDebugMode) print('⚠️ Error decoding BG route points: $e');
      }
    }

    _currentRoutePoints = bgPoints.isNotEmpty ? bgPoints : providerPoints;
  }

  Future<void> _loadCheckpointsFromStorage(SharedPreferences prefs) async {
    String? checkpointsJson = prefs.getString(_getKey('address_checkpoints'));

    if (checkpointsJson == null || checkpointsJson.isEmpty) {
      checkpointsJson = prefs.getString('address_checkpoints_$_currentUserId');
    }

    if (checkpointsJson != null && checkpointsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(checkpointsJson);
        _currentAddressCheckpoints =
            decoded
                .map(
                  (item) => AddressCheckpoint(
                    location: LatLng(
                      (item['latitude'] as num).toDouble(),
                      (item['longitude'] as num).toDouble(),
                    ),
                    address: item['address'] ?? 'Unknown',
                    timestamp:
                        DateTime.tryParse(item['timestamp'] ?? '') ??
                        DateTime.now(),
                    distanceFromPrevious:
                        (item['distanceFromPrevious'] as num?)?.toDouble() ??
                        0.0,
                    pointIndex: (item['pointIndex'] as int?) ?? 0,
                  ),
                )
                .toList();
      } catch (e) {
        if (kDebugMode) print('⚠️ Error decoding checkpoints: $e');
      }
    }
  }

  Future<void> _syncWithBackgroundServiceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUserId == null) return;

      final bgRouteJson = prefs.getString('route_points_$_currentUserId');
      if (bgRouteJson != null && bgRouteJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(bgRouteJson);
          final bgPoints =
              decoded
                  .map(
                    (point) => LatLng(
                      (point['lat'] as num).toDouble(),
                      (point['lng'] as num).toDouble(),
                    ),
                  )
                  .toList();

          if (bgPoints.length > _currentRoutePoints.length) {
            _currentRoutePoints = bgPoints;
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ Error syncing BG route: $e');
        }
      }

      await _saveData();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error syncing with BG service: $e');
    }
  }

  Future<void> onAppResumed() async {
    if (kDebugMode) print('📱 App resumed - syncing data...');
    await _loadUserInfo(); // Reload user info
    await _forceLoadFromStorage();
    if (_isCheckedIn) await _syncWithBackgroundServiceData();
    await _checkApiConnection(); // Check API connection
    notifyListeners();
  }

  void _setupLocationCallbacks() {
    _locationService.onLocationUpdate =
        (LatLng location) => _addLocationPoint(location);
    _locationService.onAddressChange =
        (LatLng location, String address) =>
            _addAddressCheckpoint(location, address);
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isCheckedIn) syncWithBackground();
    });
  }

  Future<void> setUserId(String? userId) async {
    if (_currentUserId != userId) {
      _trackingRecords.clear();
      _isCheckedIn = false;
      _currentCheckInTime = null;
      _currentCheckInLocation = null;
      _currentCheckInAddress = null;
      _currentRoutePoints.clear();
      _currentAddressCheckpoints.clear();
      _currentUserId = userId;
      await _loadUserInfo();
      await _loadData();
      notifyListeners();
    }
  }

  // ✅ UPDATED: Check-in with API integration
  Future<bool> performCheckIn() async {
    if (_isCheckedIn) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Get location
      LatLng? location = await _locationService.getLocationOnce();
      if (location == null) throw Exception('Could not fetch location');

      // Get address
      String address = await _locationService.getAddressFromLocation(location);
      final time = DateFormat('hh:mm a').format(DateTime.now());

      // ✅ Send CHECK_IN to API
      await _sendLocationToApi(
        location: location,
        activityType: 'CHECK_IN',
        address: address,
        remarks: 'Check-in at $time',
      );

      // Update local state
      _checkIn(time, location, address);
      await _backgroundService.startTracking();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) print('❌ Check-in error: $e');
      rethrow;
    }
  }

  void _checkIn(String time, LatLng location, String address) {
    _isCheckedIn = true;
    _currentCheckInTime = time;
    _currentCheckInLocation = location;
    _currentCheckInAddress = address;
    _currentRoutePoints = [location];
    _currentAddressCheckpoints = [
      AddressCheckpoint(
        location: location,
        address: address,
        timestamp: DateTime.now(),
        pointIndex: 0,
      ),
    ];
    _saveData();
    notifyListeners();
  }

  // ✅ UPDATED: Check-out with API integration
  Future<bool> performCheckOut() async {
    if (!_isCheckedIn) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _backgroundService.stopTracking();
      await syncWithBackground();

      // Get location
      LatLng? location = await _locationService.getLocationOnce();
      if (location == null) throw Exception('Could not fetch location');

      _addLocationPoint(location);
      String checkOutAddress = await _locationService.getAddressFromLocation(
        location,
      );
      await _addAddressCheckpoint(location, checkOutAddress);

      // ✅ Send CHECK_OUT to API
      await _sendLocationToApi(
        location: location,
        activityType: 'CHECK_OUT',
        address: checkOutAddress,
        remarks: 'Check-out at ${DateFormat('hh:mm a').format(DateTime.now())}',
      );

      final now = DateTime.now();
      final newRecord = UserTrackingRecordModel(
        id: now.millisecondsSinceEpoch.toString(),
        date: DateFormat('dd/MM/yyyy').format(now),
        checkInTime: _currentCheckInTime ?? 'N/A',
        checkOutTime: DateFormat('hh:mm a').format(now),
        checkInLocation: _currentCheckInLocation ?? location,
        checkOutLocation: location,
        checkInAddress: _currentCheckInAddress ?? 'Address not available',
        checkOutAddress: checkOutAddress,
        status: 'checked_out',
        routePoints: List<LatLng>.from(_currentRoutePoints),
        addressCheckpoints: List<AddressCheckpoint>.from(
          _currentAddressCheckpoints,
        ),
      );

      _addRecord(newRecord);
      _checkOut();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) print('❌ Check-out error: $e');
      rethrow;
    }
  }

  void _checkOut() {
    _isCheckedIn = false;
    _currentCheckInTime = null;
    _currentCheckInLocation = null;
    _currentCheckInAddress = null;
    _currentRoutePoints.clear();
    _currentAddressCheckpoints.clear();
    _saveData();
    notifyListeners();
  }

  // ✅ UPDATED: Add location point with API integration
  void _addLocationPoint(LatLng location) async {
    if (!_isCheckedIn) return;

    if (_currentRoutePoints.isNotEmpty) {
      final lastPoint = _currentRoutePoints.last;
      final distance = Geolocator.distanceBetween(
        lastPoint.latitude,
        lastPoint.longitude,
        location.latitude,
        location.longitude,
      );
      if (distance < minPointDistance) return;
    }

    _currentRoutePoints.add(location);
    _saveData();
    notifyListeners();

    // ✅ Send ROUTE_POINT to API every 10 points
    if (_currentRoutePoints.length % 10 == 0) {
      try {
        final address = _locationService.lastFetchedAddress ?? 'Unknown';
        await _sendLocationToApi(
          location: location,
          activityType: 'ROUTE_POINT',
          address: address,
          remarks: 'Route tracking point ${_currentRoutePoints.length}',
        );
      } catch (e) {
        if (kDebugMode) print('⚠️ Failed to send route point to API: $e');
      }
    }
  }

  Future<void> _addAddressCheckpoint(LatLng location, String address) async {
    if (!_isCheckedIn || _currentAddressCheckpoints.isEmpty) return;

    final lastCheckpoint = _currentAddressCheckpoints.last;
    final distance = Geolocator.distanceBetween(
      lastCheckpoint.location.latitude,
      lastCheckpoint.location.longitude,
      location.latitude,
      location.longitude,
    );

    if (distance >= minDistanceMeters && address != lastCheckpoint.address) {
      _currentAddressCheckpoints.add(
        AddressCheckpoint(
          location: location,
          address: address,
          timestamp: DateTime.now(),
          distanceFromPrevious: distance,
          pointIndex: _currentRoutePoints.length - 1,
        ),
      );
      _saveData();
      notifyListeners();

      // ✅ Send checkpoint to API
      try {
        await _sendLocationToApi(
          location: location,
          activityType: 'ROUTE_POINT',
          address: address,
          remarks: 'Address checkpoint: $address',
        );
      } catch (e) {
        if (kDebugMode) print('⚠️ Failed to send checkpoint to API: $e');
      }
    }
  }

  void _addRecord(UserTrackingRecordModel record) {
    _trackingRecords.insert(0, record);
    _saveData();
    notifyListeners();
  }

  double getTotalDistance() {
    if (_currentRoutePoints.length < 2) return 0.0;
    double totalDistance = 0.0;
    for (int i = 1; i < _currentRoutePoints.length; i++) {
      totalDistance += Geolocator.distanceBetween(
        _currentRoutePoints[i - 1].latitude,
        _currentRoutePoints[i - 1].longitude,
        _currentRoutePoints[i].latitude,
        _currentRoutePoints[i].longitude,
      );
    }
    return totalDistance;
  }

  Future<void> syncWithBackground() async {
    if (_isCheckedIn && _isInitialized) {
      await _syncWithBackgroundServiceData();
      notifyListeners();
    }
  }

  String _getKey(String key) =>
      _currentUserId != null ? '${key}_$_currentUserId' : key;

  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _trackingRecords.clear();
      _isCheckedIn = false;
      _currentCheckInTime = null;
      _currentCheckInLocation = null;
      _currentCheckInAddress = null;
      _currentRoutePoints.clear();
      _currentAddressCheckpoints.clear();
      _isInitialized = false;

      if (_currentUserId != null) {
        await prefs.remove(_getKey('tracking_records'));
        await prefs.remove(_getKey('is_checked_in'));
        await prefs.remove(_getKey('check_in_time'));
        await prefs.remove(_getKey('check_in_address'));
        await prefs.remove(_getKey('check_in_lat'));
        await prefs.remove(_getKey('check_in_lng'));
        await prefs.remove(_getKey('route_points'));
        await prefs.remove(_getKey('address_checkpoints'));
        await prefs.remove('is_checked_in_$_currentUserId');
        await prefs.remove('route_points_$_currentUserId');
        await prefs.remove('address_checkpoints_$_currentUserId');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error clearing user data: $e');
    }
  }

  Future<void> _loadData() async => await _forceLoadFromStorage();

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUserId == null) return;

      final recordsJson = json.encode(
        _trackingRecords.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_getKey('tracking_records'), recordsJson);
      await prefs.setBool(_getKey('is_checked_in'), _isCheckedIn);
      await prefs.setBool('is_checked_in_$_currentUserId', _isCheckedIn);
      await prefs.setString(
        _getKey('check_in_time'),
        _currentCheckInTime ?? '',
      );
      await prefs.setString(
        _getKey('check_in_address'),
        _currentCheckInAddress ?? '',
      );

      if (_currentCheckInLocation != null) {
        await prefs.setDouble(
          _getKey('check_in_lat'),
          _currentCheckInLocation!.latitude,
        );
        await prefs.setDouble(
          _getKey('check_in_lng'),
          _currentCheckInLocation!.longitude,
        );
      }

      final routeJson = json.encode(
        _currentRoutePoints
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
      );
      await prefs.setString(_getKey('route_points'), routeJson);
      await prefs.setString('route_points_$_currentUserId', routeJson);

      final checkpointsJson = json.encode(
        _currentAddressCheckpoints
            .map(
              (c) => {
                'latitude': c.location.latitude,
                'longitude': c.location.longitude,
                'address': c.address,
                'timestamp': c.timestamp.toIso8601String(),
                'distanceFromPrevious': c.distanceFromPrevious,
                'pointIndex': c.pointIndex,
              },
            )
            .toList(),
      );
      await prefs.setString(_getKey('address_checkpoints'), checkpointsJson);
      await prefs.setString(
        'address_checkpoints_$_currentUserId',
        checkpointsJson,
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error saving: $e');
    }
  }

  Future<void> clearCurrentUserData({bool clearHistory = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getKey('is_checked_in'));
      await prefs.remove(_getKey('check_in_time'));
      await prefs.remove(_getKey('check_in_lat'));
      await prefs.remove(_getKey('check_in_lng'));
      await prefs.remove(_getKey('check_in_address'));
      await prefs.remove(_getKey('route_points'));
      await prefs.remove(_getKey('address_checkpoints'));

      if (clearHistory) {
        await prefs.remove(_getKey('tracking_records'));
        _trackingRecords.clear();
      }

      _isCheckedIn = false;
      _currentCheckInTime = null;
      _currentCheckInLocation = null;
      _currentCheckInAddress = null;
      _currentRoutePoints.clear();
      _currentAddressCheckpoints.clear();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error clearing: $e');
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _apiSyncTimer?.cancel(); // ✅ NEW
    _locationService.dispose();
    adminDateController.dispose();
    super.dispose();
  }
}
