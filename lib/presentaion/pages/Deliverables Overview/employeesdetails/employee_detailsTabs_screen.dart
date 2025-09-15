import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/circular_details_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/emplo_Personal_information_TabBar.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/payslip_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/pf_cscreen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/employeesdetails/task_Details_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/components/appbar/appbar.dart';
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
        child: AppBar(
          iconTheme: IconThemeData(color: AppColor.whiteColor),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColor.primaryColor2,
          title: Text(
            "Deliverables Overview",
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
            DocumentListScreen(
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

  /// EMPLOYEE DETAILS TAB UI - REDESIGNED
  Widget _buildEmployeeDetailsTab(
    EmployeeDetailsProvider provider,
    Map<String, dynamic> data,
    String avatarUrl,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Modern Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Profile Image with Status Ring
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColor.primaryColor2,
                            AppColor.primaryColor2.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 42,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ],
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
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 6),
                // Designation
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.empDesignation.isNotEmpty
                        ? widget.empDesignation
                        : (data["designation"] ?? "Software Engineer"),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryColor2,
                      fontFamily: AppFonts.poppins,
                    ),
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
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.empBranch.isNotEmpty
                          ? widget.empBranch
                          : (data["branch"] ?? "Chennai Branch"),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Information Sections
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Column(
              children: [
                // Basic Information Section
                _buildSection("Basic Information", Icons.person_outline, [
                  _buildInfoItem(
                    "Employee ID",
                    (data["empId"]?.toString() ?? widget.empId).isNotEmpty
                        ? (data["empId"]?.toString() ?? widget.empId)
                        : "EMP12345",
                  ),
                  _buildInfoItem(
                    "Full Name",
                    widget.empName.isNotEmpty
                        ? widget.empName
                        : (data["name"] ?? "John Doe"),
                  ),
                  _buildInfoItem(
                    "Designation",
                    widget.empDesignation.isNotEmpty
                        ? widget.empDesignation
                        : (data["designation"] ?? "Software Engineer"),
                  ),
                  _buildInfoItem(
                    "Branch",
                    widget.empBranch.isNotEmpty
                        ? widget.empBranch
                        : (data["branch"] ?? "Chennai Branch"),
                  ),
                  _buildInfoItem(
                    "Joining Date",
                    data["joiningDate"] ?? "2024-01-01",
                  ),
                ]),

                const SizedBox(height: 16),

                // Contact Information Section
                _buildSection(
                  "Contact Information",
                  Icons.contact_phone_outlined,
                  [
                    _buildInfoItem(
                      "Mobile",
                      data["mobile"] ?? "+91 98765 43210",
                    ),
                    _buildInfoItem(
                      "Email",
                      data["email"] ?? "john.doe@example.com",
                    ),
                    _buildInfoItem(
                      "Present Address",
                      data["present_address"] ?? "Not provided",
                    ),
                    _buildInfoItem(
                      "Permanent Address",
                      data["permanent_address"] ?? "Not provided",
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Personal Information Section
                _buildSection("Personal Information", Icons.info_outline, [
                  _buildInfoItem("Date of Birth", data["dob"] ?? "1995-06-21"),
                  _buildInfoItem("Gender", data["gender"] ?? "Male"),
                  _buildInfoItem(
                    "Marital Status",
                    data["maritalStatus"] ?? "Single",
                  ),
                  _buildInfoItem(
                    "Aadhar Number",
                    data["aadhar"] ?? "1234-5678-9012",
                  ),
                  _buildInfoItem("PAN Number", data["pan"] ?? "ABCDE1234F"),
                ]),

                const SizedBox(height: 16),

                // Professional Information Section
                _buildSection("Professional Information", Icons.work_outline, [
                  _buildInfoItem(
                    "Payroll Category",
                    data["payroll_category"] ?? "Regular",
                  ),
                  _buildInfoItem("Education", data["education"] ?? "MBA"),
                  _buildInfoItem(
                    "Recruiter",
                    data["recruiter"] ?? "",
                    imageUrl:
                        "https://i.pravatar.cc/150?img=3", // Dummy recruiter image
                  ),
                  _buildInfoItem(
                    "Created By",
                    data["created_by"] ?? "",
                    imageUrl:
                        "https://i.pravatar.cc/150?img=7", // Dummy created_by image
                  ),
                ]),
              ],
            ),
        ],
      ),
    );
  }

  /// BUILD SECTION WIDGET
  Widget _buildSection(String title, IconData icon, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.primaryColor2.withOpacity(0.05),
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
                    color: AppColor.primaryColor2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColor.primaryColor2, size: 22),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primaryColor2,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  /// BUILD INFO ITEM WIDGET
  Widget _buildInfoItem(String label, String value, {String? imageUrl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontFamily: AppFonts.poppins,
              ),
            ),
          ),

          // Value + optional image
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(imageUrl),
                    backgroundColor: Colors.grey[200],
                  ),
                if (imageUrl != null && imageUrl.isNotEmpty)
                  const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: AppFonts.poppins,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
