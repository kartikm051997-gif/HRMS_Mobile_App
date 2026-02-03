import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../model/deliverables_model/letter_model.dart';
import '../../model/EmployeeDetailsModel/employee_details_model.dart';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
// import 'package:permission_handler/permission_handler.dart';

class DocumentListProvider extends ChangeNotifier {
  List<LetterModel> _letter = [];
  bool _isLoading = false;
  bool _isDownloading = false;
  String _downloadingLetterId = '';

  List<LetterModel> get letter => _letter;
  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;
  String get downloadingLetterId => _downloadingLetterId;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setDownloading(bool downloading, String documentId) {
    _isDownloading = downloading;
    _downloadingLetterId = documentId;
    notifyListeners();
  }

  // Load letters from EmployeeDetailsProvider
  void loadLettersFromProvider(Map<String, dynamic>? employeeDetails) {
    setLoading(true);
    try {
      _letter = [];

      if (employeeDetails != null) {
        final letterList = employeeDetails["letterList"] as List<dynamic>?;
        
        if (letterList != null && letterList.isNotEmpty) {
          for (int i = 0; i < letterList.length; i++) {
            final letterData = letterList[i] as Map<String, dynamic>;
            final letterId = letterData["letter_id"]?.toString() ?? "${i + 1}";
            final date = letterData["date"]?.toString() ?? "";
            final letterType = letterData["letter_type"]?.toString() ?? "";
            final templateName = letterData["template_name"]?.toString() ?? "";
            final content = letterData["content"]?.toString() ?? "";
            
            // Generate a filename based on letter type and date
            final fileName = "${letterType}_${date.replaceAll('/', '_')}.html";
            
            // For now, we'll use a placeholder URL since letters are HTML content
            // In a real scenario, you might want to convert HTML to PDF or serve it as a URL
            final documentUrl = ""; // Letters are HTML content, not PDF URLs

            _letter.add(LetterModel(
              id: letterId,
              date: date,
              letterType: letterType,
              documentUrl: documentUrl,
              fileName: fileName,
              content: content,
              templateName: templateName,
              description: letterData["description"]?.toString(),
              status: letterData["status"]?.toString(),
            ));
          }
        }
      }

      if (kDebugMode) {
        print("Fetched ${_letter.length} letters from EmployeeDetailsProvider");
      }
    } catch (e) {
      debugPrint("Error loading letters: $e");
      _letter = [];
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchLetter(String empId) async {
    setLoading(true);
    try {
      // This method is now deprecated - use loadLettersFromProvider instead
      await Future.delayed(const Duration(seconds: 1));
      _letter = [];
    } catch (e) {
      debugPrint("Error fetching letters: $e");
      _letter = [];
    } finally {
      setLoading(false);
    }
  }

  Future<bool> downloadDocument(LetterModel document) async {
    try {
      setDownloading(true, document.id);

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

        final filePath = '${directory.path}/${document.fileName}';

        if (kDebugMode) {
          print("Downloading to: $filePath");
        }

        await dio.download(
          document.documentUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              debugPrint('Download progress: ${(progress * 100).toStringAsFixed(0)}%');
            }
          },
        );

        // Verify file was downloaded
        final file = File(filePath);
        if (await file.exists()) {
          if (kDebugMode) {
            print("File downloaded successfully: ${file.path}");
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
      debugPrint("Error downloading document: $e");
      return false;
    } finally {
      setDownloading(false, '');
    }
  }

  // Download file method similar to DocumentProvider
  Future<String> downloadFile(String docId, String htmlContent, String fileName) async {
    try {
      // Set downloading state
      setDownloading(true, docId);

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
        filePath = '${downloadsDirectory.path}/${nameWithoutExt}_$counter.$extension';
        file = File(filePath);
        counter++;
      }

      // Convert HTML to PDF
      final pdf = await _htmlToPdf(htmlContent, fileName.replaceAll('.pdf', ''));
      final pdfBytes = await pdf.save();

      // Write PDF bytes to file
      await file.writeAsBytes(pdfBytes);

      // Verify file was created successfully
      if (await file.exists()) {
        // Reset states
        setDownloading(false, '');

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
        String location = Platform.isAndroid && downloadsDirectory.path.contains('Download')
            ? "Downloads folder"
            : "App documents";
        return "✅ File saved to $location!";
      } else {
        throw Exception("File was not created successfully");
      }
    } catch (e) {
      // Reset states on error
      setDownloading(false, '');

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

  // Convert HTML to PDF
  Future<pw.Document> _htmlToPdf(String htmlContent, String title) async {
    // Strip HTML tags for simple text display
    final textContent = htmlContent
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Expanded(
                child: pw.Text(
                  textContent,
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
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

  void refreshDocuments(String empId) {
    fetchLetter(empId);
  }

  void clearDocuments() {
    _letter.clear();
    notifyListeners();
  }
}

