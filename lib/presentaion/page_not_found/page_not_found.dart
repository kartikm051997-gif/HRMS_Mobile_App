import 'package:flutter/material.dart';

import '../../core/components/appbar/appbar.dart';
import '../../core/components/drawer/drawer.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // PreferredSizeWidget getAppBar() {
    //   if (screenWidth >= 1440) {
    //     return const LargeDesktopAppbar();
    //   } else if (screenWidth >= 1000) {
    //     return DesktopAppbar();
    //   } else if (screenWidth >= 600) {
    //     return const TabletAppbar();
    //   } else {
    //     return const MobileAppbar();
    //   }
    // }

    Widget? getEndDrawer() {
      if (screenWidth < 1000) {
        return const TabletMobileDrawer();
      }
      return null;
    }

    double getNoFilesTextSize() {
      if (screenWidth >= 1440) {
        return 35;
      } else if (screenWidth >= 1024) {
        return 30;
      } else if (screenWidth >= 768) {
        return 25;
      } else {
        return 15;
      }
    }

    double getSuggestionTextSize() {
      if (screenWidth >= 1440) {
        return 35;
      } else if (screenWidth >= 1024) {
        return 30;
      } else if (screenWidth >= 768) {
        return 25;
      } else {
        return 15;
      }
    }

    double getKeywordTextSize() {
      if (screenWidth >= 1440) {
        return 35;
      } else if (screenWidth >= 1024) {
        return 30;
      } else if (screenWidth >= 768) {
        return 25;
      } else {
        return 15;
      }
    }

    return Scaffold(
      drawer: TabletMobileDrawer(),

      appBar: CustomAppBar(title: "Not Found"),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  // Background Color Layer 1
                  Positioned(
                    left: -screenWidth * 0.15,
                    top: -screenHeight * 0.2,
                    child: Container(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        boxShadow: const [
                          BoxShadow(
                            spreadRadius: 120,
                            color: Color(0xFFFEF1D3),
                            blurRadius: 200,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(600),
                      ),
                    ),
                  ),
                  // Background Color Layer 2
                  Positioned(
                    right: 0,
                    bottom: screenHeight * 0.2,
                    child: Container(
                      width: screenWidth * 0.7,
                      height: screenHeight * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        boxShadow: const [
                          BoxShadow(
                            spreadRadius: 50,
                            color: Color(0xFFE4FDF4),
                            blurRadius: 195,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(900),
                      ),
                    ),
                  ),
                  // Content Section
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        const SpeechBubbleCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class SpeechBubbleCard extends StatelessWidget {
  const SpeechBubbleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblePainter(),
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        width: 290,
        child: Column(
          children: [
            const Text(
              'No Files Found',
              style: TextStyle(
                fontFamily: "Prompt",
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C355E), // Dark blue text
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Maybe go back and try a',
              style: TextStyle(
                fontFamily: "Prompt",
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1C355E), // Dark blue text
              ),
              textAlign: TextAlign.center,
            ),
            const Text(
              'different keyword ? ',
              style: TextStyle(
                fontFamily: "Prompt",
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1C355E), // Dark blue text
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    const radius = 20.0;
    const tailSize = 10.0;

    final path =
        Path()
          ..moveTo(radius, 0)
          ..lineTo(size.width - radius, 0)
          ..quadraticBezierTo(size.width, 0, size.width, radius)
          ..lineTo(size.width, size.height / 2 - tailSize)
          ..lineTo(size.width + 10, size.height / 2)
          ..lineTo(size.width, size.height / 2 + tailSize)
          ..lineTo(size.width, size.height - radius)
          ..quadraticBezierTo(
            size.width,
            size.height,
            size.width - radius,
            size.height,
          )
          ..lineTo(radius, size.height)
          ..quadraticBezierTo(0, size.height, 0, size.height - radius)
          ..lineTo(0, radius)
          ..quadraticBezierTo(0, 0, radius, 0)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
