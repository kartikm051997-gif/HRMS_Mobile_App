import 'package:flutter/Material.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/All_Employees_Provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/components/appbar/appbar.dart';
import '../../../../core/components/drawer/drawer.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../model/Employee_management/Employee_management.dart';

class AllEmployeeDetailsScreens extends StatelessWidget {
  final String empId;
  final Employee employee;
  const AllEmployeeDetailsScreens({
    super.key,
    required this.empId,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Employee Details"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Employee Header Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0A000000),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Employee Photo and Basic Info
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                          ),
                        ),
                        child: ClipOval(
                          child:
                              employee.photoUrl != null &&
                                      employee.photoUrl!.isNotEmpty
                                  ? Image.network(
                                    employee.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar(employee.name);
                                    },
                                  )
                                  : _buildDefaultAvatar(employee.name),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppFonts.poppins,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "ID: ${employee.employeeId}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFonts.poppins,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              employee.designation,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFonts.poppins,
                                color: const Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Status and Action Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Active",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.poppins,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Change Status Button
                      ElevatedButton.icon(
                        onPressed: () => _showChangeStatusDialog(context),
                        icon: const Icon(Icons.edit, size: 18),
                        label: Text(
                          "Change Status",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Employee Details Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0A000000),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Professional Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.poppins,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    "Department",
                    employee.department,
                    Icons.business,
                  ),
                  _buildDetailRow("Branch", employee.branch, Icons.location_on),
                  _buildDetailRow("DOJ", employee.doj, Icons.calendar_today),

                  _buildDetailRow(
                    "Payroll Category",
                    employee.payrollCategory,
                    Icons.category,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Team Information Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0A000000),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Team Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.poppins,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recruiter Info
                  _buildTeamMemberCard(
                    "Recruiter",
                    employee.recruiterName ?? "Not assigned",
                    employee.recruiterPhotoUrl,
                    Icons.person_search,
                  ),

                  const SizedBox(height: 16),

                  // Created By Info
                  _buildTeamMemberCard(
                    "Created By",
                    employee.createdByName ?? "Unknown",
                    employee.createdByPhotoUrl,
                    Icons.person_add,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showChangeStatusDialog(BuildContext context) {
    String selectedStatus = "InActive";
    DateTime? selectedDate;
    final TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    "Change Status",
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Type: *",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Radio buttons
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: Text(
                              "InActive",
                              style: TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 14,
                              ),
                            ),
                            value: "InActive",
                            groupValue: selectedStatus,
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                          RadioListTile<String>(
                            title: Text(
                              "Abscond",
                              style: TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 14,
                              ),
                            ),
                            value: "Abscond",
                            groupValue: selectedStatus,
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                          RadioListTile<String>(
                            title: Text(
                              "Notice Period",
                              style: TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 14,
                              ),
                            ),
                            value: "Notice Period",
                            groupValue: selectedStatus,
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Last Date: *",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Date picker field
                      TextFormField(
                        controller: dateController,
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                              dateController.text =
                                  "${picked.day}/${picked.month}/${picked.year}";
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Select Date",
                          hintStyle: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 14,
                            color: const Color(0xFF9CA3AF),
                          ),
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD1D5DB),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedDate != null) {
                          Navigator.pop(context);
                          _updateEmployeeStatus(
                            context,
                            selectedStatus,
                            selectedDate!,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Update",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _updateEmployeeStatus(
    BuildContext context,
    String status,
    DateTime date,
  ) {
    final provider = Provider.of<AllEmployeesProvider>(context, listen: false);
    provider.updateEmployeeStatus(employee.employeeId, status, date).then((
      success,
    ) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Employee status updated successfully",
              style: TextStyle(fontFamily: AppFonts.poppins),
            ),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to update employee status",
              style: TextStyle(fontFamily: AppFonts.poppins),
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    });
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "E",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.poppins,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard(
    String role,
    String name,
    String? photoUrl,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE2E8F0),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: ClipOval(
              child:
                  photoUrl != null && photoUrl.isNotEmpty
                      ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildSmallDefaultAvatar(name);
                        },
                      )
                      : _buildSmallDefaultAvatar(name),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.poppins,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF64748B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDefaultAvatar(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF64748B), Color(0xFF475569)],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ),
    );
  }
}
