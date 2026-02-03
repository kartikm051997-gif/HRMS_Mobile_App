import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../servicesAPI/EmployeeDetailsService/employee_details_service.dart';

class EmployeeInformationProvider extends ChangeNotifier {
  bool isLoading = false;

  File? _selectedFile;

  File? get selectedFile => _selectedFile;
  void setFile(File file) {
    _selectedFile = file;
    notifyListeners();
  }

  void clearFile() {
    _selectedFile = null;
    notifyListeners();
  }

  File? _selectedJoiningLetter;
  File? get selectedJoiningLetter => _selectedJoiningLetter;

  void setJoiningLetter(File? file) {
    _selectedJoiningLetter = file;
    notifyListeners();
  }

  void clearJoiningLetter() {
    _selectedJoiningLetter = null;
    notifyListeners();
  }

  String _selectedGender = "Male"; // Default value

  String get selectedGender => _selectedGender;

  void setGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  final List<String> _materialStatus = ["Single"];
  List<String> get materialStatus => _materialStatus;

  String? _selectedmaterialStatus = "Single"; // ✅ Set default value here
  String? get selectedmaterialStatus => _selectedmaterialStatus;

  void setSelectedmaterialStatus(String? value) {
    _selectedmaterialStatus = value;
    print("Selected Marital Status: $_selectedmaterialStatus");
    notifyListeners();
  }

  final List<String> _secondaryContactRelationship = ["mother"];
  List<String> get secondaryContactRelationship =>
      _secondaryContactRelationship;

  // ✅ Make it non-final, so we can update it
  String? _selectedSecondaryContactRelationship = "mother";
  String? get selectedSecondaryContactRelationship =>
      _selectedSecondaryContactRelationship;

  void setSelectedSecondaryContactRelationship(String? value) {
    _selectedSecondaryContactRelationship = value;
    if (kDebugMode) {
      print("Selected Relationship: $_selectedSecondaryContactRelationship");
    }
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
        "Blood Group": "A+",
        "Secondary Contact Number": "9788772707",
        "Secondary Contact Occupation": "9788772707",
        "Secondary Contact Mobile": "9788772707",
        "Permanent Address": "7 kattapomman street thiruvarur",
        "Present Address": "Virugambakkam",
      };

      // Update controllers with API data
      emailController.text = response["email"] ?? "";
      mobileController.text = response["mobile"] ?? "";
      experienceController.text = response["experience"] ?? "";
      dobController.text = response["dob"] ?? "";
      ageController.text = response["age"] ?? "";
      religionController.text = response["religion"] ?? "";
      motherTongueController.text = response["Mother Tongue"] ?? "";
      casteController.text = response["Caste"] ?? "";
      bloodGroupController.text = response["Blood Group"] ?? "";
      secondaryContactNumberController.text =
          response["Secondary Contact Number"] ?? "";
      secondaryContactOccupationController.text =
          response["Secondary Contact Occupation"] ?? "";
      secondaryContactMobileController.text =
          response["Secondary Contact Mobile"] ?? "";
      permanentAddressController.text = response["Permanent Address"] ?? "";
      presentAddressController.text = response["Present Address"] ?? "";

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching employee details: $e");
    }
  }

  @override
  void dispose() {
    dobController.dispose();
    ageController.dispose();
    emailController.dispose();
    mobileController.dispose();
    experienceController.dispose();
    religionController.dispose();
    motherTongueController.dispose();
    casteController.dispose();
    bloodGroupController.dispose();
    secondaryContactNumberController.dispose();
    secondaryContactOccupationController.dispose();
    secondaryContactMobileController.dispose();
    permanentAddressController.dispose();
    presentAddressController.dispose();
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
  final choiceOfWorkController = TextEditingController();
  final secondaryContactNumberController = TextEditingController();
  final secondaryContactRelationshipController = TextEditingController();
  final secondaryContactOccupationController = TextEditingController();
  final secondaryContactMobileController = TextEditingController();
  final permanentAddressController = TextEditingController();
  final presentAddressController = TextEditingController();
}
