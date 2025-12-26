
class SaveLocationModel {
  String? status;
  String? message;
  Data? data;

  SaveLocationModel({this.status, this.message, this.data});

  SaveLocationModel.fromJson(Map<String, dynamic> json) {
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
  int? trackingId;
  String? activityType;
  String? savedAt;

  Data({this.trackingId, this.activityType, this.savedAt});

  Data.fromJson(Map<String, dynamic> json) {
    trackingId = json['tracking_id'];
    activityType = json['activity_type'];
    savedAt = json['saved_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tracking_id'] = this.trackingId;
    data['activity_type'] = this.activityType;
    data['saved_at'] = this.savedAt;
    return data;
  }
}
