import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_mobile_app/presentaion/page_not_found/page_not_found.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/Deliverables_Overview_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/add_deliverable_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/dashborad/dashboard_screen.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/Deliverables_Overview_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/Employee_Details_Provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/add_deliverable_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/attendance_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/bank_details_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/document_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/salary_details_provider.dart';
import 'package:hrms_mobile_app/provider/forget_password_provider/forget_password_provider.dart';
import 'package:hrms_mobile_app/provider/login_provider/login_provider.dart';
import 'package:hrms_mobile_app/presentaion/pages/authentication/login/login_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/splash_screen/splash_screen.dart';

import 'package:provider/provider.dart';

import 'controller/ui_controller/appbar_controllers.dart';
import 'core/routes/app_route_observer.dart';
import 'core/routes/routes.dart';
import 'core/utils/helper_utils.dart';

void main() async {
  runApp(const MyApp());
  Get.lazyPut<AppBarController>(() => AppBarController());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ForgetPasswordProvider()),
        ChangeNotifierProvider(create: (_) => DeliverablesOverviewProvider()),
        ChangeNotifierProvider(create: (_) => AddDeliverableProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeDetailsProvider()),
        ChangeNotifierProvider(create: (_) => BankDetailsProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => SalaryDetailsProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CRM DraivF',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF2F2F2),
          ),
        ),

        navigatorObservers: [AppRouteObserver()],
        initialRoute: "/splashscreen",
        onGenerateRoute: (settings) {
          String routeName = settings.name ?? '';
          routeName = HelperUtil.normalizeUrl(routeName);

          if (HelperUtil.isValidStaticRoute(routeName)) {
            return GetPageRoute(
              settings: settings,
              page: () => _getStaticPage(routeName),
            );
          }

          return GetPageRoute(
            settings: settings,
            page: () => const NotFoundPage(),
          );
        },
      ),
    );
  }

  Widget _getStaticPage(String routeName) {
    switch (routeName) {
      case AppRoutes.splashScreen:
        return SplashScreen();
      case AppRoutes.loginScreen:
        return LoginScreen();
      case AppRoutes.dashboardScreen:
        return DashboardScreen();
      case AppRoutes.deliverablesOverview:
        return DeliverablesOverviewScreen();
      case AppRoutes.addDeliverable:
        return AddDeliverableScreen();


      default:
        return const NotFoundPage();
    }
  }
}
