class SaveLocationModel {
  String? status;
  String? message;
  SaveLocationData? data;

  SaveLocationModel({this.status, this.message, this.data});

  SaveLocationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? SaveLocationData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) data['data'] = this.data!.toJson();
    return data;
  }
}

class SaveLocationData {
  int? trackingId;
  String? activityType;
  String? savedAt;

  SaveLocationData({this.trackingId, this.activityType, this.savedAt});

  SaveLocationData.fromJson(Map<String, dynamic> json) {
    trackingId = json['tracking_id'];
    activityType = json['activity_type'];
    savedAt = json['saved_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'tracking_id': trackingId,
      'activity_type': activityType,
      'saved_at': savedAt,
    };
  }
}
