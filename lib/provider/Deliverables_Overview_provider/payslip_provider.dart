import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../model/deliverables_model/payslip_model.dart';
import '../../servicesAPI/EmployeeDetailsService/employee_details_service.dart';
import '../../servicesAPI/LogInService/LogIn_Service.dart';

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

  Future<void> fetchPaySlip(String userId) async {
    setLoading(true);
    try {
      if (kDebugMode) {
        print("🔄 PaySlipProvider: Fetching payslips for user_id: $userId");
      }

      final service = EmployeeDetailsService();
      final response = await service.getEmployeeDetails(userId);

      if (response.data?.payslips != null &&
          response.data!.payslips!.payslipList != null) {
        _payslip =
            response.data!.payslips!.payslipList!
                .map((item) => PaySlipModel.fromPayslipItem(item))
                .toList();

        if (kDebugMode) {
          print(
            "✅ PaySlipProvider: Fetched ${_payslip.length} payslip documents",
          );
          // Debug: Print PDF URLs
          for (var slip in _payslip) {
            print("📄 Payslip ${slip.id}: ${slip.documentUrl}");
          }
        }
      } else {
        _payslip = [];
        if (kDebugMode) {
          print("⚠️ PaySlipProvider: No payslips found");
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching payslip documents: $e");
      _payslip = [];
    } finally {
      setLoading(false);
    }
  }

  Future<bool> downloadDocument(PaySlipModel document) async {
    try {
      setDownloading(true, document.id);

      if (document.documentUrl.isEmpty) {
        debugPrint("❌ PaySlip URL is empty");
        return false;
      }

      // Check and request storage permission
      if (!await _requestStoragePermission()) {
        debugPrint("❌ Storage permission denied");
        return false;
      }

      final dio = Dio();
      Directory? directory;

      // Get the appropriate directory based on platform
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Navigate to the public Downloads folder
          String downloadsPath = '/storage/emulated/0/Download';
          directory = Directory(downloadsPath);

          if (!await directory.exists()) {
            // Fallback to app-specific directory if public Downloads is not accessible
            directory = await getExternalStorageDirectory();
            if (directory != null) {
              final downloadsDir = Directory('${directory.path}/Download');
              if (!await downloadsDir.exists()) {
                await downloadsDir.create(recursive: true);
              }
              directory = downloadsDir;
            }
          }
        }
      } else {
        // For iOS, use documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        debugPrint("❌ Could not access storage directory");
        return false;
      }

      final filePath = '${directory.path}/${document.fileName}';

      if (kDebugMode) {
        print("📥 Downloading payslip from: ${document.documentUrl}");
        print("💾 Saving to: $filePath");
      }

      // Construct proper PDF download URL
      String downloadUrl = document.documentUrl;

      // If URL doesn't end with .pdf, try to construct proper download URL
      if (!downloadUrl.toLowerCase().endsWith('.pdf')) {
        // Try appending /pdf or /download to get the actual PDF file
        // You may need to adjust this based on your backend API
        if (downloadUrl.contains('/payslip/')) {
          // Option 1: Try /pdf endpoint
          downloadUrl = '$downloadUrl/pdf';

          // Option 2: If that doesn't work, try /download
          // downloadUrl = '$downloadUrl/download';
        }
      }

      // Get authentication token for download
      final loginService = LoginService();
      final token = await loginService.getValidToken();

      // Add authentication headers
      final headers = <String, String>{'Accept': 'application/pdf'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';

        // Also try adding token as query parameter
        final uri = Uri.parse(downloadUrl);
        if (!uri.queryParameters.containsKey('token')) {
          downloadUrl =
              uri
                  .replace(
                    queryParameters: {...uri.queryParameters, 'token': token},
                  )
                  .toString();
        }
      }

      if (kDebugMode) {
        print("🔗 Final download URL: $downloadUrl");
      }

      // Configure Dio with retry logic
      dio.options.followRedirects = true;
      dio.options.maxRedirects = 5;
      dio.options.receiveTimeout = const Duration(seconds: 60);
      dio.options.connectTimeout = const Duration(seconds: 30);

      await dio.download(
        downloadUrl,
        filePath,
        options: Options(headers: headers, responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            if (kDebugMode) {
              print(
                '📊 Download progress: ${(progress * 100).toStringAsFixed(0)}%',
              );
            }
          }
        },
      );

      // Verify file was downloaded and has content
      final file = File(filePath);
      if (await file.exists()) {
        final fileSize = await file.length();

        if (kDebugMode) {
          print("✅ Payslip downloaded successfully");
          print("📄 File: ${file.path}");
          print("📊 Size: ${(fileSize / 1024).toStringAsFixed(2)} KB");
        }

        // Check if file has content (PDF should be > 1KB typically)
        if (fileSize < 100) {
          debugPrint(
            "⚠️ Downloaded file seems too small, might be an error page",
          );
          // Read and print file content for debugging
          if (kDebugMode) {
            final content = await file.readAsString();
            print("File content: $content");
          }
          return false;
        }

        // Try to open the downloaded file
        try {
          final result = await OpenFile.open(filePath);
          if (kDebugMode) {
            print("📱 Open file result: ${result.message}");
          }
        } catch (openError) {
          debugPrint("⚠️ Could not auto-open file: $openError");
          // File is still downloaded successfully even if we can't open it
        }

        return true;
      } else {
        debugPrint("❌ File was not created at expected location");
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error downloading payslip: $e");
      if (kDebugMode) {
        print("Stack trace: $stackTrace");
      }

      // Check if it's a DioException to get more details
      if (e is DioException) {
        debugPrint("❌ DioException type: ${e.type}");
        debugPrint("❌ Response status: ${e.response?.statusCode}");
        debugPrint("❌ Response data: ${e.response?.data}");
      }

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
