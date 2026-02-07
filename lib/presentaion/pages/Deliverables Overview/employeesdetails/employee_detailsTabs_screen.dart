import 'package:flutter/foundation.dart';
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
import '../../../../provider/login_provider/login_provider.dart';

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
  final int initialTabIndex;
  final bool showDrawer; // Option to show/hide drawer

  const EmployeeDetailsScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
    this.initialTabIndex = 0,
    this.showDrawer = true, // Default to showing drawer
  });

  // Static helper method to get correct tab index for menu items
  // This handles mapping from menu screen item names to actual tab names
  static int getTabIndexForMenuItem(String menuItemName, bool isAdmin) {
    // Map menu item names to tab names
    final Map<String, String> menuToTabName = {
      "Letters": "Letter",
      "payslips": "Payslip",
      "assetsdetails": "Assets Details",
      "Circulars": "Circular",
      "Deliverables": "Task Details",
    };

    // Get the actual tab name
    final tabName = menuToTabName[menuItemName] ?? menuItemName;

    // Define tab order for admin and normal users
    final List<String> adminTabs = [
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

    final List<String> normalUserTabs = [
      "Employee Details",
      "Attendance",
      "Bank",
      "Salary",
      "Letter",
      "Payslip",
      "Assets Details",
      "Circular",
      "Task Details",
    ];

    final tabs = isAdmin ? adminTabs : normalUserTabs;
    final index = tabs.indexOf(tabName);

    if (kDebugMode) {
      print(
        "   📍 getTabIndexForMenuItem: '$menuItemName' -> '$tabName' -> index $index",
      );
    }

    return index >= 0 ? index : 0;
  }

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> menuItems = [];

  // All available tabs (admin sees all)
  final List<String> _allMenuItems = [
    "Employee Details",
    "Attendance",
    "Bank",
    "Documents",
    "Salary",
    "Job Application", // Admin only
    "PF", // Admin only
    "ESI", // Admin only
    "Letter",
    "Payslip",
    "Assets Details",
    "Circular",
    "Task Details",
  ];

  // Admin-only tabs (hidden for normal users)
  final List<String> _adminOnlyTabs = [
    "Job Application",
    "PF",
    "ESI",
    "Documents",
  ];

  @override
  void initState() {
    super.initState();
    _initializeTabs();

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

  void _initializeTabs() {
    // Get user role
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final String roleId = loginProvider.userRole?.trim() ?? "";
    final bool isAdmin = roleId == "1";

    if (kDebugMode) {
      print("🔍 EmployeeDetailsScreen - Initializing tabs");
      print("   Role ID: '$roleId'");
      print("   Is Admin: $isAdmin");
    }

    // Filter tabs based on user role
    if (isAdmin) {
      // Admin sees all tabs including PF and ESI
      menuItems = List.from(_allMenuItems);
      if (kDebugMode) {
        print(
          "   ✅ Admin user - Showing all ${menuItems.length} tabs including PF and ESI",
        );
        print("   ✅ Tabs: ${menuItems.join(" | ")}");
      }
    } else {
      // Normal user: exclude admin-only tabs (Documents, Job Application, PF, ESI)
      menuItems =
          _allMenuItems
              .where((item) => !_adminOnlyTabs.contains(item))
              .toList();
      if (kDebugMode) {
        print(
          "   ✅ Normal user - Filtered tabs: ${menuItems.length} (removed: ${_adminOnlyTabs.join(", ")})",
        );
        print("   ✅ Tabs: ${menuItems.join(" | ")}");
        // Verify PF and ESI are NOT in the list
        if (menuItems.contains("PF") || menuItems.contains("ESI")) {
          print("   ❌ ERROR: PF or ESI found in normal user tabs!");
        } else {
          print("   ✅ Verified: PF and ESI correctly excluded for normal user");
        }
      }
    }

    // Map initialTabIndex to the correct index in filtered menuItems
    // For normal users, ensure we always start at a valid tab (index 0 = Employee Details)
    int adjustedIndex = _getAdjustedTabIndex(widget.initialTabIndex, isAdmin);

    // Safety check: ensure adjustedIndex is valid for the filtered menuItems
    if (adjustedIndex < 0 || adjustedIndex >= menuItems.length) {
      if (kDebugMode) {
        print(
          "   ⚠️ Adjusted index $adjustedIndex is out of range, defaulting to 0",
        );
      }
      adjustedIndex = 0;
    }

    // Initialize TabController with filtered length
    _tabController = TabController(
      length: menuItems.length,
      vsync: this,
      initialIndex: adjustedIndex,
    );

    if (kDebugMode) {
      print("   ✅ TabController initialized with length: ${menuItems.length}");
      print("   ✅ menuItems: ${menuItems.join(" | ")}");
      print(
        "   ✅ Initial tab index: $adjustedIndex (requested: ${widget.initialTabIndex})",
      );
    }
  }

  // Adjust tab index - maps from original index to filtered index
  int _getAdjustedTabIndex(int originalIndex, bool isAdmin) {
    // Ensure we have menuItems initialized
    if (menuItems.isEmpty) {
      if (kDebugMode) {
        print("   ⚠️ menuItems is empty, defaulting to index 0");
      }
      return 0;
    }

    // Clamp to valid range - always start at 0 (Employee Details) if index is invalid
    final adjustedIndex = originalIndex.clamp(0, menuItems.length - 1);

    if (kDebugMode) {
      print(
        "   📍 _getAdjustedTabIndex: $originalIndex -> $adjustedIndex (menuItems.length: ${menuItems.length})",
      );
      print(
        "   📍 First tab will be: ${menuItems.isNotEmpty ? menuItems[adjustedIndex] : 'N/A'}",
      );
    }

    return adjustedIndex;
  }

  List<Widget> _buildTabViews(
    bool isAdmin,
    EmployeeDetailsProvider provider,
    Map<String, dynamic> data,
    String avatarUrl,
  ) {
    // Build views in the EXACT same order as menuItems
    final views = <Widget>[];

    for (String tabName in menuItems) {
      Widget view;
      switch (tabName) {
        case "Employee Details":
          view = _buildEmployeeDetailsTab(provider, data, avatarUrl);
          break;
        case "Attendance":
          view = AttendanceCalendarScreen(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        case "Bank":
          view = BankScreen(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        case "Documents":
          view = DocumentsScreen(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        case "Salary":
          view = SalaryScreen(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        case "Job Application":
          view = ProfileTabBarView(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        case "PF":
          view = PfScreen(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        case "ESI":
          view = ESIScreen(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        case "Letter":
          view = LetterScreen(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        case "Payslip":
          view = PaySlipScreen(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        case "Assets Details":
          view = AssetsDetailsScreen(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        case "Circular":
          view = CircularDetailsScreen(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        case "Task Details":
          view = TaskDetailsScreen(
            empId: widget.empId,
            empPhoto: widget.empPhoto,
            empName: widget.empName,
            empDesignation: widget.empDesignation,
            empBranch: widget.empBranch,
          );
          break;
        default:
          view = _buildEmployeeDetailsTab(provider, data, avatarUrl);
          break;
      }
      views.add(view);
    }

    return views;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeDetailsProvider>();
    final data = provider.employeeDetails ?? {};

    // Get user role for building tab views
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final String roleId = loginProvider.userRole?.trim() ?? "";
    final bool isAdmin = roleId == "1";

    const String defaultPhoto =
        "https://cdn-icons-png.flaticon.com/512/847/847969.png";

    final String avatarUrl =
        widget.empPhoto.isNotEmpty
            ? widget.empPhoto
            : (data["photo"]?.toString().isNotEmpty ?? false)
            ? data["photo"]
            : defaultPhoto;

    // Build tab views based on current role
    final currentTabViews = _buildTabViews(isAdmin, provider, data, avatarUrl);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: widget.showDrawer ? const TabletMobileDrawer() : null,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95),
        child: AppBar(
          iconTheme: IconThemeData(color: AppColor.whiteColor),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                color: Color(0xff0FF5B7FFF),

            ),
          ),
          title: const Text(
            "Employee Details",
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
            tabs:
                menuItems.isNotEmpty
                    ? menuItems.map((e) => Tab(text: e)).toList()
                    : [const Tab(text: "Employee Details")], // Fallback
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children:
            currentTabViews.isNotEmpty
                ? currentTabViews
                : [
                  _buildEmployeeDetailsTab(provider, data, avatarUrl),
                ], // Fallback
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
    const primaryColor = Color(0xff0FF5B7FFF);

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
                      color: Color(0xff0FF5B7FFF),
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
                                  (data["name"]?.toString().isNotEmpty ?? false)
                                      ? data["name"].toString()
                                      : (widget.empName.isNotEmpty
                                          ? widget.empName
                                          : "E"),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Employee Name - ✅ Prioritize backend data
                        Text(
                          (data["name"]?.toString().isNotEmpty ?? false)
                              ? data["name"].toString()
                              : (widget.empName.isNotEmpty
                                  ? widget.empName
                                  : "N/A"),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.poppins,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Employee ID Badge - ✅ Prioritize backend data
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
                            "ECI ID: ${(data["empId"]?.toString().isNotEmpty ?? false) ? data["empId"].toString() : (widget.empId.isNotEmpty ? widget.empId : "N/A")}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.poppins,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Designation - ✅ Prioritize backend data
                        Text(
                          (data["designation"]?.toString().isNotEmpty ?? false)
                              ? data["designation"].toString()
                              : (widget.empDesignation.isNotEmpty &&
                                      widget.empDesignation != "N/A"
                                  ? widget.empDesignation
                                  : "N/A"),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.poppins,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Branch - ✅ Prioritize backend data
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
                              (data["branch"]?.toString().isNotEmpty ?? false)
                                  ? data["branch"].toString()
                                  : (widget.empBranch.isNotEmpty &&
                                          widget.empBranch != "N/A"
                                      ? widget.empBranch
                                      : "N/A"),
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
                      "Full Name",
                      (data["name"]?.toString().isNotEmpty ?? false)
                          ? data["name"].toString()
                          : (widget.empName.isNotEmpty
                              ? widget.empName
                              : "N/A"),
                      Icons.person_outline,
                    ),
                    _buildInfoRow(
                      "Designation",
                      (data["designation"]?.toString().isNotEmpty ?? false)
                          ? data["designation"].toString()
                          : (widget.empDesignation.isNotEmpty &&
                                  widget.empDesignation != "N/A"
                              ? widget.empDesignation
                              : "N/A"),
                      Icons.work_outline,
                    ),
                    _buildInfoRow(
                      "Branch",
                      (data["branch"]?.toString().isNotEmpty ?? false)
                          ? data["branch"].toString()
                          : (widget.empBranch.isNotEmpty &&
                                  widget.empBranch != "N/A"
                              ? widget.empBranch
                              : "N/A"),
                      Icons.location_on_outlined,
                    ),
                    _buildInfoRow(
                      "Joining Date",
                      (data["joiningDate"]?.toString().isNotEmpty ?? false)
                          ? data["joiningDate"].toString()
                          : "N/A",
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
                      (data["mobile"]?.toString().isNotEmpty ?? false)
                          ? data["mobile"].toString()
                          : "N/A",
                      Icons.phone_outlined,
                    ),
                    _buildInfoRow(
                      "Email",
                      (data["email"]?.toString().isNotEmpty ?? false)
                          ? data["email"].toString()
                          : "N/A",
                      Icons.email_outlined,
                    ),
                    _buildInfoRow(
                      "Present Address",
                      (data["present_address"]?.toString().isNotEmpty ?? false)
                          ? data["present_address"].toString()
                          : (data["presentAddress"]?.toString().isNotEmpty ??
                              false)
                          ? data["presentAddress"].toString()
                          : "N/A",
                      Icons.home_outlined,
                    ),
                    _buildInfoRow(
                      "Permanent Address",
                      (data["permanent_address"]?.toString().isNotEmpty ??
                              false)
                          ? data["permanent_address"].toString()
                          : (data["permanentAddress"]?.toString().isNotEmpty ??
                              false)
                          ? data["permanentAddress"].toString()
                          : "N/A",
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
                      (data["dob"]?.toString().isNotEmpty ?? false)
                          ? data["dob"].toString()
                          : (data["dateOfBirth"]?.toString().isNotEmpty ??
                              false)
                          ? data["dateOfBirth"].toString()
                          : "N/A",
                      Icons.cake_outlined,
                    ),
                    _buildInfoRow(
                      "Gender",
                      (data["gender"]?.toString().isNotEmpty ?? false)
                          ? data["gender"].toString()
                          : "N/A",
                      Icons.people_outline,
                    ),
                    _buildInfoRow(
                      "Marital Status",
                      (data["maritalStatus"]?.toString().isNotEmpty ?? false)
                          ? data["maritalStatus"].toString()
                          : "N/A",
                      Icons.favorite_outline,
                    ),
                    _buildInfoRow(
                      "Aadhar Number",
                      (data["aadhar"]?.toString().isNotEmpty ?? false)
                          ? data["aadhar"].toString()
                          : "N/A",
                      Icons.credit_card_outlined,
                    ),
                    _buildInfoRow(
                      "PAN Number",
                      (data["pan"]?.toString().isNotEmpty ?? false)
                          ? data["pan"].toString()
                          : (data["panNumber"]?.toString().isNotEmpty ?? false)
                          ? data["panNumber"].toString()
                          : "N/A",
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
                      (data["payroll_category"]?.toString().isNotEmpty ?? false)
                          ? data["payroll_category"].toString()
                          : (data["payrollCategory"]?.toString().isNotEmpty ??
                              false)
                          ? data["payrollCategory"].toString()
                          : "N/A",
                      Icons.category_outlined,
                    ),
                    _buildInfoRow(
                      "Education",
                      (data["education"]?.toString().isNotEmpty ?? false)
                          ? data["education"].toString()
                          : (data["educationQualification"]
                                  ?.toString()
                                  .isNotEmpty ??
                              false)
                          ? data["educationQualification"].toString()
                          : "N/A",
                      Icons.school_outlined,
                    ),
                    // Recruiter - Show circular avatar with backend data
                    _buildInfoRowWithAvatar(
                      "Recruiter",
                      (data["recruiter"]?.toString().isNotEmpty ?? false)
                          ? data["recruiter"].toString()
                          : "N/A",
                      (data["recruiterAvatar"]?.toString().isNotEmpty ?? false)
                          ? data["recruiterAvatar"].toString()
                          : null,
                      Icons.person_search_rounded,
                    ),
                    // Created By - Show circular avatar with backend data
                    _buildInfoRowWithAvatar(
                      "Created By",
                      (data["created_by"]?.toString().isNotEmpty ?? false)
                          ? data["created_by"].toString()
                          : (data["createdBy"]?.toString().isNotEmpty ?? false)
                          ? data["createdBy"].toString()
                          : "N/A",
                      (data["createdByAvatar"]?.toString().isNotEmpty ?? false)
                          ? data["createdByAvatar"].toString()
                          : null,
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
        color: Color(0xff0FF5B7FFF),

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
              color: Color(0xff0FF5B7FFF),
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
                    color: Color(0xff0FF5B7FFF),

                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                    color: Colors.white,
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
    const primaryColor = Color(0xff0FF5B7FFF);
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
    const primaryColor = Color(0xff0FF5B7FFF);
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
                        // ✅ Always show circular avatar (even if imageUrl is null)
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff0FF5B7FFF),

                            border: Border.all(color: borderColor),
                          ),
                          child: ClipOval(
                            child:
                                (imageUrl != null && imageUrl.isNotEmpty)
                                    ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return _buildSmallDefaultAvatar(value);
                                      },
                                    )
                                    : _buildSmallDefaultAvatar(
                                      value,
                                    ), // ✅ Show default avatar when imageUrl is null
                          ),
                        ),
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
        color: Color(0xff0FF5B7FFF),

      ),
      child: Center(
        child: Text(
          (name.isNotEmpty && name != "N/A") ? name[0].toUpperCase() : "?",
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
