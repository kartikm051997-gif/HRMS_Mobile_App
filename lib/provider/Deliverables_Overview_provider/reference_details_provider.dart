import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReferenceDetailsProvider extends ChangeNotifier {
  String _selectedOffenceConviction = "No"; // Default value
  String _selectedCourtPoliceCase = "No"; // Default value
  String _selectedCaseType = "Criminal"; // Default value

  String get selectedOffenceConviction => _selectedOffenceConviction;
  String get selectedCourtPoliceCase => _selectedCourtPoliceCase;
  String get selectedCaseType => _selectedCaseType;

  void setOffenceConviction(String value) {
    _selectedOffenceConviction = value;
    notifyListeners();
  }

  void setCourtPoliceCase(String value) {
    _selectedCourtPoliceCase = value;
    notifyListeners();
  }

  void setCaseType(String value) {
    _selectedCaseType = value;
    notifyListeners();
  }

  // Text controllers for form fields
  final nameController = TextEditingController();
  final contactNumberController = TextEditingController();
  final designationController = TextEditingController();
  final institutionController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    contactNumberController.dispose();
    designationController.dispose();
    institutionController.dispose();
    super.dispose();
  }

  // Method to validate form
  bool validateForm() {
    return nameController.text.isNotEmpty &&
        contactNumberController.text.isNotEmpty &&
        designationController.text.isNotEmpty &&
        institutionController.text.isNotEmpty;
  }

  // Method to clear form
  void clearForm() {
    nameController.clear();
    contactNumberController.clear();
    designationController.clear();
    institutionController.clear();
    _selectedOffenceConviction = "No";
    _selectedCourtPoliceCase = "No";
    _selectedCaseType = "Criminal";
    notifyListeners();
  }

  Future<void> fetchReferenceDetails(String empId) async {
    try {
      // Dummy API response (replace with real API)
      final response = {
        "name": "John Doe",
        "contact_number": "9876543210",
        "designation": "Senior Manager",
        "institution": "XYZ Corporation",
        "offence_conviction": "No",
        "court_police_case": "No",
        "case_type": "Criminal",
      };

      // Update controllers with API data
      nameController.text = response["name"] ?? "";
      contactNumberController.text = response["contact_number"] ?? "";
      designationController.text = response["designation"] ?? "";
      institutionController.text = response["institution"] ?? "";
      _selectedOffenceConviction = response["offence_conviction"] ?? "No";
      _selectedCourtPoliceCase = response["court_police_case"] ?? "No";
      _selectedCaseType = response["case_type"] ?? "Criminal";

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching reference details: $e");
    }
  }

  Future<bool> saveReferenceDetails(String empId) async {
    try {
      // Prepare data for API
      final data = {
        "emp_id": empId,
        "name": nameController.text,
        "contact_number": contactNumberController.text,
        "designation": designationController.text,
        "institution": institutionController.text,
        "offence_conviction": _selectedOffenceConviction,
        "court_police_case": _selectedCourtPoliceCase,
        "case_type": _selectedCaseType,
      };

      // Dummy API call (replace with real API)
      await Future.delayed(const Duration(seconds: 1));

      if (kDebugMode) {
        print("Saving reference details: $data");
      }

      return true;
    } catch (e) {
      debugPrint("Error saving reference details: $e");
      return false;
    }
  }
}
