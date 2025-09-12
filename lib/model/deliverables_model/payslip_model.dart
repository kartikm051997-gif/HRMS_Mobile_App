class PaySlipModel {
  final String id;
  final String date;
  final String salaryMonth;
  final String salary;
  final String documentUrl;
  final String fileName;

  PaySlipModel({
    required this.id,
    required this.date,
    required this.salaryMonth,
    required this.salary,
    required this.documentUrl,
    required this.fileName,
  });

  factory PaySlipModel.fromJson(Map<String, dynamic> json) {
    return PaySlipModel(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      salaryMonth: json['salary_month'] ?? '',
      salary: json['salary'] ?? '',
      documentUrl: json['document_url'] ?? '',
      fileName: json['file_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'salary_month': salaryMonth,
      'salary': salary,
      'document_url': documentUrl,
      'file_name': fileName,
    };
  }
}