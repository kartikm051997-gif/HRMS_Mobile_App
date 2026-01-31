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
    avatar = json['avatar'];
    email = json['email'];
    mobile = json['mobile'];
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
