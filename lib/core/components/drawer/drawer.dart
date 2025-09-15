import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import '../../constants/appcolor_dart.dart';
import '../../constants/appimages.dart';
import '../../routes/routes.dart';
import 'drawer_button.dart';
import '../../../controller/ui_controller/appbar_controllers.dart';

class TabletMobileDrawer extends StatefulWidget {
  const TabletMobileDrawer({super.key});

  @override
  State<TabletMobileDrawer> createState() => _TabletMobileDrawerState();
}

class _TabletMobileDrawerState extends State<TabletMobileDrawer> {
  bool _isPayrollExpanded = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double navItemFontSize = 18;
    final AppBarController appBarController = Get.find<AppBarController>();

    return Drawer(
      child: SizedBox(
        width: screenWidth,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Changed to white background
          ),
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColor.primaryColor1, AppColor.primaryColor2],
                  ),
                ),
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Scaffold.of(context).closeEndDrawer();
                        },
                        child: Image.network(
                          AppImages.logo,
                          height: 28,
                          width: 28,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder:
                              (context, error, stackTrace) => Image.asset(
                                AppImages.logo,
                                fit: BoxFit.cover,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard
                        TabletAppbarNavigationBtn(
                          leadingIcon: Icons.dashboard,
                          title: 'DashBoard',
                          targetPage: AppRoutes.dashboardScreen,
                          fontSize: navItemFontSize,
                        ),

                        // Deliverables Overview
                        TabletAppbarNavigationBtn(
                          leadingIcon: Icons.message_outlined,
                          title: 'Deliverables Overview',
                          targetPage: AppRoutes.deliverablesOverview,
                          fontSize: navItemFontSize,
                        ),

                        // Payroll with Submenu
                        _buildPayrollSection(navItemFontSize, appBarController),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayrollSection(
    double fontSize,
    AppBarController appBarController,
  ) {
    return Obx(() {
      // Check if any payroll submenu is active
      bool isAnyPayrollActive = _isAnyPayrollRouteActive(
        appBarController.selectedPage.value,
      );

      return Column(
        children: [
          // Main Payroll Button - Simplified without container
          InkWell(
            onTap: () {
              setState(() {
                _isPayrollExpanded = !_isPayrollExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            splashColor: AppColor.primaryColor2.withOpacity(0.3),
            highlightColor: AppColor.primaryColor2.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    _isPayrollExpanded
                        ? AppColor.primaryColor2.withOpacity(0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color:
                        isAnyPayrollActive
                            ? AppColor.primaryColor2
                            : const Color.fromARGB(255, 63, 63, 63),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Payroll',
                      style: TextStyle(
                        color:
                            isAnyPayrollActive
                                ? AppColor.primaryColor2
                                : const Color.fromARGB(255, 63, 63, 63),
                        fontSize: fontSize,
                        fontWeight:
                            isAnyPayrollActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isPayrollExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color:
                          isAnyPayrollActive
                              ? AppColor.primaryColor2
                              : const Color.fromARGB(255, 63, 63, 63),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Submenu Items
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isPayrollExpanded ? null : 0,
            child: AnimatedOpacity(
              opacity: _isPayrollExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                margin: const EdgeInsets.only(left: 20, top: 8),
                child: Column(
                  children: [
                    _buildSubmenuItem(
                      icon: Icons.schedule,
                      title: 'Attendance Log',
                      route: AppRoutes.attendanceLog,
                      fontSize: fontSize - 2,
                      appBarController: appBarController,
                    ),
                    _buildSubmenuItem(
                      icon: Icons.home_work,
                      title: 'Remote Attendance',
                      route: AppRoutes.remoteAttendance,
                      fontSize: fontSize - 2,
                      appBarController: appBarController,
                    ),
                    _buildSubmenuItem(
                      icon: Icons.report_problem,
                      title: 'Mispunch Reports',
                      route: AppRoutes.mispunchReports,
                      fontSize: fontSize - 2,
                      appBarController: appBarController,
                    ),
                    _buildSubmenuItem(
                      icon: Icons.punch_clock,
                      title: 'Employee Manual Punches',
                      route: AppRoutes.employeeManualPunches,
                      fontSize: fontSize - 2,
                      appBarController: appBarController,
                    ),
                    _buildSubmenuItem(
                      icon: Icons.savings,
                      title: 'PF',
                      route: AppRoutes.pf,
                      fontSize: fontSize - 2,
                      appBarController: appBarController,
                    ),
                    _buildSubmenuItem(
                      icon: Icons.rate_review,
                      title: 'Payroll Review',
                      route: AppRoutes.payrollReview,
                      fontSize: fontSize - 2,
                      appBarController: appBarController,
                    ),
                    _buildSubmenuItem(
                      icon: Icons.local_hospital,
                      title: 'ESI',
                      route: AppRoutes.esi,
                      fontSize: fontSize - 2,
                      appBarController: appBarController,
                    ),
                    _buildSubmenuItem(
                      icon: Icons.account_balance,
                      title: 'NEFT',
                      route: AppRoutes.neft,
                      fontSize: fontSize - 2,
                      appBarController: appBarController,
                    ),
                    _buildSubmenuItem(
                      icon: Icons.access_time,
                      title: 'Late Punch Reports',
                      route: AppRoutes.latePunchReports,
                      fontSize: fontSize - 2,
                      appBarController: appBarController,
                    ),
                    _buildSubmenuItem(
                      icon: Icons.description,
                      title: 'Salary Report',
                      route: AppRoutes.salaryReport,
                      fontSize: fontSize - 2,
                      appBarController: appBarController,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSubmenuItem({
    required IconData icon,
    required String title,
    required String route,
    required double fontSize,
    required AppBarController appBarController,
  }) {
    return Obx(() {
      bool isSelected = appBarController.selectedPage.value == route;

      return InkWell(
        onTap: () {
          Get.toNamed(route);
        },
        borderRadius: BorderRadius.circular(6),
        splashColor: AppColor.primaryColor2.withOpacity(0.3),
        highlightColor: AppColor.primaryColor2.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? AppColor.primaryColor2
                        : const Color.fromARGB(255, 63, 63, 63),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color:
                        isSelected
                            ? AppColor.primaryColor2
                            : const Color.fromARGB(255, 63, 63, 63),
                    fontSize: fontSize,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Helper method to check if any payroll route is active
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
}
