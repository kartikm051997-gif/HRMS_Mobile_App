import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';

import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import 'DashboardScreen.dart';
import 'LiveTrackingScreen.dart';
import 'SettingsScreen.dart';
import 'TasksScreen.dart';
import 'TimelineScreen.dart';

class PaGarBookAdminScreen extends StatelessWidget {
  const PaGarBookAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "PagarBook Geo"),
      drawer: const TabletMobileDrawer(),

      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuItem(
            context,
            icon: Icons.location_on,
            title: 'Live Tracking',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LiveTrackingScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.timeline,
            title: 'Timeline',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TimelineScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.dashboard,
            title: 'Dashboard',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.task_alt,
            title: 'Tasks',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TasksScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontFamily: AppFonts.poppins,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
