import '../routes/routes.dart';

class HelperUtil {
  // Static Routes
  static bool isValidStaticRoute(String route) {
    final validRoutes = [
      AppRoutes.splashScreen,
      AppRoutes.splashScreen,
      AppRoutes.loginScreen,
      AppRoutes.userTrackingScreen,
      AppRoutes.adminTracking,
      AppRoutes.deliverablesOverview,
      AppRoutes.attendanceLog,
      AppRoutes.remoteAttendance,
      AppRoutes.mispunchReports,
      AppRoutes.employeeManualPunches,
      AppRoutes.pf,
      AppRoutes.payrollReview,
      AppRoutes.esi,
      AppRoutes.neft,
      AppRoutes.latePunchReports,
      AppRoutes.salaryReport,
      AppRoutes.employeeManagement,
      AppRoutes.paySlips,
      AppRoutes.allEmployees,
      AppRoutes.professionals,
      AppRoutes.employees,
      AppRoutes.students,
      AppRoutes.f11Employees,
      AppRoutes.resumeManagement,
      AppRoutes.jobApplications,
      AppRoutes.semiFilledApplication,
      AppRoutes.joiningForms,
      AppRoutes.offerLetters,
      AppRoutes.bottomNav,
      AppRoutes.trackingTabViewScreen,
    ];

    return validRoutes.contains(route);
  }

  static String normalizeUrl(String url) {
    String path = Uri.parse(url).path.replaceAll(RegExp(r'/+'), '/');
    return path.startsWith('/') ? path : '/$path';
  }
}
