import 'dart:io';

import 'package:flutter/material.dart';

class NewEmployeeBankDetailsProvider extends ChangeNotifier{

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

  Future<void> fetchEmployeeDetails(String empId) async {
    try {
      // Dummy API response (replace with real API)
      final response = {"Employment ID": "12881"};

      // Update controllers with API data
      employmentIDController.text = response["Employment ID"] ?? "";

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching employee details: $e");
    }
  }

  final bankNameController = TextEditingController();
  final bankIFSCCodeController = TextEditingController();
  final accountNumberController = TextEditingController();
  final eSINumberController = TextEditingController();
  final pFNumberController = TextEditingController();
  final aadhaarNumberController = TextEditingController();
  final panNumberController = TextEditingController();
  final employmentIDController = TextEditingController();


  void dispose() {
    bankNameController.dispose();
    bankIFSCCodeController.dispose();
    accountNumberController.dispose();
    eSINumberController.dispose();
    pFNumberController.dispose();
    aadhaarNumberController.dispose();
    panNumberController.dispose();

    super.dispose();
  }

  bool _showBankSection = false;
  bool get showBankSection => _showBankSection;

  void toggleBankSection() {
    _showBankSection = !_showBankSection;
    notifyListeners();
  }

}