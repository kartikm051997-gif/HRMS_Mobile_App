class InActiveUserListModelClass {
  String? status;
  String? message;
  int? total;
  Data? data;

  InActiveUserListModelClass({
    this.status,
    this.message,
    this.total,
    this.data,
  });

  InActiveUserListModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  List<InActiveUser>? users;
  Pagination? pagination;

  Data({this.users, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['users'] != null) {
      users = <InActiveUser>[];
      json['users'].forEach((v) {
        users!.add(InActiveUser.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
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

class InActiveUser {
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

  InActiveUser({
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

  InActiveUser.fromJson(Map<String, dynamic> json) {
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
    avatar = json['avatar'];
    email = json['email'];
    mobile = json['mobile'];
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
    data['relieving_date'] = this.relievingDate;
    data['role'] = this.role;
    data['status'] = this.status;
    data['avatar'] = this.avatar;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
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
