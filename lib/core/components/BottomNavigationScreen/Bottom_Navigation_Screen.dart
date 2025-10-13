import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/login_provider/login_provider.dart';
import '../../../core/fonts/fonts.dart';
import '../../../presentaion/pages/dashboradScreens/Tracking_TabView_Screen.dart';
import '../../../presentaion/pages/Deliverables Overview/Deliverables_Overview_screen.dart';
import '../../../presentaion/pages/EmployeeManagement/EmployeemangementTabViewScreen/Employee_Management_Tabview.dart';
import '../../../presentaion/pages/UserProfileScreens/User_Profile_Screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final user = loginProvider.loginData?.user;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF8E0E6B),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.poppins,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.poppins,
        ),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list_rounded),
            label: "Deliverables",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: "Employees",
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
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
                        user?.fullname != null && user!.fullname!.isNotEmpty
                            ? user.fullname![0].toUpperCase()
                            : "U",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: AppFonts.poppins,
                        ),
                      )
                      : null,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
