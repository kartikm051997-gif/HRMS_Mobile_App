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
      await setUserId(empId);

      bool success = await _locationService.initLocationService();

      if (success) {
        _setupLocationCallbacks();
        _startSyncTimer();
      }

      if (kDebugMode) print('✅ Provider initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Provider initialization error: $e');
    }
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
    if (_isCheckedIn) {
      await _refreshFromStorage();
    }
  }

  // Storage Methods
  String _getKey(String key) =>
      _currentUserId != null ? '${key}_$_currentUserId' : key;

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUserId =
          prefs.getString('employeeId') ?? prefs.getString('logged_in_emp_id');

      // Load tracking records
      final recordsJson = prefs.getString(_getKey('tracking_records'));
      if (recordsJson != null) {
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
      } else {
        _trackingRecords = [];
      }

      // Load check-in state
      _isCheckedIn = prefs.getBool(_getKey('is_checked_in')) ?? false;
      _currentCheckInTime = prefs.getString(_getKey('check_in_time'));
      _currentCheckInAddress = prefs.getString(_getKey('check_in_address'));

      // Load check-in location
      final lat = prefs.getDouble(_getKey('check_in_lat'));
      final lng = prefs.getDouble(_getKey('check_in_lng'));
      if (lat != null && lng != null) {
        _currentCheckInLocation = LatLng(lat, lng);
      } else {
        _currentCheckInLocation = null;
      }

      // Load route points
      final routeJson = prefs.getString(_getKey('route_points'));
      if (routeJson != null) {
        try {
          final List<dynamic> decoded = json.decode(routeJson);
          _currentRoutePoints =
              decoded
                  .map((point) => LatLng(point['lat'], point['lng']))
                  .toList();
        } catch (e) {
          if (kDebugMode) print('⚠️ Error decoding route: $e');
          _currentRoutePoints = [];
        }
      } else {
        _currentRoutePoints = [];
      }

      // Load checkpoints
      final checkpointsJson = prefs.getString(_getKey('address_checkpoints'));
      if (checkpointsJson != null) {
        try {
          final List<dynamic> decoded = json.decode(checkpointsJson);
          _currentAddressCheckpoints =
              decoded.map((item) {
                return AddressCheckpoint(
                  location: LatLng(item['latitude'], item['longitude']),
                  address: item['address'],
                  timestamp: DateTime.parse(item['timestamp']),
                  distanceFromPrevious:
                      (item['distanceFromPrevious'] ?? 0.0) as double,
                  pointIndex: _currentRoutePoints.length - 1,
                );
              }).toList();
        } catch (e) {
          if (kDebugMode) print('⚠️ Error decoding checkpoints: $e');
          _currentAddressCheckpoints = [];
        }
      } else {
        _currentAddressCheckpoints = [];
      }

      if (kDebugMode) {
        print('✅ Loaded data for user: $_currentUserId');
        print('   - Checked in: $_isCheckedIn');
        print('   - Route points: ${_currentRoutePoints.length}');
        print('   - Checkpoints: ${_currentAddressCheckpoints.length}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save tracking records
      final recordsJson = json.encode(
        _trackingRecords.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_getKey('tracking_records'), recordsJson);

      // Save check-in state
      await prefs.setBool(_getKey('is_checked_in'), _isCheckedIn);
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

      // Save route points
      final routeJson = json.encode(
        _currentRoutePoints
            .map((point) => {'lat': point.latitude, 'lng': point.longitude})
            .toList(),
      );
      await prefs.setString(_getKey('route_points'), routeJson);

      // Save checkpoints
      final checkpointsJson = json.encode(
        _currentAddressCheckpoints
            .map(
              (c) => {
                'latitude': c.location.latitude,
                'longitude': c.location.longitude,
                'address': c.address,
                'timestamp': c.timestamp.toIso8601String(),
                'distanceFromPrevious': c.distanceFromPrevious,
              },
            )
            .toList(),
      );
      await prefs.setString(_getKey('address_checkpoints'), checkpointsJson);

      if (kDebugMode) {
        print('💾 Saved ${_currentRoutePoints.length} points');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error saving: $e');
    }
  }

  Future<void> _refreshFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Refresh route points
      final routeJson = prefs.getString(_getKey('route_points'));
      if (routeJson != null) {
        try {
          final List<dynamic> decoded = json.decode(routeJson);
          final newPoints =
              decoded
                  .map((point) => LatLng(point['lat'], point['lng']))
                  .toList();

          if (newPoints.length != _currentRoutePoints.length) {
            _currentRoutePoints = newPoints;
            if (kDebugMode) {
              print('🔄 Synced ${newPoints.length} points from background');
            }
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ Error syncing route: $e');
        }
      }

      // Refresh checkpoints
      final checkpointsJson = prefs.getString(_getKey('address_checkpoints'));
      if (checkpointsJson != null) {
        try {
          final List<dynamic> decoded = json.decode(checkpointsJson);
          final newCheckpoints =
              decoded.map((item) {
                return AddressCheckpoint(
                  location: LatLng(item['latitude'], item['longitude']),
                  address: item['address'],
                  timestamp: DateTime.parse(item['timestamp']),
                  distanceFromPrevious:
                      (item['distanceFromPrevious'] ?? 0.0) as double,
                  pointIndex: _currentRoutePoints.length - 1,
                );
              }).toList();

          if (newCheckpoints.length != _currentAddressCheckpoints.length) {
            _currentAddressCheckpoints = newCheckpoints;
            if (kDebugMode) {
              print(
                '🔄 Synced ${newCheckpoints.length} checkpoints from background',
              );
            }
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ Error syncing checkpoints: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error refreshing: $e');
    }
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
