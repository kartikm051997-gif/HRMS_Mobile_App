import 'package:flutter/material.dart';
import '../../core/fonts/fonts.dart';

class CustomMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  final Color containerColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  const CustomMenuButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.containerColor = Colors.deepPurple,
    this.borderColor = Colors.transparent,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: containerColor, // now customizable
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1), // border
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor), // customizable color
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: textColor, // customizable text color
                fontSize: 16,
                fontFamily: AppFonts.poppins,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
