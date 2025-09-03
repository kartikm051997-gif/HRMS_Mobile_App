import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/appcolor_dart.dart';
import '../../core/fonts/fonts.dart';

class InfoRow extends StatelessWidget {
  final String iconPath;
  final String label;
  final String value;

  const InfoRow({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(iconPath, width: 24.0, height: 24.0),
          const SizedBox(width: 8),
          Text(
            '$label : ',
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              color: AppColor.blackColor,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: AppFonts.poppins,
                color: AppColor.blackColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
