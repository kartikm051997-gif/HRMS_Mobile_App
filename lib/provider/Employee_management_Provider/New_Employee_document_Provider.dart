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

  // joining Letter
  void setJoiningLetter(File? file) {
    _selectedJoiningLetter = file;
    notifyListeners();
  }

  void clearJoiningLetter() {
    _selectedJoiningLetter = null;
    notifyListeners();
  }

  // contract letter
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

  // Aadhaar card
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

  // Pan card
  File? _selectedPanCard;
  File? get selectedPanCard => _selectedPanCard;

  void setPanCard(File? file) {
    _selectedPanCard = file;
    notifyListeners();
  }

  void cleaPanCard() {
    _selectedPanCard = null;
    notifyListeners();
  }

  // Bank passbook
  File? _selectedBankPassbook;
  File? get selectedBankPassbook => _selectedBankPassbook;

  void setBankPassbook(File? file) {
    _selectedBankPassbook = file;
    notifyListeners();
  }

  void cleaBankPassbook() {
    _selectedBankPassbook = null;
    notifyListeners();
  }

  // Current address proof
  File? _selectedCurrentAddressProof;
  File? get selectedCurrentAddressProof => _selectedCurrentAddressProof;

  void setCurrentAddressProof(File? file) {
    _selectedCurrentAddressProof = file;
    notifyListeners();
  }

  void cleaCurrentAddressProof() {
    _selectedCurrentAddressProof = null;
    notifyListeners();
  }

  // Driving licence
  File? _selectedDrivingLicence;
  File? get selectedDrivingLicence => _selectedDrivingLicence;

  void setDrivingLicence(File? file) {
    _selectedDrivingLicence = file;
    notifyListeners();
  }

  void cleaDrivingLicence() {
    _selectedDrivingLicence = null;
    notifyListeners();
  }

  // Passport
  File? _selectedPassport;
  File? get selectedPassport => _selectedPassport;

  void setPassport(File? file) {
    _selectedPassport = file;
    notifyListeners();
  }

  void cleaPassport() {
    _selectedPassport = null;
    notifyListeners();
  }

  // Other Document
  File? _selectedOtherDocument;
  File? get selectedOtherDocument => _selectedOtherDocument;

  void setOtherDocument(File? file) {
    _selectedOtherDocument = file;
    notifyListeners();
  }

  void cleaOtherDocument() {
    _selectedOtherDocument = null;
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
