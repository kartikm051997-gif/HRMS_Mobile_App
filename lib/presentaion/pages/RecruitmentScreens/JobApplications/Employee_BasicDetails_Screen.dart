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
    extends State<EmployeeBasicDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use ListView for scrollable content
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView(
          shrinkWrap: true, // Important if used inside another scrollable
          physics:
              const NeverScrollableScrollPhysics(), // Let parent handle scrolling
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF8F9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E0E6B).withOpacity(0.15),
                    spreadRadius: 0,
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: widget.employee == null
                          ? LinearGradient(
                              colors: [
                                Colors.grey[400]!,
                                Colors.grey[500]!,
                              ],
                            )
                          : const LinearGradient(
                              colors: [
                                Color(0xFF8E0E6B),
                                Color(0xFFD4145A),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.employee == null
                              ? Colors.grey.withOpacity(0.2)
                              : const Color(0xFF8E0E6B).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                      gradient: LinearGradient(
                        colors: [Colors.white, Color(0xFFF8F9FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
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
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF10B981),
                                  Color(0xFF059669),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ViewProfileTabViewScreens(
                                          jobId: widget.employee?.jobId,
                                          employee: widget.employee,
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.person_outline, size: 18),
                              label: const Text(
                                "View Profile",
                                style: TextStyle(fontFamily: AppFonts.poppins),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
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
        )));
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
