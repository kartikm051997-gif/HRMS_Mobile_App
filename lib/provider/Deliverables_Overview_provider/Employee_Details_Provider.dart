import 'package:flutter/material.dart';

class EmployeeDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  Map<String, dynamic>? employeeDetails;

  /// ✅ Fetch employee details by empId
  Future<void> fetchEmployeeDetails(String empId) async {
    if (empId.isEmpty) {
      debugPrint("❌ Employee ID is empty. Cannot fetch details.");
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // ⏳ Simulate API Delay (Replace with your actual API call)
      await Future.delayed(const Duration(seconds: 1));

      // ✅ Dummy Employee Data (for demo purpose)
      employeeDetails = {
        "empId": empId,
        "name": "Vignesh Raja",
        "designation": "Software Developer",
        "branch": "Corporate Office - Guindy",
        "mobile": "+91 98765 43210",
        "email": "vignesh@example.com",
        "aadhar": "1234-5678-9012",
        "pan": "ABCDE1234F",
        "joiningDate": "2024-01-10",
        "dob": "1995-06-21",
        "gender": "Male",
        "maritalStatus": "Single",
        "payrollCategory": "Full-Time",
        "education": "MCA",
        "recruiter": "HR Team",
        "createdBy": "Admin",
        "presentAddress": "No.12, Anna Nagar, Chennai",
        "permanentAddress": "No.12, Anna Nagar, Chennai",
        "photo": "", // Optional — will fallback to default photo
      };

      debugPrint("✅ Employee Details Fetched: $employeeDetails");
    } catch (e) {
      debugPrint("❌ Error fetching employee details: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Get a field safely (avoids null issues)
  String getField(String key) {
    return employeeDetails?[key]?.toString() ?? "N/A";
  }

  /// ✅ Reset Employee Data
  void clearEmployeeDetails() {
    employeeDetails = null;
    notifyListeners();
  }
}
