import 'dart:io';

import 'package:flutter/Material.dart';
import 'package:flutter/foundation.dart';

class NewEmployeeProvider extends ChangeNotifier {
  String _selectedApprovalUser = "No";


  String get selectedApprovalUser => _selectedApprovalUser;

  void setApprovalUser(String value) {
    _selectedApprovalUser = value;
    notifyListeners();
  }


  final List<String> _jobApplicationID = [
    "Karthik - JA00414",
    "Abi - JA00164",
    "Viki - JA00417",
  ];
  List<String> get jobApplicationID => _jobApplicationID;

  String? _selectedJobApplicationID;
  String? get selectedJobApplicationID => _selectedJobApplicationID;

  void setSelectedJobApplicationID(String? value) {
    _selectedJobApplicationID = value;
    if (kDebugMode) {
      print(_selectedJobApplicationID);
    }
    notifyListeners();
  }

  final List<String> _jobLocation = ["Aathur", "Assam", "Bangladesh"];
  List<String> get jobLocation => _jobLocation;

  String? _selectedJobLocation;
  String? get selectedJobLocation => _selectedJobLocation;

  void setSelectedJobLocation(String? value) {
    _selectedJobLocation = value;
    if (kDebugMode) {
      print(_selectedJobLocation);
    }
    notifyListeners();
  }

  final List<String> _gender = ["Male", "Female", "Other"];
  List<String> get gender => _gender;

  String? _selectedGender;
  String? get selectedGender => _selectedGender;

  void setSelectedGender(String? value) {
    _selectedGender = value;
    if (kDebugMode) {
      print(_selectedGender);
    }
    notifyListeners();
  }

  final List<String> _marriedStatus = [
    "unmarried",
    "married",
    "Divorced",
    "Widowed",
  ];
  List<String> get marriedStatus => _marriedStatus;

  String? _selectedMarriedStatus;
  String? get selectedMarriedStatus => _selectedMarriedStatus;

  void setSelectedMarriedStatus(String? value) {
    _selectedMarriedStatus = value;
    if (kDebugMode) {
      print(_selectedMarriedStatus);
    }
    notifyListeners();
  }

  final List<String> _nomineeRelationship = ["father", "mother"];
  List<String> get nomineeRelationship => _nomineeRelationship;

  String? _selectedNomineeRelationship;
  String? get selectedNomineeRelationship => _selectedNomineeRelationship;

  void setSelectedNomineeRelationship(String? value) {
    _selectedNomineeRelationship = value;
    if (kDebugMode) {
      print(_selectedNomineeRelationship);
    }
    notifyListeners();
  }

  final List<String> _designation = ["SoftWare Developer", "Accounts"];
  List<String> get designation => _designation;

  String? _selectedDesignation;
  String? get selectedDesignation => _selectedDesignation;

  void setSelectedDesignation(String? value) {
    _selectedDesignation = value;
    if (kDebugMode) {
      print(_selectedDesignation);
    }
    notifyListeners();
  }

  final List<String> _loginAccessFor = ["HRM", "HIS", "Referral"];
  List<String> get loginAccessFor => _loginAccessFor;



  String? _selectedLoginAccessFor;
  String? get selectedLoginAccessFor => _selectedLoginAccessFor;

  void setSelectedLoginAccessFor(String? value) {
    _selectedLoginAccessFor = value;
    if (kDebugMode) {
      print(_selectedLoginAccessFor);
    }
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

  @override
  void dispose() {
    employmentIDController.dispose();

    super.dispose();
  }

  final employmentIDController = TextEditingController();
  final fullNameController = TextEditingController();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final highestQualificationController = TextEditingController();
  final emailController = TextEditingController();
  final officialMobileController = TextEditingController();
  final addressController = TextEditingController();
  final permanentAddressController = TextEditingController();
  final dateController = TextEditingController();
  final dateOfJoiningController = TextEditingController();
  final nomineeNameController = TextEditingController();
  final officialEmailIdController = TextEditingController();
  final allowedLeaveController = TextEditingController();
}
