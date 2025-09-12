class LetterModel {
  final String id;
  final String date;
  final String letterType;
  final String documentUrl;
  final String fileName;

  LetterModel({
    required this.id,
    required this.date,
    required this.letterType,
    required this.documentUrl,
    required this.fileName,
  });

  factory LetterModel.fromJson(Map<String, dynamic> json) {
    return LetterModel(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      letterType: json['letter_type'] ?? '',
      documentUrl: json['document_url'] ?? '',
      fileName: json['file_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'letter_type': letterType,
      'document_url': documentUrl,
      'file_name': fileName,
    };
  }
}
