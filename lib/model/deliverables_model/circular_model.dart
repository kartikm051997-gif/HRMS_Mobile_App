class CircularModel {
  final String id;
  final String date;
  final String circularName;
  final String documentUrl;
  final String fileName;

  CircularModel({
    required this.id,
    required this.date,
    required this.circularName,
    required this.documentUrl,
    required this.fileName,
  });

  factory CircularModel.fromJson(Map<String, dynamic> json) {
    return CircularModel(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      circularName: json['circular_name'] ?? '',
      documentUrl: json['document_url'] ?? '',
      fileName: json['file_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'circular_name': circularName,
      'document_url': documentUrl,
      'file_name': fileName,
    };
  }
}
