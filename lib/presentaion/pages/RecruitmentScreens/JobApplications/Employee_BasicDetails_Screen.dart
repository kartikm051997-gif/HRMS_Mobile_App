import 'package:flutter/material.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../model/RecruitmentModel/Job_Application_Model.dart';
import 'ViewProfileScreens/View_Profile_Tabbar_Screens/View_Profile_Tabbar_Screens.dart';

class EmployeeBasicDetailsScreen extends StatefulWidget {
  final String? jobId; // Optional
  final JobApplicationModel? employee; // Optional

  const EmployeeBasicDetailsScreen({super.key, this.jobId, this.employee});

  @override
  State<EmployeeBasicDetailsScreen> createState() =>
      _EmployeeBasicDetailsScreenState();
}

class _EmployeeBasicDetailsScreenState
    extends State<EmployeeBasicDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // Use ListView for scrollable content
    return ListView(
      shrinkWrap: true, // Important if used inside another scrollable
      physics:
          const NeverScrollableScrollPhysics(), // Let parent handle scrolling
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      widget.employee == null
                          ? const Color(0xFFE5E7EB)
                          : const Color(0xffa14f79),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            widget.employee == null
                                ? Colors.grey.shade400
                                : Colors.white.withOpacity(0.2),
                        backgroundImage:
                            widget.employee != null
                                ? const NetworkImage(
                                  "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face",
                                )
                                : null,
                        child:
                            widget.employee == null
                                ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.employee?.name ?? "No Employee Selected",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color:
                              widget.employee == null
                                  ? Colors.grey.shade600
                                  : Colors.white,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.employee != null
                            ? "JobId: ${widget.employee?.jobId ?? 'N/A'}"
                            : "Employee details not available",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              widget.employee == null
                                  ? Colors.grey.shade500
                                  : Colors.white.withOpacity(0.8),
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    widget.employee != null
                        ? _buildDetailRow(
                          Icons.work_outline,
                          "Job Title",
                          widget.employee!.jobTitle ?? "Not specified",
                          Colors.blue,
                        )
                        : _buildPlaceholderRow(
                          Icons.work_outline,
                          "Job Title",
                          Colors.blue,
                        ),
                    const SizedBox(height: 16),
                    widget.employee != null
                        ? _buildDetailRow(
                          Icons.location_on_outlined,
                          "Primary Location",
                          widget.employee!.primaryLocation ?? "Not specified",
                          Colors.green,
                        )
                        : _buildPlaceholderRow(
                          Icons.location_on_outlined,
                          "Primary Location",
                          Colors.green,
                        ),
                    const SizedBox(height: 16),
                    widget.employee != null
                        ? _buildDetailRow(
                          Icons.phone_outlined,
                          "Phone",
                          widget.employee!.phone ?? "Not provided",
                          Colors.orange,
                        )
                        : _buildPlaceholderRow(
                          Icons.phone_outlined,
                          "Phone",
                          Colors.orange,
                        ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color:
                                  widget.employee == null
                                      ? Colors.grey.shade300
                                      : Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                widget.employee == null
                                    ? "No Status"
                                    : "Unread",
                                style: TextStyle(
                                  color:
                                      widget.employee == null
                                          ? Colors.grey.shade600
                                          : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => const ViewProfileTabViewScreens(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_outline, size: 18),
                            label: const Text(
                              "View Profile",
                              style: TextStyle(fontFamily: AppFonts.poppins),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                  fontFamily: AppFonts.poppins,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderRow(IconData icon, String label, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey.shade400),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                  fontFamily: AppFonts.poppins,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Not available",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
