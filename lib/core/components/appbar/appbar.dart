import 'package:flutter/material.dart';

import '../../constants/appcolor_dart.dart';
import '../../fonts/fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        title!,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.poppins,
          color: AppColor.whiteColor,
        ),
      ),
      // Container(
      //   height: 50,
      //   width: 180,
      //   decoration: BoxDecoration(
      //     image: DecorationImage(
      //       image: AssetImage(AppImages.logo),
      //       fit: BoxFit.contain,
      //     ),
      //   ),
      // ),
      centerTitle: true,
      leading: Builder(
        builder:
            (context) => IconButton(
              icon: const Icon(Icons.menu, size: 30, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
