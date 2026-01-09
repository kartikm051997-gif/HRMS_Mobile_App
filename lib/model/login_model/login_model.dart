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
  String? id;                 // ✅ ADD THIS
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
  String? branch;

  User({
    this.id,
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
    id = json['id']?.toString();              // ✅ VERY IMPORTANT
    userId = json['user_id']?.toString();
    username = json['username'];
    email = json['email'];
    fullname = json['fullname'];
    avatar = json['avatar'];
    designationsId = json['designations_id'];
    location = json['location'];
    appLocation = json['app_location'];
    roleId = json['role_id']?.toString();
    lastLogin = json['last_login'];
    branch = json['branch'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;                          // ✅ ADD THIS
    data['user_id'] = userId;
    data['username'] = username;
    data['email'] = email;
    data['fullname'] = fullname;
    data['avatar'] = avatar;
    data['designations_id'] = designationsId;
    data['location'] = location;
    data['app_location'] = appLocation;
    data['role_id'] = roleId;
    data['last_login'] = lastLogin;
    data['branch'] = branch;
    return data;
  }
}
