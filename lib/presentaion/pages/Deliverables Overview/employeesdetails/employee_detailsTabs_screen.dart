import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/circular_details_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/emplo_Personal_information_TabBar.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/payslip_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/pf_cscreen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/task_Details_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/components/drawer/drawer.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/Employee_Details_Provider.dart';

// Import all tab screens
import 'Assets_Details_screen.dart';
import 'attendance_screens/AttendanceScreen.dart';
import 'Bank_Screen.dart';
import 'document_screen.dart';
import 'ESI_screen.dart';
import 'letter_screen.dart';
import 'salary_screen.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final String empId;
  final String empPhoto;
  final String empName;
  final String empDesignation;
  final String empBranch;

  const EmployeeDetailsScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> menuItems = [
    "Employee Details",
    "Attendance",
    "Bank",
    "Documents",
    "Salary",
    "Job Application",
    "PF",
    "ESI",
    "Letter",
    "Payslip",
    "Assets Details",
    "Circular",
    "Task Details",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: menuItems.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeDetailsProvider>().fetchEmployeeDetails(
        widget.empId,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeDetailsProvider>();
    final data = provider.employeeDetails ?? {};

    const String defaultPhoto =
        "https://cdn-icons-png.flaticon.com/512/847/847969.png";

    final String avatarUrl =
        widget.empPhoto.isNotEmpty
            ? widget.empPhoto
            : (data["photo"]?.toString().isNotEmpty ?? false)
            ? data["photo"]
            : defaultPhoto;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const TabletMobileDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95),
        child:AppBar(
          iconTheme: IconThemeData(color: AppColor.whiteColor),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent, // important
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
          title: const Text(
            "Deliverables Overview",
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white,
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
        )

      ),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildEmployeeDetailsTab(provider, data, avatarUrl),
            AttendanceCalendarScreen(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
            BankScreen(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
            DocumentsScreen(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
            SalaryScreen(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
            ProfileTabBarView(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
            PfScreen(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
            ESIScreen(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
            LetterScreen(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
            PaySlipScreen(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
            AssetsDetailsScreen(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
            CircularDetailsScreen(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
            TaskDetailsScreen(
              empId: widget.empId,
              empPhoto: widget.empPhoto,
              empName: widget.empName,
              empDesignation: widget.empDesignation,
              empBranch: widget.empBranch,
            ),
          ],
        ),
      ),
    );
  }

  /// EMPLOYEE DETAILS TAB UI - REDESIGNED WITH ANIMATIONS
  Widget _buildEmployeeDetailsTab(
    EmployeeDetailsProvider provider,
    Map<String, dynamic> data,
    String avatarUrl,
  ) {
    // Gradient colors
    const primaryColor = Color(0xFF8E0E6B);
    const secondaryColor = Color(0xFFD4145A);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Modern Profile Header with Gradient and Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Gradient Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Profile Image
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar(
                                  widget.empName.isNotEmpty
                                      ? widget.empName
                                      : (data["name"] ?? "E"),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Employee Name
                        Text(
                          widget.empName.isNotEmpty
                              ? widget.empName
                              : (data["name"] ?? "John Doe"),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.poppins,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Employee ID Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "ID: ${widget.empId}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.poppins,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Designation
                        Text(
                          widget.empDesignation.isNotEmpty
                              ? widget.empDesignation
                              : (data["designation"] ?? "Software Engineer"),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.poppins,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Branch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.empBranch.isNotEmpty
                                  ? widget.empBranch
                                  : (data["branch"] ?? "Chennai Branch"),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontFamily: AppFonts.poppins,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Information Sections
          if (provider.isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading employee details...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                // Basic Information Section
                _buildAnimatedSection(
                  "Basic Information",
                  Icons.person_outline_rounded,
                  [
                    _buildInfoRow(
                      "Employee ID",
                      (data["empId"]?.toString() ?? widget.empId).isNotEmpty
                          ? (data["empId"]?.toString() ?? widget.empId)
                          : "EMP12345",
                      Icons.badge_outlined,
                    ),
                    _buildInfoRow(
                      "Full Name",
                      widget.empName.isNotEmpty
                          ? widget.empName
                          : (data["name"] ?? "John Doe"),
                      Icons.person_outline,
                    ),
                    _buildInfoRow(
                      "Designation",
                      widget.empDesignation.isNotEmpty
                          ? widget.empDesignation
                          : (data["designation"] ?? "Software Engineer"),
                      Icons.work_outline,
                    ),
                    _buildInfoRow(
                      "Branch",
                      widget.empBranch.isNotEmpty
                          ? widget.empBranch
                          : (data["branch"] ?? "Chennai Branch"),
                      Icons.location_on_outlined,
                    ),
                    _buildInfoRow(
                      "Joining Date",
                      data["joiningDate"] ?? "2024-01-01",
                      Icons.calendar_today_outlined,
                      isLast: true,
                    ),
                  ],
                  0,
                ),

                const SizedBox(height: 16),

                // Contact Information Section
                _buildAnimatedSection(
                  "Contact Information",
                  Icons.contact_phone_outlined,
                  [
                    _buildInfoRow(
                      "Mobile",
                      data["mobile"] ?? "+91 98765 43210",
                      Icons.phone_outlined,
                    ),
                    _buildInfoRow(
                      "Email",
                      data["email"] ?? "john.doe@example.com",
                      Icons.email_outlined,
                    ),
                    _buildInfoRow(
                      "Present Address",
                      data["present_address"] ?? "Not provided",
                      Icons.home_outlined,
                    ),
                    _buildInfoRow(
                      "Permanent Address",
                      data["permanent_address"] ?? "Not provided",
                      Icons.location_city_outlined,
                      isLast: true,
                    ),
                  ],
                  1,
                ),

                const SizedBox(height: 16),

                // Personal Information Section
                _buildAnimatedSection(
                  "Personal Information",
                  Icons.info_outline_rounded,
                  [
                    _buildInfoRow(
                      "Date of Birth",
                      data["dob"] ?? "1995-06-21",
                      Icons.cake_outlined,
                    ),
                    _buildInfoRow(
                      "Gender",
                      data["gender"] ?? "Male",
                      Icons.people_outline,
                    ),
                    _buildInfoRow(
                      "Marital Status",
                      data["maritalStatus"] ?? "Single",
                      Icons.favorite_outline,
                    ),
                    _buildInfoRow(
                      "Aadhar Number",
                      data["aadhar"] ?? "1234-5678-9012",
                      Icons.credit_card_outlined,
                    ),
                    _buildInfoRow(
                      "PAN Number",
                      data["pan"] ?? "ABCDE1234F",
                      Icons.description_outlined,
                      isLast: true,
                    ),
                  ],
                  2,
                ),

                const SizedBox(height: 16),

                // Professional Information Section
                _buildAnimatedSection(
                  "Professional Information",
                  Icons.work_outline_rounded,
                  [
                    _buildInfoRow(
                      "Payroll Category",
                      data["payroll_category"] ?? "Regular",
                      Icons.category_outlined,
                    ),
                    _buildInfoRow(
                      "Education",
                      data["education"] ?? "MBA",
                      Icons.school_outlined,
                    ),
                    _buildInfoRowWithAvatar(
                      "Recruiter",
                      data["recruiter"] ?? "Not assigned",
                      "https://i.pravatar.cc/150?img=3",
                      Icons.person_search_rounded,
                    ),
                    _buildInfoRowWithAvatar(
                      "Created By",
                      data["created_by"] ?? "Unknown",
                      "https://i.pravatar.cc/150?img=7",
                      Icons.person_add_rounded,
                      isLast: true,
                    ),
                  ],
                  3,
                ),

                const SizedBox(height: 32),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "E",
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(
    String title,
    IconData icon,
    List<Widget> items,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: _buildSection(title, icon, items),
    );
  }

  /// BUILD SECTION WIDGET
  Widget _buildSection(String title, IconData icon, List<Widget> items) {
    const primaryColor = Color(0xFF8E0E6B);
    const secondaryColor = Color(0xFFD4145A);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  secondaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:  Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  /// BUILD INFO ROW WIDGET
  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isLast = false,
  }) {
    const primaryColor = Color(0xFF8E0E6B);
    const borderColor = Color(0xFFE2E8F0);
    const textSecondary = Color(0xFF64748B);
    const textPrimary = Color(0xFF1E293B);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: borderColor.withOpacity(0.5), height: 1),
      ],
    );
  }

  /// BUILD INFO ROW WITH AVATAR WIDGET
  Widget _buildInfoRowWithAvatar(
    String label,
    String value,
    String? imageUrl,
    IconData icon, {
    bool isLast = false,
  }) {
    const primaryColor = Color(0xFF8E0E6B);
    const secondaryColor = Color(0xFFD4145A);
    const borderColor = Color(0xFFE2E8F0);
    const textSecondary = Color(0xFF64748B);
    const textPrimary = Color(0xFF1E293B);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withOpacity(0.2),
                                  secondaryColor.withOpacity(0.2),
                                ],
                              ),
                              border: Border.all(color: borderColor),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildSmallDefaultAvatar(value);
                                },
                              ),
                            ),
                          ),
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.poppins,
                              color: textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: borderColor.withOpacity(0.5), height: 1),
      ],
    );
  }

  Widget _buildSmallDefaultAvatar(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ),
    );
  }
}

