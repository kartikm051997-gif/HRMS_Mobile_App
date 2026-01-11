import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../core/constants/appcolor_dart.dart';
import '../../../provider/UserTrackingProvider/UserTrackingProvider.dart';
import '../../../provider/login_provider/login_provider.dart';
import '../../../servicesAPI/LogOutApiService/LogOutApiService.dart';
import '../authenticationScreens/loginScreens/login_screen.dart';
import 'FullImageViewScreen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final user = loginProvider.loginData?.user;
    final userId = loginProvider.loginData?.user?.userId;

    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Profile Details"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Profile Header Background
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  /// Profile Avatar
                  GestureDetector(
                    onTap: () {
                      if (user?.avatar != null && user!.avatar!.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FullImageView(
                                  imageUrl:
                                      "https://app.draravindsivf.com/hrms/${user.avatar}",
                                  tag: 'profileImageHero',
                                ),
                          ),
                        );
                      }
                    },
                    child: Hero(
                      tag: 'profileImageHero',
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withOpacity(0.2),
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
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                )
                                : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// User Name
                  Text(
                    user?.fullname ?? "User",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                  const SizedBox(height: 8),

                  /// Branch Name
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.locationName ?? "Branch Unknown",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Profile Details Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileDetailRow(
                    icon: Icons.person_outline,
                    label: "Full Name",
                    value: user?.fullname ?? "N/A",
                  ),
                  const SizedBox(height: 16),
                  _buildProfileDetailRow(
                    icon: Icons.person_outline,
                    label: "Email",
                    value: user?.email ?? "N/A",
                  ),
                  const SizedBox(height: 16),
                  _buildProfileDetailRow(
                    icon: Icons.badge_outlined,
                    label: "UserName",
                    value: user?.username ?? "N/A",
                  ),
                  const SizedBox(height: 16),

                  _buildProfileDetailRow(
                    icon: Icons.badge_outlined,
                    label: "LastLogin",
                    value: user?.lastLogin ?? "N/A",
                  ),
                ],
              ),
            ),

            /// Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors
                            .transparent, // make button background transparent
                    shadowColor: Colors.transparent, // remove button shadow
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColor.primaryColor2.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColor.primaryColor2, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: AppFonts.poppins,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // close dialog
                  _logout(context); // ✅ correct context
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final trackingProvider = context.read<UserTrackingProvider>();

    String token = prefs.getString('token') ?? '';

    final logoutResponse = await ApiService.logoutUser(token);

    if (logoutResponse.status == "success") {
      await trackingProvider.clearCurrentUserData(clearHistory: false);
      await prefs.clear();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
