import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/login_provider/login_provider.dart';
import '../Deliverables Overview/employeesdetails/employee_detailsTabs_screen.dart';
import '../Deliverables Overview/employeesdetails/task_Details_screen.dart';

class MyDetailsMenuScreen extends StatefulWidget {
  final String empId;
  final String empPhoto;
  final String empName;
  final String empDesignation;
  final String empBranch;
  final bool? isAdmin; // Optional: if null, will check from LoginProvider

  const MyDetailsMenuScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
    this.isAdmin,
  });

  @override
  State<MyDetailsMenuScreen> createState() => _MyDetailsMenuScreenState();
}

class _MyDetailsMenuScreenState extends State<MyDetailsMenuScreen> {
  int selectedIndex = -1; // No selection by default

  // Admin menu items (without "Employee Details" in list - matches first image)
  final List<String> adminMenuItems = [
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

  // Normal user menu items (with "Employee Details" as first item - matches second image)
  final List<String> normalUserMenuItems = [
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

  // Map menu items to tab indices - will use helper method from EmployeeDetailsScreen
  // This map is kept for reference but actual mapping is done via getTabIndexForMenuItem

  bool get isAdminUser {
    if (widget.isAdmin != null) return widget.isAdmin!;
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    return loginProvider.userRole == "1";
  }

  List<String> get menuItems {
    return isAdminUser ? adminMenuItems : normalUserMenuItems;
  }

  String get headerTitle {
    return isAdminUser ? "Employee Details" : "My Details";
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          headerTitle,
          style: const TextStyle(
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

                  // Special handling for "Deliverables" - navigate directly to TaskDetailsScreen
                  if (item == "Deliverables") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => TaskDetailsScreen(
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
                    isAdminUser,
                  );

                  if (kDebugMode) {
                    print(
                      "🔍 MyDetailsMenu: Navigating to '$item' -> tab index $tabIndex (isAdmin: $isAdminUser)",
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
