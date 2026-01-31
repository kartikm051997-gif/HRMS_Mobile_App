class AllEmployeeListModelClass {
  String? status;
  String? message;
  int? total;
  AllEmployeeData? data;

  AllEmployeeListModelClass({this.status, this.message, this.total, this.data});

  AllEmployeeListModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    data = json['data'] != null ? AllEmployeeData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total'] = this.total;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AllEmployeeData {
  List<AllEmployeeUser>? users;
  AllEmployeePagination? pagination;

  AllEmployeeData({this.users, this.pagination});

  AllEmployeeData.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = <AllEmployeeUser>[];
      json['users'].forEach((v) {
        users!.add(AllEmployeeUser.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? AllEmployeePagination.fromJson(json['pagination'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class AllEmployeeUser {
  String? userId;
  String? employmentId;
  String? fullname;
  String? username;
  String? designation;
  String? department;
  String? location;
  String? locationName;
  String? joiningDate;
  String? monthlyCTC;
  String? annualCTC;
  String? payrollCategory;
  String? status;
  String? avatar;
  String? email;
  String? mobile;
  String? recruiterName;
  String? recruiterPhotoUrl;
  String? createdByName;
  String? createdByPhotoUrl;

  AllEmployeeUser({
    this.userId,
    this.employmentId,
    this.fullname,
    this.username,
    this.designation,
    this.department,
    this.location,
    this.locationName,
    this.joiningDate,
    this.monthlyCTC,
    this.annualCTC,
    this.payrollCategory,
    this.status,
    this.avatar,
    this.email,
    this.mobile,
    this.recruiterName,
    this.recruiterPhotoUrl,
    this.createdByName,
    this.createdByPhotoUrl,
  });

  AllEmployeeUser.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    employmentId = json['employment_id'];
    fullname = json['fullname'];
    username = json['username'];
    designation = json['designation'];
    department = json['department'];
    location = json['location'];
    locationName = json['location_name'] ?? json['location'];
    joiningDate = json['joining_date'];
    monthlyCTC =
        json['monthly_ctc']?.toString() ?? json['monthlyCTC']?.toString();
    annualCTC = json['annual_ctc']?.toString() ?? json['annualCTC']?.toString();
    payrollCategory = json['payroll_category'] ?? json['payrollCategory'];
    status = json['status'];
    avatar = json['avatar'];
    email = json['email'];
    mobile = json['mobile'];
    recruiterName = json['recruiter_name'] ?? json['recruiterName'];
    recruiterPhotoUrl =
        json['recruiter_photo_url'] ?? json['recruiterPhotoUrl'];
    createdByName = json['created_by_name'] ?? json['createdByName'];
    createdByPhotoUrl =
        json['created_by_photo_url'] ?? json['createdByPhotoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['employment_id'] = this.employmentId;
    data['fullname'] = this.fullname;
    data['username'] = this.username;
    data['designation'] = this.designation;
    data['department'] = this.department;
    data['location'] = this.location;
    data['location_name'] = this.locationName;
    data['joining_date'] = this.joiningDate;
    data['monthly_ctc'] = this.monthlyCTC;
    data['annual_ctc'] = this.annualCTC;
    data['payroll_category'] = this.payrollCategory;
    data['status'] = this.status;
    data['avatar'] = this.avatar;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['recruiter_name'] = this.recruiterName;
    data['recruiter_photo_url'] = this.recruiterPhotoUrl;
    data['created_by_name'] = this.createdByName;
    data['created_by_photo_url'] = this.createdByPhotoUrl;
    return data;
  }
}

class AllEmployeePagination {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  int? from;
  int? to;

  AllEmployeePagination({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.from,
    this.to,
  });

  AllEmployeePagination.fromJson(Map<String, dynamic> json) {
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
