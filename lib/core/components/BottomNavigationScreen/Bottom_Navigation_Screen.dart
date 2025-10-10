import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/Deliverables_Overview_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeManagement/EmployeemangementTabViewScreen/Employee_Management_Tabview.dart';
import 'package:hrms_mobile_app/presentaion/pages/UserProfileScreens/User_Profile_Screen.dart';
import 'package:provider/provider.dart';

import '../../../presentaion/pages/dashboradScreens/Tracking_TabView_Screen.dart';
import '../../../provider/login_provider/login_provider.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    TrackingTabViewScreen(),
    DeliverablesOverviewScreen(),
    EmployeeManagementTabviewScreen(),
    UserProfileScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {"icon": Icons.home_rounded, "label": "Home"},
    {"icon": Icons.list_rounded, "label": "Deliverables"},
    {"icon": Icons.people_rounded, "label": "Employees"},
    {"icon": Icons.person_rounded, "label": "Profile"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _navItems.length,
                (index) => _buildIcon(
                  icon: _navItems[index]["icon"],
                  label: _navItems[index]["label"],
                  index: index,
                ),
              ),
            ),
          ),
        ),
      ),
      // floatingActionButton: Container(
      //   height: 65,
      //   width: 65,
      //   decoration: BoxDecoration(
      //     color: const Color(0xFFD4145A),
      //     shape: BoxShape.circle,
      //     boxShadow: [
      //       BoxShadow(
      //         color: const Color(0xFFD4145A).withOpacity(0.4),
      //         blurRadius: 20,
      //         spreadRadius: 2,
      //       ),
      //     ],
      //   ),
      //   child: Material(
      //     color: Colors.transparent,
      //     child: InkWell(
      //       onTap: () {
      //         setState(() {
      //           _selectedIndex = 1;
      //         });
      //       },
      //       splashColor: Colors.white.withOpacity(0.3),
      //       borderRadius: BorderRadius.circular(50),
      //       child: const Center(
      //         child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
      //       ),
      //     ),
      //   ),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildIcon({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool isSelected = _selectedIndex == index;
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final user = loginProvider.loginData?.user;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.3 : 1.0,
              child:
                  index ==
                          3 // 👈 3 = Profile tab index
                      ? CircleAvatar(
                        radius: isSelected ? 18 : 16,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            (user?.avatar != null && user!.avatar!.isNotEmpty)
                                ? NetworkImage(
                                  "https://app.draravindsivf.com/hrms/${user.avatar}",
                                )
                                : null,
                        child:
                            (user?.avatar == null || user!.avatar!.isEmpty)
                                ? Text(
                                  user?.fullname != null &&
                                          user!.fullname!.isNotEmpty
                                      ? user.fullname![0].toUpperCase()
                                      : "U",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                )
                                : null,
                      )
                      : Icon(
                        icon,
                        size: 28,
                        color:
                            isSelected
                                ? const Color(0xFF8E0E6B)
                                : Colors.grey.shade400,
                      ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color:
                    isSelected ? const Color(0xFF8E0E6B) : Colors.grey.shade500,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontFamily: AppFonts.poppins,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
