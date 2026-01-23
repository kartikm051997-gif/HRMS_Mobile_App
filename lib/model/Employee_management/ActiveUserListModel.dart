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
  Summary? summary;
  Pagination? pagination; // Add this

  Data({this.users, this.summary, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = [];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
    summary =
        json['summary'] != null ? Summary.fromJson(json['summary']) : null;
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null; // Add this
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    if (summary != null) {
      data['summary'] = summary!.toJson();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson(); // Add this
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
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  int? from;
  int? to;

  Pagination({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.from,
    this.to,
  });

  Pagination.fromJson(Map<String, dynamic> json) {
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
