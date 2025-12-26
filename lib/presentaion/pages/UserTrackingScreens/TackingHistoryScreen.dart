import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/fonts/fonts.dart';
import '../../../model/UserTrackingModel/GetLocationHistoryModel.dart';
import '../../../provider/UserTrackingProvider/UserTrackingProvider.dart';
import '../../../servicesAPI/ActiveUserService/UserTrackingService.dart';

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

  // 🔥 Convert API records into Day wise CheckIn / CheckOut
  List<_DailyAttendance> _convertToDaily(List<Locations> locations) {
    final List<_DailyAttendance> result = [];

    // Sort by time (important)
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
        // Start a new card
        current = _DailyAttendance(date: DateTime(dt.year, dt.month, dt.day));
        current!.checkIn = time;
        current!.checkInAddress = l.locationAddress;
        result.add(current);
      } else if (l.activityType == 'CHECK_OUT') {
        // Close last open card
        if (current != null && current!.checkOut == null) {
          current!.checkOut = time;
          current!.checkOutAddress = l.locationAddress;
          current = null;
        }
      }
    }

    // Latest first
    return result.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final dailyList = _convertToDaily(_historyModel?.data?.locations ?? []);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'Tracking History',
      //     style: TextStyle(fontFamily: AppFonts.poppins),
      //   ),
      //   actions: [
      //     IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHistory),
      //   ],
      // ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : dailyList.isEmpty
              ? const Center(child: Text("No History"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dailyList.length,
                itemBuilder: (context, index) {
                  return _DailyCard(day: dailyList[index]);
                },
              ),
    );
  }
}

// ====================== UI CARD ========================

class _DailyAttendance {
  final DateTime date;
  String? checkIn;
  String? checkOut;
  String? checkInAddress;
  String? checkOutAddress;

  _DailyAttendance({required this.date});
}

class _DailyCard extends StatelessWidget {
  final _DailyAttendance day;
  const _DailyCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd MMM yyyy').format(day.date),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.poppins,
              ),
            ),

            const SizedBox(height: 12),

            _row("START", day.checkIn, Colors.green),
            if (day.checkInAddress != null)
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 4),
                child: Text(
                  day.checkInAddress!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 12),

            _row("END", day.checkOut, Colors.red),
            if (day.checkOutAddress != null)
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 4),
                child: Text(
                  day.checkOutAddress!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, String? time, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(
          time ?? "--:--",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
