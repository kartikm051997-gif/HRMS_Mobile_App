import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/constants/appcolor_dart.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/UserTrackingProvider/User_TabView_Tracking_Provider.dart';
import '../../../provider/UserTrackingProvider/UserTrackingProvider.dart';
import '../../../provider/login_provider/login_provider.dart';
import 'TackingHistoryScreen.dart';
import 'UserTrackingScreen.dart';

class UserTrackingTabViewScreen extends StatefulWidget {
  const UserTrackingTabViewScreen({super.key});

  @override
  State<UserTrackingTabViewScreen> createState() =>
      _UserTrackingTabViewScreenState();
}

class _UserTrackingTabViewScreenState extends State<UserTrackingTabViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Tracking", "icon": Icons.map},
    {"title": "History", "icon": Icons.history},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: menuItems.length, vsync: this);

    // ✅ OPTIONAL: Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<UserTabViewTrackingProvider>().setCurrentTab(
          _tabController.index,
        );

        // ✅ NEW: Sync data when switching to tracking tab
        if (_tabController.index == 0) {
          _onTrackingTabSelected();
        }
      }
    });
  }

  // ✅ NEW: Called when tracking tab is selected
  void _onTrackingTabSelected() {
    final provider = context.read<UserTrackingProvider>();

    // Sync with background service if checked in
    if (provider.isCheckedIn) {
      provider.syncWithBackground();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final user = loginProvider.loginData?.user;

    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: AppColor.whiteColor),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          title: Text(
            "User Tracking",
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: AppColor.whiteColor,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: AppFonts.poppins,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              fontFamily: AppFonts.poppins,
            ),
            labelPadding: EdgeInsets.zero,
            // ✅ OPTIONAL: Add icons to tabs
            tabs: menuItems.map((item) => Tab(
              icon: Icon(item['icon'], size: 20),
              text: item['title'],
              iconMargin: const EdgeInsets.only(bottom: 4),
            )).toList(),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UserTrackingScreen(),
          TrackingHistoryScreen(),
        ],
      ),
    );
  }
}