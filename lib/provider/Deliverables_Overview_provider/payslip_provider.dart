import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../model/deliverables_model/payslip_model.dart';

class PaySlipProvider extends ChangeNotifier {
  List<PaySlipModel> _payslip = [];
  bool _isLoading = false;
  bool _isDownloading = false;
  String _downloadingPaySlipId = '';

  List<PaySlipModel> get payslip => _payslip;
  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;
  String get downloadingPaySlipId => _downloadingPaySlipId;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setDownloading(bool downloading, String documentId) {
    _isDownloading = downloading;
    _downloadingPaySlipId = documentId;
    notifyListeners();
  }

  Future<void> fetchPaySlip(String empId) async {
    setLoading(true);
    try {
      // Dummy API response (replace with real API)
      await Future.delayed(const Duration(seconds: 1));

      final response = [
        {
          "id": "1",
          "date": "11-02-2025",
          "salary_month": "2025-01",
          "salary": "31612.00",
          "document_url":
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
          "file_name": "payslip_jan_2025.pdf",
        },
      ];

      _payslip = response.map((doc) => PaySlipModel.fromJson(doc)).toList();

      if (kDebugMode) {
        print("Fetched ${_payslip.length} payslip documents");
      }
    } catch (e) {
      debugPrint("Error fetching payslip documents: $e");
      _payslip = [];
    } finally {
      setLoading(false);
    }
  }

  Future<bool> downloadDocument(PaySlipModel document) async {
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
          print("Downloading payslip to: $filePath");
        }

        await dio.download(
          document.documentUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              debugPrint(
                'Payslip download progress: ${(progress * 100).toStringAsFixed(0)}%',
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
            print("Open payslip result: ${result.message}");
          }

          return true;
        } else {
          debugPrint("Payslip file was not created at expected location");
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

  void refreshDocuments(String empId) {
    fetchPaySlip(empId);
  }

  void clearDocuments() {
    _payslip.clear();
    notifyListeners();
  }
}
