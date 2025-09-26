import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RecruitmentOthersProvider extends ChangeNotifier {
  String _selectedChronicIllness = "No"; // Default value

  String get selectedChronicIllness => _selectedChronicIllness;

  void setChronicIllness(String value) {
    _selectedChronicIllness = value;
    notifyListeners();
  }

  // Text controllers for form fields
  final personalIdentificationMarksController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final treatmentDetailsController = TextEditingController();

  @override
  void dispose() {
    personalIdentificationMarksController.dispose();
    heightController.dispose();
    weightController.dispose();
    treatmentDetailsController.dispose();
    super.dispose();
  }

  // Method to validate form
  bool validateForm() {
    return personalIdentificationMarksController.text.isNotEmpty &&
        heightController.text.isNotEmpty &&
        weightController.text.isNotEmpty &&
        (_selectedChronicIllness == "No" ||
            treatmentDetailsController.text.isNotEmpty);
  }

  // Method to clear form
  void clearForm() {
    personalIdentificationMarksController.clear();
    heightController.clear();
    weightController.clear();
    treatmentDetailsController.clear();
    _selectedChronicIllness = "No";
    notifyListeners();
  }

  Future<void> fetchPersonalDetails(String empId) async {
    try {
      // Dummy API response (replace with real API)
      final response = {
        "personal_identification_marks": "Mole on left hand",
        "height_cm": "175",
        "weight_kg": "70",
        "chronic_illness": "No",
        "treatment_details": "",
      };

      // Update controllers with API data
      personalIdentificationMarksController.text =
          response["personal_identification_marks"] ?? "";
      heightController.text = response["height_cm"] ?? "";
      weightController.text = response["weight_kg"] ?? "";
      _selectedChronicIllness = response["chronic_illness"] ?? "No";
      treatmentDetailsController.text = response["treatment_details"] ?? "";

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching personal details: $e");
    }
  }

  Future<bool> savePersonalDetails(String empId) async {
    try {
      // Prepare data for API
      final data = {
        "emp_id": empId,
        "personal_identification_marks":
            personalIdentificationMarksController.text,
        "height_cm": heightController.text,
        "weight_kg": weightController.text,
        "chronic_illness": _selectedChronicIllness,
        "treatment_details": treatmentDetailsController.text,
      };

      // Dummy API call (replace with real API)
      await Future.delayed(const Duration(seconds: 1));

      if (kDebugMode) {
        print("Saving personal details: $data");
      }

      return true;
    } catch (e) {
      debugPrint("Error saving personal details: $e");
      return false;
    }
  }
}
