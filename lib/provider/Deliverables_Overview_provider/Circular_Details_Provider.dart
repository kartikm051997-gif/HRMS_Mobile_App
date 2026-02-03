import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../model/deliverables_model/circular_model.dart';
import '../../model/EmployeeDetailsModel/employee_details_model.dart';

class CircularProvider extends ChangeNotifier {
  List<CircularModel> _circular = [];
  bool _isLoading = false;
  bool _isDownloading = false;
  String _downloadingCircularId = '';

  List<CircularModel> get circular => _circular;
  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;
  String get downloadingCircularId => _downloadingCircularId;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setDownloading(bool downloading, String documentId) {
    _isDownloading = downloading;
    _downloadingCircularId = documentId;
    notifyListeners();
  }

  // Load circulars from EmployeeDetailsProvider
  void loadCircularsFromProvider(Map<String, dynamic>? employeeDetails) {
    setLoading(true);
    try {
      _circular = [];

      if (employeeDetails != null) {
        final circularList = employeeDetails["circularList"] as List<dynamic>?;

        if (circularList != null && circularList.isNotEmpty) {
          for (int i = 0; i < circularList.length; i++) {
            final circularData = circularList[i] as Map<String, dynamic>;
            final letterId = circularData["letter_id"]?.toString() ?? "${i + 1}";
            final date = circularData["date"]?.toString() ?? "";
            final templateName = circularData["template_name"]?.toString() ?? "";
            final content = circularData["content"]?.toString() ?? "";

            // Generate a filename based on template name and date
            final fileName = "${templateName.replaceAll(' ', '_')}_${date.replaceAll('/', '_')}.pdf";

            final documentUrl = ""; // Circulars are HTML content, not PDF URLs

            _circular.add(CircularModel(
              id: letterId,
              date: date,
              circularName: templateName,
              documentUrl: documentUrl,
              fileName: fileName,
              content: content,
              templateName: templateName,
              description: circularData["description"]?.toString(),
              status: circularData["status"]?.toString(),
              circularFor: circularData["circular_for"]?.toString(),
            ));
          }
        }
      }

      if (kDebugMode) {
        print("Fetched ${_circular.length} circulars from EmployeeDetailsProvider");
      }
    } catch (e) {
      debugPrint("Error loading circulars: $e");
      _circular = [];
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchCircular(String empId) async {
    setLoading(true);
    try {
      // This method is now deprecated - use loadCircularsFromProvider instead
      await Future.delayed(const Duration(seconds: 1));
      _circular = [];
    } catch (e) {
      debugPrint("Error fetching circulars: $e");
      _circular = [];
    } finally {
      setLoading(false);
    }
  }

  void refreshDocuments(String empId) {
    fetchCircular(empId);
  }

  void clearDocuments() {
    _circular.clear();
    notifyListeners();
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
}