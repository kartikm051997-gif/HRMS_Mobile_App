import 'package:flutter/material.dart';

class EmployeeTabviewProvider extends ChangeNotifier {
  int _currentTabIndex = 0;
  final bool _isLoading = false;

  // Getters
  int get currentTabIndex => _currentTabIndex;
  bool get isLoading => _isLoading;

  // Tab navigation
  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}
