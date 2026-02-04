import 'dart:convert';
import 'package:flutter/foundation.dart';

class EmployeeDetailsModel {
  final String status;
  final String message;
  final EmployeeDetailsData? data;

  EmployeeDetailsModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory EmployeeDetailsModel.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailsModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data:
          json['data'] != null
              ? EmployeeDetailsData.fromJson(json['data'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message, 'data': data?.toJson()};
  }
}

class EmployeeDetailsData {
  final BasicInfo? basicInfo;
  final ProfessionalInfo? professionalInfo;
  final BankDetails? bankDetails;
  final SalaryDetails? salaryDetails;
  final AddressInfo? addressInfo;
  final CreatedBy? recruiter;
  final CreatedBy? createdBy;
  final DocumentsInfo? documents;
  final LettersInfo? letters;
  final CircularsInfo? circulars;
  final PayslipsInfo? payslips;

  EmployeeDetailsData({
    this.basicInfo,
    this.professionalInfo,
    this.bankDetails,
    this.salaryDetails,
    this.addressInfo,
    this.recruiter,
    this.createdBy,
    this.documents,
    this.letters,
    this.circulars,
    this.payslips,
  });

  factory EmployeeDetailsData.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailsData(
      basicInfo:
          json['basic_info'] != null
              ? BasicInfo.fromJson(json['basic_info'])
              : null,
      professionalInfo:
          json['professional_info'] != null
              ? ProfessionalInfo.fromJson(json['professional_info'])
              : null,
      bankDetails:
          json['bank_details'] != null
              ? BankDetails.fromJson(json['bank_details'])
              : null,
      salaryDetails:
          json['salary_details'] != null
              ? SalaryDetails.fromJson(json['salary_details'])
              : null,
      addressInfo:
          json['address_info'] != null
              ? AddressInfo.fromJson(json['address_info'])
              : null,
      recruiter:
          json['recruiter'] != null
              ? CreatedBy.fromJson(json['recruiter'])
              : null,
      createdBy:
          json['created_by'] != null
              ? CreatedBy.fromJson(json['created_by'])
              : null,
      documents:
          json['documents'] != null
              ? DocumentsInfo.fromJson(json['documents'])
              : null,
      letters:
          json['letters'] != null
              ? LettersInfo.fromJson(json['letters'])
              : null,
      circulars:
          json['circulars'] != null
              ? CircularsInfo.fromJson(json['circulars'])
              : null,
      payslips:
          json['payslips'] != null
              ? PayslipsInfo.fromJson(json['payslips'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basic_info': basicInfo?.toJson(),
      'professional_info': professionalInfo?.toJson(),
      'bank_details': bankDetails?.toJson(),
      'salary_details': salaryDetails?.toJson(),
      'address_info': addressInfo?.toJson(),
      'recruiter': recruiter?.toJson(),
      'created_by': createdBy?.toJson(),
      'documents': documents?.toJson(),
      'letters': letters?.toJson(),
      'circulars': circulars?.toJson(),
      'payslips': payslips?.toJson(),
    };
  }
}

class PayslipsInfo {
  final int? totalPayslips;
  final List<PayslipItem>? payslipList;

  PayslipsInfo({this.totalPayslips, this.payslipList});

  factory PayslipsInfo.fromJson(Map<String, dynamic> json) {
    return PayslipsInfo(
      totalPayslips:
          json['total_payslips'] is int
              ? json['total_payslips']
              : int.tryParse(json['total_payslips']?.toString() ?? '0'),
      payslipList:
          json['payslip_list'] != null
              ? (json['payslip_list'] as List)
                  .map((item) => PayslipItem.fromJson(item))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_payslips': totalPayslips,
      'payslip_list': payslipList?.map((item) => item.toJson()).toList(),
    };
  }
}

class PayslipItem {
  final String? payslipId;
  final String? salaryMonth;
  final String? createdDate;
  final String? grossSalary;
  final String? basic;
  final String? hra;
  final String? incentiveBonus;
  final String? claim;
  final String? allowance;
  final String? allowanceComments;
  final String? pf;
  final String? pt;
  final String? esi;
  final String? securityDeposit;
  final String? lop;
  final String? loanAdvance;
  final String? training;
  final String? others;
  final String? othersComments;
  final String? tds;
  final String? totalAllowances;
  final String? totalDeductions;
  final String? netSalary;
  final String? totalDays;
  final String? lopDays;
  final int? leaveDays;
  final String? workedDays;
  final String? employeeCategoryType;
  final String? status;
  final String? statusComments;
  final String? isManualLop;
  final String? isNeftReady;
  final String? payslipPdfUrl;

