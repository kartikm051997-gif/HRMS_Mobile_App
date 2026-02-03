import 'package:flutter/foundation.dart';

class ManagementApprovalListModel {
  String? status;
  int? total;
  List<ManagementApprovalUser>? data;

  ManagementApprovalListModel({
    this.status,
    this.total,
    this.data,
  });

  ManagementApprovalListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    total = json['total'];
    if (json['data'] != null) {
      data = <ManagementApprovalUser>[];
      
      // Debug: Log first employee's structure to see what fields exist
      if (kDebugMode && json['data'].isNotEmpty) {
        print('📋 ManagementApproval API Response - First Employee Structure:');
        print('   Keys: ${json['data'][0].keys.toList()}');
        print('   Full data: ${json['data'][0]}');
        if (json['data'][0]['avatar'] != null) {
          print('   ✅ Avatar field exists: ${json['data'][0]['avatar']}');
        } else {
          print('   ❌ Avatar field is NULL or missing');
        }
      }
      
      json['data'].forEach((v) {
        data!.add(ManagementApprovalUser.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ManagementApprovalUser {
  static bool _hasLoggedFirst = false; // Debug flag
  
  String? userId;
  String? employmentId;
  String? fullname;
  String? username;
  String? mobile;
  String? avatar;
  String? designation;
  String? department;
  String? location;
  String? joiningDate;
  String? role;
  String? approvalStatus;
  RecruiterInfo? recruiter;
  CreatedByInfo? createdBy;

  ManagementApprovalUser({
    this.userId,
    this.employmentId,
    this.fullname,
    this.username,
    this.mobile,
    this.avatar,
    this.designation,
    this.department,
    this.location,
    this.joiningDate,
    this.role,
    this.approvalStatus,
    this.recruiter,
    this.createdBy,
  });

  ManagementApprovalUser.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    employmentId = json['employment_id'];
    fullname = json['fullname'];
    username = json['username'];
    mobile = json['mobile'];
    
    // Try multiple possible field names for avatar
    // Since API doesn't return avatar field, use created_by.image as fallback (like Details screen)
    avatar = json['avatar']?.toString() ?? 
             json['photo']?.toString() ?? 
             json['image']?.toString() ?? 
             json['photo_url']?.toString() ?? 
             json['avatar_url']?.toString() ??
             // Fallback to created_by.image (same as Details screen uses)
             (json['created_by'] != null && json['created_by']['image'] != null 
                ? json['created_by']['image'].toString() 
                : null);
    
    designation = json['designation'];
    department = json['department'];
    location = json['location'];
    joiningDate = json['joining_date'];
    role = json['role'];
    approvalStatus = json['approval_status'];
    recruiter = json['recruiter'] != null
        ? RecruiterInfo.fromJson(json['recruiter'])
        : null;
    createdBy = json['created_by'] != null
        ? CreatedByInfo.fromJson(json['created_by'])
        : null;
    
    // Debug logging for avatar - ALWAYS log first employee
    if (kDebugMode && !ManagementApprovalUser._hasLoggedFirst) {
      ManagementApprovalUser._hasLoggedFirst = true;
      final empName = fullname ?? username ?? "Unknown";
      final empId = employmentId ?? userId ?? "Unknown";
      
      print('📸 ManagementApprovalUser Avatar Parsing (FIRST EMPLOYEE):');
      print('   User: $empName (ID: $empId)');
      print('   📋 ALL JSON KEYS: ${json.keys.toList()}');
      print('   avatar field: ${json['avatar']}');
      print('   created_by.image: ${json['created_by']?['image']}');
      print('   recruiter.image: ${json['recruiter']?['image']}');
      print('   Final avatar value: $avatar');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['employment_id'] = employmentId;
    data['fullname'] = fullname;
    data['username'] = username;
    data['mobile'] = mobile;
    data['avatar'] = avatar;
    data['designation'] = designation;
    data['department'] = department;
    data['location'] = location;
    data['joining_date'] = joiningDate;
    data['role'] = role;
    data['approval_status'] = approvalStatus;
    if (recruiter != null) {
      data['recruiter'] = recruiter!.toJson();
    }
    if (createdBy != null) {
      data['created_by'] = createdBy!.toJson();
    }
    return data;
  }
}

class RecruiterInfo {
  String? name;
  String? image;

  RecruiterInfo({this.name, this.image});

  RecruiterInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}

class CreatedByInfo {
  String? name;
  String? image;

  CreatedByInfo({this.name, this.image});

  CreatedByInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}
