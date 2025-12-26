class GetLocationHistoryModel {
  String? status;
  String? message;
  Data? data;

  GetLocationHistoryModel({this.status, this.message, this.data});

  GetLocationHistoryModel.fromJson(Map<String, dynamic> json) {
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
  List<Locations>? locations;
  Pagination? pagination;
  FiltersApplied? filtersApplied;

  Data({this.locations, this.pagination, this.filtersApplied});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['locations'] != null) {
      locations = <Locations>[];
      json['locations'].forEach((v) {
        locations!.add(new Locations.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? new Pagination.fromJson(json['pagination'])
            : null;
    filtersApplied =
        json['filters_applied'] != null
            ? new FiltersApplied.fromJson(json['filters_applied'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.locations != null) {
      data['locations'] = this.locations!.map((v) => v.toJson()).toList();
    }
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    if (this.filtersApplied != null) {
      data['filters_applied'] = this.filtersApplied!.toJson();
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['role_id'] = this.roleId;
    data['username'] = this.username;
    data['email'] = this.email;
    data['fullname'] = this.fullname;
    data['avatar'] = this.avatar;
    data['designations_id'] = this.designationsId;
    data['zone_id'] = this.zoneId;
    data['branch_id'] = this.branchId;
    data['activity_type'] = this.activityType;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['accuracy'] = this.accuracy;
    data['captured_at'] = this.capturedAt;
    data['device_time'] = this.deviceTime;
    data['remarks'] = this.remarks;
    data['location_address'] = this.locationAddress;
    data['device_id'] = this.deviceId;
    data['battery_level'] = this.batteryLevel;
    data['network_type'] = this.networkType;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
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

class FiltersApplied {
  String? userId;
  String? activityType;
  String? fromDate;
  String? toDate;

  FiltersApplied({this.userId, this.activityType, this.fromDate, this.toDate});

  FiltersApplied.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    activityType = json['activity_type'];
    fromDate = json['from_date'];
    toDate = json['to_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['activity_type'] = this.activityType;
    data['from_date'] = this.fromDate;
    data['to_date'] = this.toDate;
    return data;
  }
}
