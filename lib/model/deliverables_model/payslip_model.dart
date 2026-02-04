import '../../../model/EmployeeDetailsModel/employee_details_model.dart';

class PaySlipModel {
  final String id;
  final String date;
  final String salaryMonth;
  final String salary;
  final String documentUrl;
  final String fileName;
  final String? netSalary;
  final String? grossSalary;
  
  // Full payslip details
  final PayslipItem? payslipItem;

  PaySlipModel({
    required this.id,
    required this.date,
    required this.salaryMonth,
    required this.salary,
    required this.documentUrl,
    required this.fileName,
    this.netSalary,
    this.grossSalary,
    this.payslipItem,
  });

  factory PaySlipModel.fromJson(Map<String, dynamic> json) {
    return PaySlipModel(
      id: json['id'] ?? json['payslip_id'] ?? '',
      date: json['date'] ?? json['created_date'] ?? '',
      salaryMonth: json['salary_month'] ?? '',
      salary: json['salary'] ?? json['net_salary'] ?? '0.00',
      documentUrl: json['document_url'] ?? json['payslip_pdf_url'] ?? '',
      fileName: json['file_name'] ?? 'payslip.pdf',
      netSalary: json['net_salary']?.toString(),
      grossSalary: json['gross_salary']?.toString(),
    );
  }

  factory PaySlipModel.fromPayslipItem(PayslipItem item) {
    // Format salary month for display (e.g., "2025-01" -> "January 2025")
    String formattedMonth = item.salaryMonth ?? '';
    if (formattedMonth.isNotEmpty && formattedMonth.contains('-')) {
      try {
        final parts = formattedMonth.split('-');
        if (parts.length == 2) {
          final year = parts[0];
          final monthNum = int.tryParse(parts[1]) ?? 1;
          final monthNames = [
            '', 'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
          ];
          formattedMonth = '${monthNames[monthNum]} $year';
        }
      } catch (e) {
        // Keep original format if parsing fails
      }
    }

    return PaySlipModel(
      id: item.payslipId ?? '',
      date: item.createdDate ?? '',
      salaryMonth: formattedMonth,
      salary: item.netSalary ?? '0.00',
      documentUrl: item.payslipPdfUrl ?? '',
      fileName: 'payslip_${item.salaryMonth ?? 'unknown'}.pdf',
      netSalary: item.netSalary,
      grossSalary: item.grossSalary,
      payslipItem: item, // Store full item for detailed view
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
      'net_salary': netSalary,
      'gross_salary': grossSalary,
    };
  }
}