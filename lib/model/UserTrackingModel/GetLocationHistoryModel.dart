class GetLocationHistoryModel {
  String? status;
  String? message;
  Data? data;

  GetLocationHistoryModel({this.status, this.message, this.data});

  GetLocationHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Locations>? locations;
  Pagination? pagination;
  FiltersApplied? filtersApplied;
  UserInfo? userInfo;

  Data({this.locations, this.pagination, this.filtersApplied, this.userInfo});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['locations'] != null) {
      locations = <Locations>[];
      json['locations'].forEach((v) {
        locations!.add(Locations.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
    filtersApplied =
        json['filters_applied'] != null
            ? FiltersApplied.fromJson(json['filters_applied'])
            : null;
    userInfo =
        json['user_info'] != null ? UserInfo.fromJson(json['user_info']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (locations != null) {
      data['locations'] = locations!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    if (filtersApplied != null) {
      data['filters_applied'] = filtersApplied!.toJson();
    }
    if (userInfo != null) {
      data['user_info'] = userInfo!.toJson();
    }
    return data;
  }
}

class Locations {
  String? id;
  String? userId;
  String? roleId;
  String? username;
  String? email;
  String? fullname;
  String? avatar;
  String? designationsId;
  String? zoneId;
  String? branchId;
  String? activityType;
  String? latitude;
  String? longitude;
  String? accuracy;
  String? capturedAt;
  String? deviceTime;
  String? remarks;
  String? locationAddress;
  String? deviceId;
  String? batteryLevel;
  String? networkType;
  String? createdAt;
  String? updatedAt;
  String? userRoleId;
  String? mobile;
  String? designations;
  String? branchName;
  String? zoneName;

  Locations({
    this.id,
    this.userId,
    this.roleId,
    this.username,
    this.email,
    this.fullname,
    this.avatar,
    this.designationsId,
    this.zoneId,
    this.branchId,
    this.activityType,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.capturedAt,
    this.deviceTime,
    this.remarks,
    this.locationAddress,
    this.deviceId,
    this.batteryLevel,
    this.networkType,
    this.createdAt,
    this.updatedAt,
    this.userRoleId,
    this.mobile,
    this.designations,
    this.branchName,
    this.zoneName,
  });

  Locations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    roleId = json['role_id'];
    username = json['username'];
    email = json['email'];
    fullname = json['fullname'];
    avatar = json['avatar'];
    designationsId = json['designations_id'];
    zoneId = json['zone_id'];
    branchId = json['branch_id'];
    activityType = json['activity_type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    accuracy = json['accuracy'];
    capturedAt = json['captured_at'];
    deviceTime = json['device_time'];
    remarks = json['remarks'];
    locationAddress = json['location_address'];
    deviceId = json['device_id'];
    batteryLevel = json['battery_level'];
    networkType = json['network_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userRoleId = json['user_role_id'];
    mobile = json['mobile'];
    designations = json['designations'];
    branchName = json['branch_name'];
    zoneName = json['zone_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['role_id'] = roleId;
    data['username'] = username;
    data['email'] = email;
    data['fullname'] = fullname;
    data['avatar'] = avatar;
    data['designations_id'] = designationsId;
    data['zone_id'] = zoneId;
    data['branch_id'] = branchId;
    data['activity_type'] = activityType;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['accuracy'] = accuracy;
    data['captured_at'] = capturedAt;
    data['device_time'] = deviceTime;
    data['remarks'] = remarks;
    data['location_address'] = locationAddress;
    data['device_id'] = deviceId;
    data['battery_level'] = batteryLevel;
    data['network_type'] = networkType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['user_role_id'] = userRoleId;
    data['mobile'] = mobile;
    data['designations'] = designations;
    data['branch_name'] = branchName;
    data['zone_name'] = zoneName;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['per_page'] = perPage;
    data['total_records'] = totalRecords;
    data['total_pages'] = totalPages;
    return data;
  }
}

class FiltersApplied {
  String? userId;
  String? activityType;
  String? fromDate;
  String? toDate;
  String? zoneId;
  String? branchId;
  String? designationsId;
  String? searchEmpId;

  FiltersApplied({
    this.userId,
    this.activityType,
    this.fromDate,
    this.toDate,
    this.zoneId,
    this.branchId,
    this.designationsId,
    this.searchEmpId,
  });

  FiltersApplied.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    activityType = json['activity_type'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
    zoneId = json['zone_id'];
    branchId = json['branch_id'];
    designationsId = json['designations_id'];
    searchEmpId = json['search_emp_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['activity_type'] = activityType;
    data['from_date'] = fromDate;
    data['to_date'] = toDate;
    data['zone_id'] = zoneId;
    data['branch_id'] = branchId;
    data['designations_id'] = designationsId;
    data['search_emp_id'] = searchEmpId;
    return data;
  }
}

class UserInfo {
  String? loggedInUserId;
  String? roleId;
  bool? isAdmin;

  UserInfo({this.loggedInUserId, this.roleId, this.isAdmin});

  UserInfo.fromJson(Map<String, dynamic> json) {
    loggedInUserId = json['logged_in_user_id'];
    roleId = json['role_id'];
    isAdmin = json['is_admin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['logged_in_user_id'] = loggedInUserId;
    data['role_id'] = roleId;
    data['is_admin'] = isAdmin;
    return data;
  }
}
