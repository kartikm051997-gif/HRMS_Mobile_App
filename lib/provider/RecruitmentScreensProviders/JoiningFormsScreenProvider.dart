import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../model/RecruitmentModel/Job_Application_Model.dart';

class JoiningFormsScreenProvider extends ChangeNotifier {
  // job application tabview function

  int _currentTabIndex = 0;
  late bool _isLoading = false;

  // Getters
  int get currentTabIndex => _currentTabIndex;
  bool get isLoading => _isLoading;

  // Tab navigation
  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  bool _showFilters = false;
  bool get showFilters => _showFilters;
  int pageSize = 10;
  int currentPage = 0;
  final Dio _dio = Dio();

  // PDF download state variables
  bool _isDownloading = false;
  String _downloadingJobId = '';

  bool get isDownloading => _isDownloading;
  String get downloadingJobId => _downloadingJobId;

  void toggleFilters() {
    _showFilters = !_showFilters;
    notifyListeners();
  }

  void setPageSize(int newSize) {
    pageSize = newSize;
    currentPage = 0; // reset when changed
    notifyListeners();
  }

  void setDownloading(bool downloading, String jobId) {
    _isDownloading = downloading;
    _downloadingJobId = jobId;
    notifyListeners();
  }

  void clearAllFilters() {
    searchController.clear();
    // Refresh the employee list
    searchEmployees();
    notifyListeners();
  }

  /// Dropdown data
  final List<String> _primaryLocation = ["Aathur", "Aasam"];
  final List<String> _jobTitle = [
    "Softawre Developer",
    "Accountant",
    "Hr",
    "Tele Calling",
  ];
  final List<String> _jobStatus = ["Unread", "Call for Interview", "Selected"];
  final List<String> _assignedStaff = [
    "Durga Prakash - 10876",
    "Karthick - 7866",
    "Abi - 8764",
    "Viki - 8754",
  ];
  final List<String> _dateType = ["Joining", "interview date"];

  List<String> get primaryBranch => _primaryLocation;
  List<String> get jobTitle => _jobTitle;
  List<String> get jobStatus => _jobStatus;
  List<String> get assignedStaff => _assignedStaff;
  List<String> get dateType => _dateType;

  /// Selected values
  String? _selectedPrimaryBranch;
  String? _selectedJobTitle;
  String? _selectedJobStatus;
  String? _selectedAssignedStaff;
  String? _selectedDateType;

  String? get selectedPrimaryBranch => _selectedPrimaryBranch;
  String? get selectedJobTitle => _selectedJobTitle;
  String? get selectedJobStatus => _selectedJobStatus;
  String? get selectedAssignedStaff => _selectedAssignedStaff;
  String? get selectedDateType => _selectedDateType;

  /// Clear all filters
  void clearFilters() {
    _selectedPrimaryBranch = null;
    _selectedJobTitle = null;
    _selectedJobStatus = null;
    _selectedAssignedStaff = null;
    _selectedDateType = null;

    _filteredEmployees = List.from(_allJobApplication);
    notifyListeners();
  }

  /// Setters
  void setSelectedPrimaryBranch(String? v) {
    _selectedPrimaryBranch = v;
    notifyListeners();
  }

  void setSelectedJobTitle(String? v) {
    _selectedJobTitle = v;
    notifyListeners();
  }

  void setSelectedJobStatus(String? v) {
    _selectedJobStatus = v;
    notifyListeners();
  }

  void setSelectedAssignedStaff(String? v) {
    _selectedAssignedStaff = v;
    notifyListeners();
  }

  void setSelectedDateType(String? v) {
    _selectedDateType = v;
    notifyListeners();
  }

  /// Employee data
  List<JobApplicationModel> _allJobApplication = [];
  List<JobApplicationModel> _filteredEmployees = [];

  List<JobApplicationModel> get filteredEmployees => _filteredEmployees;

  TextEditingController searchController = TextEditingController();

  void onSearchChanged(String query) {
    // Implement your search logic here
    // Filter employees based on the search query
  }

  void clearSearch() {
    searchController.clear();
    // Reset the employee list to show all employees
  }

