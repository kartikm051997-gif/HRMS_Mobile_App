import 'package:flutter/material.dart';

class DeliverablesOverviewProvider extends ChangeNotifier {

  bool get showFilters => _showFilters;
  int pageSize = 10;
  int currentPage = 0;
  bool isLoading = false;


  final List<Map<String, dynamic>> _employees = [
    {
      "photo": "https://randomuser.me/api/portraits/men/32.jpg",
      "name": "Vignesh Raja",
      "designation": "Software Developer",
      "branch": "Corporate Office - Guindy",  // ✅ Added branch
      "location": "Corporate Office - Guindy",
      "tasks": 4,
    },
    {
      "photo": "https://randomuser.me/api/portraits/men/32.jpg",
      "name": "V.G. Lokesh",
      "designation": "Zonal Head",
      "branch": "Salem",  // ✅ Added branch
      "location": "Salem",
      "tasks": 1,
    },
    {
      "photo": "https://randomuser.me/api/portraits/men/41.jpg",
      "name": "Gokulnath",
      "designation": "Managing Director",
      "branch": "Chennai - Sholinganallur",  // ✅ Added branch
      "location": "Chennai - Sholinganallur",
      "tasks": 1,
    },{
      "photo": "https://randomuser.me/api/portraits/men/41.jpg",
      "name": "Gokulnath",
      "designation": "Managing Director",
      "branch": "Chennai - Sholinganallur",  // ✅ Added branch
      "location": "Chennai - Sholinganallur",
      "tasks": 1,
    },{
      "photo": "https://randomuser.me/api/portraits/men/41.jpg",
      "name": "Gokulnath",
      "designation": "Managing Director",
      "branch": "Chennai - Sholinganallur",  // ✅ Added branch
      "location": "Chennai - Sholinganallur",
      "tasks": 1,
    },{
      "photo": "https://randomuser.me/api/portraits/men/41.jpg",
      "name": "Gokulnath",
      "designation": "Managing Director",
      "branch": "Chennai - Sholinganallur",  // ✅ Added branch
      "location": "Chennai - Sholinganallur",
      "tasks": 1,
    },
  ];


  List<Map<String, dynamic>> get employees => _employees;

  void addEmployee(Map<String, dynamic> employee) {
    _employees.add(employee);
    notifyListeners();
  }

  void removeEmployee(int index) {
    _employees.removeAt(index);
    notifyListeners();
  }

  final List<String> _status = [
    "New Lead",
    "Interested",
    "Walk-in/Video Scheduled",
    "Walk-in/Video Done",
    "Treatment Started",
    "Treatment Done",
    "Not Interested",
    "Junk",
    "Not Picked up",
    "Call Later",
    "Walk-in Dropped",
    "Treatment Dropped",
  ];
  List<String> get status => _status;

  String? _selectedstatus;
  String? get selectedstatus => _selectedstatus;

  void setSelectedstatus(String? value) {
    _selectedstatus = value;
    print(_selectedstatus);

    notifyListeners();
  }

  final List<String> _primarylocation = [
    "Aathur",
    "Bengaluru - Electronic City",
    "Bengaluru - Hebbal",
    "Bengaluru - T Dasarahalli",
    "Bengaluru - Konanakunte",
    "Chengalpattu",
    "Chennai - Madipakkam",
    "Chennai - Sholinganallur",
    "Chennai - Tambaram",
    "Chennai - Thiruvallur",
    "Chennai - Urapakkam",
    "Chennai - Vadapalani",
    "Coimbatore - Ganapathy",
  ];
  List<String> get primarylocation => _primarylocation;

  String? _selectedprimarylocation;
  String? get selectedprimarylocation => _selectedprimarylocation;

  void setSelectedsprimarylocation(String? value) {
    _selectedprimarylocation = value;
    print(_selectedprimarylocation);

    notifyListeners();
  }

  final List<String> _datetype  = [
    "Joining date",
    "Interview date",
  ];
  List<String> get dateType => _datetype;

  String? _selecteddateType;
  String? get selecteddateType => _selecteddateType;

  void setSelectedsdateType(String? value) {
    _selecteddateType = value;
    print(_selecteddateType);

    notifyListeners();
  }


  bool _showFilters = false;
  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  void setPageSize(int newSize) {
    pageSize = newSize;
    currentPage = 0; // reset when changed
    notifyListeners();
  }


  final deliverableDateController = TextEditingController();
  final serachFieldDateController = TextEditingController();

}
