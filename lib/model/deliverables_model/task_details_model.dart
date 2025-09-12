class TaskModel {
  final String id;
  final String title;
  final String startDate;
  final String endDate;
  final String status;
  final String assignedBy;
  final String documentUrl;
  final String fileName;

  TaskModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.assignedBy,
    required this.documentUrl,
    required this.fileName,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? '',
      assignedBy: json['assigned_by'] ?? '',
      documentUrl: json['document_url'] ?? '',
      fileName: json['file_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'assigned_by': assignedBy,
      'document_url': documentUrl,
      'file_name': fileName,
    };
  }
}
