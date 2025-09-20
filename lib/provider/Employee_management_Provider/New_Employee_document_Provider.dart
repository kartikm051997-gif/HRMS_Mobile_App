import 'dart:io';

import 'package:flutter/cupertino.dart';

class NewEmployeeDocumentProvider extends ChangeNotifier {
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

  File? _selectedContractPaper;
  File? get selectedContractPaper => _selectedContractPaper;

  void setContractPaper(File? file) {
    _selectedContractPaper = file;
    notifyListeners();
  }

  void clearContractPaper() {
    _selectedContractPaper = null;
    notifyListeners();
  }

  File? _selectedAadhaarCard;
  File? get selectedAadhaarCard => _selectedAadhaarCard;

  void setAadhaarCard(File? file) {
    _selectedAadhaarCard = file;
    notifyListeners();
  }

  void clearAadhaarCard() {
    _selectedAadhaarCard = null;
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

  bool _showDocumentsSection = false;
  bool get showDocumentsSection => _showDocumentsSection;

  void toggleDocumentsSection() {
    _showDocumentsSection = !_showDocumentsSection;
    notifyListeners();
  }

  final employmentIDController = TextEditingController();
}
