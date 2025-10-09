// lib/presentaion/pages/dashboradScreens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../provider/login_provider/login_provider.dart';
import '../UserProfileScreens/User_Profile_Screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final user = loginProvider.loginData?.user;

    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          title: Text(
            "Dashboard",
            style: TextStyle(fontFamily: AppFonts.poppins),
          ),
          centerTitle: true,

          // 🌈 Gradient Background
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(
          "Welcome, ${user?.fullname ?? 'User'}",
          style: TextStyle(fontSize: 18, fontFamily: AppFonts.poppins),
        ),
      ),
    );
  }
}
