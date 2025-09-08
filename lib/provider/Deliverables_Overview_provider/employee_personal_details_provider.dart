import 'package:flutter/material.dart';

class EmployeeInformationProvider extends ChangeNotifier {
  String _selectedGender = "Male"; // Default value

  String get selectedGender => _selectedGender;

  void setGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  Future<void> fetchEmployeeDetails(String empId) async {
    try {
      // Dummy API response (replace with real API)
      final response = {
        "email": "viyraj95@gmail.com",
        "mobile": "9677670823",
        "gender": "Male",
        "experience": "5",
        "dob": "02-05-1995",
        "age": "29",
        "religion": "Hindu",
        "Mother Tongue": "Tamil",
        "Caste": "",
        "Blood Group ": "A+",
      };

      // Update controllers with API data
      emailController.text = response["email"] ?? "";
      mobileController.text = response["mobile"] ?? "";
      experienceController.text = response["experience"] ?? "";
      dobController.text = response["dob"] ?? "";
      ageController.text = response["age"] ?? "";
      religionController.text = response["religion"] ?? "";
      motherTongueController.text= response["Mother Tongue"] ?? "";
      casteController.text = response["Caste"] ?? "";
      bloodGroupController.text= response["Blood Group"] ?? "";

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching employee details: $e");
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    mobileController.dispose();
    experienceController.dispose();
    dobController.dispose();
    ageController.dispose();
    religionController.dispose();
    motherTongueController.dispose();
    casteController.dispose();
    bloodGroupController.dispose();
    super.dispose();
  }

  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final experienceController = TextEditingController();
  final dobController = TextEditingController();
  final ageController = TextEditingController();
  final religionController = TextEditingController();
  final motherTongueController = TextEditingController();
  final casteController = TextEditingController();
  final bloodGroupController = TextEditingController();
}
