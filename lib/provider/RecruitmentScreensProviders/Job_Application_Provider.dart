import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../model/RecruitmentModel/Job_Application_Model.dart';

class JobApplicationProvider extends ChangeNotifier {
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

  /// Flag to control whether to show employee cards
  /// Cards should only show after filters are applied
  bool _hasAppliedFilters = false;
  bool get hasAppliedFilters => _hasAppliedFilters;

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
    _selectedPrimaryBranch = null;
    _selectedJobTitle = null;
    _selectedJobStatus = null;
    _selectedAssignedStaff = null;
    _selectedDateType = null;
    _filteredEmployees = [];
    _hasAppliedFilters = false;
    notifyListeners();
  }

  /// Dropdown data
  final List<String> _primaryLocation = [
    "Aathur",
    "Aasam",
    "Nagapattinam",
    "Bengaluru - Hebbal",
  ];
  final List<String> _jobTitle = [
    "Softawre Developer",
    "Accountant",
    "Hr",
    "Tele Calling",
    "Lab Technician",
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

  /// Check if all required filters are selected (Status, Primary Location, Job Title)
  bool get areAllFiltersSelected {
    return _selectedJobStatus != null &&
        _selectedPrimaryBranch != null &&
        _selectedJobTitle != null;
  }

  /// Clear all filters
  void clearFilters() {
    _selectedPrimaryBranch = null;
    _selectedJobTitle = null;
    _selectedJobStatus = null;
    _selectedAssignedStaff = null;
    _selectedDateType = null;
    searchController.clear();
    _filteredEmployees = [];
    _hasAppliedFilters = false;
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
    if (!_hasAppliedFilters) return;
    
    if (query.isEmpty) {
      // Reset to all employees when search is cleared
      _filteredEmployees = List.from(_allJobApplication);
    } else {
      // Filter from all employees, not just filtered list
      final searchQuery = query.toLowerCase();
      _filteredEmployees = _allJobApplication.where((employee) {
        return employee.name.toLowerCase().contains(searchQuery) ||
            employee.jobId.toLowerCase().contains(searchQuery) ||
            employee.jobTitle.toLowerCase().contains(searchQuery) ||
            employee.primaryLocation.toLowerCase().contains(searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    if (_hasAppliedFilters) {
      searchEmployees();
    }
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
    // First time only - set filtered to empty
    _filteredEmployees = [];
    _hasAppliedFilters = false;
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

  /// Search functionality - only works after all filters are applied
  void searchEmployees() {
    if (!areAllFiltersSelected) {
      // Don't search if not all filters are selected
      return;
    }

    _isLoading = true;
    _hasAppliedFilters = true;
    notifyListeners();

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      // Show all employees when filters are applied
      // In a real app, this would be an API call with filter parameters
      _filteredEmployees = List.from(_allJobApplication);

      // Apply search text filter if present
      if (searchController.text.isNotEmpty) {
        final query = searchController.text.toLowerCase();
        _filteredEmployees = _filteredEmployees.where((employee) {
          return employee.name.toLowerCase().contains(query) ||
              employee.jobId.toLowerCase().contains(query) ||
              employee.jobTitle.toLowerCase().contains(query) ||
              employee.primaryLocation.toLowerCase().contains(query);
        }).toList();
      }

      _isLoading = false;
      notifyListeners();
    });
  }
}
