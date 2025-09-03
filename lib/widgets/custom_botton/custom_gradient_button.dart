import 'package:flutter/material.dart';

class AppFonts {
  static const String poppins = "Poppins"; // ✅ Ensure this is defined
}

class CustomGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final double width;
  final double borderRadius;
  final List<Color> gradientColors;
  final TextStyle? textStyle; // ✅ Make nullable, remove default here
  final IconData? icon;
  final double iconSize;
  final Color? iconColor;

  const CustomGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 50,
    this.width = double.infinity,
    this.borderRadius = 12,
    this.gradientColors = const [Color(0xFF6E0E6B), Color(0xFFD4145A)],
    this.textStyle, // ✅ No default here
    this.icon,
    this.iconSize = 20,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      fontSize: 16,
      color: Colors.white,
      fontFamily: AppFonts.poppins, // ✅ Now works fine!
      fontWeight: FontWeight.w500,
    );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: iconSize,
                    color:
                        iconColor ?? textStyle?.color ?? defaultTextStyle.color,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style:
                      textStyle ?? defaultTextStyle, // ✅ Apply default if null
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
