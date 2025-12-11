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
  bool _isSearching = false;
  bool _isInitialized = false;


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

  // Constants
  static const double minDistanceMeters = 100.0;
  static const double minPointDistance = 20.0;


  // Initialize
  Future<void> initialize() async {
    try {
      await _backgroundService.initializeService();

      final prefs = await SharedPreferences.getInstance();
      final empId =
          prefs.getString('logged_in_emp_id') ?? prefs.getString('employeeId');

      // ✅ CRITICAL: Check if user has changed and clear old data
      final previousUserId = _currentUserId;
      if (previousUserId != null && previousUserId != empId && empId != null) {
        if (kDebugMode) {
          print('🔄 USER CHANGE DETECTED: $previousUserId → $empId');
          print('🧹 Clearing all data for previous user: $previousUserId');
        }
        // Clear ALL data for the old user
        await _clearUserData();
        _trackingRecords.clear();
        _currentUserId = null; // Reset to force reload
      }

      // ✅ Set user ID
      _currentUserId = empId;

      if (kDebugMode) {
        print('🔄 UserTrackingProvider.initialize() called');
        print('   Previous user ID: $previousUserId');
        print('   Current user ID from prefs: $empId');
        print('   Final user ID: $_currentUserId');
      }

      // ✅ Force load all persisted data from SharedPreferences
      await _forceLoadFromStorage();

      bool success = await _locationService.initLocationService();

      if (success) {
        _setupLocationCallbacks();
        _startSyncTimer();
      }

      // ✅ If user was checked in, ensure we sync with background service data
      if (_isCheckedIn) {
        await _syncWithBackgroundServiceData();
        if (kDebugMode) print('🔄 Synced with background service on init');
      }

      _isInitialized = true;
      notifyListeners();

      if (kDebugMode) print('✅ Provider initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Provider initialization error: $e');
    }
  }
  
  // ✅ NEW: Force load all data from SharedPreferences
  Future<void> _forceLoadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_currentUserId == null) {
        _currentUserId = prefs.getString('employeeId') ?? 
                         prefs.getString('logged_in_emp_id');
      }

      if (_currentUserId == null) {
        if (kDebugMode) print('⚠️ No user ID found, cannot load data');
        return;
      }

      // ✅ DEBUG: Check what data exists in SharedPreferences
      if (kDebugMode) {
        print('🔍 Checking stored data for user: $_currentUserId');
        final allKeys = prefs.getKeys();
        final userKeys = allKeys.where((key) => key.contains(_currentUserId!)).toList();
        print('   Found ${userKeys.length} user-specific keys: $userKeys');

        // Check specific keys
        final routeKey = 'route_points_$_currentUserId';
        final hasRouteData = prefs.containsKey(routeKey);
        final routeDataLength = prefs.getString(routeKey)?.length ?? 0;
        print('   Background route data exists: $hasRouteData (length: $routeDataLength)');
      }

      // ✅ Load check-in state - check both provider key and background service key
      final providerCheckedIn = prefs.getBool(_getKey('is_checked_in')) ?? false;
      final bgServiceCheckedIn = prefs.getBool('is_checked_in_$_currentUserId') ?? false;
      _isCheckedIn = providerCheckedIn || bgServiceCheckedIn;

      if (kDebugMode) {
        print('📊 Check-in state: provider=$providerCheckedIn, bg=$bgServiceCheckedIn');
      }

      // ✅ Load check-in time
      _currentCheckInTime = prefs.getString(_getKey('check_in_time'));
      if (_currentCheckInTime?.isEmpty ?? true) {
        _currentCheckInTime = null;
      }

      // ✅ Load check-in address
      _currentCheckInAddress = prefs.getString(_getKey('check_in_address'));
      if (_currentCheckInAddress?.isEmpty ?? true) {
        _currentCheckInAddress = null;
      }

      // ✅ Load check-in location
      final lat = prefs.getDouble(_getKey('check_in_lat'));
      final lng = prefs.getDouble(_getKey('check_in_lng'));
      if (lat != null && lng != null) {
        _currentCheckInLocation = LatLng(lat, lng);
      } else {
        _currentCheckInLocation = null;
      }

      // ✅ Load route points - try both provider key and background service key
      await _loadRoutePointsFromStorage(prefs);

      // ✅ Load address checkpoints - try both keys
      await _loadCheckpointsFromStorage(prefs);

      // ✅ Load tracking records
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
        print('   - Checked in: $_isCheckedIn');
        print('   - Check-in time: $_currentCheckInTime');
        print('   - Route points: ${_currentRoutePoints.length}');
        print('   - Checkpoints: ${_currentAddressCheckpoints.length}');
        print('   - Records: ${_trackingRecords.length}');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error force loading data: $e');
    }
  }

  // ✅ FIXED: Load route points from both provider and background service keys
  Future<void> _loadRoutePointsFromStorage(SharedPreferences prefs) async {
    List<LatLng> providerPoints = [];
    List<LatLng> bgPoints = [];

    // Try provider key (main app saves without timestamp)
    String? providerRouteJson = prefs.getString(_getKey('route_points'));
    if (providerRouteJson != null && providerRouteJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(providerRouteJson);
        providerPoints = decoded.map((point) {
          return LatLng(
            (point['lat'] as num).toDouble(),
            (point['lng'] as num).toDouble(),
          );
        }).toList();
        if (kDebugMode) print('✅ Loaded ${providerPoints.length} provider route points');
      } catch (e) {
        if (kDebugMode) print('⚠️ Error decoding provider route points: $e');
      }
    }

    // Try background service key (background service saves WITH timestamp)
    String? bgRouteJson = prefs.getString('route_points_$_currentUserId');
    if (bgRouteJson != null && bgRouteJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(bgRouteJson);
        bgPoints = decoded.map((point) {
          // ✅ CRITICAL FIX: Handle both formats (with/without timestamp)
          // Background service adds timestamp, but we only need lat/lng
          return LatLng(
            (point['lat'] as num).toDouble(),
            (point['lng'] as num).toDouble(),
          );
        }).toList();
        if (kDebugMode) print('✅ Loaded ${bgPoints.length} background route points');
      } catch (e) {
        if (kDebugMode) print('⚠️ Error decoding BG route points: $e');
        // Try alternative format if standard parsing fails
        try {
          final List<dynamic> decoded = json.decode(bgRouteJson);
          if (decoded.isNotEmpty && decoded.first is Map) {
            bgPoints = decoded.map((point) => LatLng(
              (point['latitude'] ?? point['lat'] as num).toDouble(),
              (point['longitude'] ?? point['lng'] as num).toDouble(),
            )).toList();
            if (kDebugMode) print('✅ Loaded ${bgPoints.length} BG points (alt format)');
          }
        } catch (e2) {
          if (kDebugMode) print('⚠️ Error decoding BG route points (alt): $e2');
        }
      }
    }

    // ✅ CRITICAL FIX: Always prefer background service data if it exists and has points
    // Background service data is more complete as it collects while app is closed
    if (bgPoints.isNotEmpty) {
      _currentRoutePoints = bgPoints;
      if (kDebugMode) print('📍 Using ${bgPoints.length} background service points (most complete)');
    } else if (providerPoints.isNotEmpty) {
      _currentRoutePoints = providerPoints;
      if (kDebugMode) print('📍 Using ${providerPoints.length} provider points (fallback)');
    } else {
      _currentRoutePoints = [];
      if (kDebugMode) print('📍 No route points found in storage');
    }

    if (kDebugMode) {
      print('📊 Route points summary:');
      print('   Provider: ${providerPoints.length}, Background: ${bgPoints.length}');
      print('   Final: ${_currentRoutePoints.length} points');
    }
  }

  // ✅ NEW: Load checkpoints from both provider and background service keys  
  Future<void> _loadCheckpointsFromStorage(SharedPreferences prefs) async {
    List<AddressCheckpoint> checkpoints = [];

    // Try provider key first
    String? checkpointsJson = prefs.getString(_getKey('address_checkpoints'));
    
    // If empty, try background service key
    if (checkpointsJson == null || checkpointsJson.isEmpty) {
      checkpointsJson = prefs.getString('address_checkpoints_$_currentUserId');
    }

    if (checkpointsJson != null && checkpointsJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(checkpointsJson);
        checkpoints = decoded.map((item) {
          return AddressCheckpoint(
            location: LatLng(
              (item['latitude'] as num).toDouble(),
              (item['longitude'] as num).toDouble(),
            ),
            address: item['address'] ?? 'Unknown',
            timestamp: DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
            distanceFromPrevious: (item['distanceFromPrevious'] as num?)?.toDouble() ?? 0.0,
            pointIndex: (item['pointIndex'] as int?) ?? 0,
          );
        }).toList();
        
        if (kDebugMode) print('🏠 Loaded ${checkpoints.length} checkpoints');
      } catch (e) {
        if (kDebugMode) print('⚠️ Error decoding checkpoints: $e');
      }
    }

    _currentAddressCheckpoints = checkpoints;
  }

  // ✅ NEW: Sync specifically with background service saved data
  Future<void> _syncWithBackgroundServiceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_currentUserId == null) return;

      // ✅ Get route points from background service key
      final bgRouteJson = prefs.getString('route_points_$_currentUserId');
      if (bgRouteJson != null && bgRouteJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(bgRouteJson);
          final bgPoints = decoded.map((point) {
            return LatLng(
              (point['lat'] as num).toDouble(),
              (point['lng'] as num).toDouble(),
            );
          }).toList();

          // ✅ Merge: use the one with more points
          if (bgPoints.length > _currentRoutePoints.length) {
            _currentRoutePoints = bgPoints;
            if (kDebugMode) {
              print('🔄 Updated route points from BG service: ${bgPoints.length} points');
            }
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ Error syncing BG route: $e');
        }
      }

      // ✅ Get checkpoints from background service key
      final bgCheckpointsJson = prefs.getString('address_checkpoints_$_currentUserId');
      if (bgCheckpointsJson != null && bgCheckpointsJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(bgCheckpointsJson);
          final bgCheckpoints = decoded.map((item) {
            return AddressCheckpoint(
              location: LatLng(
                (item['latitude'] as num).toDouble(),
                (item['longitude'] as num).toDouble(),
              ),
              address: item['address'] ?? 'Unknown',
              timestamp: DateTime.tryParse(item['timestamp'] ?? '') ?? DateTime.now(),
              distanceFromPrevious: (item['distanceFromPrevious'] as num?)?.toDouble() ?? 0.0,
              pointIndex: _currentRoutePoints.length - 1,
            );
          }).toList();

          // ✅ Merge: use the one with more checkpoints
          if (bgCheckpoints.length > _currentAddressCheckpoints.length) {
            _currentAddressCheckpoints = bgCheckpoints;
            if (kDebugMode) {
              print('🔄 Updated checkpoints from BG service: ${bgCheckpoints.length} checkpoints');
            }
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ Error syncing BG checkpoints: $e');
        }
      }

      // ✅ Save merged data back to provider keys
      await _saveData();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error syncing with BG service: $e');
    }
  }

  // ✅ NEW: Called when app resumes from background
  Future<void> onAppResumed() async {
    if (kDebugMode) print('📱 App resumed - syncing data...');
    
    // Force reload from storage
    await _forceLoadFromStorage();
    
    // Sync with background service
    if (_isCheckedIn) {
      await _syncWithBackgroundServiceData();
    }
    
    notifyListeners();
  }

  //date controller

  final adminDateController = TextEditingController();




  void _setupLocationCallbacks() {
    _locationService.onLocationUpdate = (LatLng location) {
      _addLocationPoint(location);
    };

    _locationService.onAddressChange = (LatLng location, String address) {
      _addAddressCheckpoint(location, address);
    };
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isCheckedIn) {
        syncWithBackground();
      }
    });
  }

  Future<void> setUserId(String? userId) async {
    if (_currentUserId != userId) {
      if (kDebugMode) print('👤 Setting user ID: $userId');

      _trackingRecords.clear();
      _isCheckedIn = false;
      _currentCheckInTime = null;
      _currentCheckInLocation = null;
      _currentCheckInAddress = null;
      _currentRoutePoints.clear();
      _currentAddressCheckpoints.clear();
      _currentUserId = userId;

      await _loadData();
      notifyListeners();
    }
  }

  // Check In
  Future<bool> performCheckIn() async {
    if (_isCheckedIn) {
      if (kDebugMode) print('⚠️ Already checked in');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get location
      LatLng? location = await _locationService.getLocationOnce();
      if (location == null) {
        throw Exception('Could not fetch your current location');
      }

      // Get address
      String address = await _locationService.getAddressFromLocation(location);
      final now = DateTime.now();
      final formatter = DateFormat('hh:mm a');
      final time = formatter.format(now);

      // Save check-in data
      _checkIn(time, location, address);

      // ✅ Request battery optimization exemption (critical for background service)
      try {
        // Import needed: import '../../core/utils/battery_optimization_helper.dart';
        // Note: This is non-blocking, service will still start
        // BatteryOptimizationHelper.requestBatteryOptimizationExemption();
        if (kDebugMode) print('📱 Battery optimization check skipped (add helper if needed)');
      } catch (e) {
        if (kDebugMode) print('⚠️ Battery optimization check error: $e');
      }

      // Start background tracking
      await _backgroundService.startTracking();
      if (kDebugMode) print('🚀 Background tracking started');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) print('❌ Check-in failed: $e');
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

    if (kDebugMode) print('✅ Checked in at: $address');
    _saveData();
    notifyListeners();
  }

  // Check Out
  Future<bool> performCheckOut() async {
    if (!_isCheckedIn) {
      if (kDebugMode) print('⚠️ Not checked in');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Stop background tracking
      await _backgroundService.stopTracking();
      if (kDebugMode) print('🛑 Background tracking stopped');

      // Sync one last time
      await syncWithBackground();

      // Get final location
      LatLng? location = await _locationService.getLocationOnce();
      if (location == null) {
        throw Exception('Could not fetch your current location');
      }

      // Add final point
      _addLocationPoint(location);

      // Get checkout address
      String checkOutAddress = await _locationService.getAddressFromLocation(
        location,
      );
      await _addAddressCheckpoint(location, checkOutAddress);

      // Create record
      final now = DateTime.now();
      final formatter = DateFormat('hh:mm a');
      final dateFormatter = DateFormat('dd/MM/yyyy');
      final totalDistance = getTotalDistance();

      final newRecord = UserTrackingRecordModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: dateFormatter.format(now),
        checkInTime: _currentCheckInTime ?? 'N/A',
        checkOutTime: formatter.format(now),
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

      if (kDebugMode) {
        print('📊 Check-out Summary:');
        print('   - Total points: ${newRecord.routePoints?.length}');
        print('   - Checkpoints: ${newRecord.addressCheckpoints?.length}');
        print('   - Distance: ${(totalDistance / 1000).toStringAsFixed(2)} km');
      }

      _addRecord(newRecord);
      _checkOut();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) print('❌ Check-out failed: $e');
      rethrow;
    }
  }

  void _checkOut() {
    if (kDebugMode) {
      print('🔴 Checking out...');
      print('   Total points: ${_currentRoutePoints.length}');
      print('   Total checkpoints: ${_currentAddressCheckpoints.length}');
    }

    _isCheckedIn = false;
    _currentCheckInTime = null;
    _currentCheckInLocation = null;
    _currentCheckInAddress = null;
    _currentRoutePoints.clear();
    _currentAddressCheckpoints.clear();
    _saveData();
    notifyListeners();
  }

  void _addLocationPoint(LatLng location) {
    if (!_isCheckedIn) return;

    if (_currentRoutePoints.isNotEmpty) {
      final lastPoint = _currentRoutePoints.last;
      final distance = Geolocator.distanceBetween(
        lastPoint.latitude,
        lastPoint.longitude,
        location.latitude,
        location.longitude,
      );

      if (distance < minPointDistance) {
        if (kDebugMode) {
          print(
            '⏭️ Skipping point - only ${distance.toStringAsFixed(1)}m from last',
          );
        }
        return;
      }

      if (kDebugMode) {
        print(
          '📍 Point #${_currentRoutePoints.length + 1} added (${distance.toStringAsFixed(1)}m from last)',
        );
      }
    }

    _currentRoutePoints.add(location);
    _saveData();
    notifyListeners();
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

      if (kDebugMode) {
        print('🏠 Checkpoint #${_currentAddressCheckpoints.length}: $address');
        print('   Distance: ${distance.toStringAsFixed(1)}m from last');
      }
      _saveData();
      notifyListeners();
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
    // ✅ FIXED: Only sync if checked in AND initialized
    // This prevents unnecessary syncing when not checked in
    if (_isCheckedIn && _isInitialized) {
      await _syncWithBackgroundServiceData();
      notifyListeners();
    }
  }

  // Storage Methods
  String _getKey(String key) =>
      _currentUserId != null ? '${key}_$_currentUserId' : key;

  // ✅ Clear all user-specific data (both in-memory and SharedPreferences)
  Future<void> _clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear in-memory data
      _trackingRecords.clear();
      _isCheckedIn = false;
      _currentCheckInTime = null;
      _currentCheckInLocation = null;
      _currentCheckInAddress = null;
      _currentRoutePoints.clear();
      _currentAddressCheckpoints.clear();
      _isInitialized = false;

      // Clear SharedPreferences data for current user (if user ID exists)
      if (_currentUserId != null) {
        await prefs.remove(_getKey('tracking_records'));
        await prefs.remove(_getKey('is_checked_in'));
        await prefs.remove(_getKey('check_in_time'));
        await prefs.remove(_getKey('check_in_address'));
        await prefs.remove(_getKey('check_in_lat'));
        await prefs.remove(_getKey('check_in_lng'));
        await prefs.remove(_getKey('route_points'));
        await prefs.remove(_getKey('address_checkpoints'));

        // Also clear background service keys
        await prefs.remove('is_checked_in_$_currentUserId');
        await prefs.remove('route_points_$_currentUserId');
        await prefs.remove('address_checkpoints_$_currentUserId');
        await prefs.remove('service_should_run_$_currentUserId');
        await prefs.remove('last_tracking_update_$_currentUserId');
      }

      if (kDebugMode) {
        print('🧹 Cleared all data for user: $_currentUserId');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error clearing user data: $e');
    }
  }

  Future<void> _loadData() async {
    // ✅ Use the improved force load method
    await _forceLoadFromStorage();
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_currentUserId == null) {
        if (kDebugMode) print('⚠️ Cannot save - no user ID');
        return;
      }

      // Save tracking records
      final recordsJson = json.encode(
        _trackingRecords.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_getKey('tracking_records'), recordsJson);

      // ✅ Save check-in state to BOTH provider key AND background service key
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

      // Save check-in location
      if (_currentCheckInLocation != null) {
        await prefs.setDouble(
          _getKey('check_in_lat'),
          _currentCheckInLocation!.latitude,
        );
        await prefs.setDouble(
          _getKey('check_in_lng'),
          _currentCheckInLocation!.longitude,
        );
      } else {
        await prefs.remove(_getKey('check_in_lat'));
        await prefs.remove(_getKey('check_in_lng'));
      }

      // ✅ Save route points to BOTH provider key AND background service key
      final routeJson = json.encode(
        _currentRoutePoints
            .map((point) => {'lat': point.latitude, 'lng': point.longitude})
            .toList(),
      );
      await prefs.setString(_getKey('route_points'), routeJson);
      await prefs.setString('route_points_$_currentUserId', routeJson);

      // ✅ Save checkpoints to BOTH provider key AND background service key
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
      await prefs.setString('address_checkpoints_$_currentUserId', checkpointsJson);

      if (kDebugMode) {
        print('💾 Saved ${_currentRoutePoints.length} points for user $_currentUserId');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error saving: $e');
    }
  }

  Future<void> _refreshFromStorage() async {
    // ✅ Use the improved sync method
    await _syncWithBackgroundServiceData();
  }

  // Clear data
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

      if (kDebugMode) print('🧹 Cleared user data');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error clearing: $e');
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _locationService.dispose();
    super.dispose();
  }
}
