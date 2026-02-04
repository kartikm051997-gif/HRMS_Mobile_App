import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/Deliverables_Overview_provider/deliverables_provider.dart';
import '../../../widgets/shimmer_custom_screen/shimmer_custom_screen.dart';

class DeliverablesScreen extends StatefulWidget {
  final String empId;
  final String empPhoto;
  final String empName;
  final String empDesignation;
  final String empBranch;

  const DeliverablesScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<DeliverablesScreen> createState() => _DeliverablesScreenState();
}

class _DeliverablesScreenState extends State<DeliverablesScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<DeliverablesProvider>().fetchDeliverables(widget.empId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: const TabletMobileDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Deliverables",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: Consumer<DeliverablesProvider>(
        builder: (context, deliverablesProvider, child) {
          if (deliverablesProvider.isLoading) {
            return const CustomCardShimmer(itemCount: 5);
          }

          if (deliverablesProvider.deliverables.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deliverablesProvider.deliverables.length,
            itemBuilder: (context, index) {
              final deliverable = deliverablesProvider.deliverables[index];
              return _buildDeliverableCard(deliverable);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No Deliverables Found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your deliverables will appear here",
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverableCard(Map<String, dynamic> deliverable) {
    final status = deliverable["status"] ?? "Pending";
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    deliverable["title"] ?? "Untitled",
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Description
          if (deliverable["description"] != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                deliverable["description"],
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),

          // Divider
          Divider(height: 1, color: Colors.grey[200]),

          // Info Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today_outlined,
                    "Due Date",
                    deliverable["dueDate"] ?? "N/A",
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[200]),
                Expanded(
                  child: _buildInfoItem(
                    Icons.flag_outlined,
                    "Priority",
                    deliverable["priority"] ?? "N/A",
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[200]),
                Expanded(
                  child: _buildInfoItem(
                    Icons.category_outlined,
                    "Category",
                    deliverable["category"] ?? "General",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontFamily: AppFonts.poppins,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF059669);
      case 'in progress':
      case 'in-progress':
        return const Color(0xFFD97706);
      case 'pending':
        return const Color(0xFF2563EB);
      case 'not started':
      case 'not yet start':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
