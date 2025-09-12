import 'package:flutter/material.dart';
import '../../constants/appimages.dart';
import '../../routes/routes.dart';
import 'drawer_button.dart';

class TabletMobileDrawer extends StatelessWidget {
  const TabletMobileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double navItemFontSize = 18;
    return  Drawer(
      child: SizedBox(
        width: screenWidth,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [AppColor.primaryColor1, AppColor.primaryColor2],

            // ),
          ),
          child: Column(
            children: [
              DrawerHeader(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Social Media Icons
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Handle tap here
                          Scaffold.of(context).closeEndDrawer();
                        },
                        child: Image.network(
                          AppImages.logo,
                          height: 28,
                          width: 28,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder:
                              (context, error, stackTrace) => Image.asset(
                            AppImages.logo,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabletAppbarNavigationBtn(
                          leadingIcon: Icons.dashboard,
                          title: 'DashBoard',
                          targetPage: AppRoutes.dashboardScreen,
                          fontSize: navItemFontSize,
                        ),TabletAppbarNavigationBtn(
                          leadingIcon: Icons.message_outlined,
                          title: 'Deliverables Overview',
                          targetPage: AppRoutes.deliverablesOverview,
                          fontSize: navItemFontSize,
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
