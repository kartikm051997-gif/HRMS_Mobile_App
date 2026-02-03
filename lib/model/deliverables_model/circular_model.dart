class CircularModel {
  final String id;
  final String date;
  final String circularName;
  final String documentUrl;
  final String fileName;
  final String? content; // HTML content
  final String? templateName;
  final String? description;
  final String? status;
  final String? circularFor;

  CircularModel({
    required this.id,
    required this.date,
    required this.circularName,
    required this.documentUrl,
    required this.fileName,
    this.content,
    this.templateName,
    this.description,
    this.status,
    this.circularFor,
  });

  factory CircularModel.fromJson(Map<String, dynamic> json) {
    return CircularModel(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      circularName: json['circular_name'] ?? '',
      documentUrl: json['document_url'] ?? '',
      fileName: json['file_name'] ?? '',
      content: json['content']?.toString(),
      templateName: json['template_name']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      circularFor: json['circular_for']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'circular_name': circularName,
      'document_url': documentUrl,
      'file_name': fileName,
      'content': content,
      'template_name': templateName,
      'description': description,
      'status': status,
      'circular_for': circularFor,
    };
  }
}
