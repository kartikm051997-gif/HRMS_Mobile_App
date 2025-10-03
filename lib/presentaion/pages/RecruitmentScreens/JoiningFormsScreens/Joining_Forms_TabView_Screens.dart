import 'package:flutter/Material.dart';
import 'package:provider/provider.dart';

import '../../../../core/components/drawer/drawer.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/RecruitmentScreensProviders/JoiningFormsScreenProvider.dart';
import 'Genarate_Joining_Form_Screen.dart';
import 'Joining_Form_List_Screen.dart';

class JoiningFormsTabViewScreen extends StatefulWidget {
  const JoiningFormsTabViewScreen({super.key});

  @override
  State<JoiningFormsTabViewScreen> createState() =>
      _JoiningFormsTabViewScreenState();
}

class _JoiningFormsTabViewScreenState extends State<JoiningFormsTabViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<JoiningFormsScreenProvider>().setCurrentTab(
          _tabController.index,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Consumer<JoiningFormsScreenProvider>(
      builder: (context, provider, child) {
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            drawer: const TabletMobileDrawer(),

            appBar: AppBar(
              iconTheme: IconThemeData(color: AppColor.whiteColor),

              centerTitle: true,
              backgroundColor: AppColor.primaryColor2,

              elevation: 2,
              title: Text(
                "Joining Forms",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.poppins,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColor.whiteColor,
                unselectedLabelColor: AppColor.gryColor,
                indicatorColor: AppColor.whiteColor,
                labelStyle: TextStyle(fontFamily: AppFonts.poppins),
                tabs: const [
                  Tab(text: 'Joining Form List'),
                  Tab(text: 'Generate Joining Form'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                JoiningFormListScreen(empId: "12345"),

                GenerateJoiningFormScreen(empId: "12345"),
              ],
            ),
          ),
        );
      },
    );
  }
}
