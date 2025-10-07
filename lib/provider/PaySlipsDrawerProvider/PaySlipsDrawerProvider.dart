import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class PaySlipsDrawerProvider extends ChangeNotifier {
  String? _searchType;
  String? _selectedEmployee;
  String? _selectedLocation;
  DateTime? _selectedMonth;
  List<Employee> _employees = [];
  List<String> _locations = [];
  List<Payslip> _payslips = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _downloadingPayslipId = '';

  String? get searchType => _searchType;
  String? get selectedEmployee => _selectedEmployee;
  String? get selectedLocation => _selectedLocation;
  DateTime? get selectedMonth => _selectedMonth;
  List<Employee> get employees => _employees;
  List<String> get locations => _locations;
  List<Payslip> get payslips => _payslips;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get downloadingPayslipId => _downloadingPayslipId;

  bool isDownloadingPayslip(String payslipId) {
    return _downloadingPayslipId == payslipId;
  }

  void setDownloading(bool isDownloading, String payslipId) {
    _downloadingPayslipId = isDownloading ? payslipId : '';
    notifyListeners();
  }

  void setSearchType(String value) {
    _searchType = value;
    _selectedEmployee = null;
    _selectedLocation = null;
    _selectedMonth = null;
    _payslips = [];
    notifyListeners();
  }

  void setSelectedEmployee(String? value) {
    _selectedEmployee = value;
    notifyListeners();
  }

  void setSelectedLocation(String? value) {
    _selectedLocation = value;
    notifyListeners();
  }

  void setSelectedMonth(DateTime? value) {
    _selectedMonth = value;
    notifyListeners();
  }

  Future<void> loadEmployees() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _employees = [
        Employee(
          id: '10055',
          name: 'Ramya',
          designation: 'Zonal Head',
          branch: 'Management',
          zone: 'South',
        ),
        Employee(
          id: '10088',
          name: 'V.G.Lokesh',
          designation: 'Zonal Head',
          branch: 'Management',
          zone: 'North',
        ),
        Employee(
          id: '10162',
          name: 'S.Venkataraman',
          designation: 'Managing Director',
          branch: 'Management',
          zone: 'Corporate',
        ),
        Employee(
          id: '10178',
          name: 'A.M.Sreekanth',
          designation: 'Managing Director',
          branch: 'Management',
          zone: 'Corporate',
        ),
      ];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load employees';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLocations() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _locations = [
        'Aathur',
        'Assam',
        'Bangladesh',
        'Bengaluru - Dasarahalli',
        'Bengaluru - Electronic City',
        'Bengaluru - Hebbal',
        'Bengaluru - Konanakunte',
      ];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load locations';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPayslipsByEmployee(String employeeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _payslips = [
        Payslip(
          id: '1',
          monthYear: 'January 2025',
          empId: '10055',
          name: 'Ramya',
          designation: 'Cluster Head',
          workingDays: 31,
          lopDays: 0,
          grossSalary: 35000.00,
          totalDeductions: 0.00,
          netSalary: 35000.00,
          status: 0,
          pdfUrl:
              'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', // Add your actual URL
          fileName: 'Payslip_Ramya_January_2025.pdf',
        ),
        Payslip(
          id: '2',
          monthYear: 'December 2024',
          empId: '10055',
          name: 'Ramya',
          designation: 'Cluster Head',
          workingDays: 30,
          lopDays: 0,
          grossSalary: 35000.00,
          totalDeductions: 0.00,
          netSalary: 35000.00,
          status: 0,
          pdfUrl:
              'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', // Add your actual URL
          fileName: 'Payslip_Ramya_December_2024.pdf',
        ),
      ];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to search payslips';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPayslipsByLocationMonth(
    String location,
    DateTime month,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _payslips = [
        Payslip(
          id: '1',
          monthYear: 'January 2025',
          empId: '10055',
          name: 'Ramya',
          designation: 'Cluster Head',
          workingDays: 31,
          lopDays: 0,
          grossSalary: 35000.00,
          totalDeductions: 0.00,
          netSalary: 35000.00,
          status: 0,
          pdfUrl:
              'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', // Add your actual URL
          fileName: 'Payslip_Ramya_January_2025.pdf',
        ),
      ];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to search payslips';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Download payslip with proper file handling
  Future<bool> downloadPayslip(Payslip payslip) async {
    try {
      setDownloading(true, payslip.id);

      // Check and request storage permission
      if (await _requestStoragePermission()) {
        final dio = Dio();
        Directory? directory;

        // Get the appropriate directory based on platform
        if (Platform.isAndroid) {
          // For Android, use external storage Downloads folder
          directory = await getExternalStorageDirectory();
          if (directory != null) {
            // Create Downloads folder if it doesn't exist
            final downloadsDir = Directory('${directory.path}/Download');
            if (!await downloadsDir.exists()) {
              await downloadsDir.create(recursive: true);
            }
            directory = downloadsDir;
          }
        } else {
          // For iOS, use documents directory
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          debugPrint("Could not access storage directory");
          return false;
        }

        final filePath = '${directory.path}/${payslip.fileName}';

        if (kDebugMode) {
          print("Downloading payslip to: $filePath");
        }

        await dio.download(
          payslip.pdfUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              debugPrint(
                'Download progress: ${(progress * 100).toStringAsFixed(0)}%',
              );
            }
          },
        );

        // Verify file was downloaded
        final file = File(filePath);
        if (await file.exists()) {
          if (kDebugMode) {
            print("Payslip downloaded successfully: ${file.path}");
            print("File size: ${await file.length()} bytes");
          }

          // Try to open the downloaded file
          final result = await OpenFile.open(filePath);
          if (kDebugMode) {
            print("Open file result: ${result.message}");
          }

          return true;
        } else {
          debugPrint("File was not created at expected location");
          return false;
        }
      } else {
        debugPrint("Storage permission denied");
        return false;
      }
    } catch (e) {
      debugPrint("Error downloading payslip: $e");
      return false;
    } finally {
      setDownloading(false, '');
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need different permissions
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Try to request manage external storage permission first
      var result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        return true;
      }

      // Fallback to regular storage permission
      if (await Permission.storage.isGranted) {
        return true;
      }

      result = await Permission.storage.request();
      return result.isGranted;
    } else {
      // For iOS, no special permission needed for app documents directory
      return true;
    }
  }

  void clearPayslips() {
    _payslips = [];
    notifyListeners();
  }

  void refreshPayslips(String empId) {
    searchPayslipsByEmployee(empId);
  }
}

