import 'package:flutter/material.dart';

class EduExpProvider extends ChangeNotifier {
  String _selectedNoticePeriod = "Male"; // Default value

  String get selectedGender => _selectedNoticePeriod;

  void setGender(String gender) {
    _selectedNoticePeriod = gender;
    notifyListeners();
  }

  final qualificationController = TextEditingController();
  final yearController = TextEditingController();
  final nameOfInstitutionController = TextEditingController();
  final percentageController = TextEditingController();
  final organizationController = TextEditingController();
  final designationController = TextEditingController();
  final previousExperienceYearController = TextEditingController();
  final salaryDrawnPerMonthController = TextEditingController();
  final reasonForLeavingController = TextEditingController();
  final computerLiteracyController = TextEditingController();
  final otherSkillsController = TextEditingController();
  final stayController = TextEditingController();
  final minimumYearsGuaranteedToStayController = TextEditingController();
  final probableOfDateOfJoiningController = TextEditingController();

  @override
  void dispose() {
    qualificationController.dispose();
    yearController.dispose();
    nameOfInstitutionController.dispose();
    percentageController.dispose();
    organizationController.dispose();
    designationController.dispose();
    previousExperienceYearController.dispose();
    salaryDrawnPerMonthController.dispose();
    reasonForLeavingController.dispose();
    computerLiteracyController.dispose();
    otherSkillsController.dispose();
    stayController.dispose();
    minimumYearsGuaranteedToStayController.dispose();
    probableOfDateOfJoiningController.dispose();

    super.dispose();
  }

  Future<void> fetchEduExpDetails(String empId) async {
    try {
      // Dummy API response (replace with real API)
      final response = {
        "qualification": "MCA",
        "year": "2018-08",
        "name of institution / university": "Anna university",
        "percentage obtained": "78",
        "organization": "zealous services",
        "designation": "software Developer",
        "previous Experience Year": "4",
        "salary Drawn per Month (INR)": "40000",
        "reason for Leaving": "Night shift",
        "computer Literacy": "yes",
        "other Skills": "upwork freelancing",
        "stay": "Day Scholar",
        "minimum Years Guaranteed to Stay": "5",
        "Probable of Date of Joining": "2018-08",
      };

      // Update controllers with API data
      qualificationController.text = response["qualification"] ?? "";
      yearController.text = response["year"] ?? "";
      nameOfInstitutionController.text =
          response["name of institution / university"] ?? "";
      percentageController.text = response["percentage obtained"] ?? "";
      organizationController.text = response["organization"] ?? "";
      designationController.text = response["designation"] ?? "";
      previousExperienceYearController.text =
          response["previous Experience Year"] ?? "";
      salaryDrawnPerMonthController.text =
          response["salary Drawn per Month (INR)"] ?? "";
      reasonForLeavingController.text = response["reason for Leaving"] ?? "";
      computerLiteracyController.text = response["computer Literacy"] ?? "";
      otherSkillsController.text = response["other Skills"] ?? "";
      stayController.text = response["stay"] ?? "";
      minimumYearsGuaranteedToStayController.text =
          response["minimum Years Guaranteed to Stay"] ?? "";
      probableOfDateOfJoiningController.text =
          response["Probable of Date of Joining"] ?? "";

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching employee details: $e");
    }
  }
}