  PayslipItem({
    this.payslipId,
    this.salaryMonth,
    this.createdDate,
    this.grossSalary,
    this.basic,
    this.hra,
    this.incentiveBonus,
    this.claim,
    this.allowance,
    this.allowanceComments,
    this.pf,
    this.pt,
    this.esi,
    this.securityDeposit,
    this.lop,
    this.loanAdvance,
    this.training,
    this.others,
    this.othersComments,
    this.tds,
    this.totalAllowances,
    this.totalDeductions,
    this.netSalary,
    this.totalDays,
    this.lopDays,
    this.leaveDays,
    this.workedDays,
    this.employeeCategoryType,
    this.status,
    this.statusComments,
    this.isManualLop,
    this.isNeftReady,
    this.payslipPdfUrl,
  });

  factory PayslipItem.fromJson(Map<String, dynamic> json) {
    return PayslipItem(
      payslipId: json['payslip_id']?.toString(),
      salaryMonth: json['salary_month']?.toString(),
      createdDate: json['created_date']?.toString(),
      grossSalary: json['gross_salary']?.toString(),
      basic: json['basic']?.toString(),
      hra: json['hra']?.toString(),
      incentiveBonus: json['incentive_bonus']?.toString(),
      claim: json['claim']?.toString(),
      allowance: json['allowance']?.toString(),
      allowanceComments: json['allowance_comments']?.toString(),
      pf: json['pf']?.toString(),
      pt: json['pt']?.toString(),
      esi: json['esi']?.toString(),
      securityDeposit: json['security_deposit']?.toString(),
      lop: json['lop']?.toString(),
      loanAdvance: json['loan_advance']?.toString(),
      training: json['training']?.toString(),
      others: json['others']?.toString(),
      othersComments: json['others_comments']?.toString(),
      tds: json['tds']?.toString(),
      totalAllowances: json['total_allowances']?.toString(),
      totalDeductions: json['total_deductions']?.toString(),
      netSalary: json['net_salary']?.toString(),
      totalDays: json['total_days']?.toString(),
      lopDays: json['lop_days']?.toString(),
      leaveDays: json['leave_days'] is int
          ? json['leave_days']
          : int.tryParse(json['leave_days']?.toString() ?? '0'),
      workedDays: json['worked_days']?.toString(),
      employeeCategoryType: json['employee_category_type']?.toString(),
      status: json['status']?.toString(),
      statusComments: json['status_comments']?.toString(),
      isManualLop: json['is_manual_lop']?.toString(),
      isNeftReady: json['is_neft_ready']?.toString(),
      payslipPdfUrl: json['payslip_pdf_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payslip_id': payslipId,
      'salary_month': salaryMonth,
      'created_date': createdDate,
      'gross_salary': grossSalary,
      'basic': basic,
      'hra': hra,
      'incentive_bonus': incentiveBonus,
      'claim': claim,
      'allowance': allowance,
      'allowance_comments': allowanceComments,
      'pf': pf,
      'pt': pt,
      'esi': esi,
      'security_deposit': securityDeposit,
      'lop': lop,
      'loan_advance': loanAdvance,
      'training': training,
      'others': others,
      'others_comments': othersComments,
      'tds': tds,
      'total_allowances': totalAllowances,
      'total_deductions': totalDeductions,
      'net_salary': netSalary,
      'total_days': totalDays,
      'lop_days': lopDays,
      'leave_days': leaveDays,
      'worked_days': workedDays,
      'employee_category_type': employeeCategoryType,
      'status': status,
      'status_comments': statusComments,
      'is_manual_lop': isManualLop,
      'is_neft_ready': isNeftReady,
      'payslip_pdf_url': payslipPdfUrl,
    };
  }
}

class BasicInfo {
  final String? userId;
  final String? employmentId;
  final String? username;
  final String? fullname;
  final String? email;
  final String? mobile;
  final String? emergencyContact;
  final String? avatar;
  final String? status;

  BasicInfo({
    this.userId,
    this.employmentId,
    this.username,
    this.fullname,
    this.email,
    this.mobile,
    this.emergencyContact,
    this.avatar,
    this.status,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      userId: json['user_id']?.toString(),
      employmentId: json['employment_id']?.toString(),
      username: json['username']?.toString(),
      fullname: json['fullname']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      emergencyContact: json['emergency_contact']?.toString(),
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'employment_id': employmentId,
      'username': username,
      'fullname': fullname,
      'email': email,
      'mobile': mobile,
      'emergency_contact': emergencyContact,
      'avatar': avatar,
      'status': status,
    };
  }
}

class ProfessionalInfo {
  final String? designation;
  final String? department;
  final String? branch;
  final String? zoneId;
  final String? educationQualification;
  final String? payrollCategory;
  final String? joiningDate;
  final String? dateOfBirth;
  final String? gender;
  final String? maritalStatus;

