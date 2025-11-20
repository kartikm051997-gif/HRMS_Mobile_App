import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../model/UserTrackingModel/UserTrackingModel.dart';
import '../../../provider/UserTrackingProvider/TrackingDetailProvider.dart';
import 'TrackingMapTabScreen.dart';
import 'TrackingTimelineTabScreen.dart';


class TimeLineMapTabViewScreen extends StatefulWidget {
  final UserTrackingRecordModel record;

  const TimeLineMapTabViewScreen({super.key, required this.record});

  @override
  State<TimeLineMapTabViewScreen> createState() => _TimeLineMapTabViewScreenState();
}

class _TimeLineMapTabViewScreenState extends State<TimeLineMapTabViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackingDetailProvider(widget.record),
      child: Scaffold(
        drawer: const TabletMobileDrawer(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 48),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Tracking Details',
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [Tab(text: 'TIMELINE'), Tab(text: 'MAP')],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            TrackingTimelineTab(),
            TrackingMapTab(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}