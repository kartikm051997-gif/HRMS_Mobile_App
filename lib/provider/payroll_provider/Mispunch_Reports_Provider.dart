import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MisPunchReportsProvider extends ChangeNotifier {
  List<MisPunchModel> _allReports = [];
  List<MisPunchModel> _filteredReports = [];
  bool _isLoading = false;
  bool _isDownloading = false;
  String _downloadingReportId = '';
  String _searchQuery = '';
  String? _selectedLocation;

  bool _hasSearched = false;

  bool get hasSearched => _hasSearched;

  void setHasSearched(bool value) {
    _hasSearched = value;
    notifyListeners();
  }
  // Changed: Remove default value, make it nullable

  final List<String> _locations = [
    'Corporate Office - Guindy',
    'Trichy',
    'Tanjore',
    'Pollachi',
    'Bengaluru - Electronic City',
    'Chennai - Tambaram',
    'Madurai',
    'Bengaluru - Konanakutte',
    'Harur',
    'Karur',
    'Tirupati',
    'Sathyamangalam',
    'Coimbatore - Thudiyalur',
    'Kallakurichi',
    'Bengaluru - Hebbal',
    'Vellore',
    'Assam',
    'Chennai - Vadapalani',
    'Villupuram',
    'Bengaluru - Dasarahalli',
  ];

  List<MisPunchModel> get filteredReports => _filteredReports;
  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;
  String get downloadingReportId => _downloadingReportId;
  String get searchQuery => _searchQuery;
  String? get selectedLocation => _selectedLocation; // Made getter nullable
  List<String> get locations => _locations;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setDownloading(bool downloading, String reportId) {
    _isDownloading = downloading;
    _downloadingReportId = reportId;
    notifyListeners();
  }

  void setSelectedLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
    // Re-apply filters when location changes
    _applyFilters();
  }

  Future<void> fetchReports(int dayFilter) async {
    setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Dummy data - replace with real API
      final response = _getDummyData(dayFilter);
      _allReports =
          response.map((report) => MisPunchModel.fromJson(report)).toList();
      _applyFilters();

      if (kDebugMode) {
        print(
          "Fetched ${_allReports.length} mispunch reports for $dayFilter days at $_selectedLocation",
        );
      }
    } catch (e) {
      debugPrint("Error fetching mispunch reports: $e");
      _allReports = [];
      _filteredReports = [];
    } finally {
      setLoading(false);
    }
  }

  List<Map<String, dynamic>> _getDummyData(int dayFilter) {
    // Generate different data based on selected location
    final baseData = <Map<String, dynamic>>[];

    // Add location-specific employees
    if (_selectedLocation == 'Corporate Office - Guindy') {
      baseData.addAll([
        {
          "id": "1",
          "empId": "11530",
          "name": "M.Sneha",
          "designation": "HR Trainee",
          "date": "16-09",
          "inTime": "09:27",
          "outTime": "-",
          "status": "mispunch",
          "location": "Corporate Office - Guindy",
        },
        {
          "id": "2",
          "empId": "11691",
          "name": "DIVYAA AMALANATHAN",
          "designation": "Sr.HR Executive",
          "date": "16-09",
          "inTime": "10:34",
          "outTime": "-",
          "status": "mispunch",
          "location": "Corporate Office - Guindy",
        },
      ]);
    } else if (_selectedLocation == 'Tanjore') {
      baseData.addAll([
        {
          "id": "3",
          "empId": "11771",
          "name": "Vignesh Raja",
          "designation": "Software Developer",
          "date": "16-09",
          "inTime": "10:07",
          "outTime": "-",
          "status": "mispunch",
          "location": "Tanjore",
        },
        {
          "id": "4",
          "empId": "11936",
          "name": "Deepika Vasudevan",
          "designation": "Jr. HR Executive",
          "date": "16-09",
          "inTime": "09:55",
          "outTime": "-",
          "status": "mispunch",
          "location": "Tanjore",
        },
      ]);
    } else {
      // For other locations, show sample data
      baseData.addAll([
        {
          "id": "5",
          "empId": "12001",
          "name": "Sample Employee 1",
          "designation": "Manager",
          "date": "16-09",
          "inTime": "09:30",
          "outTime": "-",
          "status": "mispunch",
          "location": _selectedLocation,
        },
        {
          "id": "6",
          "empId": "12002",
          "name": "Sample Employee 2",
          "designation": "Executive",
          "date": "16-09",
          "inTime": "-",
          "outTime": "-",
          "status": "absent",
          "location": _selectedLocation,
        },
      ]);
    }

    // Add more data for different day filters
    if (dayFilter >= 2) {
      baseData.addAll([
        {
          "id": "${baseData.length + 1}",
          "empId": "11944",
          "name": "Akash Kasiraja",
          "designation": "Driver",
          "date": "15-09",
          "inTime": "-",
          "outTime": "-",
          "status": "absent",
          "location": _selectedLocation,
        },
      ]);
    }

    if (dayFilter >= 3) {
      baseData.addAll([
        {
          "id": "${baseData.length + 1}",
          "empId": "12537",
          "name": "Sagayamary Ramakrishnan",
          "designation": "Patient Auditing",
          "date": "14-09",
          "inTime": "-",
          "outTime": "-",
          "status": "absent",
          "location": _selectedLocation,
        },
      ]);
    }

    return baseData;
  }

  void searchReports(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<MisPunchModel> filtered = List.from(_allReports);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((report) {
            return report.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                report.empId.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                report.designation.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }

    _filteredReports = filtered;
  }

  Future<bool> generateOverallPDF() async {
    try {
      setDownloading(true, 'overall');

      if (await _requestStoragePermission()) {
        final dio = Dio();
        Directory? directory;

        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            final downloadsDir = Directory('${directory.path}/Download');
            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }
            directory = downloadsDir;
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          debugPrint("Could not access storage directory");
          return false;
        }

        // Generate filename with location and date info
        final locationName = _selectedLocation
            ?.replaceAll(' ', '_')
            .replaceAll('-', '_');
        final fileName =
            "mispunch_overall_report_${locationName}_${DateTime.now().millisecondsSinceEpoch}.pdf";
        final filePath = '${directory.path}/$fileName';

        if (kDebugMode) {
          print("Generating overall PDF to: $filePath");
        }

        // Dummy PDF URL (replace with API in real case)
        const overallPdfUrl =
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";

        await dio.download(
          overallPdfUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              debugPrint(
                'Overall PDF generation progress: ${(progress * 100).toStringAsFixed(0)}%',
              );
            }
          },
        );

        // Verify file
        final file = File(filePath);
        if (await file.exists()) {
          if (kDebugMode) {
            print("Overall PDF generated successfully: ${file.path}");
            print("File size: ${await file.length()} bytes");
          }

          // ✅ Open with OpenFile (same as your reference code)
          final result = await OpenFile.open(filePath);
          if (kDebugMode) {
            print("Open file result: ${result.message}");
          }

          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error generating overall PDF: $e");
      return false;
    } finally {
      setDownloading(false, '');
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), try MANAGE_EXTERNAL_STORAGE first
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      var result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        return true;
      }

      // Fallback: legacy storage permission
      if (await Permission.storage.isGranted) {
        return true;
      }

      result = await Permission.storage.request();
      return result.isGranted;
    } else {
      // iOS does not need special storage permission
      return true;
    }
  }
}

class MisPunchModel {
  final String id;
  final String empId;
  final String name;
  final String designation;
  final String date;
  final String inTime;
  final String outTime;
  final String status;
  final String location;
  final String pdfUrl;

  MisPunchModel({
    required this.id,
    required this.empId,
    required this.name,
    required this.designation,
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.status,
    required this.location,
    required this.pdfUrl,
  });

  factory MisPunchModel.fromJson(Map<String, dynamic> json) {
    return MisPunchModel(
      id: json['id'] ?? '',
      empId: json['empId'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      date: json['date'] ?? '',
      inTime: json['inTime'] ?? '',
      outTime: json['outTime'] ?? '',
      status: json['status'] ?? '',
      location: json['location'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',
    );
  }
}
