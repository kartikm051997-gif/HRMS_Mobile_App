import 'package:flutter/material.dart';

class EmployeeAssetModel {
  String empId;
  String empName;
  String department;
  String designation;
  String photo;
  String assetType;
  String mobile;
  String sim;
  String laptop;
  String tablet;

  EmployeeAssetModel({
    required this.empId,
    required this.empName,
    required this.department,
    required this.designation,
    required this.photo,
    required this.assetType,
    required this.mobile,
    required this.sim,
    required this.laptop,
    required this.tablet,
  });
}

class EmployeeAssetProvider extends ChangeNotifier {
  List<EmployeeAssetModel> assetList = [
    EmployeeAssetModel(
      empId: '10101',
      empName: 'Sathya',
      department: 'Trichy',
      designation: 'Lab Technician',
      photo: 'assets/images/avatar.png',
      assetType: 'Mobile, SIM',
      mobile: 'REDMI',
      sim: '8925929428',
      laptop: '-',
      tablet: '-',
    ),
    EmployeeAssetModel(
      empId: '10215',
      empName: 'Nanthini P',
      department: 'Thiruvallur',
      designation: 'Admin',
      photo: 'assets/images/avatar.png',
      assetType: 'Mobile,SIM,Tablet',
      mobile: 'REDMI',
      sim: '6381502190',
      laptop: '-',
      tablet: 'Lenova m11 (HA21H23H)',
    ),
    // Add more dummy data as needed
  ];

  EmployeeAssetModel? selectedEmployee;
  
  // ✅ Search functionality
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  
  // ✅ Get filtered list based on search query
  List<EmployeeAssetModel> get filteredAssetList {
    if (_searchQuery.isEmpty) {
      return assetList;
    }
    
    final query = _searchQuery.toLowerCase().trim();
    return assetList.where((emp) {
      return emp.empId.toLowerCase().contains(query) ||
             emp.empName.toLowerCase().contains(query) ||
             emp.department.toLowerCase().contains(query) ||
             emp.designation.toLowerCase().contains(query);
    }).toList();
  }
  
  // ✅ Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  // ✅ Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void selectEmployee(EmployeeAssetModel emp) {
    selectedEmployee = emp;
    notifyListeners();
  }

  void clearSelected() {
    selectedEmployee = null;
    notifyListeners();
  }

  void updateAsset({
    required String assetType,
    required String mobile,
    required String sim,
    String? laptop,
    String? tablet,
  }) {
    if (selectedEmployee != null) {
      selectedEmployee!.assetType = assetType;
      selectedEmployee!.mobile = mobile;
      selectedEmployee!.sim = sim;
      selectedEmployee!.laptop = laptop ?? '-';
      selectedEmployee!.tablet = tablet ?? '-';
      notifyListeners();
    }
  }
}
