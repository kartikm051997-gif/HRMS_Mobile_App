import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:hrms_mobile_app/model/RecruitmentModel/Job_Application_Model.dart';
import '../../../../core/components/appbar/appbar.dart';
import '../../../../core/components/drawer/drawer.dart';
import 'Application_Information_Screen.dart';
import 'Assign_Button_Screen.dart';
import 'Employee_BasicDetails_Screen.dart';
import 'Status_Button_Screen.dart';
import 'Status_Tracking_Button_Screen.dart';
import 'View_Resume_Button_Screen.dart';

class JobApplicationDetailsScreen extends StatefulWidget {
  final String jobId;
  final JobApplicationModel employee;

  const JobApplicationDetailsScreen({
    super.key,
    required this.jobId,
    required this.employee,
  });

  @override
  State<JobApplicationDetailsScreen> createState() =>
      _JobApplicationDetailsScreenState();
}

class _JobApplicationDetailsScreenState
    extends State<JobApplicationDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Job Application Details"),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Card
            EmployeeBasicDetailsScreen(
              jobId: widget.employee.jobId,
              employee: widget.employee,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatusButtonScreen()),
                const SizedBox(width: 12), // spacing between buttons
                Expanded(child: AssignButtonScreen()),
              ],
            ),
            SizedBox(height: 12),
            ViewResumeButtonScreen(employee: widget.employee),

            SizedBox(height: 12),
            StatusTrackingScreen(),
            SizedBox(height: 12),

            ApplicationInformationScreen(),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
