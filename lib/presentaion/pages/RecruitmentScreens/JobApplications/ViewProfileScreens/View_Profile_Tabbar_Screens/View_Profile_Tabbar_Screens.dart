import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/components/drawer/drawer.dart';
import '../../../../../../core/constants/appcolor_dart.dart';
import '../../../../../../core/fonts/fonts.dart';
import '../../../../../../model/RecruitmentModel/Job_Application_Model.dart';
import '../../../../../../provider/RecruitmentScreensProviders/Job_Application_Provider.dart';
import '../../../../Deliverables Overview/employeesdetails/other_details_screen.dart';
import '../../../../Deliverables Overview/employeesdetails/reference_details_screen.dart';
import 'Job_Application_Edit_Screen.dart';
import 'Recruitment_Edu_Experience_Screen.dart';
import 'Recruitment_Personal_Details_Screen.dart';

class ViewProfileTabViewScreens extends StatefulWidget {
  final String? jobId; // Optional
  final JobApplicationModel? employee;
  const ViewProfileTabViewScreens({super.key, this.jobId, this.employee});

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
    _tabController = TabController(length: 5, vsync: this);

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
              elevation: 0,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF8E0E6B),
                      Color(0xFFD4145A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title:  Text(
                "Employee Profile Details",
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  color: Colors.white,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                labelStyle: const TextStyle(
                  fontFamily: AppFonts.poppins,

                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Job Application Edit'),
                  Tab(text: 'Personal Detail'),
                  Tab(text: 'Education & Experience Detail'),
                  Tab(text: 'Other Details'),
                  Tab(text: 'Reference'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                JobApplicationEditScreen(jobId: widget.employee!.jobId),

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
