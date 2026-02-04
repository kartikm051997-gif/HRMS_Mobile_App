import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/login_provider/login_provider.dart';
import '../Deliverables Overview/employeesdetails/employee_detailsTabs_screen.dart';
import 'deliverables_screen.dart';
import 'automated_payroll_individual_screen.dart';
import 'normal_user_my_details_menu_screen.dart';

class AdminMyDetailsMenuScreen extends StatefulWidget {
  final String empId;
  final String empPhoto;
  final String empName;
  final String empDesignation;
  final String empBranch;

  const AdminMyDetailsMenuScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<AdminMyDetailsMenuScreen> createState() =>
      _AdminMyDetailsMenuScreenState();
}

class _AdminMyDetailsMenuScreenState extends State<AdminMyDetailsMenuScreen> {
  int selectedIndex = -1;

  // Admin menu items (with "Employee Details" as first item - includes PF, ESI, Job Application, Documents)
  final List<String> menuItems = [
    "Employee Details",
    "Attendance",
    "Bank",
    "Documents",
    "Salary",
    "Job Application",
    "PF",
    "ESI",
    "Letters",
    "payslips",
    "assetsdetails",
    "Circulars",
    "Deliverables",
    "automated_payroll_individual",
  ];

  // Map menu items to tab indices in EmployeeDetailsScreen
  // Admin tabs: [0:Employee Details, 1:Attendance, 2:Bank, 3:Documents, 4:Salary, 5:Job Application, 6:PF, 7:ESI, 8:Letter, 9:Payslip, 10:Assets Details, 11:Circular, 12:Task Details]
  final Map<String, int> menuToTabIndex = {
    "Employee Details": 0,
    "Attendance": 1,
    "Bank": 2,
    "Salary": 4, // Salary is at index 4 (after Documents)
    "Letters": 8, // Letter is at index 8
    "payslips": 9, // Payslip is at index 9
    "assetsdetails": 10, // Assets Details is at index 10
    "Circulars": 11, // Circular is at index 11
    // "Deliverables" and "automated_payroll_individual" navigate to standalone screens
  };

  @override
  Widget build(BuildContext context) {
    // ✅ CRITICAL: Check user role dynamically - if not admin, redirect to normal user screen
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final String roleId = loginProvider.userRole?.trim() ?? "";
    final bool isAdmin = roleId == "1";

    // Debug logging
    if (kDebugMode) {
      print("🔍 AdminMyDetailsMenuScreen build");
      print("   Role ID: '$roleId'");
      print("   Role ID length: ${roleId.length}");
      print("   Is Admin: $isAdmin");
      print("   User ID: ${widget.empId}");
    }

    if (!isAdmin) {
      // User is not admin, redirect to normal user menu screen
      if (kDebugMode) {
        print("   ⚠️ Not admin - redirecting to NormalUserMyDetailsMenuScreen");
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (_) => NormalUserMyDetailsMenuScreen(
                    empId: widget.empId,
                    empPhoto: widget.empPhoto,
                    empName: widget.empName,
                    empDesignation: widget.empDesignation,
                    empBranch: widget.empBranch,
                  ),
            ),
          );
        }
      });
      // Return empty container while redirecting
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (kDebugMode) print("   ✅ Admin confirmed - showing admin menu");

    const primaryColor = Color(0xFF8E0E6B);
    const backgroundColor = Color(0xFFF8FAFC);
    const cardBackgroundColor = Colors.white;
    const selectedBackgroundColor = Color(0xFF8E0E6B);
    const textColor = Color(0xFF1E293B);
    const dividerColor = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const TabletMobileDrawer(),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "Employee Details",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: menuItems.length,
            separatorBuilder:
                (context, index) =>
                    Divider(height: 1, thickness: 1, color: dividerColor),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final isSelected = selectedIndex == index;

              return InkWell(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });

                  // Special handling for "Deliverables" - navigate to standalone screen
                  if (item == "Deliverables") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => DeliverablesScreen(
                              empId: widget.empId,
                              empPhoto: widget.empPhoto,
                              empName: widget.empName,
                              empDesignation: widget.empDesignation,
                              empBranch: widget.empBranch,
                            ),
                      ),
                    );
                    return;
                  }

                  // Special handling for "automated_payroll_individual" - navigate to standalone screen
                  if (item == "automated_payroll_individual") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => AutomatedPayrollIndividualScreen(
                              empId: widget.empId,
                              empPhoto: widget.empPhoto,
                              empName: widget.empName,
                              empDesignation: widget.empDesignation,
                              empBranch: widget.empBranch,
                            ),
                      ),
                    );
                    return;
                  }

                  // Navigate to EmployeeDetailsScreen with the selected tab
                  // Use the helper method from EmployeeDetailsScreen to get correct index
                  final tabIndex = EmployeeDetailsScreen.getTabIndexForMenuItem(
                    item,
                    true,
                  );

                  if (kDebugMode) {
                    print(
                      "🔍 AdminMenu: Navigating to '$item' -> tab index $tabIndex",
                    );
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EmployeeDetailsScreen(
                            empId: widget.empId,
                            empPhoto: widget.empPhoto,
                            empName: widget.empName,
                            empDesignation: widget.empDesignation,
                            empBranch: widget.empBranch,
                            initialTabIndex: tabIndex,
                            showDrawer:
                                false, // Don't show drawer when navigated from menu
                          ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? selectedBackgroundColor
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
