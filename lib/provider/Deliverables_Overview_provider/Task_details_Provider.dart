import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../model/deliverables_model/task_details_model.dart';

class TaskDetailsProvider extends ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  bool _isDownloading = false;
  String _downloadingTaskId = '';

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;
  String get downloadingTaskId => _downloadingTaskId;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setDownloading(bool downloading, String taskId) {
    _isDownloading = downloading;
    _downloadingTaskId = taskId;
    notifyListeners();
  }

  Future<void> fetchTasks(String empId) async {
    setLoading(true);
    try {
      // Dummy API response (replace with real API)
      await Future.delayed(const Duration(seconds: 1));

      final response = [
        {
          "id": "1",
          "title": "Test1",
          "start_date": "08-08-2025",
          "end_date": "06-08-2025",
          "status": "In-progress",
          "assigned_by": "Chandra Kumar",
          "document_url":
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
          "file_name": "test1_attachment.pdf",
        },
        {
          "id": "2",
          "title": "Test2",
          "start_date": "08-08-2025",
          "end_date": "08-08-2025",
          "status": "Testing",
          "assigned_by": "Chandra Kumar",
          "document_url":
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
          "file_name": "test2_attachment.pdf",
        },
        {
          "id": "3",
          "title": "need tasks",
          "start_date": "09-08-2025",
          "end_date": "08-08-2025",
          "status": "Completed",
          "assigned_by": "Chandra Kumar",
          "document_url":
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
          "file_name": "need_tasks_attachment.pdf",
        },
        {
          "id": "4",
          "title": "Need crm update",
          "start_date": "09-08-2025",
          "end_date": "10-08-2025",
          "status": "Not Yet Start",
          "assigned_by": "Chandra Kumar",
          "document_url":
              "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
          "file_name": "crm_update_attachment.pdf",
        },
      ];

      _tasks = response.map((task) => TaskModel.fromJson(task)).toList();

      if (kDebugMode) {
        print("Fetched ${_tasks.length} tasks");
      }
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
      _tasks = [];
    } finally {
      setLoading(false);
    }
  }

  Future<bool> downloadTask(TaskModel task) async {
    try {
      setDownloading(true, task.id);

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

        final filePath = '${directory.path}/${task.fileName}';
        if (kDebugMode) {
          print("Downloading document to: $filePath");
        }

        await dio.download(
          task.documentUrl,
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
    fetchTasks(empId);
  }

  void clearDocuments() {
    _tasks.clear();
    notifyListeners();
  }
}
