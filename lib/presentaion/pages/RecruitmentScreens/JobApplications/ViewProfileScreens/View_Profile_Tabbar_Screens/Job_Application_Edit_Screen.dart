import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:provider/provider.dart';

import '../../../../../../provider/RecruitmentScreensProviders/Job_Applocation_Edit_Provider.dart';
import '../../../../../../core/fonts/fonts.dart';

class JobApplicationEditScreen extends StatefulWidget {
  final String jobId;

  const JobApplicationEditScreen({super.key, required this.jobId});

  @override
  State<JobApplicationEditScreen> createState() =>
      _JobApplicationEditScreenState();
}

class _JobApplicationEditScreenState extends State<JobApplicationEditScreen> {
  String? selectedAssignee;
  List<String> assigneeList = [
    "Durga Prakash - 10876",
    "Karthick - 7866",
    "Abi - 8764",
    "Viki - 8754",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<JobApplicationEditProvider>();
      provider.initializeEmployees();
      provider.loadJobApplication(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<JobApplicationEditProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor2),
            );
          }

          if (provider.currentJobApplication == null) {
            return Center(
              child: Text(
                'Job application not found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: AppFonts.poppins,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildJobApplicationCard(provider),
                const SizedBox(height: 16),
                _buildActionButtons(provider),
                const SizedBox(height: 24),
                _buildDetailsSection(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobApplicationCard(JobApplicationEditProvider provider) {
    final jobApp = provider.currentJobApplication!;

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Text(
                    jobApp.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobApp.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Job ID: ${jobApp.jobId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoGrid(jobApp, provider),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(jobApp, JobApplicationEditProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInfoItem('Job Title:', jobApp.jobTitle)),
            Expanded(child: _buildInfoItem('Experience:', '0')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                'Primary Location:',
                jobApp.primaryLocation,
              ),
            ),
            Expanded(child: _buildInfoItem('Applied On:', jobApp.createdDate)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem('Interview Date:', jobApp.interviewDate),
            ),
            Expanded(
              child: _buildInfoItem(
                'Assigned:',
                provider.selectedAssignee ?? '-',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        provider.selectedStatus,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(provider.selectedStatus),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      provider.selectedStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(provider.selectedStatus),
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Access:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontFamily: AppFonts.poppins,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(JobApplicationEditProvider provider) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Action',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: AppFonts.poppins,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatusButton(provider)),
              const SizedBox(width: 12),
              Expanded(child: _buildAssignButton(provider)),
              const SizedBox(width: 12),
              _buildDownloadButton(provider),
              const SizedBox(width: 12),
              _buildHistoryButton(provider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(JobApplicationEditProvider provider) {
    return Container(
      height: 45,
      child: ElevatedButton.icon(
        onPressed:
            provider.isUpdatingStatus
                ? null
                : () => _showStatusDialog(provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon:
            provider.isUpdatingStatus
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.check_circle, size: 18),
        label: const Text(
          'Status',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ),
    );
  }

  Widget _buildAssignButton(JobApplicationEditProvider provider) {
    return Container(
      height: 45,
      child: ElevatedButton.icon(
        onPressed:
            provider.isAssigning ? null : () => _showAssignDialog(provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon:
            provider.isAssigning
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.assignment_ind, size: 18),
        label: const Text(
          'Assign',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadButton(JobApplicationEditProvider provider) {
    return Container(
      height: 45,
      width: 45,
      child: ElevatedButton(
        onPressed:
            provider.isDownloading
                ? null
                : () => provider.downloadJobApplicationPDF(
                  provider.currentJobApplication!,
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            provider.isDownloading
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.download, size: 18),
      ),
    );
  }

  Widget _buildDetailsSection(JobApplicationEditProvider provider) {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: AppFonts.poppins,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Phone Number:',
            provider.currentJobApplication!.phone,
          ),
          _buildDetailRow('Uploaded By:', 'HR Team'),
          _buildDetailRow(
            'Created Date:',
            provider.currentJobApplication!.createdDate,
          ),
          if (provider.currentJobApplication!.joiningDate.isNotEmpty)
            _buildDetailRow(
              'Joining Date:',
              provider.currentJobApplication!.joiningDate,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.poppins,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,

                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.poppins,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'unread':
        return Colors.orange;
      case 'call for interview':
        return Colors.blue;
      case 'selected':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in progress':
        return Colors.purple;
      case 'completed':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _showStatusDialog(JobApplicationEditProvider provider) {
    final descController = TextEditingController();
    String selectedStatus = provider.selectedStatus;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Change Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          provider.jobStatus
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter description',
                        hintStyle: TextStyle(fontFamily: AppFonts.poppins),
                        contentPadding: EdgeInsets.all(12),
                      ),
                      style: const TextStyle(fontFamily: AppFonts.poppins),
                    ),
                  ],
                ),
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
                  onPressed: () async {
                    if (descController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill out description.',
                            style: TextStyle(fontFamily: AppFonts.poppins),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    final success = await provider.updateJobApplicationStatus(
                      provider.currentJobApplication!.jobId,
                      selectedStatus,
                    );

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Status updated to $selectedStatus',
                            style: const TextStyle(
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffa14f79),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(fontFamily: AppFonts.poppins),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAssignDialog(JobApplicationEditProvider provider) {
    String? tempSelectedAssignee = selectedAssignee;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
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
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Assign to *",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: InputBorder.none,
                        ),
                        hint: const Text(
                          "Select",
                          style: TextStyle(fontFamily: AppFonts.poppins),
                        ),
                        value: tempSelectedAssignee,
                        items:
                            assigneeList.map((String assignee) {
                              return DropdownMenuItem<String>(
                                value: assignee,
                                child: Text(
                                  assignee,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            tempSelectedAssignee = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(fontFamily: AppFonts.poppins),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            if (tempSelectedAssignee != null) {
                              Navigator.of(context).pop();

                              final success = await provider
                                  .assignJobApplication(
                                    provider.currentJobApplication!.jobId,
                                    tempSelectedAssignee!,
                                  );

                              if (success && mounted) {
                                setState(() {
                                  selectedAssignee = tempSelectedAssignee;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Assigned to $tempSelectedAssignee",
                                      style: const TextStyle(
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                    backgroundColor: Colors.blue,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffa14f79),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
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
      },
    );
  }

  void _showHistoryDialog(JobApplicationEditProvider provider) {
    final history = provider.getJobApplicationHistory();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Application History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 300,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: history.length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 20),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(item['status']!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item['action']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'By: ${item['user']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                                Text(
                                  item['date']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(fontFamily: AppFonts.poppins),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistoryButton(JobApplicationEditProvider provider) {
    return Container(
      height: 45,
      width: 45,
      child: ElevatedButton(
        onPressed: () => _showHistoryDialog(provider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Icon(Icons.history, size: 18),
      ),
    );
  }
}
