import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/fonts/fonts.dart';
import '../../../../model/RecruitmentModel/Job_Application_Model.dart';
import '../../../../provider/RecruitmentScreensProvider/Job_Application_Provider.dart';

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

    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width, // Add this line
          child: Consumer<JobApplicationProvider>(
            builder: (context, provider, child) {
              bool isDownloading =
                  provider.isDownloading &&
                  provider.downloadingJobId == widget.employee!.jobId;

              return ElevatedButton.icon(
                onPressed:
                    isDownloading
                        ? null
                        : () async {
                          _downloadJobApplicationPDF(provider);
                        },
                icon:
                    isDownloading
                        ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Icon(Icons.visibility_outlined, size: 18),
                label: Text(
                  isDownloading ? "Downloading..." : "View Resume",
                  style: TextStyle(fontFamily: AppFonts.poppins),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDownloading ? Colors.grey : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
