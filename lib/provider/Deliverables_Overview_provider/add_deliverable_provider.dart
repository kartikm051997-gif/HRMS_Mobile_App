import 'dart:io';

import 'package:flutter/material.dart';

class AddDeliverableProvider extends ChangeNotifier {
  final List<String> _employeename = [
    "Chennai - Sholinganallur",
    "Chennai - Madipakkam",
    "Chennai - Urapakkam",
    "Kanchipuram",
    "Hosur",
    "Tiruppur",
    "Erode",
  ];
  List<String> get employeeName => _employeename;

  String? _selectedemployeeName;
  String? get selectedemployeeName => _selectedemployeeName;

  void setSelectedemployeeName(String? value) {
    _selectedemployeeName = value;
    print(_selectedemployeeName);
    notifyListeners();
  }

  final List<String> _priority = ["High", "Meduim", "Low"];
  List<String> get priority => _priority;

  String? _selectedpriority;
  String? get selectedpriority => _selectedpriority;

  void setSelectedpriority(String? value) {
    _selectedpriority = value;
    print(_selectedpriority);
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
