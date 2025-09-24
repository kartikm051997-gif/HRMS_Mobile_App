import 'package:flutter/material.dart';

import '../../../../core/components/appbar/appbar.dart';
import '../../../../core/components/drawer/drawer.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../model/RecruitmentModel/Resume_Management_Model.dart';

class ResumeManagementDetailsScreen extends StatefulWidget {
  final String cvId;
  final ResumeManagementModel employee;

  const ResumeManagementDetailsScreen({
    super.key,
    required this.cvId,
    required this.employee,
  });

  @override
  State<ResumeManagementDetailsScreen> createState() =>
      _ResumeManagementDetailsScreenState();
}

class _ResumeManagementDetailsScreenState
    extends State<ResumeManagementDetailsScreen>
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
      appBar: const CustomAppBar(title: "Resume Management"),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildInfoSection(),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    context;
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 35,
                    decoration: BoxDecoration(
                      color: AppColor.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "Action",
                        style: TextStyle(
                          color: AppColor.whiteColor,
                          fontSize: 16,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                    ),
                  ),
                ), // Space for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Modern Profile Header
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.employee.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: AppFonts.poppins,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 6),

          // Job title subtitle
          Text(
            widget.employee.jobTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Chips row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildChip(Icons.badge, "cvId: ${widget.employee.cvId}"),
              _buildChip(Icons.phone, widget.employee.phone),
              _buildChip(
                Icons.location_on_outlined,
                widget.employee.primaryLocation,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable Chip
  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.poppins,
              color: const Color(0xFF3730A3),
            ),
          ),
        ],
      ),
    );
  }

  /// Info Section (Uploaded by, etc.)
  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Additional Info",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          // Uploaded by
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundImage:
                    (widget.employee.uploadedBy.isNotEmpty)
                        ? NetworkImage(widget.employee.uploadedBy)
                        : const NetworkImage("https://i.pravatar.cc/150?img=5"),
              ),

              const SizedBox(width: 12),

              // Uploaded By Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Uploaded By",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.employee.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                        color: const Color(0xFF374151),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Created By Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Created By",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.employee.createdDate,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                        color: const Color(0xFF374151),
                      ),
                      overflow: TextOverflow.ellipsis,
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
}
