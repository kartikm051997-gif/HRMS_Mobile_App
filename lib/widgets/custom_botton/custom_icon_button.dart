import 'package:flutter/material.dart';

class CustomIconSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color borderColor;
  final Color iconColor;
  final Color backgroundColor;

  const CustomIconSquareButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.borderColor = const Color(0xFFCBD5E0), // light grey border
    this.iconColor = Colors.black87,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(12), // rounded corners
        ),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }
}
