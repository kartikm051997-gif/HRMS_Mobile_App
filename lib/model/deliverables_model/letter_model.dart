class LetterModel {
  final String id;
  final String date;
  final String letterType;
  final String documentUrl;
  final String fileName;
  final String? content; // HTML content
  final String? templateName;
  final String? description;
  final String? status;

  LetterModel({
    required this.id,
    required this.date,
    required this.letterType,
    required this.documentUrl,
    required this.fileName,
    this.content,
    this.templateName,
    this.description,
    this.status,
  });

  factory LetterModel.fromJson(Map<String, dynamic> json) {
    return LetterModel(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      letterType: json['letter_type'] ?? '',
      documentUrl: json['document_url'] ?? '',
      fileName: json['file_name'] ?? '',
      content: json['content']?.toString(),
      templateName: json['template_name']?.toString(),
      description: json['description']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'letter_type': letterType,
      'document_url': documentUrl,
      'file_name': fileName,
      'content': content,
      'template_name': templateName,
      'description': description,
      'status': status,
    };
  }
}
