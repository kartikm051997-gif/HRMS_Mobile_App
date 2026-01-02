import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/fonts/fonts.dart';
import '../../../model/UserTrackingModel/GetLocationHistoryModel.dart';
import '../../../model/UserTrackingModel/UserTrackingModel.dart';
import '../../../provider/UserTrackingProvider/UserTrackingProvider.dart';
import '../../../servicesAPI/UserTrackingService/UserTrackingService.dart';
import 'TimeLine_Map_TabView_Screen.dart';

class TrackingHistoryScreen extends StatefulWidget {
  const TrackingHistoryScreen({super.key});

  @override
  State<TrackingHistoryScreen> createState() => _TrackingHistoryScreenState();
}

class _TrackingHistoryScreenState extends State<TrackingHistoryScreen> {
  GetLocationHistoryModel? _historyModel;
  bool _isLoading = false;
  String? _error;

  String? _selectedActivityType;
  DateTime? _fromDate;
  DateTime? _toDate;
  final int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<UserTrackingProvider>();

      final model = await TrackingApiService.getLocationHistory(
        userId: provider.currentUserId,
        activityType: _selectedActivityType,
        fromDate:
            _fromDate == null
                ? null
                : DateFormat('yyyy-MM-dd').format(_fromDate!),
        toDate:
            _toDate == null ? null : DateFormat('yyyy-MM-dd').format(_toDate!),
        page: _currentPage,
        perPage: 50,
      );

      if (mounted) {
        setState(() {
          _historyModel = model;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<_DailyAttendance> _convertToDaily(List<Locations> locations) {
    final List<_DailyAttendance> result = [];

    locations.sort(
      (a, b) => DateTime.parse(
        a.capturedAt!,
      ).compareTo(DateTime.parse(b.capturedAt!)),
    );

    _DailyAttendance? current;

    for (final l in locations) {
      if (l.capturedAt == null) continue;

      final dt = DateTime.parse(l.capturedAt!);
      final time = DateFormat('hh:mm a').format(dt);

      if (l.activityType == 'CHECK_IN') {
        current = _DailyAttendance(date: DateTime(dt.year, dt.month, dt.day));
        current.checkIn = time;
        current.checkInAddress = l.locationAddress;
        current.checkInLocation = LatLng(
          double.parse(l.latitude ?? '0'),
          double.parse(l.longitude ?? '0'),
        );
        current.locations.add(l);
        result.add(current);
      } else if (l.activityType == 'CHECK_OUT') {
        if (current != null && current.checkOut == null) {
          current.checkOut = time;
          current.checkOutAddress = l.locationAddress;
          current.checkOutLocation = LatLng(
            double.parse(l.latitude ?? '0'),
            double.parse(l.longitude ?? '0'),
          );
          current.locations.add(l);
          current = null;
        }
      } else {
        if (current != null) {
          current.locations.add(l);
        }
      }
    }

    return result.reversed.toList();
  }

  void _navigateToDetail(_DailyAttendance day) {
    if (day.checkInLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tracking data available')),
      );
      return;
    }

    final record = _convertToTrackingRecord(day);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimeLineMapTabViewScreen(record: record),
      ),
    );
  }

  UserTrackingRecordModel _convertToTrackingRecord(_DailyAttendance day) {
    final List<LatLng> routePoints = [];
    final List<AddressCheckpoint> checkpoints = [];

    LatLng? previousLocation;

    for (int i = 0; i < day.locations.length; i++) {
      final loc = day.locations[i];
      final latLng = LatLng(
        double.parse(loc.latitude ?? '0'),
        double.parse(loc.longitude ?? '0'),
      );

      if (loc.activityType == 'CHECK_IN' || loc.activityType == 'CHECK_OUT') {
        routePoints.add(latLng);
      } else if (loc.activityType == 'TRACKING') {
        routePoints.add(latLng);

        if (loc.locationAddress != null && loc.locationAddress!.isNotEmpty) {
          double distance = 0.0;
          if (previousLocation != null) {
            distance = _calculateDistance(previousLocation, latLng);
          }

          checkpoints.add(
            AddressCheckpoint(
              location: latLng,
              address: loc.locationAddress!,
              timestamp: DateTime.parse(loc.capturedAt!),
              distanceFromPrevious: distance,
            ),
          );
        }
      }

      previousLocation = latLng;
    }

    String status = day.checkOut != null ? 'COMPLETED' : 'ACTIVE';

    return UserTrackingRecordModel(
      id: 'history_${day.date.millisecondsSinceEpoch}',
      date: DateFormat('dd MMM yyyy').format(day.date),
      checkInTime: day.checkIn ?? '--:--',
      checkOutTime: day.checkOut ?? '--:--',
      checkInAddress: day.checkInAddress ?? 'Unknown location',
      checkOutAddress: day.checkOutAddress ?? 'Unknown location',
      checkInLocation: day.checkInLocation!,
      checkOutLocation: day.checkOutLocation ?? day.checkInLocation!,
      routePoints: routePoints,
      addressCheckpoints: checkpoints,
      status: status,
    );
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000;
    final double lat1 = start.latitude * (math.pi / 180);
    final double lat2 = end.latitude * (math.pi / 180);
    final double lon1 = start.longitude * (math.pi / 180);
    final double lon2 = end.longitude * (math.pi / 180);

    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    final dailyList = _convertToDaily(_historyModel?.data?.locations ?? []);

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading history',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadHistory,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E0E6B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : dailyList.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No tracking history',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your tracking sessions will appear here',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dailyList.length,
                itemBuilder: (context, index) {
                  return _AnimatedSimpleCard(
                    day: dailyList[index],
                    index: index,
                    onTap: () => _navigateToDetail(dailyList[index]),
                  );
                },
              ),
    );
  }
}

// ====================== DATA MODEL ========================

class _DailyAttendance {
  final DateTime date;
  String? checkIn;
  String? checkOut;
  String? checkInAddress;
  String? checkOutAddress;
  LatLng? checkInLocation;
  LatLng? checkOutLocation;
  List<Locations> locations = [];

  _DailyAttendance({required this.date});
}

// ====================== ANIMATED SIMPLE CARD ========================

class _AnimatedSimpleCard extends StatefulWidget {
  final _DailyAttendance day;
  final int index;
  final VoidCallback onTap;

  const _AnimatedSimpleCard({
    required this.day,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AnimatedSimpleCard> createState() => _AnimatedSimpleCardState();
}

class _AnimatedSimpleCardState extends State<_AnimatedSimpleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingPoints =
        widget.day.locations.length > 2 ? widget.day.locations.length - 2 : 0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            DateFormat('dd MMM yyyy').format(widget.day.date),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (trackingPoints > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$trackingPoints points',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Check In
                    _TimeRow(
                      icon: Icons.login,
                      label: 'Check In',
                      time: widget.day.checkIn ?? '--:--',
                      address: widget.day.checkInAddress,
                      color: Colors.green,
                    ),

                    const SizedBox(height: 12),

                    // Check Out
                    _TimeRow(
                      icon: Icons.logout,
                      label: 'Check Out',
                      time: widget.day.checkOut ?? '--:--',
                      address: widget.day.checkOutAddress,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final String? address;
  final Color color;

  const _TimeRow({
    required this.icon,
    required this.label,
    required this.time,
    required this.address,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                ],
              ),
              if (address != null && address!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  address!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontFamily: AppFonts.poppins,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
