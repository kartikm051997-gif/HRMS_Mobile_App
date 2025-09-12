import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddDeliverableProvider extends ChangeNotifier {
  final List<String> _employeeName = [
    "Chennai - Sholinganallur",
    "Chennai - Madipakkam",
    "Chennai - Urapakkam",
    "Kanchipuram",
    "Hosur",
    "Tiruppur",
    "Erode",
  ];
  List<String> get employeeName => _employeeName;

  String? _selectedEmployeeName;
  String? get selectedEmployeeName => _selectedEmployeeName;

  void setSelectedEmployeeName(String? value) {
    _selectedEmployeeName = value;
    if (kDebugMode) {
      print(_selectedEmployeeName);
    }
    notifyListeners();
  }

  final List<String> _priority = ["High", "medium", "Low"];
  List<String> get priority => _priority;

  String? _selectedPriority;
  String? get selectedPriority => _selectedPriority;

  void setSelectedPriority(String? value) {
    _selectedPriority = value;
    if (kDebugMode) {
      print(_selectedPriority);
    }
    notifyListeners();
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

  final titleTaskController = TextEditingController();
  final endDateController = TextEditingController();
  final descriptionController = TextEditingController();
}