  ProfessionalInfo({
    this.designation,
    this.department,
    this.branch,
    this.zoneId,
    this.educationQualification,
    this.payrollCategory,
    this.joiningDate,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
  });

  factory ProfessionalInfo.fromJson(Map<String, dynamic> json) {
    return ProfessionalInfo(
      designation: json['designation']?.toString(),
      department: json['department']?.toString(),
      branch: json['branch']?.toString(),
      zoneId: json['zone_id']?.toString(),
      educationQualification: json['education_qualification']?.toString(),
      payrollCategory: json['payroll_category']?.toString(),
      joiningDate: json['joining_date']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'designation': designation,
      'department': department,
      'branch': branch,
      'zone_id': zoneId,
      'education_qualification': educationQualification,
      'payroll_category': payrollCategory,
      'joining_date': joiningDate,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'marital_status': maritalStatus,
    };
  }
}

class BankDetails {
  final String? bankName;
  final String? accountNumber;
  final String? bankIfscCode;
  final String? branchName;
  final String? accountName;
  final String? panNumber;
  final String? uanNumber;

  BankDetails({
    this.bankName,
    this.accountNumber,
    this.bankIfscCode,
    this.branchName,
    this.accountName,
    this.panNumber,
    this.uanNumber,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankName: json['bank_name']?.toString(),
      accountNumber: json['account_number']?.toString(),
      bankIfscCode: json['bank_ifsc_code']?.toString(),
      branchName: json['branch_name']?.toString(),
      accountName: json['account_name']?.toString(),
      panNumber: json['pan_number']?.toString(),
      uanNumber: json['uan_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_name': bankName,
      'account_number': accountNumber,
      'bank_ifsc_code': bankIfscCode,
      'branch_name': branchName,
      'account_name': accountName,
      'pan_number': panNumber,
      'uan_number': uanNumber,
    };
  }
}

class SalaryDetails {
  final String? annualCtc;
  final String? monthlyCtc;
  final String? basic;
  final String? hra;
  final String? pf; // Changed to String to handle "101525703211"
  final String? esi;
  final String? monthlyTakeHome;
  final String? monthlyTds;

  SalaryDetails({
    this.annualCtc,
    this.monthlyCtc,
    this.basic,
    this.hra,
    this.pf,
    this.esi,
    this.monthlyTakeHome,
    this.monthlyTds,
  });

  factory SalaryDetails.fromJson(Map<String, dynamic> json) {
    return SalaryDetails(
      annualCtc: json['annual_ctc']?.toString(),
      monthlyCtc: json['monthly_ctc']?.toString(),
      basic: json['basic']?.toString(),
      hra: json['hra']?.toString(),
      pf: json['pf']?.toString(), // Keep as string to preserve full PF number
      esi: json['esi']?.toString(),
      monthlyTakeHome: json['monthly_take_home']?.toString(),
      monthlyTds: json['monthly_tds']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'annual_ctc': annualCtc,
      'monthly_ctc': monthlyCtc,
      'basic': basic,
      'hra': hra,
      'pf': pf,
      'esi': esi,
      'monthly_take_home': monthlyTakeHome,
      'monthly_tds': monthlyTds,
    };
  }
}

class AddressInfo {
  final String? permanentAddress;
  final String? presentAddress;
  final String? city;

  AddressInfo({this.permanentAddress, this.presentAddress, this.city});

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      permanentAddress: json['permanent_address']?.toString(),
      presentAddress: json['present_address']?.toString(),
      city: json['city']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'permanent_address': permanentAddress,
      'present_address': presentAddress,
      'city': city,
    };
  }
}

class CreatedBy {
  final String? userId;
  final String? fullname;
  final String? avatar;

  CreatedBy({this.userId, this.fullname, this.avatar});

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      userId: json['user_id']?.toString(),
      fullname: json['fullname']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'fullname': fullname, 'avatar': avatar};
  }
}

class DocumentsInfo {
  final int? totalDocuments;
  final List<DocumentItem>? documentList;

  DocumentsInfo({this.totalDocuments, this.documentList});

  factory DocumentsInfo.fromJson(Map<String, dynamic> json) {
    return DocumentsInfo(
      totalDocuments:
          json['total_documents'] is int
              ? json['total_documents']
              : int.tryParse(json['total_documents']?.toString() ?? '0'),
      documentList:
          json['document_list'] != null
              ? (json['document_list'] as List)
                  .map((item) => DocumentItem.fromJson(item))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_documents': totalDocuments,
      'document_list': documentList?.map((item) => item.toJson()).toList(),
    };
  }
}

