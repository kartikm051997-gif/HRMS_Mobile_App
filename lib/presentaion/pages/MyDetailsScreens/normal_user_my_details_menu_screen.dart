import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/login_provider/login_provider.dart';
import '../Deliverables Overview/employeesdetails/employee_detailsTabs_screen.dart';
import 'deliverables_screen.dart';
import 'automated_payroll_individual_screen.dart';
import 'admin_my_details_menu_screen.dart';

class NormalUserMyDetailsMenuScreen extends StatefulWidget {
  final String empId;
  final String empPhoto;
  final String empName;
  final String empDesignation;
  final String empBranch;

  const NormalUserMyDetailsMenuScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<NormalUserMyDetailsMenuScreen> createState() =>
      _NormalUserMyDetailsMenuScreenState();
}

class _NormalUserMyDetailsMenuScreenState
    extends State<NormalUserMyDetailsMenuScreen> {
  int selectedIndex = 0; // "Employee Details" is selected by default

  // Normal user menu items (with "Employee Details" as first item - matches second image)
  final List<String> menuItems = [
    "Employee Details",
    "Attendance",
    "Bank",
    "Salary",
    "Letters",
    "payslips",
    "assetsdetails",
    "Circulars",
    "Deliverables",
    "automated_payroll_individual",
  ];

  // Map menu items to tab indices in EmployeeDetailsScreen
  // Normal user tabs: [0:Employee Details, 1:Attendance, 2:Bank, 3:Salary, 4:Letter, 5:Payslip, 6:Assets Details, 7:Circular, 8:Task Details]
  // Note: Documents, Job Application, PF, ESI are removed for normal users
  final Map<String, int> menuToTabIndex = {
    "Employee Details": 0,
    "Attendance": 1,
    "Bank": 2,
    "Salary": 3, // Salary is at index 3 for normal users
    "Letters": 4, // Letter is at index 4 for normal users
    "payslips": 5, // Payslip is at index 5 for normal users
    "assetsdetails": 6, // Assets Details is at index 6 for normal users
    "Circulars": 7, // Circular is at index 7 for normal users
    // "Deliverables" and "automated_payroll_individual" navigate to standalone screens
  };

  @override
  Widget build(BuildContext context) {
    // ✅ CRITICAL: Check user role dynamically - if admin, redirect to admin screen
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final String roleId = loginProvider.userRole?.trim() ?? "";
    final bool isAdmin = roleId == "1";

    // Debug logging
    if (kDebugMode) {
      print("🔍 NormalUserMyDetailsMenuScreen build");
      print("   Role ID: '$roleId'");
      print("   Role ID length: ${roleId.length}");
      print("   Is Admin: $isAdmin");
      print("   User ID: ${widget.empId}");
    }

    if (isAdmin) {
      // User is admin, redirect to admin menu screen
      if (kDebugMode) {
        print("   ⚠️ Is admin - redirecting to AdminMyDetailsMenuScreen");
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (_) => AdminMyDetailsMenuScreen(
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

    if (kDebugMode) {
      print("   ✅ Normal user confirmed - showing normal user menu");
    }

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
          "My Details",
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
                    false,
                  );

                  if (kDebugMode) {
                    print(
                      "🔍 NormalUserMenu: Navigating to '$item' -> tab index $tabIndex",
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
