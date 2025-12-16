import 'package:flutter/foundation.dart';
import '../../apibaseScreen/Api_Base_Screens.dart';

class Employee {
  final String employeeId;
  final String name;
  final String branch;
  final String doj;
  final String department;
  final String designation;
  final String monthlyCTC;
  final String payrollCategory;
  final String status;
  final String? photoUrl;
  final String? recruiterName;
  final String? recruiterPhotoUrl;
  final String? createdByName;
  final String? createdByPhotoUrl;
  final String? userId;
  final String? username;
  final String? mobile;
  final String? email;
  final String? zoneId;
  final String? annualCtc;
  final String? recentPunchDate;

  Employee({
    required this.employeeId,
    required this.name,
    required this.branch,
    required this.doj,
    required this.department,
    required this.designation,
    required this.monthlyCTC,
    required this.payrollCategory,
    required this.status,
    this.photoUrl,
    this.recruiterName,
    this.recruiterPhotoUrl,
    this.createdByName,
    this.createdByPhotoUrl,
    this.userId,
    this.username,
    this.mobile,
    this.email,
    this.zoneId,
    this.annualCtc,
    this.recentPunchDate,
  });

  /// Factory constructor to create Employee from API Users object
  factory Employee.fromApiUser(dynamic user) {
    // Handle photo URL - prepend base URL if it's a relative path
    String? photoUrl;

    // Get avatar value and check if it's valid
    final avatarValue = user.avatar;

    if (avatarValue != null &&
        avatarValue.toString().trim().isNotEmpty &&
        avatarValue.toString().toLowerCase() != 'null' &&
        avatarValue.toString().toLowerCase() != 'none') {

      final avatar = avatarValue.toString().trim();

      // Check if it's already a full URL (starts with http:// or https://)
      if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
        photoUrl = avatar;
      } else if (avatar.isNotEmpty) {
        // It's a relative path, prepend base URL
        // Remove leading slash if present
        final cleanPath = avatar.startsWith('/') ? avatar.substring(1) : avatar;
        // Use baseUrl from ApiBase instead of hardcoding
        photoUrl = '${ApiBase.baseUrl}$cleanPath';
      }
    }

    // Debug: Print avatar info
    if (kDebugMode) {
      final empId = user.employmentId ?? user.userId ?? "Unknown";
      final empName = user.fullname ?? user.username ?? "Unknown";
      print('👤 Employee: $empName (ID: $empId)');
      print('   📸 Raw Avatar: ${user.avatar} (Type: ${user.avatar.runtimeType})');
      print('   🔗 Final PhotoURL: $photoUrl');
    }

    return Employee(
      employeeId: user.employmentId ?? user.userId ?? "",
      name: user.fullname ?? user.username ?? "Unknown",
      branch: user.locationName ?? "N/A",
      doj: user.joiningDate ?? "N/A",
      department: user.department ?? "N/A",
      designation: user.designation ?? "N/A",
      monthlyCTC: user.monthlyCtc ?? "0",
      payrollCategory: user.payrollCategory ?? "N/A",
      status: user.status ?? "Active",
      photoUrl: photoUrl,
      userId: user.userId,
      username: user.username,
      mobile: user.mobile,
      email: user.email,
      zoneId: user.zoneId,
      annualCtc: user.annualCtc,
      recentPunchDate: user.recentPunchDate,
    );
  }
}
