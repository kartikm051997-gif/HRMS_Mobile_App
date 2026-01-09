import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/appcolor_dart.dart';
import '../../../provider/UserTrackingProvider/UserTrackingProvider.dart';
import '../../../servicesAPI/UserTrackingService/UserTrackingService.dart';

class MapStyles {
  static const String modernTealStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#f5f5f5"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#b2dfdb"}]
  }
]
''';
}

class UserTrackingScreen extends StatefulWidget {
  const UserTrackingScreen({super.key});

  @override
  State<UserTrackingScreen> createState() => _UserTrackingScreenState();
}

class _UserTrackingScreenState extends State<UserTrackingScreen>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polyLines = {};
  bool _showFilter = true;
  bool _isDisposed = false;

  int _lastRoutePointsCount = 0;
  int _lastCheckpointsCount = 0;

  // ✅ NEW: API Status tracking
  bool _isApiConnected = false;
  String? _lastApiSyncTime;
  bool _isSyncing = false;
  Timer? _apiStatusTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    context.read<UserTrackingProvider>().addListener(_onProviderChanged);
    _startApiStatusCheck(); // ✅ NEW
  }

  void _onProviderChanged() {
    final provider = context.read<UserTrackingProvider>();

    if (provider.currentRoutePoints.length != _lastRoutePointsCount ||
        provider.currentAddressCheckpoints.length != _lastCheckpointsCount) {
      _lastRoutePointsCount = provider.currentRoutePoints.length;
      _lastCheckpointsCount = provider.currentAddressCheckpoints.length;

      if (mounted) {
        _updateMapMarkersWithRoute();
      }
    }

    // ✅ NEW: Update API status from provider
    if (!_isDisposed && mounted) {
      setState(() {
        _isApiConnected = provider.isApiConnected;
        _lastApiSyncTime = provider.lastApiSyncTime;
      });
    }

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (kDebugMode) print('📱 App state: $state');

    if (state == AppLifecycleState.resumed) {
      final provider = context.read<UserTrackingProvider>();

      provider.onAppResumed().then((_) {
        if (mounted) {
          _updateMapMarkersWithRoute();
          _checkApiStatus(); // ✅ NEW: Check API when app resumes
          if (kDebugMode) print('🔄 Synced from background on resume');
        }
      });
    }
  }

  // ✅ NEW: Start periodic API status check
  void _startApiStatusCheck() {
    _checkApiStatus();
    _apiStatusTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkApiStatus();
    });
  }

  // ✅ NEW: Check API connection status
  Future<void> _checkApiStatus() async {
    try {
      final isConnected = await TrackingApiService.testConnection();

      if (_isDisposed || !mounted) return;

      setState(() {
        _isApiConnected = isConnected;
      });
    } catch (e) {
      if (_isDisposed || !mounted) return;

      setState(() {
        _isApiConnected = false;
      });
    }
  }

  // ✅ NEW: Manual sync with API
  Future<void> _manualSyncWithApi() async {
    if (_isSyncing) return;

    if (!_isDisposed && mounted) {
      setState(() {
        _isSyncing = true;
      });
    }

    try {
      final provider = context.read<UserTrackingProvider>();
      await provider.manualSyncWithApi();

      if (!_isDisposed && mounted) {
        _showSnackBar(
          '✓ Synced successfully with server',
          backgroundColor: Colors.green,
        );
        _checkApiStatus();
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        _showSnackBar(
          'Sync failed: ${e.toString()}',
          backgroundColor: Colors.orange,
        );
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  // ✅ NEW: Format last sync time
  String _getLastSyncText() {
    if (_lastApiSyncTime == null) return 'Never synced';

    try {
      final syncTime = DateTime.parse(_lastApiSyncTime!);
      final diff = DateTime.now().difference(syncTime);

      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _initializeApp() async {
    final provider = context.read<UserTrackingProvider>();
    await provider.initialize();

    if (mounted) {
      _updateMapMarkersWithRoute();

      if (provider.isCheckedIn && provider.currentRoutePoints.isNotEmpty) {
        final lastPoint = provider.currentRoutePoints.last;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(lastPoint, 15),
        );
        if (kDebugMode) {
          print(
            '📍 Restored ${provider.currentRoutePoints.length} route points',
          );
        }
      }
    }
  }

  Future<void> _applyMapStyle(GoogleMapController controller) async {
    try {
      await controller.setMapStyle(MapStyles.modernTealStyle);
      if (kDebugMode) print('✅ Custom map style applied');
    } catch (e) {
      if (kDebugMode) print('❌ Error applying map style: $e');
    }
  }

  void _updateMapMarkersWithRoute() {
    final provider = context.read<UserTrackingProvider>();

    final newMarkers = <Marker>{};
    final newPolyLines = <Polyline>{};

    if (provider.isCheckedIn && provider.currentCheckInLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('check_in'),
          position: provider.currentCheckInLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: '🟢 Check In',
            snippet: provider.currentCheckInTime ?? '',
          ),
        ),
      );
    }

    if (provider.currentLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: provider.currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: '📍 Current Location'),
        ),
      );

      for (int i = 0; i < provider.currentAddressCheckpoints.length; i++) {
        final checkpoint = provider.currentAddressCheckpoints[i];
        newMarkers.add(
          Marker(
            markerId: MarkerId('checkpoint_$i'),
            position: checkpoint.location,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(
              title: '🏠 Stop ${i + 1}',
              snippet: checkpoint.address,
            ),
          ),
        );
      }

      if (provider.isCheckedIn && provider.currentRoutePoints.length >= 2) {
        newPolyLines.add(
          Polyline(
            polylineId: const PolylineId('tracking_route'),
            points: provider.currentRoutePoints,
            color: AppColor.primaryColor1,
            width: 5,
            geodesic: true,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        );
      }
    }

    if (_markers.length != newMarkers.length ||
        _polyLines.length != newPolyLines.length) {
      setState(() {
        _markers = newMarkers;
        _polyLines = newPolyLines;
      });
    }
  }

  Future<void> _handleCheckIn() async {
    final provider = context.read<UserTrackingProvider>();

    if (provider.isCheckedIn) {
      _showSnackBar('Already checked in', backgroundColor: Colors.orange);
      return;
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationRequiredDialog(
        title: 'Location Service Disabled',
        message: 'Please enable location services to check in',
        isServiceIssue: true,
      );
      return;
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationRequiredDialog(
          title: 'Location Permission Denied',
          message: 'Location permission is required',
          isServiceIssue: false,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationRequiredDialog(
        title: 'Location Permission Required',
        message: 'Please enable location from settings',
        isServiceIssue: false,
        showSettings: true,
      );
      return;
    }

    // ===================== FACE VERIFICATION COMMENTED =====================
    /*
  final hasVerified = await _hasFaceVerifiedToday();

  if (hasVerified) {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FaceIdentificationScreen(
          employeeId: 'EMP001',
          employeeName: 'John Doe',
          isCheckIn: true,
          displayOnly: true,
        ),
      ),
    );

    if (result == true && mounted) {
      await _performActualCheckIn();
    }
  } else {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FaceIdentificationScreen(
          employeeId: 'EMP001',
          employeeName: 'John Doe',
          isCheckIn: true,
          displayOnly: false,
        ),
      ),
    );

    if (result == true && mounted) {
      await _markFaceVerifiedToday();
      await _performActualCheckIn();
    }
  }
  */

    // ===================== DIRECT CHECK-IN WITHOUT FACE =====================
    await _performActualCheckIn();
  }

  Future<void> _performActualCheckIn() async {
    final provider = context.read<UserTrackingProvider>();

    try {
      final success = await provider.performCheckIn();

      if (success && mounted) {
        _updateMapMarkersWithRoute();

        if (provider.currentCheckInLocation != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(provider.currentCheckInLocation!, 15),
          );
        }

        // ✅ Check API status after check-in
        _checkApiStatus();

        // ✅ Enhanced message mentioning API
        _showSnackBar(
          '✓ Checked in at ${provider.currentCheckInTime}\n'
          '🎯 Tracking active • ${_isApiConnected ? "🌐 Syncing to server" : "📱 Saving locally"}',
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Check in failed: ${e.toString()}',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> _handleCheckOut() async {
    final provider = context.read<UserTrackingProvider>();

    if (!provider.isCheckedIn) {
      _showSnackBar('Please check in first', backgroundColor: Colors.orange);
      return;
    }

    try {
      final success = await provider.performCheckOut();

      if (success && mounted) {
        final totalDistance = provider.getTotalDistance();

        // ✅ Check API status after check-out
        _checkApiStatus();

        // ✅ Enhanced message mentioning API
        _showSnackBar(
          '✓ Checked out successfully\n'
          '📏 ${(totalDistance / 1000).toStringAsFixed(2)} km traveled\n'
          '${_isApiConnected ? "🌐 Data synced to server" : "📱 Data saved locally"}',
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Check out failed: ${e.toString()}',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _showSnackBar(
    String message, {
    Color backgroundColor = Colors.green,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: AppFonts.poppins),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  void _showLocationRequiredDialog({
    required String title,
    required String message,
    bool isServiceIssue = false,
    bool showSettings = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontFamily: AppFonts.poppins, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'No Thanks',
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (showSettings) {
                  await Geolocator.openAppSettings();
                } else if (isServiceIssue) {
                  await Geolocator.openLocationSettings();
                } else {
                  await Geolocator.requestPermission();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                showSettings ? 'Open Settings' : 'Turn On',
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _hasFaceVerifiedToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final lastVerifiedDate = prefs.getString('last_face_verified_date');

      if (lastVerifiedDate == today) {
        if (kDebugMode) print('✅ Face already verified today');
        return true;
      }

      if (kDebugMode) {
        print('⚠️ Face verification needed (last: $lastVerifiedDate)');
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ Error checking face verification: $e');
      return false;
    }
  }

  Future<void> _markFaceVerifiedToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await prefs.setString('last_face_verified_date', today);
      if (kDebugMode) print('✅ Marked face verified for: $today');
    } catch (e) {
      if (kDebugMode) print('❌ Error marking face verified: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map - Full screen
          Selector<UserTrackingProvider, LatLng?>(
            selector: (_, provider) => provider.currentLocation,
            builder: (context, currentLocation, child) {
              if (currentLocation == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentLocation,
                  zoom: 15,
                ),
                markers: _markers,
                polylines: _polyLines,
                onMapCreated: (controller) async {
                  _mapController = controller;
                  await _applyMapStyle(controller);
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: true,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
              );
            },
          ),

          // Header with API Status
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Selector<UserTrackingProvider, _HeaderData>(
                  selector:
                      (_, provider) => _HeaderData(
                        isCheckedIn: provider.isCheckedIn,
                        isLoading: provider.isLoading,
                        checkInTime: provider.currentCheckInTime,
                        checkInAddress: provider.currentCheckInAddress,
                        routePointsCount: provider.currentRoutePoints.length,
                        checkpointsCount:
                            provider.currentAddressCheckpoints.length,
                        totalDistance: provider.getTotalDistance(),
                        failedApiCallsCount: provider.failedApiCallsCount,
                      ),
                  builder: (context, headerData, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          _showFilter ? 20 : 16,
                        ),
                        border: Border.all(
                          color:
                              _showFilter
                                  ? Colors.grey.shade200
                                  : AppColor.primaryColor1.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ NEW: API Status Row
                          Row(
                            children: [
                              // Connection indicator
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _isApiConnected
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        _isApiConnected
                                            ? Colors.green.withOpacity(0.3)
                                            : Colors.red.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color:
                                            _isApiConnected
                                                ? Colors.green
                                                : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isApiConnected ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        color:
                                            _isApiConnected
                                                ? Colors.green
                                                : Colors.red,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Last sync time
                              Expanded(
                                child: Text(
                                  'Synced ${_getLastSyncText()}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ),

                              // Failed calls indicator
                              if (headerData.failedApiCallsCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.sync_problem,
                                        size: 12,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${headerData.failedApiCallsCount}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Manual sync button
                              InkWell(
                                onTap: _isSyncing ? null : _manualSyncWithApi,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColor.primaryColor1.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child:
                                      _isSyncing
                                          ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    AppColor.primaryColor1,
                                                  ),
                                            ),
                                          )
                                          : Icon(
                                            Icons.sync,
                                            size: 16,
                                            color: AppColor.primaryColor1,
                                          ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Toggle button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showFilter = !_showFilter;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOutCubic,
                              padding: EdgeInsets.symmetric(
                                horizontal: _showFilter ? 12 : 10,
                                vertical: _showFilter ? 8 : 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColor.primaryColor1.withOpacity(0.12),
                                    AppColor.primaryColor1.withOpacity(0.08),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColor.primaryColor1.withOpacity(
                                    0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: TextStyle(
                                      color: AppColor.primaryColor1,
                                      fontSize: _showFilter ? 13 : 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                    child: Text(
                                      _showFilter
                                          ? 'Hide Details'
                                          : 'Show Details',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedRotation(
                                    turns: _showFilter ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOutBack,
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColor.primaryColor1,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expandable content (rest of your existing code)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                            child:
                                _showFilter
                                    ? TweenAnimationBuilder<double>(
                                      duration: const Duration(
                                        milliseconds: 350,
                                      ),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      curve: Curves.easeOut,
                                      builder: (context, opacity, child) {
                                        return Opacity(
                                          opacity: opacity,
                                          child: Transform.translate(
                                            offset: Offset(
                                              0,
                                              10 * (1 - opacity),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 16),
                                                if (headerData.isCheckedIn) ...[
                                                  // Status indicator
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.green
                                                              .withOpacity(0.1),
                                                          Colors.green
                                                              .withOpacity(
                                                                0.05,
                                                              ),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.green
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        TweenAnimationBuilder<
                                                          double
                                                        >(
                                                          duration:
                                                              const Duration(
                                                                seconds: 1,
                                                              ),
                                                          tween: Tween(
                                                            begin: 0.8,
                                                            end: 1.0,
                                                          ),
                                                          curve:
                                                              Curves.easeInOut,
                                                          builder: (
                                                            context,
                                                            scale,
                                                            child,
                                                          ) {
                                                            return Transform.scale(
                                                              scale: scale,
                                                              child: Container(
                                                                width: 10,
                                                                height: 10,
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .green,
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: Colors
                                                                          .green
                                                                          .withOpacity(
                                                                            0.5,
                                                                          ),
                                                                      blurRadius:
                                                                          8,
                                                                      spreadRadius:
                                                                          2,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          onEnd: () {
                                                            setState(() {});
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            '${headerData.routePointsCount} points • '
                                                            '${headerData.checkpointsCount} places • '
                                                            '${(headerData.totalDistance / 1000).toStringAsFixed(2)} km',
                                                            style: const TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 13,
                                                              fontFamily:
                                                                  AppFonts
                                                                      .poppins,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 14),

                                                  // Address container
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          14,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Colors.grey.shade50,
                                                          Colors.grey.shade100,
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end:
                                                            Alignment
                                                                .bottomRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade300,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: AppColor
                                                                .primaryColor1
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Icon(
                                                            Icons.location_on,
                                                            color:
                                                                AppColor
                                                                    .primaryColor1,
                                                            size: 18,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            headerData
                                                                    .checkInAddress ??
                                                                '',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade800,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              height: 1.3,
                                                              fontFamily:
                                                                  AppFonts
                                                                      .poppins,
                                                            ),
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                ],

                                                // Buttons
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          gradient: const LinearGradient(
                                                            colors: [
                                                              Color(0xFF8E0E6B),
                                                              Color(0xFFD4145A),
                                                            ],
                                                            begin:
                                                                Alignment
                                                                    .centerLeft,
                                                            end:
                                                                Alignment
                                                                    .centerRight,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                14,
                                                              ),
                                                        ),
                                                        child: ElevatedButton(
                                                          onPressed:
                                                              headerData
                                                                      .isLoading
                                                                  ? null
                                                                  : _handleCheckIn,
                                                          style: ElevatedButton.styleFrom(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 14,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    14,
                                                                  ),
                                                            ),
                                                            elevation: 0,
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            shadowColor:
                                                                Colors
                                                                    .transparent,
                                                          ),
                                                          child:
                                                              headerData
                                                                      .isLoading
                                                                  ? const SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                      valueColor:
                                                                          AlwaysStoppedAnimation(
                                                                            Colors.white,
                                                                          ),
                                                                    ),
                                                                  )
                                                                  : Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: const [
                                                                      Icon(
                                                                        Icons
                                                                            .login,
                                                                        size:
                                                                            20,
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        'Check In',
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          fontFamily:
                                                                              AppFonts.poppins,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed:
                                                            headerData.isLoading
                                                                ? null
                                                                : _handleCheckOut,
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .grey
                                                                  .shade100,
                                                          foregroundColor:
                                                              Colors
                                                                  .grey
                                                                  .shade800,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 14,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  14,
                                                                ),
                                                          ),
                                                          elevation: 0,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: const [
                                                            Icon(
                                                              Icons.logout,
                                                              size: 20,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              'Check Out',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily:
                                                                    AppFonts
                                                                        .poppins,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true; // 🔥 important
    _apiStatusTimer?.cancel();
    context.read<UserTrackingProvider>().removeListener(_onProviderChanged);
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    super.dispose();
  }
}

class _HeaderData {
  final bool isCheckedIn;
  final bool isLoading;
  final String? checkInTime;
  final String? checkInAddress;
  final int routePointsCount;
  final int checkpointsCount;
  final double totalDistance;
  final int failedApiCallsCount; // ✅ NEW

  _HeaderData({
    required this.isCheckedIn,
    required this.isLoading,
    required this.checkInTime,
    required this.checkInAddress,
    required this.routePointsCount,
    required this.checkpointsCount,
    required this.totalDistance,
    required this.failedApiCallsCount, // ✅ NEW
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _HeaderData &&
          isCheckedIn == other.isCheckedIn &&
          isLoading == other.isLoading &&
          checkInTime == other.checkInTime &&
          checkInAddress == other.checkInAddress &&
          routePointsCount == other.routePointsCount &&
          checkpointsCount == other.checkpointsCount &&
          totalDistance == other.totalDistance &&
          failedApiCallsCount == other.failedApiCallsCount;

  @override
  int get hashCode => Object.hash(
    isCheckedIn,
    isLoading,
    checkInTime,
    checkInAddress,
    routePointsCount,
    checkpointsCount,
    totalDistance,
    failedApiCallsCount,
  );
}
