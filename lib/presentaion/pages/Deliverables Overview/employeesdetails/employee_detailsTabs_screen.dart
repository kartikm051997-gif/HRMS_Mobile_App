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
      drawer: const TabletMobileDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          95,
        ), // AppBar + TabBar combined height
        child: AppBar(
          iconTheme: IconThemeData(
            color: AppColor.whiteColor, // ✅ Makes drawer icon white
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColor.primaryColor2,
          title: Text(
            "Deliverables Overview",
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w500,
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
              fontSize: 15,
              fontFamily: AppFonts.poppins,
            ),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: menuItems.map((e) => Tab(text: e)).toList(),
          ),
        ),
      ),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true, // ✅ Removes the extra white space below TabBar
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

  /// EMPLOYEE DETAILS TAB UI
  Widget _buildEmployeeDetailsTab(
    EmployeeDetailsProvider provider,
    Map<String, dynamic> data,
    String avatarUrl,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.empName.isNotEmpty
                      ? widget.empName
                      : (data["name"] ?? "John Doe"),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Designation: ${widget.empDesignation.isNotEmpty ? widget.empDesignation : (data["designation"] ?? "Software Engineer")}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Branch: ${widget.empBranch.isNotEmpty ? widget.empBranch : (data["branch"] ?? "Chennai Branch")}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          provider.isLoading
              ? const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
              : Card(
                color: Colors.white,
                elevation: 2,
                shadowColor: Colors.grey.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _row(
                        "Emp ID",
                        (data["empId"]?.toString() ?? widget.empId).isNotEmpty
                            ? (data["empId"]?.toString() ?? widget.empId)
                            : "EMP12345", // 👈 Dummy Emp ID
                      ),
                      _row(
                        "Name",
                        widget.empName.isNotEmpty
                            ? widget.empName
                            : (data["name"] ?? "John Doe"),
                      ),

                      _row(
                        "Designation",
                        widget.empDesignation.isNotEmpty
                            ? widget.empDesignation
                            : (data["designation"] ?? "Software Engineer"),
                      ),
                      _row(
                        "Branch",
                        widget.empBranch.isNotEmpty
                            ? widget.empBranch
                            : (data["branch"] ?? "Chennai Branch"),
                      ),
                      _row("Mobile", data["mobile"] ?? "+91 98765 43210"),
                      _row("Email", data["email"] ?? "john.doe@example.com"),
                      _row("Aadhar", data["aadhar"] ?? "1234-5678-9012"),
                      _row("PAN No", data["pan"] ?? "ABCDE1234F"),
                      _row(
                        "Payroll Category",
                        data["payroll_category"] ?? "N/A",
                      ),
                      _row(
                        "Education Qualification",
                        data["education"] ?? "N/A",
                      ),
                      _row("Recruiter", data["recruiter"] ?? "N/A"),
                      _row("Created By", data["created_by"] ?? "N/A"),
                      _row("Joining Date", data["joiningDate"] ?? "2024-01-01"),
                      _row("Present Address", data["present_address"] ?? "-"),
                      _row(
                        "Permanent Address",
                        data["permanent_address"] ?? "-",
                      ),
                      _row("DOB", data["dob"] ?? "1995-06-21"),
                      _row("Gender", data["gender"] ?? "Male"),
                      _row("Marital Status", data["maritalStatus"] ?? "Single"),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  /// COMMON ROW WIDGET
  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: AppFonts.poppins,
              color: Color(0xFF1A237E),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF37474F),
                fontFamily: AppFonts.poppins,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
