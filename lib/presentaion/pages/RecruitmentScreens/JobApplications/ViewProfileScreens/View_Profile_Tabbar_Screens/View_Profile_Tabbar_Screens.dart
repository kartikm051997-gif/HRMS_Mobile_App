import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/components/drawer/drawer.dart';
import '../../../../../../core/constants/appcolor_dart.dart';
import '../../../../../../core/fonts/fonts.dart';
import '../../../../../../provider/RecruitmentScreensProvider/Job_Application_Provider.dart';
import '../../../../Deliverables Overview/employeesdetails/edu_exp_Details_screen.dart';
import '../../../../Deliverables Overview/employeesdetails/employee_personal_details_screen.dart';
import '../../../../Deliverables Overview/employeesdetails/other_details_screen.dart';
import '../../../../Deliverables Overview/employeesdetails/reference_details_screen.dart';
import 'Recruitment_Edu_Experience_Screen.dart';
import 'Recruitment_Personal_Details_Screen.dart';

class ViewProfileTabViewScreens extends StatefulWidget {
  const ViewProfileTabViewScreens({super.key});

  @override
  State<ViewProfileTabViewScreens> createState() =>
      _ViewProfileTabViewScreensState();
}

class _ViewProfileTabViewScreensState extends State<ViewProfileTabViewScreens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<JobApplicationProvider>().setCurrentTab(
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
    return Consumer<JobApplicationProvider>(
      builder: (context, provider, child) {
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            drawer: const TabletMobileDrawer(),

            appBar: AppBar(
              iconTheme: IconThemeData(color: AppColor.whiteColor),

              centerTitle: true,
              backgroundColor: AppColor.primaryColor2,

              elevation: 2,
              title: const Text(
                "Employee Profile Details",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.poppins,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColor.whiteColor,
                unselectedLabelColor: AppColor.gryColor,
                indicatorColor: AppColor.whiteColor,
                labelStyle: TextStyle(fontFamily: AppFonts.poppins),
                tabs: const [
                  Tab(text: 'Personal Detail'),
                  Tab(text: 'Education & Experience Detail'),
                  Tab(text: 'Other Details'),
                  Tab(text: 'Reference'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: const [
                RecruitmentPersonalDetailsScreen(empId: "12345"),
                RecruitmentEduExperienceScreen(empId: "12345"),
                OtherDetailsScreen(empId: "12345"),
                ReferenceDetailsScreen(empId: "12345"),
              ],
            ),
          ),
        );
      },
    );
  }
}
