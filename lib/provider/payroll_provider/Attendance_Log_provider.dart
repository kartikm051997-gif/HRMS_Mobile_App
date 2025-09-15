import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AttendanceLogProvider extends ChangeNotifier {
  final List<String> _zones = [
    "AP & Vellore",
    "CENTRAL TN",
    "CHENNAI",
    "International",
    "KARNATAKA",
    "KERALA",
    "Not Specified",
    "SOUTH TN",
    "WEST 1 TN",
    "West 2",
  ];

  List<String> get zones => _zones;

  String? _selectedZones;
  String? get selectedZones => _selectedZones;

  void setSelectedZones(String? value) {
    _selectedZones = value;
    if (kDebugMode) {
      print(_selectedZones);
    }
    notifyListeners();
  }

  final List<String> _branches = [
    "AP & Vellore",
    "CENTRAL TN",
    "CHENNAI",
    "International",
    "KARNATAKA",
    "KERALA",
    "Not Specified",
    "SOUTH TN",
    "WEST 1 TN",
    "West 2",
  ];

  List<String> get branches => _branches;

  String? _selectedBranches;
  String? get selectedBranches => _selectedBranches;

  void setSelectedBranches(String? value) {
    _selectedBranches = value;
    if (kDebugMode) {
      print(_selectedBranches);
    }
    notifyListeners();
  }

  final List<String> _type = [
    "Employee salary category",
    "designation",
    "monthly CTC range",
  ];
  List<String> get type => _type;

  String? _selectedType;
  String? get selectedType => _selectedType;

  void setSelectedType(String? value) {
    _selectedType = value;
    if (kDebugMode) {
      print(_selectedType);
    }
    notifyListeners();
  }

  final List<String> _selectMonDay = ["Month", "Day"];
  List<String> get monDay => _selectMonDay;

  String? _selectedMonDay;
  String? get selectedMonDay => _selectedMonDay;

  void setSelectedMonDay(String? value) {
    _selectedMonDay = value;
    if (kDebugMode) {
      print(_selectedMonDay);
    }
    notifyListeners();
  }

  void resetSelections() {
    _selectedZones = null;
    _selectedBranches = null;
    _selectedType = null;
    notifyListeners();
  }

  final dateController = TextEditingController();

}
