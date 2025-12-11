import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final List<String> menuItems = ["Tracking", " History List"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: menuItems.length, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<UserTabViewTrackingProvider>().setCurrentTab(
          _tabController.index,
        );

        // ✅ CRITICAL: When switching tabs, ensure UserTrackingProvider is properly initialized
        // This ensures we show the correct user's data
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final trackingProvider = context.read<UserTrackingProvider>();
          if (!trackingProvider.isInitialized) {
            await trackingProvider.initialize();
          } else {
            // Even if initialized, double-check we're showing current user's data
            final prefs = await SharedPreferences.getInstance();
            final currentUserId = prefs.getString('logged_in_emp_id') ?? prefs.getString('employeeId');
            if (trackingProvider.currentUserId != currentUserId) {
              if (kDebugMode) print('🔄 Tab switch: User ID mismatch, re-initializing...');
              await trackingProvider.initialize();
            }
          }
        });
      }
    });
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
            isScrollable: false, // 👈 full-width tabs like WhatsApp
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
            labelPadding: EdgeInsets.zero, // 👈 removes left-right gap
            tabs: menuItems.map((e) => Tab(text: e)).toList(),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [UserTrackingScreen(), TrackingHistoryScreen()],
      ),
    );
  }
}
