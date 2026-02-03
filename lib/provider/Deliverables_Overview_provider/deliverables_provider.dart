import 'package:flutter/foundation.dart';

class DeliverablesProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _deliverables = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get deliverables => _deliverables;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchDeliverables(String empId) async {
    setLoading(true);
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Dummy data - replace with actual API call later
      _deliverables = [
        {
          "id": "1",
          "title": "Project Documentation",
          "description": "Complete project documentation for Q1 deliverables",
          "status": "Completed",
          "dueDate": "2025-01-15",
          "completedDate": "2025-01-12",
          "priority": "High",
          "category": "Documentation",
        },
        {
          "id": "2",
          "title": "Code Review",
          "description": "Review and approve code changes for main branch",
          "status": "In Progress",
          "dueDate": "2025-01-20",
          "completedDate": null,
          "priority": "Medium",
          "category": "Development",
        },
        {
          "id": "3",
          "title": "Client Presentation",
          "description": "Prepare presentation slides for client meeting",
          "status": "Pending",
          "dueDate": "2025-01-25",
          "completedDate": null,
          "priority": "High",
          "category": "Presentation",
        },
      ];

      if (kDebugMode) {
        print("✅ Fetched ${_deliverables.length} deliverables");
      }
    } catch (e) {
      debugPrint("❌ Error fetching deliverables: $e");
      _deliverables = [];
    } finally {
      setLoading(false);
    }
  }

  void clearDeliverables() {
    _deliverables = [];
    notifyListeners();
  }
}
