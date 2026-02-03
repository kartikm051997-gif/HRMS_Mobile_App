import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:convert';
import '../../servicesAPI/LogInService/LogIn_Service.dart';

class DocumentProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final LoginService _loginService = LoginService();

  // State variables
  bool _isLoading = true;
  String _downloadProgress = '';
  final Map<String, bool> _downloadingStates = {};

  // Document data - Now fetched from EmployeeDetailsProvider
  List<Map<String, dynamic>> _documents = [];

  // Getters
  bool get isLoading => _isLoading;
  String get downloadProgress => _downloadProgress;
  List<Map<String, dynamic>> get documents => _documents;
  Map<String, bool> get downloadingStates => _downloadingStates;

  // Initialize documents - Now fetches from EmployeeDetailsProvider
  Future<void> initializeDocuments() async {
    _isLoading = true;
    notifyListeners();

    // Initialize downloading states
    for (var doc in _documents) {
      _downloadingStates[doc["id"] ?? doc["document_name"]] = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load documents from EmployeeDetailsProvider
  void loadDocumentsFromProvider(Map<String, dynamic>? employeeDetails) {
    _isLoading = true;
    notifyListeners();

    try {
      _documents = [];
      _downloadingStates.clear();

      if (employeeDetails != null) {
        final documentList = employeeDetails["documentList"] as List<dynamic>?;

        if (documentList != null && documentList.isNotEmpty) {
          for (int i = 0; i < documentList.length; i++) {
            final doc = documentList[i] as Map<String, dynamic>;
            // Clean document name - ensure it's just the name, not JSON
            String documentName = doc["document_name"]?.toString() ?? "Document ${i + 1}";
            // Remove any JSON-like content from document name
            documentName = documentName.split(',').first.trim();
            if (documentName.length > 50) {
              documentName = documentName.substring(0, 50);
            }
            
            String fileUrl = doc["file_url"]?.toString() ?? "";
            String filename = doc["filename"]?.toString() ?? "";
            final hasFile =
                doc["has_file"] == true ||
                doc["has_file"] == 1 ||
                doc["has_file"] == "1";

            // Handle file_url that might be a JSON string (for "Other Document")
            if (fileUrl.isNotEmpty && fileUrl.contains('[') && fileUrl.contains('{')) {
              try {
                // Extract JSON part from URL
                final jsonStart = fileUrl.indexOf('[');
                if (jsonStart != -1) {
                  final jsonString = fileUrl.substring(jsonStart);
                  final List<dynamic> parsed = jsonDecode(jsonString);
                  if (parsed.isNotEmpty && parsed[0] is Map) {
                    final firstDoc = parsed[0] as Map<String, dynamic>;
                    // Extract proper file URL
                    fileUrl = firstDoc['fullPath']?.toString() ?? 
                             firstDoc['path']?.toString() ?? 
                             fileUrl;
                    // Extract filename if not already set
                    if (filename.isEmpty) {
                      filename = firstDoc['fileName']?.toString() ?? "";
                    }
                  }
                }
              } catch (e) {
                if (kDebugMode) print("⚠️ Could not parse file_url JSON: $e");
                // If parsing fails, try to extract a clean URL
                if (fileUrl.contains('http')) {
                  final urlMatch = RegExp(r'https?://[^\s\[\]]+').firstMatch(fileUrl);
                  if (urlMatch != null) {
                    fileUrl = urlMatch.group(0) ?? fileUrl;
                  }
                }
              }
            }

            // Clean filename - remove any JSON-like content
            if (filename.isNotEmpty) {
              filename = filename.split(',').first.trim();
              if (filename.length > 50) {
                filename = filename.substring(0, 50);
              }
            }

            // Extract file extension from filename or URL
            String fileExtension = "pdf";
            if (filename.isNotEmpty) {
              final parts = filename.split('.');
              if (parts.length > 1) {
                fileExtension = parts.last.toLowerCase();
              }
            } else if (fileUrl.isNotEmpty) {
              final urlParts = fileUrl.split('.');
              if (urlParts.length > 1) {
                fileExtension = urlParts.last.split('?').first.toLowerCase();
              }
            }

            _documents.add({
              "id": "${documentName}_$i",
              "title": documentName,
              "url": fileUrl,
              "filename": filename,
              "isDownloadable": hasFile && fileUrl.isNotEmpty,
              "fileExtension": fileExtension,
              "hasFile": hasFile,
            });

            _downloadingStates["${documentName}_$i"] = false;
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch documents from API (legacy method - kept for backward compatibility)
  Future<void> fetchDocuments(String empId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // This method is now deprecated - use loadDocumentsFromProvider instead
      await Future.delayed(const Duration(milliseconds: 500));

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

      // Get auth token for authenticated downloads
      final token = await _loginService.getValidToken();

      // Download file with progress tracking and auth headers
      await _dio.download(
        url,
        filePath,
        options: Options(
          headers:
              token != null
                  ? {
                    "Authorization": "Bearer $token",
                    "Content-Type": "application/json",
                  }
                  : {},
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
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

        // Try to open the file after download
        try {
          final result = await OpenFile.open(filePath);
          if (kDebugMode) {
            print("📄 File opened: ${result.message}");
          }
        } catch (e) {
          if (kDebugMode) {
            print("⚠️ Could not open file automatically: $e");
          }
        }

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
