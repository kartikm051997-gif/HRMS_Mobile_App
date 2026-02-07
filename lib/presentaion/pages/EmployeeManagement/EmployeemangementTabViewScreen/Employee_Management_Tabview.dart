import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeManagement/AllEmployeesScreens/All_Employee_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeManagement/InActiveScreens/Inactive_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/components/drawer/drawer.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Employee_management_Provider/employee_tabview_provider.dart';
import '../NewEmployeeScreens/New_Employee_Screen.dart';
import '../activeScreens/ActiveScreen.dart';
import '../activescreens/ActiveScreen.dart' hide ActiveScreen;
import '../AbscondScreens/abscond_screen.dart';
import '../managementApproval/management_approval_screen.dart';
import '../NoticePeriod/notice_period_screen.dart';

class EmployeeManagementTabviewScreen extends StatefulWidget {
  const EmployeeManagementTabviewScreen({super.key});

  @override
  State<EmployeeManagementTabviewScreen> createState() =>
      _EmployeeManagementTabviewScreenState();
}

class _EmployeeManagementTabviewScreenState
    extends State<EmployeeManagementTabviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> menuItems = [
    "Active",
    "Management Approval",
    "Abscond",
    "Notice Period",
    "Inactive",
    "All Employee",
    "New Employee",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: menuItems.length, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<EmployeeTabviewProvider>().setCurrentTab(
          _tabController.index,
        );
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
    return Consumer<EmployeeTabviewProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          drawer: const TabletMobileDrawer(),
          appBar: AppBar(
            iconTheme: IconThemeData(color: AppColor.whiteColor),
            centerTitle: true,
            elevation: 0,

            // Remove backgroundColor
            // backgroundColor: AppColor.primaryColor2,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                color: Color(0xff0FF5B7FFF)
              ),
            ),

            title: Text(
              "Employees Management",
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: AppColor.whiteColor,
              ),
            ),

            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
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
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: menuItems.map((e) => Tab(text: e)).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              ActiveScreen(key: const ValueKey('active_screen')), // this is your filter + pagination screen
              ManagementApprovalScreen(key: const ValueKey('management_approval_screen')),
              AbscondScreen(key: const ValueKey('abscond_screen')),
              NoticePeriodScreen(key: const ValueKey('notice_period_screen')),
              InActiveScreen(key: const ValueKey('inactive_screen')),
              AllEmployeeScreen(key: const ValueKey('all_employee_screen')),
              NewEmployeeScreen(key: const ValueKey('new_employee_screen'), empId: "12345"),
            ],
          ),
        );
      },
    );
  }
}
