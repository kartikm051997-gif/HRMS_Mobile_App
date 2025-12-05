import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../core/components/appbar/appbar.dart';
import '../../../../core/components/drawer/drawer.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../model/RecruitmentModel/Resume_Management_Model.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../EmployeeManagement/NewEmployeeScreens/Document_Upload_Field_for_Joining_Letter_Screen.dart';

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

  // Form controllers for New Resume
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  String? _selectedJobTitle;
  String? _selectedPrimaryLocation;
  File? _selectedResumeFile;

  // Dropdown data
  final List<String> _jobTitleList = [
    "Software Developer",
    "Accountant",
    "Hr",
    "Tele Calling",
    "Lab Technician",
  ];
  final List<String> _primaryLocationList = [
    "Aathur",
    "Aasam",
    "Nagapattinam",
    "Bengaluru - Hebbal",
  ];

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
    _nameController.dispose();
    _mobileNumberController.dispose();
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
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () {
                      _showNewResumeDialog(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8E0E6B),
                            Color(0xFFD4145A),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8E0E6B).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Add New Resume",
                          style: TextStyle(
                            color: AppColor.whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 700),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8E0E6B).withOpacity(0.8),
                          const Color(0xFFD4145A).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF8E0E6B).withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8E0E6B).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Action",
                        style: TextStyle(
                          color: const Color(0xFF8E0E6B),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                    ),
                  ),
                ),

                // Space for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Modern Profile Header
  Widget _buildProfileHeader() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E0E6B).withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 0,
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
      ),
    );
  }

  /// Reusable Chip
  Widget _buildChip(IconData icon, String label) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8E0E6B).withOpacity(0.1),
              const Color(0xFFD4145A).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF8E0E6B).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E0E6B).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF8E0E6B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: const Color(0xFF8E0E6B),
            ),
          ),
        ],
      ),
      ),
    );
  }

  /// Info Section (Uploaded by, etc.)
  Widget _buildInfoSection() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E0E6B).withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
              spreadRadius: 0,
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
      ),
    );
  }

  /// Show New Resume Dialog
  void _showNewResumeDialog(BuildContext context) {
    // Reset form when opening dialog
    _nameController.clear();
    _mobileNumberController.clear();
    _selectedJobTitle = null;
    _selectedPrimaryLocation = null;
    _selectedResumeFile = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with title and close button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "New Resume",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.poppins,
                          color: AppColor.blackColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Purple gradient separator line
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8E0E6B),
                        Color(0xFFD4145A),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8E0E6B).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name field
                          CustomTextField(
                            controller: _nameController,
                            labelText: "Name",
                            hintText: "Enter Name",
                            isMandatory: true,
                            keyboardType: TextInputType.name,
                          ),
                          const SizedBox(height: 16),

                          // Mobile Number field
                          CustomTextField(
                            controller: _mobileNumberController,
                            labelText: "Mobile Number",
                            hintText: "Enter Mobile Number",
                            isMandatory: true,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          // Job Title dropdown
                          CustomSearchDropdownWithSearch(
                            labelText: "Job Title",
                            items: _jobTitleList,
                            selectedValue: _selectedJobTitle,
                            onChanged: (value) {
                              setState(() {
                                _selectedJobTitle = value;
                              });
                            },
                            hintText: "Select Job Title",
                            isMandatory: true,
                          ),
                          const SizedBox(height: 16),

                          // Primary Location dropdown
                          CustomSearchDropdownWithSearch(
                            labelText: "Primary Location",
                            items: _primaryLocationList,
                            selectedValue: _selectedPrimaryLocation,
                            onChanged: (value) {
                              setState(() {
                                _selectedPrimaryLocation = value;
                              });
                            },
                            hintText: "Select Primary Location",
                            isMandatory: true,
                          ),
                          const SizedBox(height: 16),

                          // Resume file upload
                          DocumentUploadField(
                            labelText: "Resume",
                            isMandatory: true,
                            selectedFile: _selectedResumeFile,
                            allowedExtensions: const ['doc', 'pdf', 'docx'],
                            onFilePicked: (file) {
                              setState(() {
                                _selectedResumeFile = file;
                              });
                            },
                          ),
                          const SizedBox(height: 8),

                          // File type instructions
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              "Only .doc and .pdf files are allowed. File Size 2mb",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: AppFonts.poppins,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Save button with gradient
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8E0E6B),
                                      Color(0xFFD4145A),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8E0E6B)
                                          .withOpacity(0.3),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _handleSaveResume(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "Save",
                                    style: TextStyle(
                                      color: AppColor.whiteColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Handle Save Resume
  void _handleSaveResume(BuildContext context) {
    // Validate form
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Name"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_mobileNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Mobile Number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedJobTitle == null || _selectedJobTitle!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select Job Title"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPrimaryLocation == null || _selectedPrimaryLocation!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select Primary Location"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedResumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload Resume file"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implement API call to save resume
    // Here you would typically call your API service to save the resume
    // For now, just show success message and close dialog

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Resume saved successfully"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();

    // Reset form after saving
    _nameController.clear();
    _mobileNumberController.clear();
    _selectedJobTitle = null;
    _selectedPrimaryLocation = null;
    _selectedResumeFile = null;
  }
}
