class ActiveUserList {
  String? status;
  String? message;
  Data? data;

  ActiveUserList({this.status, this.message, this.data});

  ActiveUserList.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Users>? users;
  Pagination? pagination;
  Summary? summary;
  FiltersApplied? filtersApplied;

  Data({this.users, this.pagination, this.summary, this.filtersApplied});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(new Users.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? new Pagination.fromJson(json['pagination'])
            : null;
    summary =
        json['summary'] != null ? new Summary.fromJson(json['summary']) : null;
    filtersApplied =
        json['filters_applied'] != null
            ? new FiltersApplied.fromJson(json['filters_applied'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.summary != null) {
      data['summary'] = this.summary!.toJson();
    }
    if (this.filtersApplied != null) {
      data['filters_applied'] = this.filtersApplied!.toJson();
    }
    return data;
  }
}

class Users {
  String? userId;
  String? employmentId;
  String? username;
  String? fullname;
  String? mobile;
  String? email;
  String? avatar;
  String? locationName;
  String? zoneId;
  String? designation;
  String? department;
  String? joiningDate;
  String? monthlyCtc;
  String? annualCtc;
  String? recentPunchDate;
  String? payrollCategory;
  String? status;

  Users({
    this.userId,
    this.employmentId,
    this.username,
    this.fullname,
    this.mobile,
    this.email,
    this.avatar,
    this.locationName,
    this.zoneId,
    this.designation,
    this.department,
    this.joiningDate,
    this.monthlyCtc,
    this.annualCtc,
    this.recentPunchDate,
    this.payrollCategory,
    this.status,
  });

  Users.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    employmentId = json['employment_id'];
    username = json['username'];
    fullname = json['fullname'];
    mobile = json['mobile'];
    email = json['email'];
    avatar = json['avatar'];
    locationName = json['location_name'];
    zoneId = json['zone_id'];
    designation = json['designation'];
    department = json['department'];
    joiningDate = json['joining_date'];
    monthlyCtc = json['monthly_ctc'];
    annualCtc = json['annual_ctc'];
    recentPunchDate = json['recent_punch_date'];
    payrollCategory = json['payroll_category'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['employment_id'] = this.employmentId;
    data['username'] = this.username;
    data['fullname'] = this.fullname;
    data['mobile'] = this.mobile;
    data['email'] = this.email;
    data['avatar'] = this.avatar;
    data['location_name'] = this.locationName;
    data['zone_id'] = this.zoneId;
    data['designation'] = this.designation;
    data['department'] = this.department;
    data['joining_date'] = this.joiningDate;
    data['monthly_ctc'] = this.monthlyCtc;
    data['annual_ctc'] = this.annualCtc;
    data['recent_punch_date'] = this.recentPunchDate;
    data['payroll_category'] = this.payrollCategory;
    data['status'] = this.status;
    return data;
  }
}

class Pagination {
  int? currentPage;
  int? perPage;
  int? totalRecords;
  int? totalPages;

  Pagination({
    this.currentPage,
    this.perPage,
    this.totalRecords,
    this.totalPages,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    perPage = json['per_page'];
    totalRecords = json['total_records'];
    totalPages = json['total_pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    data['per_page'] = this.perPage;
    data['total_records'] = this.totalRecords;
    data['total_pages'] = this.totalPages;
    return data;
  }
}

class Summary {
  String? grandTotal;
  String? totalMonthlyCtc;
  String? f11Employees;
  String? professionalFee;
  String? studentCtc;

  Summary({
    this.grandTotal,
    this.totalMonthlyCtc,
    this.f11Employees,
    this.professionalFee,
    this.studentCtc,
  });

  Summary.fromJson(Map<String, dynamic> json) {
    grandTotal = json['grand_total'];
    totalMonthlyCtc = json['total_monthly_ctc'];
    f11Employees = json['f11_employees'];
    professionalFee = json['professional_fee'];
    studentCtc = json['student_ctc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['grand_total'] = this.grandTotal;
    data['total_monthly_ctc'] = this.totalMonthlyCtc;
    data['f11_employees'] = this.f11Employees;
    data['professional_fee'] = this.professionalFee;
    data['student_ctc'] = this.studentCtc;
    return data;
  }
}

class FiltersApplied {
  String? cmpid;
  String? zoneId;
  String? locationsId;
  String? designationsId;
  String? ctcRange;
  String? punch;
  String? dolpFromdate;
  String? dolpTodate;
  String? fromdate;
  String? todate;

  FiltersApplied({
    this.cmpid,
    this.zoneId,
    this.locationsId,
    this.designationsId,
    this.ctcRange,
    this.punch,
    this.dolpFromdate,
    this.dolpTodate,
    this.fromdate,
    this.todate,
  });

  FiltersApplied.fromJson(Map<String, dynamic> json) {
    cmpid = json['cmpid'];
    zoneId = json['zone_id'];
    locationsId = json['locations_id'];
    designationsId = json['designations_id'];
    ctcRange = json['ctc_range'];
    punch = json['punch'];
    dolpFromdate = json['dolp_fromdate'];
    dolpTodate = json['dolp_todate'];
    fromdate = json['fromdate'];
    todate = json['todate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cmpid'] = this.cmpid;
    data['zone_id'] = this.zoneId;
    data['locations_id'] = this.locationsId;
    data['designations_id'] = this.designationsId;
    data['ctc_range'] = this.ctcRange;
    data['punch'] = this.punch;
    data['dolp_fromdate'] = this.dolpFromdate;
    data['dolp_todate'] = this.dolpTodate;
    data['fromdate'] = this.fromdate;
    data['todate'] = this.todate;
    return data;
  }
}
