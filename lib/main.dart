import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_mobile_app/presentaion/page_not_found/page_not_found.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/Deliverables_Overview_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/add_deliverable_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/PayRoll/Attendance Log_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/dashborad/dashboard_screen.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/Assets_Details_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/Circular_Details_Provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/Deliverables_Overview_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/Employee_Details_Provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/Task_details_Provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/add_deliverable_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/attendance_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/bank_details_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/document_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/edu_exp_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/employee_information_details_TabBar_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/employee_personal_details_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/ESI_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/letter_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/other_details_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/payslip_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/pf_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/reference_details_provider.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/salary_details_provider.dart';
import 'package:hrms_mobile_app/provider/forget_password_provider/forget_password_provider.dart';
import 'package:hrms_mobile_app/provider/login_provider/login_provider.dart';
import 'package:hrms_mobile_app/presentaion/pages/authentication/login/login_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/splash_screen/splash_screen.dart';
import 'package:hrms_mobile_app/provider/payroll_provider/Attendance_Log_provider.dart';
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
        ChangeNotifierProvider(
          create: (_) => EmployeeInformationTabBarProvider(),
        ),
        ChangeNotifierProvider(create: (_) => EmployeeInformationProvider()),
        ChangeNotifierProvider(create: (_) => EduExpProvider()),
        ChangeNotifierProvider(create: (_) => OtherDetailsProvider()),
        ChangeNotifierProvider(create: (_) => ReferenceDetailsProvider()),
        ChangeNotifierProvider(create: (_) => PfProvider()),
        ChangeNotifierProvider(create: (_) => ESIProvider()),
        ChangeNotifierProvider(create: (_) => DocumentListProvider()),
        ChangeNotifierProvider(create: (_) => PaySlipProvider()),
        ChangeNotifierProvider(create: (_) => AssetsDetailsProvider()),
        ChangeNotifierProvider(create: (_) => CircularProvider()),
        ChangeNotifierProvider(create: (_) => TaskDetailsProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceLogProvider()),
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
      case AppRoutes.attendanceLog:
        return AttendanceLogScreen();

      default:
        return const NotFoundPage();
    }
  }
}
