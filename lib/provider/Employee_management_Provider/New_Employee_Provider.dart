import 'package:flutter/Material.dart';
import 'package:flutter/foundation.dart';

class NewEmployeeProvider extends ChangeNotifier {
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
}
