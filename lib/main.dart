import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_mobile_app/presentaion/page_not_found/page_not_found.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/Deliverables_Overview_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/add_deliverable_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeManagement/EmployeemangementTabViewScreen/Employee_Management_Tabview.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeScreens/AllEmployeeScreens/All_Employee_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeScreens/EmployeeScreens/EmployeeBasicDeatils.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeScreens/F11EmployeesScreens/F11EmployeesScreens.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeScreens/ProfessionalsScreens/Professionals_Screens.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeScreens/StudentScreen/Student_Screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/PayRoll/Attendance Log_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/PayRoll/Mispunch_Reports%20-Screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/PayRoll/Remote_Attendance_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/RecruitmentScreens/JobApplications/Job_Application_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/RecruitmentScreens/ResumeManagementScreens/ResumeManagementScreens.dart';
import 'package:hrms_mobile_app/presentaion/pages/authenticationScreens/loginScreens/login_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/dashboradScreens/dashboard_screen.dart';
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
import 'package:hrms_mobile_app/provider/Employee_management_Provider/Abscond_Provider.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/Active_Provider.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/All_Employees_Provider.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/InActiveProvider.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/NewEmployee_Bank_Details_Provider.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/New_Employee_Provider.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/New_Employee_document_Provider.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/Notice_Period_Provider.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/Payroll_Category_Type_provider.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/employee_tabview_provider.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/management_approval_provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProvider/Job_Application_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProvider/Recruitment_Edu_Exp_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProvider/Recruitment_Others_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProvider/Recruitment_Personal_Details_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProvider/Recruitment_Referenec_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProvider/Resume_Management_Provider.dart';
import 'package:hrms_mobile_app/provider/employeeProvider/All_Employee_Provider.dart';
import 'package:hrms_mobile_app/provider/employeeProvider/Employee_Basic_Provider.dart';
import 'package:hrms_mobile_app/provider/employeeProvider/F11_Employee_Provider.dart';
import 'package:hrms_mobile_app/provider/employeeProvider/Professionals_Provider.dart';
import 'package:hrms_mobile_app/provider/employeeProvider/Student_Provider.dart';
import 'package:hrms_mobile_app/provider/forget_password_provider/forget_password_provider.dart';
import 'package:hrms_mobile_app/provider/login_provider/login_provider.dart';
import 'package:hrms_mobile_app/presentaion/pages/splash_screen/splash_screen.dart';
import 'package:hrms_mobile_app/provider/payroll_provider/Attendance_Log_provider.dart';
import 'package:hrms_mobile_app/provider/payroll_provider/Mispunch_Reports_Provider.dart';
import 'package:hrms_mobile_app/provider/payroll_provider/Remote_Attendance_Provider.dart';
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
        ChangeNotifierProvider(create: (_) => RemoteAttendanceProvider()),
        ChangeNotifierProvider(create: (_) => MisPunchReportsProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeTabviewProvider()),
        ChangeNotifierProvider(create: (_) => ActiveProvider()),
        ChangeNotifierProvider(create: (_) => ManagementApprovalProvider()),
        ChangeNotifierProvider(create: (_) => AbscondProvider()),
        ChangeNotifierProvider(create: (_) => NoticePeriodProvider()),
        ChangeNotifierProvider(create: (_) => InActiveProvider()),
        ChangeNotifierProvider(create: (_) => AllEmployeesProvider()),
        ChangeNotifierProvider(create: (_) => NewEmployeeProvider()),
        ChangeNotifierProvider(create: (_) => NewEmployeeBankDetailsProvider()),
        ChangeNotifierProvider(create: (_) => NewEmployeeDocumentProvider()),
        ChangeNotifierProvider(create: (_) => PayrollCategoryTypeProvider()),
        ChangeNotifierProvider(create: (_) => AllEmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ProfessionalsProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeBasicProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => F11EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ResumeManagementProvider()),
        ChangeNotifierProvider(create: (_) => JobApplicationProvider()),
        ChangeNotifierProvider(create: (_) => RecruitmentEmpPersonalDetailsProvider()),
        ChangeNotifierProvider(create: (_) => RecruitmentEduExpProvider()),
        ChangeNotifierProvider(create: (_) => RecruitmentOthersProvider()),
        ChangeNotifierProvider(create: (_) => RecruitmentReferenceProvider()),

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
      case AppRoutes.remoteAttendance:
        return RemoteAttendanceScreen();
      case AppRoutes.mispunchReports:
        return MisPunchReportsScreen();
      case AppRoutes.employeeManagement:
        return EmployeeManagementTabviewScreen();
      case AppRoutes.allEmployees:
        return AllEmployeeScreen();
      case AppRoutes.professionals:
        return ProfessionalsScreens();
      case AppRoutes.employees:
        return EmployeeBasicDetails();
      case AppRoutes.students:
        return StudentScreen();
      case AppRoutes.f11Employees:
        return F11EmployeesScreens();
      case AppRoutes.resumeManagement:
        return ResumeManagementScreens();
      case AppRoutes.jobApplications:
        return JobApplicationScreen();

      default:
        return const NotFoundPage();
    }
  }
}
