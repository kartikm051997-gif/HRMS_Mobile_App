import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/constants/appcolor_dart.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/EmployeeAssetProvider/EmployeeAssetProvider.dart';
import 'AssetDetailsTabScreen.dart';
import 'AssetUpdateTabScreen.dart';

class EmployeeAssetScreen extends StatelessWidget {
  const EmployeeAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeAssetProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const TabletMobileDrawer(),
        backgroundColor: Colors.grey[100],

        // -------------------- APP BAR WITH GRADIENT --------------------
        appBar: AppBar(
          iconTheme: IconThemeData(color: AppColor.whiteColor),

          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          title: Text(
            "Asset Management",
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          bottom: TabBar(
            onTap: (index) {
              if (index == 0) {
                provider.clearSelected();
              } else if (index == 1 && provider.selectedEmployee == null) {
                provider.clearSelected();
              }
            },

            // -------------------- ACTIVE INDICATOR --------------------
            indicatorColor: Colors.white,
            indicatorWeight: 3,

            // -------------------- ACTIVE TAB TEXT STYLE --------------------
            labelColor: Colors.white,
            labelStyle: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),

            // -------------------- INACTIVE TAB TEXT STYLE --------------------
            unselectedLabelColor: Colors.grey[300],
            unselectedLabelStyle: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),

            tabs: const [
              Tab(text: "Asset Details"),
              Tab(text: "Add / Update Asset"),
            ],
          ),
        ),

        // -------------------- TAB VIEW --------------------
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [AssetDetailsTab(), AssetUpdateTab()],
        ),
      ),
    );
  }
}
