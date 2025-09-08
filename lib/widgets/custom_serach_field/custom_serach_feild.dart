import 'package:flutter/material.dart';
import '../../core/constants/appcolor_dart.dart';
import '../../core/fonts/fonts.dart';

class CustomSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final Function()? onClear;
  final bool autoFocus;

  const CustomSearchField({
    super.key,
    required this.controller,
    this.hintText = "Search...",
    this.onChanged,
    this.onClear,
    this.autoFocus = false,
  });

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: AppColor.gryColor,
      controller: widget.controller,
      autofocus: widget.autoFocus,
      onChanged: (value) {
        if (widget.onChanged != null) widget.onChanged!(value);
        setState(() {}); // Update suffix icon visibility
      },
      style: const TextStyle(
        fontSize: 14,
        color: AppColor.blackColor,
        fontFamily: AppFonts.poppins,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: AppColor.hinttextblackColor,
          fontSize: 14,
          fontFamily: AppFonts.poppins,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColor.primaryColor2),

        // ✅ Show clear button when user types
        suffixIcon:
            widget.controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    widget.controller.clear();
                    if (widget.onClear != null) widget.onClear!();
                    setState(() {});
                  },
                )
                : null,

        // ✅ Full Border Design
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColor.blackColor, // Default border color
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColor.primaryColor2, // Highlight border when focused
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red, // Border when there's an error
            width: 1,
          ),
        ),
      ),
    );
  }
}
