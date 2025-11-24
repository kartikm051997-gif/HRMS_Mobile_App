import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AttendanceLogProvider extends ChangeNotifier {
  // ZONES
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
      print("Selected Zones: $_selectedZones");
    }
    notifyListeners();
  }

  // BRANCHES
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
      print("Selected Branches: $_selectedBranches");
    }
    notifyListeners();
  }

  // TYPE
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
      print("Selected Type: $_selectedType");
    }
    notifyListeners();
  }

  // EMPLOYEE SALARY CATEGORY
  final List<String> _employeeSalaryCategory = [
    "Professional",
    "Employee",
    "Employee F11",
    "Student",
  ];

  List<String> get employeeSalaryCategory => _employeeSalaryCategory;

  String? _selectedEmployeeSalaryCategory;
  String? get selectedEmployeeSalaryCategory => _selectedEmployeeSalaryCategory;

  void setSelectedEmployeeSalaryCategory(String? value) {
    _selectedEmployeeSalaryCategory = value;
    if (kDebugMode) {
      print("Selected Employee Salary Category: $_selectedEmployeeSalaryCategory");
    }
    notifyListeners();
  }

  // MONTH / DAY
  final List<String> _selectMonDay = ["Month", "Day"];
  List<String> get monDay => _selectMonDay;

  String? _selectedMonDay;
  String? get selectedMonDay => _selectedMonDay;

  void setSelectedMonDay(String? value) {
    _selectedMonDay = value;
    dateController.clear();
    if (kDebugMode) {
      print("Selected Month/Day: $_selectedMonDay");
    }
    notifyListeners();
  }

  // DATE CONTROLLER
  final dateController = TextEditingController();

  // ATTENDANCE DATA & LOADING STATE
  List<Map<String, dynamic>> _attendanceData = [];
  List<Map<String, dynamic>> get attendanceData => _attendanceData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Fetch Attendance Data
  Future<void> fetchAttendanceData({
    required String zones,
    required String branches,
    required String type,
    required String salaryCategory,
    required String period,
    required String date,
    String? employeeSearch,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock data - Replace with actual API call
      List<Map<String, dynamic>> mockData = [
        {
          'empId': '12570',
          'name': 'Prasanth K',
          'branch': 'Corporate Office - Guindy',
          'designation': 'Software Developer',
          'inTime': '09:30',
          'outTime': '-',
          'hoursWorked': '-',
        },
        {
          'empId': '12736',
          'name': 'Sharan M',
          'branch': 'Corporate Office - Guindy',
          'designation': 'Software Developer',
          'inTime': '09:38',
          'outTime': '-',
          'hoursWorked': '-',
        },
        {
          'empId': '12745',
          'name': 'Abhishek K P',
          'branch': 'Corporate Office - Guindy',
          'designation': 'Software Developer',
          'inTime': '09:19',
          'outTime': '09:20',
          'hoursWorked': '00hrs:00m',
        },
        {
          'empId': '12753',
          'name': 'Karthick M',
          'branch': 'Corporate Office - Guindy',
          'designation': 'Software Developer',
          'inTime': '09:19',
          'outTime': '-',
          'hoursWorked': '-',
        },
        {
          'empId': '13018',
          'name': 'Madhan Paramasivam',
          'branch': 'Corporate Office - Guindy',
          'designation': 'Software Developer',
          'inTime': '09:35',
          'outTime': '-',
          'hoursWorked': '-',
        },
      ];

      // Filter by employee search if provided
      if (employeeSearch != null && employeeSearch.isNotEmpty) {
        final searchLower = employeeSearch.toLowerCase();
        _attendanceData = mockData.where((item) {
          final empId = (item['empId'] ?? '').toString().toLowerCase();
          final name = (item['name'] ?? '').toString().toLowerCase();
          return empId.contains(searchLower) ||
              name.contains(searchLower);
        }).toList();

        if (kDebugMode) {
          print("Filtered by employee: $employeeSearch");
          print("Found ${_attendanceData.length} records");
        }
      } else {
        _attendanceData = mockData;
      }

      if (kDebugMode) {
        print("API Call Parameters:");
        print("Zones: $zones");
        print("Branches: $branches");
        print("Type: $type");
        print("Salary Category: $salaryCategory");
        print("Period: $period");
        print("Date: $date");
        print("Employee Search: $employeeSearch");
        print("Total Records: ${_attendanceData.length}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching attendance data: $e");
      }
      _attendanceData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset all selections
  void resetSelections() {
    _selectedZones = null;
    _selectedBranches = null;
    _selectedType = null;
    _selectedEmployeeSalaryCategory = null;
    _selectedMonDay = null;
    dateController.clear();
    _attendanceData = [];
    _isLoading = false;
    notifyListeners();
  }

  // Cleanup
  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }
}