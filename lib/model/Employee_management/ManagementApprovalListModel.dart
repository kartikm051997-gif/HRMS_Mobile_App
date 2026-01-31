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
  String? userId;
  String? employmentId;
  String? fullname;
  String? username;
  String? mobile;
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['employment_id'] = employmentId;
    data['fullname'] = fullname;
    data['username'] = username;
    data['mobile'] = mobile;
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
