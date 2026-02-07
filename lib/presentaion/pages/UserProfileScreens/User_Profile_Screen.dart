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
      backgroundColor: const Color(0xFFF8F9FE),
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Profile Details"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
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
                          radius: 50,
                          backgroundColor: AppColor.primaryColor1.withOpacity(
                            0.1,
                          ),
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
                                      color: AppColor.primaryColor1,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 32,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 6),

                    /// Branch Name
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor1.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user?.locationName ?? "Branch Unknown",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColor.primaryColor1,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// Profile Details Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                      icon: Icons.email_outlined,
                      label: "Email",
                      value: user?.email ?? "N/A",
                    ),
                    const SizedBox(height: 16),
                    _buildProfileDetailRow(
                      icon: Icons.badge_outlined,
                      label: "Username",
                      value: user?.username ?? "N/A",
                    ),
                    const SizedBox(height: 16),
                    _buildProfileDetailRow(
                      icon: Icons.access_time_outlined,
                      label: "Last Login",
                      value: user?.lastLogin ?? "N/A",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor1,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        Icon(icon, color: AppColor.primaryColor1, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontFamily: AppFonts.poppins,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              "Are you sure you want to logout?",
              style: TextStyle(fontFamily: AppFonts.poppins),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppColor.primaryColor1,
                    fontFamily: AppFonts.poppins,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _logout(context);
                },
                child: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: AppFonts.poppins,
                    fontWeight: FontWeight.w500,
                  ),
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
