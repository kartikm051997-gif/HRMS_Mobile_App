import 'package:flutter/foundation.dart';

/// Model for abscondUserList_api response.
/// Structure inferred from inactive/active list APIs (status, message, total, data.users, data.pagination).
class AbscondUserListModelClass {
  String? status;
  String? message;
  int? total;
  AbscondData? data;

  AbscondUserListModelClass({
    this.status,
    this.message,
    this.total,
    this.data,
  });

  AbscondUserListModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    data = json['data'] != null ? AbscondData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AbscondData {
  List<AbscondUser>? users;
  AbscondPagination? pagination;

  AbscondData({this.users, this.pagination});

  AbscondData.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = <AbscondUser>[];
      for (var v in json['users']) {
        users!.add(AbscondUser.fromJson(v));
      }
    }
    pagination = json['pagination'] != null
        ? AbscondPagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class AbscondUser {
  static bool _hasLoggedFirst = false; // Debug flag
  
  String? userId;
  String? employmentId;
  String? fullname;
  String? username;
  String? designation;
  String? department;
  String? location;
  String? locationName;
  String? joiningDate;
  String? relievingDate;
  String? role;
  String? status;
  String? avatar;
  String? email;
  String? mobile;

  AbscondUser({
    this.userId,
    this.employmentId,
    this.fullname,
    this.username,
    this.designation,
    this.department,
    this.location,
    this.locationName,
    this.joiningDate,
    this.relievingDate,
    this.role,
    this.status,
    this.avatar,
    this.email,
    this.mobile,
  });

  AbscondUser.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    employmentId = json['employment_id'];
    fullname = json['fullname'];
    username = json['username'];
    designation = json['designation'];
    department = json['department'];
    location = json['location'];
    locationName = json['location_name'] ?? json['location'];
    joiningDate = json['joining_date'];
    relievingDate = json['relieving_date'];
    role = json['role'];
    status = json['status'];
    // Try multiple possible field names for avatar, with created_by.avatar/image as fallback
    avatar = json['avatar']?.toString() ?? 
             json['photo']?.toString() ?? 
             json['image']?.toString() ?? 
             json['photo_url']?.toString() ?? 
             json['avatar_url']?.toString() ??
             (json['created_by'] != null 
                ? (json['created_by']['avatar']?.toString() ?? json['created_by']['image']?.toString())
                : null);
    email = json['email'];
    mobile = json['mobile'];
    
    // Debug logging for avatar parsing (only first user)
    if (kDebugMode && !AbscondUser._hasLoggedFirst && fullname != null) {
      AbscondUser._hasLoggedFirst = true;
      print("📸 AbscondUser.fromJson - FIRST USER: ${fullname}:");
      print("   All JSON keys: ${json.keys.toList()}");
      print("   Raw avatar: ${json['avatar']}");
      print("   Raw photo: ${json['photo']}");
      print("   Raw image: ${json['image']}");
      print("   Raw created_by: ${json['created_by']}");
      if (json['created_by'] != null) {
        print("   created_by.avatar: ${json['created_by']['avatar']}");
        print("   created_by.image: ${json['created_by']['image']}");
      }
      print("   Final avatar value: $avatar");
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['employment_id'] = employmentId;
    data['fullname'] = fullname;
    data['username'] = username;
    data['designation'] = designation;
    data['department'] = department;
    data['location'] = location;
    data['location_name'] = locationName;
    data['joining_date'] = joiningDate;
    data['relieving_date'] = relievingDate;
    data['role'] = role;
    data['status'] = status;
    data['avatar'] = avatar;
    data['email'] = email;
    data['mobile'] = mobile;
    return data;
  }
}

class AbscondPagination {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  int? from;
  int? to;

  AbscondPagination({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.from,
    this.to,
  });

  AbscondPagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    perPage = json['per_page'];
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'per_page': perPage,
      'current_page': currentPage,
      'last_page': lastPage,
      'from': from,
      'to': to,
    };
  }
}
