import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../model/deliverables_model/circular_model.dart';

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

  Future<void> fetchCircular(String empId) async {
    setLoading(true);
    try {
      // Dummy API response (replace with real API)
      await Future.delayed(const Duration(seconds: 1));

      final response = [
        {
          "id": "1",
          "date": "11-02-2025",
          "circular_name": "Biometric Punching Requirement",
          "document_url":
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
          "file_name": "payslip_jan_2025.pdf",
        },
        {
          "id": "2",
          "date": "11-02-2025",
          "circular_name": "Circular for M.SC Clinical Embryology",
          "document_url":
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
          "file_name": "payslip_jan_2025.pdf",
        },
        {
          "id": "3",
          "date": "11-02-2025",
          "circular_name":
              "Uniformity and Discipline Guidelines for All Branches",
          "document_url":
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
          "file_name": "payslip_jan_2025.pdf",
        },
        {
          "id": "4",
          "date": "11-02-2025",
          "circular_name": "Final Warning – Biometric Attendance Compliance",
          "document_url":
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
          "file_name": "payslip_jan_2025.pdf",
        },
      ];

      _circular = response.map((doc) => CircularModel.fromJson(doc)).toList();

      if (kDebugMode) {
        print("Fetched ${_circular.length} circular documents");
      }
    } catch (e) {
      debugPrint("Error fetching circular documents: $e");
      _circular = [];
    } finally {
      setLoading(false);
    }
  }

  Future<bool> downloadDocument(CircularModel document) async {
    try {
      setDownloading(true, document.id);

      // Check and request storage permission
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

        final filePath = '${directory.path}/${document.fileName}';
        if (kDebugMode) {
          print("Downloading document to: $filePath");
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

        final file = File(filePath);
        if (await file.exists()) {
          if (kDebugMode) {
            print("File downloaded successfully: ${file.path}");
          }

          final result = await OpenFile.open(filePath);
          if (kDebugMode) {
            print("Open file result: ${result.message}");
          }

          return true;
        } else {
          debugPrint("File not created at expected location");
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

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      var result = await Permission.manageExternalStorage.request();
      if (result.isGranted) return true;

      if (await Permission.storage.isGranted) {
        return true;
      }

      result = await Permission.storage.request();
      return result.isGranted;
    } else {
      return true;
    }
  }

  void refreshDocuments(String empId) {
    fetchCircular(empId);
  }

  void clearDocuments() {
    _circular.clear();
    notifyListeners();
  }
}

// ✅ This should be OUTSIDE CircularProvider