// Models
class Employee {
  final String id;
  final String name;
  final String designation;
  final String branch;
  final String zone;

  Employee({
    required this.id,
    required this.name,
    required this.designation,
    required this.branch,
    required this.zone,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      branch: json['branch'] ?? '',
      zone: json['zone'] ?? '',
    );
  }
}

class Payslip {
  final String id;
  final String monthYear;
  final String empId;
  final String name;
  final String designation;
  final int workingDays;
  final int lopDays;
  final double grossSalary;
  final double totalDeductions;
  final double netSalary;
  final int status;
  final String pdfUrl;
  final String fileName;

  Payslip({
    required this.id,
    required this.monthYear,
    required this.empId,
    required this.name,
    required this.designation,
    required this.workingDays,
    required this.lopDays,
    required this.grossSalary,
    required this.totalDeductions,
    required this.netSalary,
    required this.status,
    required this.pdfUrl,
    required this.fileName,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    return Payslip(
      id: json['id'] ?? '',
      monthYear: json['monthYear'] ?? '',
      empId: json['empId'] ?? '',
      name: json['name'] ?? '',
      designation: json['designation'] ?? '',
      workingDays: json['workingDays'] ?? 0,
      lopDays: json['lopDays'] ?? 0,
      grossSalary: (json['grossSalary'] ?? 0).toDouble(),
      totalDeductions: (json['totalDeductions'] ?? 0).toDouble(),
      netSalary: (json['netSalary'] ?? 0).toDouble(),
      status: json['status'] ?? 0,
      pdfUrl: json['pdfUrl'] ?? '',
      fileName: json['fileName'] ?? 'payslip.pdf',
    );
  }
}
