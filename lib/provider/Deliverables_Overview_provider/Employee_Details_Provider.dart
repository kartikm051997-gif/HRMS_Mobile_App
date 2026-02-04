import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../model/EmployeeDetailsModel/employee_details_model.dart';
import '../../../servicesAPI/EmployeeDetailsService/employee_details_service.dart';

class EmployeeDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  Map<String, dynamic>? employeeDetails;
  EmployeeDetailsModel? _employeeDetailsModel;

  // Getters for easy access to structured data
  BasicInfo? get basicInfo => _employeeDetailsModel?.data?.basicInfo;
  ProfessionalInfo? get professionalInfo =>
      _employeeDetailsModel?.data?.professionalInfo;
  BankDetails? get bankDetails => _employeeDetailsModel?.data?.bankDetails;
  SalaryDetails? get salaryDetails =>
      _employeeDetailsModel?.data?.salaryDetails;
  AddressInfo? get addressInfo => _employeeDetailsModel?.data?.addressInfo;
  CreatedBy? get recruiter => _employeeDetailsModel?.data?.recruiter;
  CreatedBy? get createdBy => _employeeDetailsModel?.data?.createdBy;
  DocumentsInfo? get documents => _employeeDetailsModel?.data?.documents;
  LettersInfo? get letters => _employeeDetailsModel?.data?.letters;
  CircularsInfo? get circulars => _employeeDetailsModel?.data?.circulars;
  PayslipsInfo? get payslips => _employeeDetailsModel?.data?.payslips;

  /// ✅ Fetch employee details by userId/empId using API
  /// Note: API expects user_id, but we accept empId which might be userId or employmentId
  Future<void> fetchEmployeeDetails(String userIdOrEmpId) async {
    if (userIdOrEmpId.isEmpty) {
      debugPrint("❌ User ID/Emp ID is empty. Cannot fetch details.");
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        print(
          "🔄 EmployeeDetailsProvider: Fetching details for user_id: $userIdOrEmpId",
        );
      }

      // API expects user_id, so we use the provided ID directly
      // If it's employmentId, the API might still work, or we may need to map it
      final service = EmployeeDetailsService();
      _employeeDetailsModel = await service.getEmployeeDetails(userIdOrEmpId);

      if (_employeeDetailsModel != null &&
          _employeeDetailsModel!.data != null) {
        // Convert model to Map for backward compatibility
        employeeDetails = _convertModelToMap(_employeeDetailsModel!);

        if (kDebugMode) {
          print("✅ Employee Details Fetched Successfully");
          print("   Name: ${basicInfo?.fullname ?? 'N/A'}");
          print("   Designation: ${professionalInfo?.designation ?? 'N/A'}");
          print("   Branch: ${professionalInfo?.branch ?? 'N/A'}");
        }
      } else {
        debugPrint("⚠️ EmployeeDetailsProvider: Response data is null");
        employeeDetails = {};
      }
    } catch (e) {
      debugPrint("❌ Error fetching employee details: $e");
      employeeDetails = {};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Convert model to Map for backward compatibility with existing code
  Map<String, dynamic> _convertModelToMap(EmployeeDetailsModel model) {
    final basic = model.data?.basicInfo;
    final professional = model.data?.professionalInfo;
    final bank = model.data?.bankDetails;
    final salary = model.data?.salaryDetails;
    final address = model.data?.addressInfo;
    final recruiter = model.data?.recruiter;
    final createdBy = model.data?.createdBy;
    final documents = model.data?.documents;
    final letters = model.data?.letters;
    final circulars = model.data?.circulars;

    return {
      // Basic Info - provide both camelCase and snake_case for UI compatibility
      "empId": basic?.employmentId ?? basic?.userId ?? "",
      "userId": basic?.userId ?? "",
      "employmentId": basic?.employmentId ?? "",
      "name": basic?.fullname ?? "",
      "fullname": basic?.fullname ?? "",
      "username": basic?.username ?? "",
      "mobile": basic?.mobile ?? "",
      "email": basic?.email ?? "",
      "emergencyContact": basic?.emergencyContact ?? "",
      "photo": basic?.avatar ?? "",
      "avatar": basic?.avatar ?? "",
      "status": basic?.status ?? "",

      // Professional Info
      "designation": professional?.designation ?? "",
      "department": professional?.department ?? "",
      "branch": professional?.branch ?? "",
      "zoneId": professional?.zoneId ?? "",
      "joiningDate": professional?.joiningDate ?? "",
      "dob": professional?.dateOfBirth ?? "",
      "dateOfBirth": professional?.dateOfBirth ?? "",
      "gender": professional?.gender ?? "",
      "maritalStatus": professional?.maritalStatus ?? "",
      "payrollCategory": professional?.payrollCategory ?? "",
      "payroll_category":
          professional?.payrollCategory ?? "", // UI expects snake_case
      "education": professional?.educationQualification ?? "",
      "educationQualification": professional?.educationQualification ?? "",

      // Address Info - provide both formats for UI compatibility
      "presentAddress": address?.presentAddress ?? "",
      "present_address": address?.presentAddress ?? "", // UI expects snake_case
      "permanentAddress": address?.permanentAddress ?? "",
      "permanent_address":
          address?.permanentAddress ?? "", // UI expects snake_case
      "city": address?.city ?? "",

      // Bank Details
      "pan": bank?.panNumber ?? "",
      "panNumber": bank?.panNumber ?? "",
      "aadhar": "", // Not in API response
      "bankName": bank?.bankName ?? "",
      "accountNumber": bank?.accountNumber ?? "",
      "bankIfscCode": bank?.bankIfscCode ?? "",
      "branchName": bank?.branchName ?? "",
      "accountName": bank?.accountName ?? "",
      "uanNumber": bank?.uanNumber ?? "",

      // Salary Details
      "annualCtc": salary?.annualCtc ?? "",
      "monthlyCtc": salary?.monthlyCtc ?? "",
      "basic": salary?.basic ?? "",
      "hra": salary?.hra ?? "",
      "pf": salary?.pf?.toString() ?? "",
      "esi": salary?.esi ?? "",
      "monthlyTakeHome": salary?.monthlyTakeHome ?? "",
      "monthlyTds": salary?.monthlyTds ?? "",

      // Recruiter & Created By
      "recruiter": recruiter?.fullname ?? "",
      "recruiterAvatar": recruiter?.avatar ?? "",
      "created_by": createdBy?.fullname ?? "", // UI expects snake_case
      "createdBy": createdBy?.fullname ?? "",
      "createdByAvatar": createdBy?.avatar ?? "",

      // Documents
      "totalDocuments": documents?.totalDocuments ?? 0,
      "documentList":
          documents?.documentList
              ?.map(
                (doc) => {
                  "document_name": doc.documentName ?? "",
                  "filename": doc.filename ?? "",
                  "file_url": doc.fileUrl ?? "",
                  "has_file": doc.hasFile ?? false,
                },
              )
              .toList() ??
          [],

      // Letters
      "totalLetters": letters?.totalLetters ?? 0,
      "letterList":
          letters?.letterList
              ?.map(
                (letter) => {
                  "letter_id": letter.letterId ?? "",
                  "letter_type": letter.letterType ?? "",
                  "template_name": letter.templateName ?? "",
                  "content": letter.content ?? "",
                  "description": letter.description ?? "",
                  "date": letter.date ?? "",
                  "status": letter.status ?? "",
                },
              )
              .toList() ??
          [],

      // Circulars
      "totalCirculars": circulars?.totalCirculars ?? 0,
      "circularList":
          circulars?.circularList
              ?.map(
                (circular) => {
                  "letter_id": circular.letterId ?? "",
                  "letter_type": circular.letterType ?? "",
                  "template_name": circular.templateName ?? "",
                  "content": circular.content ?? "",
                  "description": circular.description ?? "",
                  "date": circular.date ?? "",
                  "status": circular.status ?? "",
                  "circular_for": circular.circularFor ?? "",
                },
              )
              .toList() ??
          [],
    };
  }

  /// ✅ Get a field safely (avoids null issues)
  String getField(String key) {
    return employeeDetails?[key]?.toString() ?? "N/A";
  }

  /// ✅ Reset Employee Data
  void clearEmployeeDetails() {
    employeeDetails = null;
    _employeeDetailsModel = null;
    notifyListeners();
  }
}
