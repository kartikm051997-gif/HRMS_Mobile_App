import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentaion/pages/UserTrackingScreens/Tracking_TabView_Screen.dart';
import '../../../provider/login_provider/login_provider.dart';
import '../../../core/fonts/fonts.dart';
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
  late LoginProvider loginProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loginProvider = Provider.of<LoginProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final user = loginProvider.loginData?.user;

    final List<Widget> screens = const [
      UserTrackingTabViewScreen(),
      DeliverablesOverviewScreen(),
      EmployeeManagementTabviewScreen(),
      UserProfileScreen(),
    ];

    return Builder(
      builder: (rootContext) {
        return Scaffold(
          body: screens[_selectedIndex],

          // ---------------- FAB -----------------
          floatingActionButton: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (!mounted) return;
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(
                      content: Text('Add button pressed'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          ),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,

          // ---------------- Bottom Navigation -----------------
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomAppBar(
              color: Colors.white,
              elevation: 0,
              notchMargin: 8,
              shape: const CircularNotchedRectangle(),
              child: SizedBox(
                height: 65,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildNavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        index: 0,
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        icon: (Icons.list_rounded),
                        label: 'Deliverables',
                        index: 1,
                      ),
                    ),

                    const SizedBox(width: 40), // ⭐ Space for FAB

                    Expanded(
                      child: _buildNavItem(
                        icon: (Icons.people_rounded),
                        label: 'Employees',
                        index: 2,
                      ),
                    ),
                    Expanded(child: _buildProfileNavItem(user: user, index: 3)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- Navigation Item -----------------
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 1.0),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    icon,
                    color:
                        isSelected
                            ? const Color(0xFF8E0E6B)
                            : Colors.grey.shade400,
                    size: 26,
                  ),
                );
              },
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color:
                    isSelected ? const Color(0xFF8E0E6B) : Colors.grey.shade500,
                fontFamily: AppFonts.poppins,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Profile Navigation Item -----------------
  Widget _buildProfileNavItem({required dynamic user, required int index}) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        // padding: const EdgeInsets.symmetric(vertical: 6),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 1.0, end: isSelected ? 1.15 : 1.0),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFF8E0E6B)
                                  : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
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
                                  user?.fullname != null &&
                                          user!.fullname!.isNotEmpty
                                      ? user.fullname![0].toUpperCase()
                                      : "U",
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? const Color(0xFF8E0E6B)
                                            : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                )
                                : null,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected
                          ? const Color(0xFF8E0E6B)
                          : Colors.grey.shade500,
                  fontFamily: AppFonts.poppins,
                ),
                child: const Text('Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
