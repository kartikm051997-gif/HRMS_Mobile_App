import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/widgets/custom_botton/custom_gradient_button.dart';

import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomAppBar(title: "Tasks"),
      drawer: const TabletMobileDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTaskCard(
            title: 'Complete Project Report',
            assignedTo: 'Ganesh Kumar',
            dueDate: '15 Dec 2025',
            priority: 'High',
            priorityColor: Colors.red,
            status: 'In Progress',
          ),
          _buildTaskCard(
            title: 'Client Meeting Preparation',
            assignedTo: 'Ramesh Singh',
            dueDate: '12 Dec 2025',
            priority: 'Medium',
            priorityColor: Colors.orange,
            status: 'Pending',
          ),
          _buildTaskCard(
            title: 'Update Dashboard UI',
            assignedTo: 'Suresh Patel',
            dueDate: '10 Dec 2025',
            priority: 'Low',
            priorityColor: Colors.green,
            status: 'Completed',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String assignedTo,
    required String dueDate,
    required String priority,
    required Color priorityColor,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                assignedTo,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                dueDate,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontFamily: AppFonts.poppins,
                ),
              ),
              const Spacer(),
              Text(
                status,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
