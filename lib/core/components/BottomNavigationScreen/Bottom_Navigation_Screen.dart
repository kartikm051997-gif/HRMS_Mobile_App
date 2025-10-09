import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/presentaion/pages/dashboradScreens/dashboard_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables Overview/Deliverables_Overview_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeManagement/EmployeemangementTabViewScreen/Employee_Management_Tabview.dart';
import 'package:hrms_mobile_app/presentaion/pages/UserProfileScreens/User_Profile_Screen.dart';

import '../../../widgets/custom_botton/custom_gradient_button.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DeliverablesOverviewScreen(),
    EmployeeManagementTabviewScreen(),
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF8E0E6B),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontFamily: AppFonts.poppins,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppFonts.poppins,
          fontWeight: FontWeight.w400,
        ),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Deliverables",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: "Employees",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
