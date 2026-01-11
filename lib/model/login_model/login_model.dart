class LoginApiModel {
  String? status;
  String? message;
  String? token;
  User? user;

  LoginApiModel({this.status, this.message, this.token, this.user});

  LoginApiModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    token = json['token'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['token'] = this.token;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? userId;
  String? username;
  String? email;
  String? fullname;
  String? avatar;
  String? designationsId;   // ✅ FIXED
  String? location;
  String? locationName;
  String? zoneId;
  String? zoneName;
  String? appLocation;     // ✅ FIXED
  String? roleId;
  String? lastLogin;

  User({
    this.userId,
    this.username,
    this.email,
    this.fullname,
    this.avatar,
    this.designationsId,
    this.location,
    this.locationName,
    this.zoneId,
    this.zoneName,
    this.appLocation,
    this.roleId,
    this.lastLogin,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    email = json['email'];
    fullname = json['fullname'];
    avatar = json['avatar'];
    designationsId = json['designations_id'];   // now safe
    location = json['location'];
    locationName = json['location_name'];
    zoneId = json['zone_id'];
    zoneName = json['zone_name'];
    appLocation = json['app_location'];        // now safe
    roleId = json['role_id'];
    lastLogin = json['last_login'];
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'fullname': fullname,
      'avatar': avatar,
      'designations_id': designationsId,
      'location': location,
      'location_name': locationName,
      'zone_id': zoneId,
      'zone_name': zoneName,
      'app_location': appLocation,
      'role_id': roleId,
      'last_login': lastLogin,
    };
  }
}
