import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/fonts/fonts.dart';
import '../../../../model/RecruitmentModel/Job_Application_Model.dart';
import '../../../../provider/RecruitmentScreensProviders/Job_Application_Provider.dart';

class ViewResumeButtonScreen extends StatefulWidget {
  final JobApplicationModel? employee;

  const ViewResumeButtonScreen({super.key, this.employee});

  @override
  State<ViewResumeButtonScreen> createState() => _ViewResumeButtonScreenState();
}

class _ViewResumeButtonScreenState extends State<ViewResumeButtonScreen> {
  @override
  Widget build(BuildContext context) {
    // If employee is null, show a disabled button or placeholder
    if (widget.employee == null) {
      return Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: Text(
                "View Resume",
                style: TextStyle(fontFamily: AppFonts.poppins),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Consumer<JobApplicationProvider>(
      builder: (context, provider, child) {
        bool isDownloading =
            provider.isDownloading &&
            provider.downloadingJobId == widget.employee!.jobId;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isDownloading
                ? null
                : const LinearGradient(
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF2563EB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDownloading ? Colors.grey.shade400 : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDownloading
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDownloading
                  ? null
                  : () async {
                      _downloadJobApplicationPDF(provider);
                    },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isDownloading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.description_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isDownloading ? "Downloading..." : "View Resume",
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    if (!isDownloading)
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 18,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadJobApplicationPDF(
    JobApplicationProvider provider,
  ) async {
    // Add null check
    if (widget.employee == null) return;

    try {
      final success = await provider.downloadJobApplicationPDF(
        widget.employee!,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Job application PDF downloaded and opened successfully!",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Failed to download job application PDF. Please try again.",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Error downloading PDF: ${e.toString()}",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
