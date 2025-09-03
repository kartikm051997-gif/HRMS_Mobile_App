import 'package:flutter/material.dart';

import '../../core/constants/appcolor_dart.dart';

class CustomBox extends StatelessWidget {
  final String heading;
  final String subHeading;
  final Color headingColor;
  final Color subHeadingColor;

  const CustomBox({
    super.key,
    required this.heading,
    required this.subHeading,
    required this.headingColor,
    required this.subHeadingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.gryColor),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: TextStyle(
                color: headingColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subHeading,
              style: TextStyle(
                color: subHeadingColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,

              ),
            ),
          ],
        ),
      ),
    );
  }
}