  /// Initialize with sample data (replace with API call)
  void initializeEmployees() {
    _allJobApplication = [
      JobApplicationModel(
        jobId: "RA232",
        name: "RAJKUMAR MOHAMMEDAN",
        phone: "95******41",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        uploadedBy: "https://example.com/recruiter2.jpg",
        createdDate: "16/09/2025",
        photoUrl: "https://example.com/photo1.jpg",
        interviewDate: "12/08/2025",
        joiningDate: "12/08/2025",
      ),
      JobApplicationModel(
        jobId: "RA231",
        name: "Sanjay E",
        phone: "70******96",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        uploadedBy: "https://example.com/recruiter2.jpg",
        createdDate: "16/09/2025",
        photoUrl: "https://example.com/photo1.jpg",
        interviewDate: "12/08/2025",
        joiningDate: "12/08/2025",
      ),
      JobApplicationModel(
        jobId: "RA230",
        name: "	Divya",
        phone: "91******47",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        uploadedBy: "https://example.com/recruiter2.jpg",
        createdDate: "16/09/2025",
        photoUrl: "https://example.com/photo1.jpg",
        interviewDate: "12/08/2025",
        joiningDate: "12/08/2025",
      ),
      JobApplicationModel(
        jobId: "RA229",
        name: "sadesh kumar",
        phone: "9*******30",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        uploadedBy: "https://example.com/recruiter2.jpg",
        createdDate: "16/09/2025",
        photoUrl: "https://example.com/photo1.jpg",
        interviewDate: "12/08/2025",
        joiningDate: "12/08/2025",
      ),
      JobApplicationModel(
        jobId: "RA228",
        name: "Sriram Kunjithapadam",
        phone: "80******29",
        jobTitle: "Lab Technician",
        primaryLocation: "Bengaluru - Hebbal",
        uploadedBy: "https://example.com/recruiter2.jpg",
        createdDate: "16/09/2025",
        photoUrl: "https://example.com/photo1.jpg",
        interviewDate: "12/08/2025",
        joiningDate: "12/08/2025",
      ),
    ];
    _filteredEmployees = List.from(_allJobApplication);
    notifyListeners();
  }

  /// PDF Download functionality for Job Applications
  Future<bool> downloadJobApplicationPDF(
    JobApplicationModel jobApplication,
  ) async {
    try {
      setDownloading(true, jobApplication.jobId);

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

        // Create filename based on job application data
        final fileName =
            'job_application_${jobApplication.jobId}_${jobApplication.name.replaceAll(' ', '_')}.pdf';
        final filePath = '${directory.path}/$fileName';

        // Use dummy PDF URL (same as in letter provider)
        const pdfUrl =
            "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf";

        if (kDebugMode) {
          print("Downloading job application PDF to: $filePath");
        }

        await dio.download(
          pdfUrl,
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
            print("Job application PDF downloaded successfully: ${file.path}");
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
      debugPrint("Error downloading job application PDF: $e");
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

  /// Search functionality
  void searchEmployees() {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _filteredEmployees =
          _allJobApplication.where((employee) {
            bool matches = true;

            // Filter by company (if selected)
            if (_selectedPrimaryBranch != null &&
                _selectedPrimaryBranch!.isNotEmpty) {
              // Add company filtering logic when you have company data in Employee model
            }

            // Filter by zone (if selected)
            if (_selectedJobTitle != null && _selectedJobTitle!.isNotEmpty) {
              // Add zone filtering logic when you have zone data in Employee model
            }
            if (_selectedAssignedStaff != null &&
                _selectedAssignedStaff!.isNotEmpty) {
              // Add zone filtering logic when you have zone data in Employee model
            }
            if (_selectedDateType != null && _selectedDateType!.isNotEmpty) {
              // Add zone filtering logic when you have zone data in Employee model
            }
            if (_selectedJobStatus != null && selectedJobStatus!.isNotEmpty) {
              // Add zone filtering logic when you have zone data in Employee model
            }

            return matches;
          }).toList();

      _isLoading = false;
      notifyListeners();
    });
  }
}
