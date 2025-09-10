import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
// import 'package:permission_handler/permission_handler.dart';

class DocumentListProvider extends ChangeNotifier {
  List<DocumentModel> _documents = [];
  bool _isLoading = false;
  bool _isDownloading = false;
  String _downloadingDocumentId = '';

  List<DocumentModel> get documents => _documents;
  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;
  String get downloadingDocumentId => _downloadingDocumentId;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setDownloading(bool downloading, String documentId) {
    _isDownloading = downloading;
    _downloadingDocumentId = documentId;
    notifyListeners();
  }

  Future<void> fetchDocuments(String empId) async {
    setLoading(true);
    try {
      // Dummy API response (replace with real API)
      await Future.delayed(const Duration(seconds: 1));

      final response = [
        {
          "id": "1",
          "date": "19-06-2025",
          "letter_type": "Notice",
          "document_url":
          "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
          "file_name": "notice_19062025.pdf",
        },
      ];

      _documents = response.map((doc) => DocumentModel.fromJson(doc)).toList();

      if (kDebugMode) {
        print("Fetched ${_documents.length} documents");
      }
    } catch (e) {
      debugPrint("Error fetching documents: $e");
      _documents = [];
    } finally {
      setLoading(false);
    }
  }

  Future<bool> downloadDocument(DocumentModel document) async {
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
    fetchDocuments(empId);
  }

  void clearDocuments() {
    _documents.clear();
    notifyListeners();
  }
}

class DocumentModel {
  final String id;
  final String date;
  final String letterType;
  final String documentUrl;
  final String fileName;

  DocumentModel({
    required this.id,
    required this.date,
    required this.letterType,
    required this.documentUrl,
    required this.fileName,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      letterType: json['letter_type'] ?? '',
      documentUrl: json['document_url'] ?? '',
      fileName: json['file_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'letter_type': letterType,
      'document_url': documentUrl,
      'file_name': fileName,
    };
  }
}