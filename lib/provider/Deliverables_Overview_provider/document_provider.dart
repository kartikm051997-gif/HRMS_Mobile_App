import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class DocumentProvider extends ChangeNotifier {
  final Dio _dio = Dio();

  // State variables
  bool _isLoading = true;
  String _downloadProgress = '';
  final Map<String, bool> _downloadingStates = {};

  // Document data
  final List<Map<String, dynamic>> _documents = [
    {
      "id": "1",
      "title": "Resume",
      "url":
          "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      "isDownloadable": true,
      "type": "resume",
      "fileExtension": "pdf",
      "uploadDate": "2024-01-15",
      "size": "245 KB",
    },
    {
      "id": "2",
      "title": "Offer Letter",
      "url":
          "https://file-examples.com/storage/fef68e5288c566cbcab4db7/2017/10/file_example_PDF_500_kB.pdf",
      "isDownloadable": true,
      "type": "portfolio",
      "fileExtension": "pdf",
      "uploadDate": "2024-01-20",
      "size": "500 KB",
    },
    {
      "id": "3",
      "title": "Adhar card",
      "url":
          "https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf",
      "isDownloadable": true,
      "type": "cv",
      "fileExtension": "pdf",
      "uploadDate": "2024-01-25",
      "size": "180 KB",
    },
    {
      "id": "4",
      "title": "Pan Card",
      "url":
          "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      "isDownloadable": true,
      "type": "resume",
      "fileExtension": "pdf",
      "uploadDate": "2024-02-01",
      "size": "320 KB",
    },
    {
      "id": "5",
      "title": "Bank Passbook",
      "url":
          "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      "isDownloadable": true,
      "type": "cv",
      "fileExtension": "pdf",
      "uploadDate": "2024-02-05",
      "size": "280 KB",
    },
    {
      "id": "6",
      "title": "Other Document",
      "url":
          "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      "isDownloadable": true,
      "type": "cv",
      "fileExtension": "pdf",
      "uploadDate": "2024-02-05",
      "size": "280 KB",
    },
  ];

  // Getters
  bool get isLoading => _isLoading;
  String get downloadProgress => _downloadProgress;
  List<Map<String, dynamic>> get documents => _documents;
  Map<String, bool> get downloadingStates => _downloadingStates;

  // Initialize documents
  Future<void> initializeDocuments() async {
    _isLoading = true;
    notifyListeners();

    // Initialize downloading states
    for (var doc in _documents) {
      _downloadingStates[doc["id"]] = false;
    }

    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 800));

    _isLoading = false;
    notifyListeners();
  }

  // Fetch documents from API (you can implement this later)
  Future<void> fetchDocuments(String empId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      // final response = await _dio.get('/api/documents/$empId');
      // _documents = response.data;

      // For now, just simulate loading
      await Future.delayed(const Duration(milliseconds: 1000));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Request storage permissions
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus == PermissionStatus.granted;
      }
      return true;
    }
    return true;
  }

  // Download file with improved directory handling
  Future<String> downloadFile(String docId, String url, String fileName) async {
    try {
      // Set downloading state
      _downloadingStates[docId] = true;
      notifyListeners();

      // Clean filename to avoid path issues
      fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      // Get download directory with fallback options
      Directory? downloadsDirectory;

      if (Platform.isAndroid) {
        // Try multiple directory options for better compatibility
        List<Directory?> possibleDirs = [
          // Option 1: Try Downloads folder (requires MANAGE_EXTERNAL_STORAGE on Android 11+)
          Directory('/storage/emulated/0/Download'),
          // Option 2: App-specific external directory (works without special permissions)
          await getExternalStorageDirectory(),
          // Option 3: App documents directory (always works)
          await getApplicationDocumentsDirectory(),
        ];

        for (Directory? dir in possibleDirs) {
          if (dir != null) {
            try {
              // Test if directory exists or can be created
              bool dirExists = await dir.exists();
              if (!dirExists) {
                await dir.create(recursive: true);
                dirExists = await dir.exists();
              }

              if (dirExists) {
                // Test write permission by creating a temp file
                final testFile = File('${dir.path}/.temp_test');
                await testFile.writeAsString('test');
                await testFile.delete();

                downloadsDirectory = dir;
                break;
              }
            } catch (e) {
              // Continue to next directory option
              continue;
            }
          }
        }
      } else {
        // iOS - use documents directory
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory == null) {
        throw Exception("Could not find accessible download directory");
      }

      String filePath = '${downloadsDirectory.path}/$fileName';

      // Ensure the file doesn't already exist or create unique name
      File file = File(filePath);
      int counter = 1;
      while (await file.exists()) {
        String nameWithoutExt = fileName.split('.').first;
        String extension = fileName.split('.').last;
        filePath =
            '${downloadsDirectory.path}/${nameWithoutExt}_$counter.$extension';
        file = File(filePath);
        counter++;
      }

      // Download file with progress tracking
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress =
                '${(received / total * 100).toStringAsFixed(0)}%';
            notifyListeners();
          }
        },
      );

      // Verify file was created successfully
      if (await file.exists()) {
        // Reset states
        _downloadingStates[docId] = false;
        _downloadProgress = '';
        notifyListeners();

        // Return success message with file location
        String location =
            Platform.isAndroid && downloadsDirectory.path.contains('Download')
                ? "Downloads folder"
                : "App documents";
        return "✅ File saved to $location!";
      } else {
        throw Exception("File was not created successfully");
      }
    } catch (e) {
      // Reset states on error
      _downloadingStates[docId] = false;
      _downloadProgress = '';
      notifyListeners();

      String errorMsg = "❌ Download failed: ";
      if (e.toString().contains('PathAccessException')) {
        errorMsg += "No permission to write to directory";
      } else if (e.toString().contains('SocketException')) {
        errorMsg += "Network error - check internet connection";
      } else {
        errorMsg += e.toString();
      }

      return errorMsg;
    }
  }

  // Check if document is downloading
  bool isDocumentDownloading(String docId) {
    return _downloadingStates[docId] ?? false;
  }

  // Get file icon based on type
  String getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'resume':
        return '📄';
      case 'cv':
        return '📋';
      case 'portfolio':
        return '📋';
      case 'portfolio':
        return '📋';
      default:
        return '📄';
    }
  }

  // Get type color
  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'resume':
        return Colors.blue;
      case 'cv':
        return Colors.green;
      case 'portfolio':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Add document (for future use)
  void addDocument(Map<String, dynamic> document) {
    _documents.add(document);
    _downloadingStates[document["id"]] = false;
    notifyListeners();
  }

  // Remove document
  void removeDocument(String docId) {
    _documents.removeWhere((doc) => doc["id"] == docId);
    _downloadingStates.remove(docId);
    notifyListeners();
  }

  // Update document
  void updateDocument(String docId, Map<String, dynamic> updatedDoc) {
    final index = _documents.indexWhere((doc) => doc["id"] == docId);
    if (index != -1) {
      _documents[index] = updatedDoc;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}