class DocumentItem {
  final String? documentName;
  final String? filename;
  final String? fileUrl;
  final bool? hasFile;

  DocumentItem({this.documentName, this.filename, this.fileUrl, this.hasFile});

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    // Handle file_url that might be a JSON string for "Other Document"
    String? parsedFileUrl = json['file_url']?.toString();

    // If file_url is a JSON string (like for "Other Document"), try to parse it
    if (parsedFileUrl != null && parsedFileUrl.startsWith('[')) {
      try {
        final List<dynamic> parsed = jsonDecode(parsedFileUrl);
        if (parsed.isNotEmpty && parsed[0] is Map) {
          final firstDoc = parsed[0] as Map<String, dynamic>;
          parsedFileUrl =
              firstDoc['fullPath']?.toString() ??
              firstDoc['path']?.toString() ??
              parsedFileUrl;
        }
      } catch (e) {
        // If parsing fails, use original URL
        if (kDebugMode) print("⚠️ Could not parse file_url JSON: $e");
      }
    }

    return DocumentItem(
      documentName: json['document_name']?.toString(),
      filename: json['filename']?.toString(),
      fileUrl: parsedFileUrl,
      hasFile:
          json['has_file'] == true ||
          json['has_file'] == 1 ||
          json['has_file'] == "1",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_name': documentName,
      'filename': filename,
      'file_url': fileUrl,
      'has_file': hasFile,
    };
  }
}

class LettersInfo {
  final int? totalLetters;
  final List<LetterItem>? letterList;

  LettersInfo({this.totalLetters, this.letterList});

  factory LettersInfo.fromJson(Map<String, dynamic> json) {
    return LettersInfo(
      totalLetters:
          json['total_letters'] is int
              ? json['total_letters']
              : int.tryParse(json['total_letters']?.toString() ?? '0'),
      letterList:
          json['letter_list'] != null
              ? (json['letter_list'] as List)
                  .map((item) => LetterItem.fromJson(item))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_letters': totalLetters,
      'letter_list': letterList?.map((item) => item.toJson()).toList(),
    };
  }
}

class LetterItem {
  final String? letterId;
  final String? letterType;
  final String? templateName;
  final String? content;
  final String? description;
  final String? date;
  final String? status;

  LetterItem({
    this.letterId,
    this.letterType,
    this.templateName,
    this.content,
    this.description,
    this.date,
    this.status,
  });

  factory LetterItem.fromJson(Map<String, dynamic> json) {
    return LetterItem(
      letterId: json['letter_id']?.toString(),
      letterType: json['letter_type']?.toString(),
      templateName: json['template_name']?.toString(),
      content: json['content']?.toString(),
      description: json['description']?.toString(),
      date: json['date']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'letter_id': letterId,
      'letter_type': letterType,
      'template_name': templateName,
      'content': content,
      'description': description,
      'date': date,
      'status': status,
    };
  }
}

class CircularsInfo {
  final int? totalCirculars;
  final List<CircularItem>? circularList;

  CircularsInfo({this.totalCirculars, this.circularList});

  factory CircularsInfo.fromJson(Map<String, dynamic> json) {
    return CircularsInfo(
      totalCirculars:
          json['total_circulars'] is int
              ? json['total_circulars']
              : int.tryParse(json['total_circulars']?.toString() ?? '0'),
      circularList:
          json['circular_list'] != null
              ? (json['circular_list'] as List)
                  .map((item) => CircularItem.fromJson(item))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_circulars': totalCirculars,
      'circular_list': circularList?.map((item) => item.toJson()).toList(),
    };
  }
}

class CircularItem {
  final String? letterId;
  final String? letterType;
  final String? templateName;
  final String? content;
  final String? description;
  final String? date;
  final String? status;
  final String? circularFor;

  CircularItem({
    this.letterId,
    this.letterType,
    this.templateName,
    this.content,
    this.description,
    this.date,
    this.status,
    this.circularFor,
  });

  factory CircularItem.fromJson(Map<String, dynamic> json) {
    return CircularItem(
      letterId: json['letter_id']?.toString(),
      letterType: json['letter_type']?.toString(),
      templateName: json['template_name']?.toString(),
      content: json['content']?.toString(),
      description: json['description']?.toString(),
      date: json['date']?.toString(),
      status: json['status']?.toString(),
      circularFor: json['circular_for']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'letter_id': letterId,
      'letter_type': letterType,
      'template_name': templateName,
      'content': content,
      'description': description,
      'date': date,
      'status': status,
      'circular_for': circularFor,
    };
  }
}
