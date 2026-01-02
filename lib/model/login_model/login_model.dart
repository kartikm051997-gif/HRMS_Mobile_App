class LoginApiModel {
  String? status;
  String? message;
  String? token;
  String? userId;
  String? role;
  User? user;

  LoginApiModel({
    this.status,
    this.message,
    this.token,
    this.userId,
    this.role,
    this.user,
  });

  LoginApiModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    token = json['token'];
    userId = json['user_id'];
    role = json['role'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['token'] = this.token;
    data['user_id'] = this.userId;
    data['role'] = this.role;
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
  String? designationsId;
  String? location;
  String? appLocation;
  String? roleId;
  String? lastLogin;
  String? branch; // Keep for backward compatibility

  User({
    this.userId,
    this.username,
    this.email,
    this.fullname,
    this.avatar,
    this.designationsId,
    this.location,
    this.appLocation,
    this.roleId,
    this.lastLogin,
    this.branch,
  });

  User.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    email = json['email'];
    fullname = json['fullname'];
    avatar = json['avatar'];
    designationsId = json['designations_id'];
    location = json['location'];
    appLocation = json['app_location'];
    roleId = json['role_id'];
    lastLogin = json['last_login'];
    branch = json['branch']; // Keep for backward compatibility
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['username'] = this.username;
    data['email'] = this.email;
    data['fullname'] = this.fullname;
    data['avatar'] = this.avatar;
    data['designations_id'] = this.designationsId;
    data['location'] = this.location;
    data['app_location'] = this.appLocation;
    data['role_id'] = this.roleId;
    data['last_login'] = this.lastLogin;
    data['branch'] = this.branch;
    return data;
  }
}
