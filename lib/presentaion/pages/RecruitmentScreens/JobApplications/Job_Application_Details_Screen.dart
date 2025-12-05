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
    extends State<JobApplicationDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Job Application Details"),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Employee Card
                EmployeeBasicDetailsScreen(
                  jobId: widget.employee.jobId,
                  employee: widget.employee,
                ),
                const SizedBox(height: 20),
                
                // Action Buttons Section with Card - Clean Single Column Layout
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Color(0xFFF8F9FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E0E6B).withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF8E0E6B),
                                  Color(0xFFD4145A),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8E0E6B).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.dashboard_customize_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8E0E6B),
                              fontFamily: AppFonts.poppins,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Single Column Layout - More Spacious
                      StatusButtonScreen(),
                      const SizedBox(height: 16),
                      AssignButtonScreen(),
                      const SizedBox(height: 16),
                      ViewResumeButtonScreen(employee: widget.employee),
                      const SizedBox(height: 16),
                      StatusTrackingScreen(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Application Information
                ApplicationInformationScreen(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
