import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../provider/login_provider/login_provider.dart';
import '../../../servicesAPI/LogOutApiService/LogOutApiService.dart';
import '../../../servicesAPI/LogOutApiService/LogOutApiService.dart'
    as LogOutApiService;
import '../../../servicesAPI/LogInService/LogIn_Service.dart';
import '../../constants/appimages.dart';
import '../../routes/routes.dart';
import '../../../controller/ui_controller/appbar_controllers.dart';
import '../../../presentaion/pages/Deliverables Overview/employeesdetails/employee_detailsTabs_screen.dart';
import '../../../presentaion/pages/authenticationScreens/loginScreens/login_screen.dart';
import '../../../presentaion/pages/MyDetailsScreens/admin_my_details_menu_screen.dart';
import '../../../presentaion/pages/MyDetailsScreens/normal_user_my_details_menu_screen.dart';

class TabletMobileDrawer extends StatefulWidget {
  const TabletMobileDrawer({super.key});

  @override
  State<TabletMobileDrawer> createState() => _TabletMobileDrawerState();
}

class _TabletMobileDrawerState extends State<TabletMobileDrawer>
    with SingleTickerProviderStateMixin {
  bool _isPayrollExpanded = false;
  bool _isEmployeesExpanded = false;
  bool _isRecruitmentExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Modern gradient colors
  static const Color primaryColor = Color(0xFF8E0E6B);
  static const Color secondaryColor = Color(0xFFD4145A);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtextColor = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final user = loginProvider.loginData?.user;
    final AppBarController appBarController = Get.find<AppBarController>();
    final bool isAdmin = loginProvider.userRole == "1";

    if (loginProvider.loginData == null) {
      return const Drawer(child: Center(child: CircularProgressIndicator()));
    }

    return Drawer(
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Modern Header
            _buildModernHeader(user),

            // Navigation Items
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Label
                    _buildSectionLabel("MAIN MENU"),
                    const SizedBox(height: 8),

                    // Main Navigation Items
                    // _buildNavItem(
                    //   icon: Icons.location_on_rounded,
                    //   title: 'User Tracking',
                    //   route: AppRoutes.userTrackingScreen,
                    //   index: 0,
                    // ),

                    // 🔹 Admin-only items (role == "1")
                    if (isAdmin) ...[
                      _buildNavItem(
                        icon: Icons.inventory_2_rounded,
                        title: 'PargarBook Admin',
                        route: AppRoutes.paGarBookAdmin,
                        index: 5,
                      ),
                      _buildNavItem(
                        icon: Icons.people_alt_rounded,
                        title: 'Employees Management',
                        route: AppRoutes.employeeManagement,
                        index: 3,
                      ),
                    ],

                    // 🔹 My Details → Navigate to EmployeeDetailsScreen for all users
                    _buildMyDetailsNavItem(
                      icon: Icons.dashboard_rounded,
                      title: 'My Details',
                      index: 2,
                      user: user,
                    ),

                    // 🔹 Admin-only menus
                    if (isAdmin) ...[
                      // _buildNavItem(
                      //   icon: Icons.admin_panel_settings_rounded,
                      //   title: 'Admin Tracking',
                      //   route: AppRoutes.adminTracking,
                      //   index: 1,
                      // ),
                    ],

                    const SizedBox(height: 16),
                    if (isAdmin) ...[
                      _buildSectionLabel("MODULES"),
                      const SizedBox(height: 8),

                      _buildPayrollSection(appBarController),
                      const SizedBox(height: 4),
                      _buildEmployeesSection(appBarController),
                      const SizedBox(height: 4),
                      _buildRecruitmentSection(appBarController),
                    ],

                    const SizedBox(height: 16),
                    if (isAdmin) ...[
                      _buildSectionLabel("OTHERS"),
                      const SizedBox(height: 8),

                      _buildNavItem(
                        icon: Icons.receipt_long_rounded,
                        title: 'PaySlips',
                        route: AppRoutes.paySlips,
                        index: 4,
                      ),
                      _buildNavItem(
                        icon: Icons.inventory_2_rounded,
                        title: 'Asset Details',
                        route: AppRoutes.assetDetails,
                        index: 5,
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Logout Button - Fixed at bottom, visible to all users
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: _buildLogoutButton(loginProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(dynamic user) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x307C3AED),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and Close Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  AppImages.logo,
                  height: 24,
                  width: 24,
                  color: Colors.white,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.business_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                ),
              ),
              // Close Button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // User Info Row
          Row(
            children: [
              // Avatar with Gradient Border
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage:
                      (user?.avatar != null && user!.avatar!.isNotEmpty)
                          ? NetworkImage(
                            "https://app.draravindsivf.com/hrms/${user.avatar}",
                          )
                          : null,
                  child:
                      (user?.avatar == null || user!.avatar!.isEmpty)
                          ? Text(
                            user?.fullname != null && user!.fullname!.isNotEmpty
                                ? user.fullname![0].toUpperCase()
                                : "U",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              fontFamily: AppFonts.poppins,
                            ),
                          )
                          : null,
                ),
              ),
              const SizedBox(width: 16),

              // User Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullname ?? "Welcome!",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: AppFonts.poppins,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              user?.username ?? "Welcome!",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontFamily: AppFonts.poppins,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      user?.locationName ?? "Branch Unknown",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: subtextColor.withOpacity(0.7),
          fontFamily: AppFonts.poppins,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required String route,
    required int index,
    VoidCallback? onTap,
  }) {
    final AppBarController appBarController = Get.find<AppBarController>();

    return Obx(() {
      bool isSelected = appBarController.selectedPage.value == route;

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 50)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                if (onTap != null) {
                  onTap();
                } else {
                  // Get.offNamed(route);
                  Get.toNamed(route);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isSelected
                          ? Border.all(color: primaryColor.withOpacity(0.3))
                          : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? primaryColor.withOpacity(0.15)
                                : subtextColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? primaryColor : subtextColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? primaryColor : textColor,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMyDetailsNavItem({
    required IconData icon,
    required String title,
    required int index,
    required dynamic user,
  }) {
    final AppBarController appBarController = Get.find<AppBarController>();

    return Obx(() {
      // Check if EmployeeDetailsScreen is selected (using a custom route check)
      bool isSelected = appBarController.selectedPage.value == '/employeeDetails';

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 50)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to appropriate menu screen based on user role
                final loginProvider = Provider.of<LoginProvider>(context, listen: false);
                final String roleId = loginProvider.userRole?.trim() ?? "";
                final bool isAdmin = roleId == "1";
                
                // Debug logging
                if (kDebugMode) {
                  print("🔍 Drawer - My Details clicked");
                  print("   Raw roleId from user: ${user?.roleId}");
                  print("   Processed roleId: '$roleId'");
                  print("   Role ID length: ${roleId.length}");
                  print("   Is Admin: $isAdmin");
                  print("   User ID: ${user?.userId}");
                  print("   Full user data: ${user?.toJson()}");
                }
                
                final empId = user?.userId ?? "";
                final empPhoto = (user?.avatar != null && user!.avatar!.isNotEmpty)
                    ? "https://app.draravindsivf.com/hrms/${user.avatar}"
                    : "";
                final empName = user?.fullname ?? "N/A";
                final empDesignation = "N/A"; // User model doesn't have designation
                final empBranch = user?.locationName ?? "N/A";

                // Use separate screens for admin vs normal user
                if (isAdmin) {
                  if (kDebugMode) print("   → Navigating to AdminMyDetailsMenuScreen");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminMyDetailsMenuScreen(
                        empId: empId,
                        empPhoto: empPhoto,
                        empName: empName,
                        empDesignation: empDesignation,
                        empBranch: empBranch,
                      ),
                    ),
                  );
                } else {
                  if (kDebugMode) print("   → Navigating to NormalUserMyDetailsMenuScreen");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NormalUserMyDetailsMenuScreen(
                        empId: empId,
                        empPhoto: empPhoto,
                        empName: empName,
                        empDesignation: empDesignation,
                        empBranch: empBranch,
                      ),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isSelected
                          ? Border.all(color: primaryColor.withOpacity(0.3))
                          : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? primaryColor.withOpacity(0.15)
                                : subtextColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? primaryColor : subtextColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? primaryColor : textColor,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildExpandableSection({
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
    required bool isAnyChildActive,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isExpanded || isAnyChildActive
                        ? primaryColor.withOpacity(0.08)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient:
                          isExpanded || isAnyChildActive
                              ? const LinearGradient(
                                colors: [primaryColor, secondaryColor],
                              )
                              : null,
                      color:
                          isExpanded || isAnyChildActive
                              ? null
                              : subtextColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color:
                          isExpanded || isAnyChildActive
                              ? Colors.white
                              : subtextColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color:
                            isExpanded || isAnyChildActive
                                ? primaryColor
                                : textColor,
                        fontSize: 14,
                        fontWeight:
                            isExpanded || isAnyChildActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color:
                          isExpanded || isAnyChildActive
                              ? primaryColor
                              : subtextColor,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Submenu with Animation
        AnimatedCrossFade(
          firstChild: const SizedBox(height: 0, width: double.infinity),
          secondChild: Container(
            margin: const EdgeInsets.only(left: 24, top: 4),
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
            child: Column(children: children),
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  Widget _buildSubmenuItem({
    required IconData icon,
    required String title,
    required String route,
    required AppBarController appBarController,
  }) {
    return Obx(() {
      bool isSelected = appBarController.selectedPage.value == route;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            // Get.offNamed(route);
            Get.toNamed(route);
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? primaryColor.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? primaryColor : subtextColor,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color:
                          isSelected
                              ? primaryColor
                              : textColor.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPayrollSection(AppBarController appBarController) {
    return Obx(() {
      bool isAnyPayrollActive = _isAnyPayrollRouteActive(
        appBarController.selectedPage.value,
      );

      return _buildExpandableSection(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Payroll',
        isExpanded: _isPayrollExpanded,
        isAnyChildActive: isAnyPayrollActive,
        onTap: () => setState(() => _isPayrollExpanded = !_isPayrollExpanded),
        children: [
          _buildSubmenuItem(
            icon: Icons.schedule_rounded,
            title: 'Attendance Log',
            route: AppRoutes.attendanceLog,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.home_work_rounded,
            title: 'Remote Attendance',
            route: AppRoutes.remoteAttendance,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.report_problem_rounded,
            title: 'Mispunch Reports',
            route: AppRoutes.mispunchReports,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.punch_clock_rounded,
            title: 'Employee Manual Punches',
            route: AppRoutes.employeeManualPunches,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.savings_rounded,
            title: 'PF',
            route: AppRoutes.pf,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.rate_review_rounded,
            title: 'Payroll Review',
            route: AppRoutes.payrollReview,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.local_hospital_rounded,
            title: 'ESI',
            route: AppRoutes.esi,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.account_balance_rounded,
            title: 'NEFT',
            route: AppRoutes.neft,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.access_time_rounded,
            title: 'Late Punch Reports',
            route: AppRoutes.latePunchReports,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.description_rounded,
            title: 'Salary Report',
            route: AppRoutes.salaryReport,
            appBarController: appBarController,
          ),
        ],
      );
    });
  }

  Widget _buildEmployeesSection(AppBarController appBarController) {
    return Obx(() {
      bool isAnyEmployeeActive = _isAnyEmployeeRouteActive(
        appBarController.selectedPage.value,
      );

      return _buildExpandableSection(
        icon: Icons.people_rounded,
        title: 'Employees',
        isExpanded: _isEmployeesExpanded,
        isAnyChildActive: isAnyEmployeeActive,
        onTap:
            () => setState(() => _isEmployeesExpanded = !_isEmployeesExpanded),
        children: [
          _buildSubmenuItem(
            icon: Icons.group_rounded,
            title: 'All',
            route: AppRoutes.allEmployees,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.work_rounded,
            title: 'Professionals',
            route: AppRoutes.professionals,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.badge_rounded,
            title: 'Employees',
            route: AppRoutes.employees,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.school_rounded,
            title: 'Students',
            route: AppRoutes.students,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.apartment_rounded,
            title: 'F11 Employees',
            route: AppRoutes.f11Employees,
            appBarController: appBarController,
          ),
        ],
      );
    });
  }

  Widget _buildRecruitmentSection(AppBarController appBarController) {
    return Obx(() {
      bool isAnyRecruitmentActive = _isAnyRecruitmentRouteActive(
        appBarController.selectedPage.value,
      );

      return _buildExpandableSection(
        icon: Icons.group_work_rounded,
        title: 'Recruitment',
        isExpanded: _isRecruitmentExpanded,
        isAnyChildActive: isAnyRecruitmentActive,
        onTap:
            () => setState(
              () => _isRecruitmentExpanded = !_isRecruitmentExpanded,
            ),
        children: [
          _buildSubmenuItem(
            icon: Icons.description_rounded,
            title: 'Resume Management',
            route: AppRoutes.resumeManagement,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.work_outline_rounded,
            title: 'Job Applications',
            route: AppRoutes.jobApplications,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.edit_document,
            title: 'Semi Filled Application',
            route: AppRoutes.semiFilledApplication,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.how_to_reg_rounded,
            title: 'Joining Forms',
            route: AppRoutes.joiningForms,
            appBarController: appBarController,
          ),
          _buildSubmenuItem(
            icon: Icons.mail_rounded,
            title: 'Offer Letters',
            route: AppRoutes.offerLetters,
            appBarController: appBarController,
          ),
        ],
      );
    });
  }

  // Widget _buildFooter() {
  //   return Container(
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, -5),
  //         ),
  //       ],
  //     ),
  //     child: SafeArea(
  //       top: false,
  //       child: Row(
  //         children: [
  //           // App Version
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   "HRMS Mobile",
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.w600,
  //                     color: textColor,
  //                     fontFamily: AppFonts.poppins,
  //                   ),
  //                 ),
  //                 Text(
  //                   "Version 1.0.0",
  //                   style: TextStyle(
  //                     fontSize: 11,
  //                     color: subtextColor,
  //                     fontFamily: AppFonts.poppins,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //
  //           // Logout Button
  //           // Material(
  //           //   color: Colors.transparent,
  //           //   child: InkWell(
  //           //     onTap: () {
  //           //       // Handle logout
  //           //       _showLogoutDialog();
  //           //     },
  //           //     borderRadius: BorderRadius.circular(12),
  //           //     child: Container(
  //           //       padding: const EdgeInsets.symmetric(
  //           //         horizontal: 16,
  //           //         vertical: 10,
  //           //       ),
  //           //       decoration: BoxDecoration(
  //           //         gradient: const LinearGradient(
  //           //           colors: [primaryColor, secondaryColor],
  //           //         ),
  //           //         borderRadius: BorderRadius.circular(12),
  //           //         boxShadow: [
  //           //           BoxShadow(
  //           //             color: primaryColor.withOpacity(0.3),
  //           //             blurRadius: 8,
  //           //             offset: const Offset(0, 4),
  //           //           ),
  //           //         ],
  //           //       ),
  //           //       child: const Row(
  //           //         mainAxisSize: MainAxisSize.min,
  //           //         children: [
  //           //           Icon(Icons.logout_rounded, color: Colors.white, size: 18),
  //           //           SizedBox(width: 8),
  //           //           Text(
  //           //             "Logout",
  //           //             style: TextStyle(
  //           //               fontSize: 13,
  //           //               fontWeight: FontWeight.w600,
  //           //               color: Colors.white,
  //           //               fontFamily: AppFonts.poppins,
  //           //             ),
  //           //           ),
  //           //         ],
  //           //       ),
  //           //     ),
  //           //   ),
  //           // ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showLogoutDialog() {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           title: Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(10),
  //                 decoration: BoxDecoration(
  //                   color: Colors.red.withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: const Icon(
  //                   Icons.logout_rounded,
  //                   color: Colors.red,
  //                   size: 24,
  //                 ),
  //               ),
  //               const SizedBox(width: 14),
  //               const Text(
  //                 "Logout",
  //                 style: TextStyle(
  //                   fontFamily: AppFonts.poppins,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           content: const Text(
  //             "Are you sure you want to logout?",
  //             style: TextStyle(
  //               fontFamily: AppFonts.poppins,
  //               color: Color(0xFF64748B),
  //             ),
  //           ),
  //           actions: [
  //             // Cancel button
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text(
  //                 "Cancel",
  //                 style: TextStyle(
  //                   fontFamily: AppFonts.poppins,
  //                   color: subtextColor,
  //                 ),
  //               ),
  //             ),
  //
  //             // Logout button
  //             // ElevatedButton(
  //             //   onPressed: () async {
  //             //     // Close the dialog
  //             //     Navigator.pop(context);
  //             //
  //             //     final prefs = await SharedPreferences.getInstance();
  //             //
  //             //     // Get the user's token (assuming you have it saved after login)
  //             //     String token = prefs.getString('token') ?? '';
  //             //
  //             //     try {
  //             //       // Call the logout API
  //             //       final logoutResponse = await ApiService.logoutUser(token);
  //             //
  //             //       // If the logout response is successful
  //             //       if (logoutResponse.status == "success") {
  //             //         // Clear session data and login information
  //             //         final loginProvider = Provider.of<LoginProvider>(
  //             //           context,
  //             //           listen: false,
  //             //         );
  //             //         loginProvider.logout();
  //             //
  //             //         // Clear session and preferences
  //             //         await prefs.remove('userData');
  //             //         await prefs.remove('isLoggedIn');
  //             //         await prefs.remove('loginTime');
  //             //         await prefs.remove('employeeId');
  //             //         await prefs.remove('logged_in_emp_id');
  //             //
  //             //         // Navigate to the login screen
  //             //         Get.offAllNamed(AppRoutes.loginScreen);
  //             //       } else {
  //             //         // Handle unsuccessful logout
  //             //         debugPrint('Logout failed: ${logoutResponse.message}');
  //             //         // Optionally show a failure message
  //             //       }
  //             //     } catch (e) {
  //             //       debugPrint('Error logging out: $e');
  //             //       // Optionally show an error message
  //             //     }
  //             //   },
  //             //   style: ElevatedButton.styleFrom(
  //             //     backgroundColor: Colors.red,
  //             //     foregroundColor: Colors.white,
  //             //     shape: RoundedRectangleBorder(
  //             //       borderRadius: BorderRadius.circular(10),
  //             //     ),
  //             //   ),
  //             //   child: const Text(
  //             //     "Logout",
  //             //     style: TextStyle(
  //             //       fontFamily: AppFonts.poppins,
  //             //       fontWeight: FontWeight.w600,
  //             //     ),
  //             //   ),
  //             // ),
  //           ],
  //         ),
  //   );
  // }

  // Helper methods to check active routes
  bool _isAnyPayrollRouteActive(String currentRoute) {
    List<String> payrollRoutes = [
      AppRoutes.attendanceLog,
      AppRoutes.remoteAttendance,
      AppRoutes.mispunchReports,
      AppRoutes.employeeManualPunches,
      AppRoutes.pf,
      AppRoutes.payrollReview,
      AppRoutes.esi,
      AppRoutes.neft,
      AppRoutes.latePunchReports,
      AppRoutes.salaryReport,
    ];
    return payrollRoutes.contains(currentRoute);
  }

  bool _isAnyEmployeeRouteActive(String currentRoute) {
    List<String> employeeRoutes = [
      AppRoutes.allEmployees,
      AppRoutes.professionals,
      AppRoutes.employees,
      AppRoutes.students,
      AppRoutes.f11Employees,
    ];
    return employeeRoutes.contains(currentRoute);
  }

  bool _isAnyRecruitmentRouteActive(String currentRoute) {
    List<String> recruitmentRoutes = [
      AppRoutes.resumeManagement,
      AppRoutes.jobApplications,
      AppRoutes.semiFilledApplication,
      AppRoutes.joiningForms,
      AppRoutes.offerLetters,
    ];
    return recruitmentRoutes.contains(currentRoute);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LOGOUT BUTTON (Visible to all users)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildLogoutButton(LoginProvider loginProvider) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(loginProvider),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.poppins,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(LoginProvider loginProvider) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  "Logout",
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            content: const Text(
              "Are you sure you want to logout?",
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                color: subtextColor,
              ),
            ),
            actions: [
              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    color: subtextColor,
                  ),
                ),
              ),
              // Logout button
              ElevatedButton(
                onPressed: () async {
                  if (kDebugMode) print("🚪 Logout button pressed");
                  
                  // Close dialog first
                  Navigator.pop(context);
                  if (kDebugMode) print("✅ Dialog closed");
                  
                  // Close drawer if still open
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                    if (kDebugMode) print("✅ Drawer closed");
                  }
                  
                  // Small delay to ensure UI is fully closed
                  await Future.delayed(const Duration(milliseconds: 300));
                  
                  // Call logout API if token exists
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('authToken');
                    if (token != null && token.isNotEmpty) {
                      try {
                        final response = await LogOutApiService.ApiService.logoutUser(token);
                        if (kDebugMode) {
                          print("✅ Logout API called successfully");
                          print("📋 Response status: ${response.status}");
                          print("📋 Response message: ${response.message}");
                        }
                      } catch (e) {
                        // Continue with logout even if API call fails
                        if (kDebugMode) print("⚠️ Logout API call failed: $e");
                      }
                    } else {
                      if (kDebugMode) print("⚠️ No token found for logout API");
                    }
                  } catch (e) {
                    if (kDebugMode) print("⚠️ Error calling logout API: $e");
                  }
                  
                  // Step 1: Clear session data
                  try {
                    final loginService = LoginService();
                    await loginService.clearSession();
                    if (kDebugMode) print("✅ Session cleared");
                  } catch (e) {
                    if (kDebugMode) print("❌ Error clearing session: $e");
                  }
                  
                  // Step 2: Navigate to login screen IMMEDIATELY
                  // Use Navigator with rootNavigator to bypass drawer context
                  try {
                    if (kDebugMode) print("🔄 Navigating to login screen...");
                    
                    // Close drawer first if it's open
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                      await Future.delayed(const Duration(milliseconds: 100));
                    }
                    
                    // Navigate using rootNavigator
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false, // Remove all routes
                    );
                    
                    if (kDebugMode) print("✅ Navigation completed");
                  } catch (e) {
                    if (kDebugMode) print("❌ Navigation error: $e");
                    
                    // Fallback: Try GetX navigation
                    try {
                      Get.offAllNamed(AppRoutes.loginScreen);
                      if (kDebugMode) print("✅ Fallback navigation via GetX");
                    } catch (e2) {
                      if (kDebugMode) print("❌ GetX navigation also failed: $e2");
                    }
                  }
                  
                  // Step 3: Clear provider state (this won't navigate since we already did)
                  // But we'll skip calling logout() to avoid double navigation
                  // The session is already cleared, so login screen will detect no session
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
