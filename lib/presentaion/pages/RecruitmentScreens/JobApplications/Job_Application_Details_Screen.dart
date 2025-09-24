import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:hrms_mobile_app/model/RecruitmentModel/Job_Application_Model.dart';
import 'package:provider/provider.dart';
import '../../../../core/components/appbar/appbar.dart';
import '../../../../core/components/drawer/drawer.dart';
import '../../../../provider/RecruitmentScreensProvider/Job_Application_Provider.dart';

class JobApplicationDetailsScreen extends StatefulWidget {
  final String jobId;
  final JobApplicationModel employee;

  const JobApplicationDetailsScreen({
    super.key,
    required this.jobId,
    required this.employee,
  });

  @override
  State<JobApplicationDetailsScreen> createState() =>
      _JobApplicationDetailsScreenState();
}

class _JobApplicationDetailsScreenState
    extends State<JobApplicationDetailsScreen> {
  String? selectedAssignee;
  bool showAssignDialog = false;

  // Sample assignee list - replace with your actual data
  final List<String> assigneeList = [
    "Durga Prakash",
    "S.Madhumitha",
    "M.Sneha",
    "DIVYAA AMALANATHAN",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Job Application"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Card
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
                  // Top Purple Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xffa14f79),
                      borderRadius: BorderRadius.only(
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
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: NetworkImage(
                              "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face",
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            widget.employee.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "JobId: ${widget.employee.jobId}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom White Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Job Title
                        _buildDetailRow(
                          Icons.work_outline,
                          "Job Title",
                          widget.employee.jobTitle,
                          Colors.blue,
                        ),
                        SizedBox(height: 16),

                        // Primary Location
                        _buildDetailRow(
                          Icons.location_on_outlined,
                          "Primary Location",
                          widget.employee.primaryLocation,
                          Colors.green,
                        ),
                        SizedBox(height: 16),

                        // Phone Number
                        _buildDetailRow(
                          Icons.phone_outlined,
                          "Phone",
                          widget.employee.phone,
                          Colors.orange,
                        ),
                        SizedBox(height: 20),

                        // Status Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Unread",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showStatusDialog(context);
                    },
                    icon: Icon(Icons.info_outline, size: 18),
                    label: Text(
                      "Status",
                      style: TextStyle(fontFamily: AppFonts.poppins),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAssignDialog();
                    },
                    icon: Icon(Icons.assignment_ind, size: 18),
                    label: Text(
                      "Assign",
                      style: TextStyle(fontFamily: AppFonts.poppins),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffa14f79),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: Consumer<JobApplicationProvider>(
                    builder: (context, provider, child) {
                      bool isDownloading =
                          provider.isDownloading &&
                          provider.downloadingJobId == widget.employee.jobId;

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
                          backgroundColor:
                              isDownloading ? Colors.grey : Colors.blue,
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
            ),

            SizedBox(height: 20),

            // Additional Information Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Application Information",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow("Applied on", "24/09/2025"),
                  _buildInfoRow("Interview Date", "-"),
                  _buildInfoRow("Joining Date", "-"),
                  _buildInfoRow("Total no .Of Experience", "-"),
                  _buildAccessRow(),
                  _buildInfoRow("Remark", "-"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadJobApplicationPDF(
    JobApplicationProvider provider,
  ) async {
    try {
      final success = await provider.downloadJobApplicationPDF(widget.employee);

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

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        SizedBox(width: 12),
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
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: AppFonts.poppins,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
              fontFamily: AppFonts.poppins,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        // optional background/border if you like:
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Access',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 40,
              width: 140,
              child: Stack(
                children: List.generate(4, (index) {
                  return Positioned(
                    left: index * 24,
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Assign",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Text(
                  "Assign to *",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    fontFamily: AppFonts.poppins,
                  ),
                ),

                SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: InputBorder.none,
                    ),
                    hint: Text(
                      "Select",
                      style: TextStyle(fontFamily: AppFonts.poppins),
                    ),
                    value: selectedAssignee,
                    items:
                        assigneeList.map((String assignee) {
                          return DropdownMenuItem<String>(
                            value: assignee,
                            child: Text(assignee),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAssignee = newValue;
                      });
                    },
                  ),
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontFamily: AppFonts.poppins),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedAssignee != null) {
                          // Handle assignment logic here
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Assigned to $selectedAssignee"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffa14f79),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        "Assign",
                        style: TextStyle(fontFamily: AppFonts.poppins),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    Widget buildAccessImages(List<String> imageUrls) {
      return SizedBox(
        height: 36,
        child: Stack(
          children: List.generate(imageUrls.length, (index) {
            return Positioned(
              left: index * 28.0, // overlap by reducing this value
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(imageUrls[index]),
                ),
              ),
            );
          }),
        ),
      );
    }
  }

  void _showStatusDialog(BuildContext context) {
    final _descController = TextEditingController();
    String _selectedStatus = 'Unread';
    final List<String> statusList = ['Unread', 'In Progress', 'Completed'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Change Status',
            style: TextStyle(fontFamily: AppFonts.poppins),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status *',
                      style: TextStyle(fontFamily: AppFonts.poppins),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items:
                          statusList
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description *',
                      style: TextStyle(fontFamily: AppFonts.poppins),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter description',
                        hintStyle: TextStyle(fontFamily: AppFonts.poppins),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: AppFonts.poppins),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_descController.text.trim().isEmpty) {
                  // Simple validation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please fill out description.',
                        style: TextStyle(fontFamily: AppFonts.poppins),
                      ),
                    ),
                  );
                  return;
                }
                // Handle update logic here
                Navigator.pop(context);
              },
              child: const Text(
                'Update',
                style: TextStyle(fontFamily: AppFonts.poppins),
              ),
            ),
          ],
        );
      },
    );
  }
}
