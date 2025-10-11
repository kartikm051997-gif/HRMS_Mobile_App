import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'TackingHistoryScreen.dart';

// Singleton class to manage tracking state across screens
class TrackingManager {
  static final TrackingManager _instance = TrackingManager._internal();
  factory TrackingManager() => _instance;
  TrackingManager._internal();

  List<TrackingRecord> trackingRecords = [];
  bool isCheckedIn = false;
  String? currentCheckInTime;
  LatLng? currentCheckInLocation;

  void addRecord(TrackingRecord record) {
    trackingRecords.insert(0, record);
  }

  void checkIn(String time, LatLng location) {
    isCheckedIn = true;
    currentCheckInTime = time;
    currentCheckInLocation = location;
  }

  void checkOut() {
    isCheckedIn = false;
    currentCheckInTime = null;
    currentCheckInLocation = null;
  }
}

// Model class for tracking records
class TrackingRecord {
  final String id;
  final String date;
  final String checkInTime;
  final String checkOutTime;
  final LatLng checkInLocation;
  final LatLng checkOutLocation;
  final String status;

  TrackingRecord({
    required this.id,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.checkInLocation,
    required this.checkOutLocation,
    required this.status,
  });

  factory TrackingRecord.fromJson(Map<String, dynamic> json) {
    return TrackingRecord(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      checkInTime: json['checkInTime'] ?? '',
      checkOutTime: json['checkOutTime'] ?? '',
      checkInLocation: LatLng(
        json['checkInLatitude'] ?? 0.0,
        json['checkInLongitude'] ?? 0.0,
      ),
      checkOutLocation: LatLng(
        json['checkOutLatitude'] ?? 0.0,
        json['checkOutLongitude'] ?? 0.0,
      ),
      status: json['status'] ?? 'checked_out',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'checkInLatitude': checkInLocation.latitude,
      'checkInLongitude': checkInLocation.longitude,
      'checkOutLatitude': checkOutLocation.latitude,
      'checkOutLongitude': checkOutLocation.longitude,
      'status': status,
    };
  }
}

// USER TRACKING SCREEN
class UserTrackingScreen extends StatefulWidget {
  const UserTrackingScreen({super.key});

  @override
  State<UserTrackingScreen> createState() => _UserTrackingScreenState();
}

class _UserTrackingScreenState extends State<UserTrackingScreen> {
  final TrackingManager _trackingManager = TrackingManager();
  DateTime? selectedDate;
  String? checkInTime;
  String? checkOutTime;
  String? createdDate;
  String? updatedDate;
  LatLng? currentLocation;
  bool isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _updateDates();
    _getCurrentLocation();
    _loadExistingState();
  }

  void _loadExistingState() {
    setState(() {
      if (_trackingManager.isCheckedIn) {
        checkInTime = _trackingManager.currentCheckInTime;
      }
    });
  }

  void _updateDates() {
    final now = DateTime.now();
    final dateOnly = DateFormat('dd/MM/yyyy');

    setState(() {
      createdDate = dateOnly.format(now);
      updatedDate = dateOnly.format(now);
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
        // Fallback to default location (San Francisco)
        currentLocation = const LatLng(37.7749, -122.4194);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get location: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _handleCheckIn() async {
    if (_trackingManager.isCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already checked in'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get fresh location
    await _getCurrentLocation();

    if (currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    // TODO: Replace with actual API call
    // final response = await ApiService.checkIn({
    //   'checkInTime': formatter.format(now),
    //   'latitude': currentLocation!.latitude,
    //   'longitude': currentLocation!.longitude,
    // });

    final time = formatter.format(now);
    _trackingManager.checkIn(time, currentLocation!);

    setState(() {
      checkInTime = time;
      updatedDate = dateFormatter.format(now);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checked in at $time'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleCheckOut() async {
    if (!_trackingManager.isCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please check in first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get fresh location for checkout
    await _getCurrentLocation();

    if (currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    // TODO: Replace with actual API call
    // final response = await ApiService.checkOut({
    //   'checkOutTime': formatter.format(now),
    //   'latitude': currentLocation!.latitude,
    //   'longitude': currentLocation!.longitude,
    // });

    final newRecord = TrackingRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: dateFormatter.format(now),
      checkInTime: _trackingManager.currentCheckInTime ?? 'N/A',
      checkOutTime: formatter.format(now),
      checkInLocation:
          _trackingManager.currentCheckInLocation ?? currentLocation!,
      checkOutLocation: currentLocation!,
      status: 'checked_out',
    );

    _trackingManager.addRecord(newRecord);
    _trackingManager.checkOut();

    setState(() {
      checkOutTime = formatter.format(now);
      updatedDate = dateFormatter.format(now);
      checkInTime = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checked out at ${newRecord.checkOutTime}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Status
            if (isLoadingLocation)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Getting current location...',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
            if (isLoadingLocation) const SizedBox(height: 16),

            // Current Location Display
            if (currentLocation != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current Location: ${currentLocation!.latitude.toStringAsFixed(4)}, ${currentLocation!.longitude.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (currentLocation != null) const SizedBox(height: 16),

            // Check In / Check Out Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleCheckIn,
                    icon: const Icon(Icons.login),
                    label: const Text(
                      'Check In',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleCheckOut,
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Check Out',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Date Filter
            Text(
              'Date Filter',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                          : 'Select Date',
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Check In Card
            _buildTrackingCard(
              title: 'Check In',
              time: checkInTime ?? '--:--',
              icon: Icons.login,
              color: Colors.green,
            ),
            const SizedBox(height: 12),

            // Check Out Card
            _buildTrackingCard(
              title: 'Check Out',
              time: checkOutTime ?? '--:--',
              icon: Icons.logout,
              color: Colors.red,
            ),
            const SizedBox(height: 12),

            // Created Date Card
            _buildInfoCard(
              title: 'Created Date',
              value: createdDate ?? '--/--/----',
              icon: Icons.calendar_month,
            ),
            const SizedBox(height: 12),

            // Updated Date Card
            _buildInfoCard(
              title: 'Updated Date',
              value: updatedDate ?? '--/--/----',
              icon: Icons.update,
            ),
            const SizedBox(height: 24),

            // View History Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrackingHistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text(
                  'View Tracking History',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 150),

          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCard({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
