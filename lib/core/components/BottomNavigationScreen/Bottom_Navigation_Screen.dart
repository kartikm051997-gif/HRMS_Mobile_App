import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../presentaion/pages/PagarBookAdminScreens/PagarBookAdminScreen.dart';
import '../../../presentaion/pages/UserTrackingScreens/Tracking_History_TabView_Screen.dart';
import '../../../provider/UserTrackingProvider/UserTrackingProvider.dart';
import '../../../provider/login_provider/login_provider.dart';
import '../../../core/fonts/fonts.dart';
import '../../../presentaion/pages/EmployeeManagement/EmployeemangementTabViewScreen/Employee_Management_Tabview.dart';
import '../../../presentaion/pages/UserProfileScreens/User_Profile_Screen.dart';
import '../../../presentaion/pages/MyDetailsScreens/admin_my_details_menu_screen.dart';
import '../../../presentaion/pages/MyDetailsScreens/normal_user_my_details_menu_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;
  late LoginProvider loginProvider;

  // ✅ Add GlobalKey for Scaffold to access drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // ✅ CRITICAL: Initialize tracking provider when BottomNavScreen is created
    // This ensures user-specific data is loaded for the current logged-in user
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeTrackingForCurrentUser();
    });
  }

  // ✅ Initialize tracking provider for current logged-in user
  Future<void> _initializeTrackingForCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId =
          prefs.getString('logged_in_emp_id') ?? prefs.getString('employeeId');

      if (kDebugMode) {
        print('🏠 BottomNavScreen initializing for user: $currentUserId');
      }

      // Force re-initialize the tracking provider to load current user's data
      final trackingProvider = context.read<UserTrackingProvider>();
      await trackingProvider.initialize();

      if (kDebugMode) {
        print('✅ BottomNavScreen: Tracking provider initialized');
        print('   User ID: $currentUserId');
        print(
          '   Tracking records: ${trackingProvider.trackingRecords.length}',
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ BottomNavScreen initialization error: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loginProvider = Provider.of<LoginProvider>(context, listen: false);
    // ✅ Ensure non-admin users start on NormalUserMyDetailsMenuScreen (index 0)
    final String roleId = loginProvider.userRole?.trim() ?? "";
    final bool isAdmin = roleId == "1";

    if (kDebugMode) {
      print("🔍 BottomNavScreen didChangeDependencies");
      print("   Role ID: '$roleId'");
      print("   Is Admin: $isAdmin");
    }

    // Non-admin users have no bottom nav items, so keep index at 0
    if (!isAdmin && _selectedIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectedIndex = 0);
        }
      });
    }
  }

  // ✅ Handle back button press
  Future<bool> _onWillPop() async {
    // If on home screen (index 0), open drawer instead of closing app
    if (_selectedIndex == 0) {
      _scaffoldKey.currentState?.openDrawer();
      return false; // Don't exit app
    } else {
      // If on other screens, go back to home
      setState(() => _selectedIndex = 0);
      return false; // Don't exit app
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = loginProvider.loginData?.user;
    final String roleId = loginProvider.userRole?.trim() ?? "";
    final bool isAdmin = roleId == "1";

    // Debug logging
    if (kDebugMode) {
      print("🔍 BottomNavScreen build");
      print("   Raw roleId from user: ${user?.roleId}");
      print("   Processed roleId: '$roleId'");
      print("   Role ID length: ${roleId.length}");
      print("   Is Admin: $isAdmin");
      print("   User ID: ${user?.userId}");
    }

    // ✅ Screens list - order matches bottom nav indices
    // For admin (role == "1"): [Home, Employees, Profile]
    // For non-admin: [NormalUserMyDetailsMenuScreen] (shows current user's menu)
    final List<Widget> screens =
        isAdmin
            ? const [
              PaGarBookAdminScreen(),
              EmployeeManagementTabviewScreen(),
              UserProfileScreen(),
            ]
            : [
              // Normal user: Show NormalUserMyDetailsMenuScreen with current user's details
              _buildEmployeeDetailsScreenForCurrentUser(user),
            ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Builder(
        builder: (rootContext) {
          return Scaffold(
            key: _scaffoldKey, // ✅ Add scaffold key
            // ✅ Add Drawer
            body: screens[_selectedIndex.clamp(0, screens.length - 1)],

            // ---------------- FAB ----------------- (only for admin)
            floatingActionButton:
                isAdmin
                    ? Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor1,

                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE91E63).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (!mounted) return;
                            ScaffoldMessenger.of(rootContext).showSnackBar(
                              const SnackBar(
                                content: Text('Add button pressed'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    )
                    : null,

            floatingActionButtonLocation:
                isAdmin ? FloatingActionButtonLocation.centerDocked : null,

            // ---------------- Bottom Navigation -----------------
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BottomAppBar(
                color: Colors.white,
                elevation: 0,
                notchMargin: 8,
                shape: const CircularNotchedRectangle(),
                child: SizedBox(
                  height: 65,
                  child:
                      isAdmin
                          ? Row(
                            children: [
                              Expanded(
                                child: _buildNavItem(
                                  icon: Icons.home_rounded,
                                  label: 'Home',
                                  index: 0,
                                ),
                              ),
                              const SizedBox(width: 40), // Space for FAB
                              Expanded(
                                child: _buildNavItem(
                                  icon: Icons.people_rounded,
                                  label: 'Employees',
                                  index: 1,
                                ),
                              ),
                              Expanded(
                                child: _buildProfileNavItem(
                                  user: user,
                                  index: 2,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            // Non-admin: No bottom nav items (can access via drawer)
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [],
                          ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Build Drawer Widget

  // ✅ Drawer Item Widget
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: AppFonts.poppins,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
    );
  }

  // ---------------- Navigation Item -----------------
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 1.0),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    icon,
                    color:
                        isSelected
                            ? AppColor.primaryColor1
                            : Colors.grey.shade400,
                    size: 26,
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color:
                    isSelected ? AppColor.primaryColor1 : Colors.grey.shade500,
                fontFamily: AppFonts.poppins,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Profile Navigation Item -----------------
  Widget _buildProfileNavItem({required dynamic user, required int index}) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 1.0, end: isSelected ? 1.15 : 1.0),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFF8E0E6B)
                                  : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            (user?.avatar != null && user!.avatar!.isNotEmpty)
                                ? NetworkImage(
                                  "https://app.draravindsivf.com/hrms/${user.avatar}",
                                )
                                : null,
                        child:
                            (user?.avatar == null || user!.avatar!.isEmpty)
                                ? Text(
                                  user?.fullname != null &&
                                          user!.fullname!.isNotEmpty
                                      ? user.fullname![0].toUpperCase()
                                      : "U",
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? const Color(0xFF8E0E6B)
                                            : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                )
                                : null,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? const Color(0xFF8E0E6B)
                          : Colors.grey.shade500,
                  fontFamily: AppFonts.poppins,
                ),
                child: const Text('Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build appropriate menu screen for current user
  Widget _buildEmployeeDetailsScreenForCurrentUser(dynamic user) {
    final empId = user?.userId ?? "";
    final empPhoto =
        (user?.avatar != null && user!.avatar!.isNotEmpty)
            ? "https://app.draravindsivf.com/hrms/${user.avatar}"
            : "";
    final empName = user?.fullname ?? "N/A";
    final empDesignation = "N/A"; // User model doesn't have designation
    final empBranch = user?.locationName ?? "N/A";

    // Normal users see NormalUserMyDetailsMenuScreen
    return NormalUserMyDetailsMenuScreen(
      empId: empId,
      empPhoto: empPhoto,
      empName: empName,
      empDesignation: empDesignation,
      empBranch: empBranch,
    );
  }
}
