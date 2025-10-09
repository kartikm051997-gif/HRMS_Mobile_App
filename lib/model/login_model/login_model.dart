class LoginApiModel {
  String? status;
  String? message;
  String? userId;
  String? role;
  User? user;

  LoginApiModel({this.status, this.message, this.userId, this.role, this.user});

  LoginApiModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    userId = json['user_id'];
    role = json['role'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['user_id'] = this.userId;
    data['role'] = this.role;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? fullname;
  String? branch;
  String? avatar;

  User({this.fullname, this.branch, this.avatar});

  User.fromJson(Map<String, dynamic> json) {
    fullname = json['fullname'];
    branch = json['branch'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fullname'] = this.fullname;
    data['branch'] = this.branch;
    data['avatar'] = this.avatar;
    return data;
  }
}
