import 'package:flutter/foundation.dart';

class EmployeeManualPunchesProvider extends ChangeNotifier {
  // LOCATIONS
  final List<String> _location = [
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

  List<String> get location => _location;

  String? _selectedLocation;
  String? get selectedLocation => _selectedLocation;

  void setSelectedLocation(String? value) {
    _selectedLocation = value;
    if (kDebugMode) {
      print("Selected Location: $_selectedLocation");
    }
    notifyListeners();
  }

  // MONTHS
  final List<String> _months = [
    "January 2025",
    "February 2025",
    "March 2025",
    "April 2025",
    "May 2025",
    "June 2025",
    "July 2025",
    "August 2025",
    "September 2025",
    "October 2025",
    "November 2025",
    "December 2025",
  ];

  List<String> get months => _months;

  String? _selectedMonth;
  String? get selectedMonth => _selectedMonth;

  void setSelectedMonth(String? value) {
    _selectedMonth = value;
    if (kDebugMode) {
      print("Selected Month: $_selectedMonth");
    }
    notifyListeners();
  }

  // LOADING STATE
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // MANUAL PUNCHES DATA
  List<Map<String, dynamic>> _manualPunches = [];
  List<Map<String, dynamic>> get manualPunches => _manualPunches;

  // Fetch Manual Punches Data with Full Month Calendar
  Future<void> fetchManualPunches({
    required String location,
    required String month,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data with FULL MONTH (30/31 days) calendar view
      // Data structure: Each employee has attendance for ALL days of the month
      _manualPunches = [
        {
          'empId': '11691',
          'name': 'DIVYAA AMALANATHAN',
          'designation': 'Sr.HR Executive',
          'workingDays': '23',
          'allowedLeave': '4',
          'attendance': {
            '1': {'status': 'P', 'punchCount': 3, 'times': ['09:15', '13:00', '18:30']},
            '2': {'status': 'P', 'punchCount': 3, 'times': ['09:10', '13:05', '18:25']},
            '3': {'status': 'P', 'punchCount': 3, 'times': ['09:20', '13:10', '18:35']},
            '4': {'status': 'L', 'punchCount': 0, 'times': []},
            '5': {'status': 'H', 'punchCount': 0, 'times': []},
            '6': {'status': 'P', 'punchCount': 3, 'times': ['09:05', '13:00', '18:20']},
            '7': {'status': 'P', 'punchCount': 3, 'times': ['09:18', '13:15', '18:40']},
            '8': {'status': 'P', 'punchCount': 3, 'times': ['09:12', '13:08', '18:28']},
            '9': {'status': 'P', 'punchCount': 3, 'times': ['09:25', '13:20', '18:45']},
            '10': {'status': 'P', 'punchCount': 3, 'times': ['09:08', '13:02', '18:22']},
            '11': {'status': 'A', 'punchCount': 0, 'times': []},
            '12': {'status': 'H', 'punchCount': 0, 'times': []},
            '13': {'status': 'P', 'punchCount': 3, 'times': ['09:30', '13:25', '18:50']},
            '14': {'status': 'P', 'punchCount': 3, 'times': ['09:14', '13:12', '18:32']},
            '15': {'status': 'P', 'punchCount': 3, 'times': ['09:22', '13:18', '18:38']},
            '16': {'status': 'P', 'punchCount': 3, 'times': ['10:04', '13:30', '19:22']},
            '17': {'status': 'P', 'punchCount': 3, 'times': ['10:33', '13:45', '19:31']},
            '18': {'status': 'P', 'punchCount': 3, 'times': ['11:02', '14:00', '19:23']},
            '19': {'status': 'H', 'punchCount': 0, 'times': []},
            '20': {'status': 'P', 'punchCount': 3, 'times': ['09:16', '13:14', '18:34']},
            '21': {'status': 'P', 'punchCount': 3, 'times': ['09:28', '13:22', '18:42']},
            '22': {'status': 'L', 'punchCount': 0, 'times': []},
            '23': {'status': 'P', 'punchCount': 3, 'times': ['09:11', '13:06', '18:26']},
            '24': {'status': 'P', 'punchCount': 3, 'times': ['09:19', '13:16', '18:36']},
            '25': {'status': 'P', 'punchCount': 3, 'times': ['09:24', '13:19', '18:44']},
            '26': {'status': 'H', 'punchCount': 0, 'times': []},
            '27': {'status': 'P', 'punchCount': 3, 'times': ['09:13', '13:09', '18:29']},
            '28': {'status': 'P', 'punchCount': 3, 'times': ['09:21', '13:17', '18:37']},
            '29': {'status': 'A', 'punchCount': 0, 'times': []},
            '30': {'status': 'P', 'punchCount': 3, 'times': ['09:17', '13:13', '18:33']},
            '31': {'status': 'P', 'punchCount': 3, 'times': ['09:26', '13:21', '18:46']},
          },
        },
        {
          'empId': '11771',
          'name': 'Vignesh Raja',
          'designation': 'Software Developer',
          'workingDays': '24',
          'allowedLeave': '4',
          'attendance': {
            '1': {'status': 'P', 'punchCount': 3, 'times': ['09:10', '13:05', '18:25']},
            '2': {'status': 'P', 'punchCount': 3, 'times': ['09:18', '13:12', '18:32']},
            '3': {'status': 'P', 'punchCount': 3, 'times': ['09:22', '13:18', '18:38']},
            '4': {'status': 'P', 'punchCount': 3, 'times': ['09:15', '13:10', '18:30']},
            '5': {'status': 'H', 'punchCount': 0, 'times': []},
            '6': {'status': 'P', 'punchCount': 3, 'times': ['09:20', '13:15', '18:35']},
            '7': {'status': 'P', 'punchCount': 3, 'times': ['09:25', '13:20', '18:40']},
            '8': {'status': 'L', 'punchCount': 0, 'times': []},
            '9': {'status': 'P', 'punchCount': 3, 'times': ['09:12', '13:08', '18:28']},
            '10': {'status': 'P', 'punchCount': 3, 'times': ['09:30', '13:25', '18:45']},
            '11': {'status': 'P', 'punchCount': 3, 'times': ['09:17', '13:13', '18:33']},
            '12': {'status': 'H', 'punchCount': 0, 'times': []},
            '13': {'status': 'P', 'punchCount': 3, 'times': ['09:14', '13:09', '18:29']},
            '14': {'status': 'P', 'punchCount': 3, 'times': ['09:28', '13:22', '18:42']},
            '15': {'status': 'A', 'punchCount': 0, 'times': []},
            '16': {'status': 'P', 'punchCount': 3, 'times': ['09:18', '13:14', '18:32']},
            '17': {'status': 'P', 'punchCount': 3, 'times': ['10:48', '14:15', '18:52']},
            '18': {'status': 'P', 'punchCount': 3, 'times': ['10:00', '13:45', '18:59']},
            '19': {'status': 'H', 'punchCount': 0, 'times': []},
            '20': {'status': 'P', 'punchCount': 3, 'times': ['09:16', '13:11', '18:31']},
            '21': {'status': 'L', 'punchCount': 0, 'times': []},
            '22': {'status': 'P', 'punchCount': 3, 'times': ['09:24', '13:19', '18:39']},
            '23': {'status': 'P', 'punchCount': 3, 'times': ['09:19', '13:14', '18:34']},
            '24': {'status': 'P', 'punchCount': 3, 'times': ['09:26', '13:21', '18:41']},
            '25': {'status': 'P', 'punchCount': 3, 'times': ['09:21', '13:16', '18:36']},
            '26': {'status': 'H', 'punchCount': 0, 'times': []},
            '27': {'status': 'P', 'punchCount': 3, 'times': ['09:13', '13:08', '18:28']},
            '28': {'status': 'A', 'punchCount': 0, 'times': []},
            '29': {'status': 'P', 'punchCount': 3, 'times': ['09:23', '13:18', '18:38']},
            '30': {'status': 'P', 'punchCount': 3, 'times': ['09:27', '13:22', '18:42']},
            '31': {'status': 'L', 'punchCount': 0, 'times': []},
          },
        },
        {
          'empId': '11850',
          'name': 'Raj Kumar',
          'designation': 'UI/UX Designer',
          'workingDays': '22',
          'allowedLeave': '3',
          'attendance': {
            '1': {'status': 'P', 'punchCount': 3, 'times': ['09:20', '13:10', '18:35']},
            '2': {'status': 'P', 'punchCount': 3, 'times': ['09:15', '13:08', '18:30']},
            '3': {'status': 'L', 'punchCount': 0, 'times': []},
            '4': {'status': 'P', 'punchCount': 3, 'times': ['09:25', '13:15', '18:40']},
            '5': {'status': 'H', 'punchCount': 0, 'times': []},
            '6': {'status': 'P', 'punchCount': 3, 'times': ['09:18', '13:12', '18:33']},
            '7': {'status': 'P', 'punchCount': 3, 'times': ['09:22', '13:18', '18:38']},
            '8': {'status': 'P', 'punchCount': 3, 'times': ['09:28', '13:22', '18:42']},
            '9': {'status': 'A', 'punchCount': 0, 'times': []},
            '10': {'status': 'P', 'punchCount': 3, 'times': ['09:16', '13:11', '18:31']},
            '11': {'status': 'P', 'punchCount': 3, 'times': ['09:24', '13:19', '18:39']},
            '12': {'status': 'H', 'punchCount': 0, 'times': []},
            '13': {'status': 'P', 'punchCount': 3, 'times': ['09:19', '13:14', '18:34']},
            '14': {'status': 'P', 'punchCount': 3, 'times': ['09:26', '13:21', '18:41']},
            '15': {'status': 'P', 'punchCount': 3, 'times': ['09:21', '13:16', '18:36']},
            '16': {'status': 'P', 'punchCount': 3, 'times': ['09:30', '13:25', '18:45']},
            '17': {'status': 'P', 'punchCount': 3, 'times': ['10:15', '13:50', '19:00']},
            '18': {'status': 'P', 'punchCount': 3, 'times': ['09:45', '13:35', '18:30']},
            '19': {'status': 'H', 'punchCount': 0, 'times': []},
            '20': {'status': 'L', 'punchCount': 0, 'times': []},
            '21': {'status': 'P', 'punchCount': 3, 'times': ['09:23', '13:18', '18:38']},
            '22': {'status': 'P', 'punchCount': 3, 'times': ['09:27', '13:22', '18:42']},
            '23': {'status': 'A', 'punchCount': 0, 'times': []},
            '24': {'status': 'P', 'punchCount': 3, 'times': ['09:14', '13:09', '18:29']},
            '25': {'status': 'P', 'punchCount': 3, 'times': ['09:29', '13:24', '18:44']},
            '26': {'status': 'H', 'punchCount': 0, 'times': []},
            '27': {'status': 'P', 'punchCount': 3, 'times': ['09:17', '13:13', '18:33']},
            '28': {'status': 'P', 'punchCount': 3, 'times': ['09:25', '13:20', '18:40']},
            '29': {'status': 'P', 'punchCount': 3, 'times': ['09:20', '13:15', '18:35']},
            '30': {'status': 'A', 'punchCount': 0, 'times': []},
            '31': {'status': 'P', 'punchCount': 3, 'times': ['09:31', '13:26', '18:46']},
          },
        },
      ];

      if (kDebugMode) {
        print("API Call Parameters:");
        print("Location: $location");
        print("Month: $month");
        print("Total Employees: ${_manualPunches.length}");
        print("Data structure: Full month calendar with attendance status");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching manual punches: $e");
      }
      _manualPunches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset all selections
  void resetSelections() {
    _selectedLocation = null;
    _selectedMonth = null;
    _manualPunches = [];
    _isLoading = false;
    notifyListeners();
  }
}