import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';

import '../../model/deliverables_model/letter_model.dart';
import '../../model/EmployeeDetailsModel/employee_details_model.dart';

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

            _letter.add(
              LetterModel(
                id: letterId,
                date: date,
                letterType: letterType,
                documentUrl: documentUrl,
                fileName: fileName,
                content: content,
                templateName: templateName,
                description: letterData["description"]?.toString(),
                status: letterData["status"]?.toString(),
              ),
            );
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

  // Download file method with structured PDF layout
  Future<String> downloadFile(
      String docId,
      String htmlContent,
      String fileName,
      dynamic document,
      ) async {
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
        filePath =
        '${downloadsDirectory.path}/${nameWithoutExt}_$counter.$extension';
        file = File(filePath);
        counter++;
      }

      // Convert HTML to PDF with structured layout
      final pdf = await _htmlToPdf(
        htmlContent,
        fileName.replaceAll('.pdf', ''),
        document,
      );
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

  // Convert HTML to PDF with structured sections matching website
  Future<pw.Document> _htmlToPdf(
      String htmlContent,
      String title,
      dynamic document,
      ) async {
    // Parse the HTML content to extract structured data
    String parsedContent = htmlContent
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<p>'), '\n')
        .replaceAll(RegExp(r'</p>'), '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();

    // Extract recipient info, subject, and body
    final lines = parsedContent.split('\n');
    String toSection = '';
    String subjectSection = '';
    String bodyContent = '';

    bool foundTo = false;
    bool foundSubject = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.toLowerCase().startsWith('to,') || line.toLowerCase() == 'to') {
        foundTo = true;
        continue;
      }

      if (line.toLowerCase().startsWith('subject:')) {
        foundSubject = true;
        subjectSection = line;
        continue;
      }

      if (foundTo && !foundSubject && line.isNotEmpty) {
        toSection += line + '\n';
      } else if (foundSubject && line.isNotEmpty) {
        bodyContent += line + '\n';
      }
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // SECTION 1: HEADER with Company Name and Date/ID
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 15),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 1.5),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Company Name
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Dr. ARAVIND's IVF",
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#E91E8C'),
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'FERTILITY & PREGNANCY CENTRE',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    // Date and ID
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Date: ${document.date ?? ""}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.black,
                          ),
                        ),
                        if (document.id != null && document.id.isNotEmpty)
                          pw.Text(
                            'NC${document.id}',
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.black,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // SECTION 2: NOTICE TITLE (Centered)
              pw.Center(
                child: pw.Text(
                  'Notice',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),

              pw.SizedBox(height: 25),

              // SECTION 3: TO ADDRESS
              if (toSection.isNotEmpty) ...[
                pw.Text(
                  'To,',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  toSection.trim(),
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.black,
                    lineSpacing: 1.3,
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // SECTION 4: SUBJECT
              if (subjectSection.isNotEmpty) ...[
                pw.Text(
                  subjectSection,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 15),
              ],

              // SECTION 5: MAIN CONTENT (Justified)
              pw.Text(
                bodyContent.trim(),
                style: const pw.TextStyle(
                  fontSize: 11,
                  lineSpacing: 1.5,
                  color: PdfColors.black,
                ),
                textAlign: pw.TextAlign.justify,
              ),

              pw.Spacer(),

              // SECTION 6: FOOTER (Locations)
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 20),
                padding: const pw.EdgeInsets.only(top: 12),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey300, width: 1),
                  ),
                ),
                child: pw.Text(
                  'Tamil Nadu: Chennai-Sholinganallur, Vadapalani, Tambaram, Madipakkam, Urapakkam | Kanchipuram | Thiruvallur | Chengalpattu | Vellore | Hosur | Salem | Kallakurichi | Namakkal | Attur | Harur | Erode | Karur | Sathyamangalam | Coimbatore- Ganapathy,Sundarapuram,Thudiyalur | Pollachi | Tiruppur | Trichy | Thanjavur | Madurai | Kerala: Palakkad, Kozhikode | Karnataka: Bengaluru-Electronic City, Konanakunte, Hebbal, T.Dasarahalli | Andhra Pradesh: Tirupati | International: Sri Lanka | Bangladesh',
                  style: const pw.TextStyle(
                    fontSize: 6.5,
                    color: PdfColors.grey600,
                  ),
                  textAlign: pw.TextAlign.justify,
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