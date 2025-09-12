import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/Task_details_Provider.dart';
import '../../../../widgets/shimmer_custom_screen/shimmer_custom_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;

  const TaskDetailsScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<TaskDetailsProvider>().fetchTasks(widget.empId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TaskDetailsProvider>(
        builder: (context, taskProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                taskProvider.isLoading
                    ? const CustomCardShimmer(
                      itemCount: 4,
                    ) // ✅ Show shimmer when loading
                    : taskProvider.tasks.isEmpty
                    ? const Center(
                      child: Text(
                        "No PF details found.",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: AppFonts.poppins,
                          color: Colors.black54,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: taskProvider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = taskProvider.tasks[index];
                        final isDownloading =
                            taskProvider.isDownloading &&
                            taskProvider.downloadingTaskId == task.id;

                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.grey.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Task Title + Download Button
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppFonts.poppins,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    isDownloading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.green,
                                                ),
                                          ),
                                        )
                                        : InkWell(
                                          onTap: () async {
                                            final success = await taskProvider
                                                .downloadTask(task);

                                            if (!mounted) return;

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  success
                                                      ? "Downloaded: ${task.fileName}"
                                                      : "Failed to download",
                                                ),
                                                backgroundColor:
                                                    success
                                                        ? Colors.green
                                                        : Colors.red,
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Icon(
                                              Icons.download,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Date Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateCard(
                                        "Start Date",
                                        task.startDate,
                                        Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDateCard(
                                        "End Date",
                                        task.endDate,
                                        Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Status Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Status",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: AppFonts.poppins,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(task.status),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            task.status,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppFonts.poppins,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Assigned by",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: AppFonts.poppins,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(task.status),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            task.assignedBy,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppFonts.poppins,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // File Name
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          );
        },
      ),
    );
  }

  Widget _buildDateCard(String label, String date, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in-progress':
        return Colors.orange;
      case 'testing':
        return Colors.blue;
      case 'not yet start':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
