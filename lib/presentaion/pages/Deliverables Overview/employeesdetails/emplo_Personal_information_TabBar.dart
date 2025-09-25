import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/reference_details_screen.dart';
import 'package:provider/provider.dart';
import '../../../../provider/Deliverables_Overview_provider/employee_information_details_TabBar_provider.dart';
import 'edu_exp_Details_screen.dart';
import 'employee_personal_details_screen.dart';
import 'other_details_screen.dart';

class ProfileTabBarView extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;

  const ProfileTabBarView({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<ProfileTabBarView> createState() => _ProfileTabBarViewState();
}

class _ProfileTabBarViewState extends State<ProfileTabBarView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<EmployeeInformationTabBarProvider>().setCurrentTab(
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
    return Consumer<EmployeeInformationTabBarProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // TabBar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColor.primaryColor2,
                unselectedLabelColor: AppColor.gryColor,
                indicatorColor: AppColor.primaryColor2,
                labelStyle: TextStyle(fontFamily: AppFonts.poppins),
                tabs: const [
                  Tab(text: 'Personal Detail'),
                  Tab(text: 'Education & Experience Detail'),
                  Tab(text: 'Other Details'),
                  Tab(text: 'Reference'),
                ],
              ),
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  EmployeePersonalDetailsScreen(
                    empId: "12345", // Replace with your dynamic employee ID
                  ),
                  EduExpDetailsScreen(empId: "12345"), // Tab 2
                  OtherDetailsScreen(empId: "12345"),
                  ReferenceDetailsScreen(empId: "12345"), // Tab 4
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
