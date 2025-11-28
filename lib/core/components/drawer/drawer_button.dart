import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/ui_controller/appbar_controllers.dart';
import '../../constants/appcolor_dart.dart';
import '../../fonts/fonts.dart';

class TabletAppbarNavigationBtn extends StatelessWidget {
  final String title;
  final String targetPage;
  final bool highlight;
  final bool hasBorder;
  final IconData? icon;
  final double? fontSize;
  final bool isTopInfo;
  final Color? bgColor;
  final Color? titleColor;
  final IconData? leadingIcon;

  const TabletAppbarNavigationBtn({
    super.key,
    required this.title,
    required this.targetPage,
    this.highlight = false,
    this.hasBorder = false,
    this.icon,
    this.isTopInfo = false,
    this.fontSize,
    this.bgColor,
    this.titleColor,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final AppBarController appBarController = Get.find();

    final Color resolvedTextColor =
        highlight
            ? const Color.fromARGB(255, 0, 0, 0)
            : (titleColor ?? const Color.fromARGB(255, 54, 54, 54));

    return Obx(() {
      final bool isSelected = appBarController.selectedPage.value == targetPage;
      return GestureDetector(
        onTap: () {
          // Close drawer first
          Navigator.of(context).pop();
          // Use offNamed to replace current screen, so back button goes to home
          Get.offNamed(targetPage);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding:
                  highlight
                      ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
                      : EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color:
                    bgColor ??
                    (highlight ? AppColor.mediumGrey : Colors.transparent),
                border:
                    hasBorder
                        ? Border.all(color: AppColor.mediumGrey, width: 1.5)
                        : null,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(
                      leadingIcon,
                      size: 20,
                      color:
                          isSelected
                              ? AppColor.primaryColor2
                              : const Color.fromARGB(255, 63, 63, 63),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: isTopInfo ? 22 : fontSize,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected
                                ? AppColor.primaryColor2
                                : const Color.fromARGB(255, 63, 63, 63),
                      ),
                    ),
                  ),
                  if (highlight) ...[
                    const SizedBox(width: 4),
                    Icon(
                      icon ?? Icons.arrow_forward_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
