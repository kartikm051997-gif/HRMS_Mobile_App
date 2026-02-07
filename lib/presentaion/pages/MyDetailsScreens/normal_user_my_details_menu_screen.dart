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
  int selectedIndex = -1;

  final List<Map<String, dynamic>> menuItems = [
    {"title": "Employee Details", "icon": Icons.person_outline},
    {"title": "Attendance", "icon": Icons.calendar_today_outlined},
    {"title": "Bank", "icon": Icons.account_balance_outlined},
    {"title": "Salary", "icon": Icons.payments_outlined},
    {"title": "Letters", "icon": Icons.mail_outline},
    {"title": "payslips", "icon": Icons.description_outlined},
    {"title": "assetsdetails", "icon": Icons.inventory_2_outlined},
    {"title": "Circulars", "icon": Icons.campaign_outlined},
    {"title": "Deliverables", "icon": Icons.task_alt_outlined},
    {
      "title": "automated_payroll_individual",
      "icon": Icons.auto_awesome_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final String roleId = loginProvider.userRole?.trim() ?? "";
    final bool isAdmin = roleId == "1";

    if (kDebugMode) {
      print("🔍 NormalUserMyDetailsMenuScreen build");
      print("   Role ID: '$roleId'");
      print("   Is Admin: $isAdmin");
    }

    if (isAdmin) {
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    const primaryColor = Color(0xFF5B7FFF);
    const backgroundColor = Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const TabletMobileDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Details",
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: Column(
        children: [
          // Simple Profile Header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  backgroundImage:
                      widget.empPhoto.isNotEmpty
                          ? NetworkImage(widget.empPhoto)
                          : null,
                  child:
                      widget.empPhoto.isEmpty
                          ? const Icon(
                            Icons.person,
                            size: 28,
                            color: primaryColor,
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.empName,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.poppins,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.empBranch,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFonts.poppins,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleMenuTap(item["title"], index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item["icon"],
                                color: isSelected ? Colors.white : primaryColor,
                                size: 22,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  _getDisplayName(item["title"]),
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : const Color(0xFF1A1A1A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : const Color(0xFF9CA3AF),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayName(String title) {
    switch (title) {
      case "payslips":
        return "Payslips";
      case "assetsdetails":
        return "Assets Details";
      case "automated_payroll_individual":
        return "Automated Payroll";
      default:
        return title;
    }
  }

  void _handleMenuTap(String item, int index) {
    setState(() {
      selectedIndex = index;
    });

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

    final tabIndex = EmployeeDetailsScreen.getTabIndexForMenuItem(item, false);

    if (kDebugMode) {
      print("🔍 NormalUserMenu: Navigating to '$item' -> tab index $tabIndex");
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
              showDrawer: false,
            ),
      ),
    );
  }
}
