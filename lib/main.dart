import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_mobile_app/presentaion/page_not_found/page_not_found.dart';
import 'package:hrms_mobile_app/presentaion/pages/AdminScreen/AdminTrackingScreen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/Deliverables_Overview_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/Deliverables%20Overview/add_deliverable_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeAssetScreens/EmployeeAssetScreen.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeManagement/EmployeemangementTabViewScreen/Employee_Management_Tabview.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeScreens/AllEmployeeScreens/All_Employee_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeScreens/EmployeeScreens/EmployeeBasicDeatils.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeScreens/F11EmployeesScreens/F11EmployeesScreens.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeScreens/ProfessionalsScreens/Professionals_Screens.dart';
import 'package:hrms_mobile_app/presentaion/pages/EmployeeScreens/StudentScreen/Student_Screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/PayRoll/Attendance Log_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/PayRoll/Employee_Manual_Punches_Screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/PayRoll/Mispunch_Reports%20-Screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/PayRoll/Remote_Attendance_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/PaySlipsScreens/PaySlipDrawerScreen.dart';
import 'package:hrms_mobile_app/presentaion/pages/RecruitmentScreens/JobApplications/Job_Application_screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/RecruitmentScreens/JoiningFormsScreens/Joining_Forms_TabView_Screens.dart';
import 'package:hrms_mobile_app/presentaion/pages/RecruitmentScreens/ResumeManagementScreens/ResumeManagementScreens.dart';
import 'package:hrms_mobile_app/presentaion/pages/RecruitmentScreens/SemiFilledApplicationScreens/Semi_Filled_Application_Screens.dart';
import 'package:hrms_mobile_app/presentaion/pages/UserTrackingScreens/Tracking_History_TabView_Screen.dart';
import 'package:hrms_mobile_app/presentaion/pages/authenticationScreens/loginScreens/login_screen.dart';
import 'package:hrms_mobile_app/provider/AdminTrackingProvider/AdminTrackingProvider.dart';
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
import 'package:hrms_mobile_app/provider/EmployeeAssetProvider/EmployeeAssetProvider.dart';
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
import 'package:hrms_mobile_app/provider/FaceIdentificationProvider/Face_Identification_Provider_Screen.dart';
import 'package:hrms_mobile_app/provider/PaySlipsDrawerProvider/PaySlipsDrawerProvider.dart';
import 'package:hrms_mobile_app/provider/PaySlipsDrawerProvider/PayrollDetailsProvider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProviders/Job_Application_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProviders/Job_Applocation_Edit_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProviders/JoiningFormsScreenProvider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProviders/Recruitment_Edu_Exp_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProviders/Recruitment_Others_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProviders/Recruitment_Personal_Details_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProviders/Recruitment_Referenec_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProviders/Resume_Management_Provider.dart';
import 'package:hrms_mobile_app/provider/RecruitmentScreensProviders/Semi_Filled_Application_Provider.dart';
import 'package:hrms_mobile_app/provider/UserTrackingProvider/UserTrackingProvider.dart';
import 'package:hrms_mobile_app/provider/employeeProvider/All_Employee_Provider.dart';
import 'package:hrms_mobile_app/provider/employeeProvider/Employee_Basic_Provider.dart';
import 'package:hrms_mobile_app/provider/employeeProvider/F11_Employee_Provider.dart';
import 'package:hrms_mobile_app/provider/employeeProvider/Professionals_Provider.dart';
import 'package:hrms_mobile_app/provider/employeeProvider/Student_Provider.dart';
import 'package:hrms_mobile_app/provider/forget_password_provider/forget_password_provider.dart';
import 'package:hrms_mobile_app/provider/login_provider/login_provider.dart';
import 'package:hrms_mobile_app/presentaion/pages/splash_screen/splash_screen.dart';
import 'package:hrms_mobile_app/provider/payroll_provider/Attendance_Log_provider.dart';
import 'package:hrms_mobile_app/provider/payroll_provider/Employee_Manual_Punches_Provider.dart';
import 'package:hrms_mobile_app/provider/payroll_provider/Mispunch_Reports_Provider.dart';
import 'package:hrms_mobile_app/provider/payroll_provider/Remote_Attendance_Provider.dart';
import 'package:provider/provider.dart';
import 'Service/BackgroundTrackingScreen.dart';
import 'controller/ui_controller/appbar_controllers.dart';
import 'core/components/BottomNavigationScreen/Bottom_Navigation_Screen.dart';
import 'core/routes/app_route_observer.dart';
import 'core/routes/routes.dart';
import 'core/utils/helper_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🟢 Initialize GetX dependencies
  Get.put(AppBarController(), permanent: true);

  // 🟢 Initialize LoginProvider and restore session
  final loginProvider = LoginProvider();
  final isLoggedIn = await loginProvider.initializeSession();

  // 🟢 Initialize background service (non-blocking)
  Future.microtask(() async {
    await BackgroundTrackingService().initializeService();
  });

  // ✅ Launch app with the initialized loginProvider instance
  runApp(MyApp(isLoggedIn: isLoggedIn, loginProvider: loginProvider));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final LoginProvider loginProvider;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.loginProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🟢 Use the pre-initialized LoginProvider instance
        ChangeNotifierProvider<LoginProvider>.value(value: loginProvider),
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
        ChangeNotifierProvider(create: (_) => EmployeeManualPunchesProvider()),
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
        ChangeNotifierProvider(
          create: (_) => RecruitmentEmpPersonalDetailsProvider(),
        ),
        ChangeNotifierProvider(create: (_) => RecruitmentEduExpProvider()),
        ChangeNotifierProvider(create: (_) => RecruitmentOthersProvider()),
        ChangeNotifierProvider(create: (_) => RecruitmentReferenceProvider()),
        ChangeNotifierProvider(create: (_) => JobApplicationEditProvider()),
        ChangeNotifierProvider(create: (_) => SemiFilledApplicationProvider()),
        ChangeNotifierProvider(create: (_) => JoiningFormsScreenProvider()),
        ChangeNotifierProvider(create: (_) => PaySlipsDrawerProvider()),
        ChangeNotifierProvider(create: (_) => PayrollDetailsProvider()),
        ChangeNotifierProvider(create: (_) => AdminTrackingProvider()),
        ChangeNotifierProvider(create: (_) => UserTrackingProvider()),
        ChangeNotifierProvider(create: (_) => FaceVerificationProvider()),
        ChangeNotifierProvider(create: (_) => FaceVerificationProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeAssetProvider()),
        ChangeNotifierProvider(create: (_) => PayrollReviewProvider()),
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
        initialRoute: isLoggedIn ? AppRoutes.bottomNav : AppRoutes.splashScreen,
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
      case AppRoutes.userTrackingScreen:
        return const UserTrackingTabViewScreen();
      case AppRoutes.adminTracking:
        return const AdminTrackingScreen();
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
      case AppRoutes.employeeManualPunches:
        return EmployeeManualPunchesScreen();
      case AppRoutes.employeeManagement:
        return EmployeeManagementTabviewScreen();
      case AppRoutes.paySlips:
        return PaySlipDrawerScreen();
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
      case AppRoutes.semiFilledApplication:
        return SemiFilledApplicationScreens();
      case AppRoutes.joiningForms:
        return JoiningFormsTabViewScreen();
      case AppRoutes.bottomNav:
        return const BottomNavScreen();
      case AppRoutes.trackingTabViewScreen:
        return const UserTrackingTabViewScreen();
      case AppRoutes.assetDetails:
        return const EmployeeAssetScreen ();
      default:
        return const NotFoundPage();
    }
  }
}
