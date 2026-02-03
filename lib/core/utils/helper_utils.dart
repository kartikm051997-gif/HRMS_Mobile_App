import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
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
      AppRoutes.assetDetails,
      AppRoutes.paGarBookAdmin,
    ];

    return validRoutes.contains(route);
  }

  static String normalizeUrl(String url) {
    String path = Uri.parse(url).path.replaceAll(RegExp(r'/+'), '/');
    return path.startsWith('/') ? path : '/$path';
  }

  /// Navigate to login screen when token expires
  /// This clears all navigation stack and goes to login
  static void navigateToLoginOnTokenExpiry() {
    if (kDebugMode) {
      print("🚨 Token expired - Navigating to login screen");
    }
    try {
      Get.offAllNamed(AppRoutes.loginScreen);
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error navigating to login: $e");
      }
    }
  }
}
