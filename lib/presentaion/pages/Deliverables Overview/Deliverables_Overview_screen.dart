import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_mobile_app/widgets/custom_botton/custom_gradient_button.dart';
import 'package:provider/provider.dart';
import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../provider/Deliverables_Overview_provider/Deliverables_Overview_provider.dart';
import '../../../widgets/custom_serach_field/custom_serach_feild.dart';
import '../../../widgets/custom_textfield/Custom_date_field.dart';
import '../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import 'add_deliverable_screen.dart';
import 'employeesdetails/employee_detailsTabs_screen.dart';

class DeliverablesOverviewScreen extends StatelessWidget {
  const DeliverablesOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deliverablesOverviewProvider =
    Provider.of<DeliverablesOverviewProvider>(context);

    return Scaffold(
      backgroundColor:
      Colors.grey[50], // Light background for professional look
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Deliverables Overview"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            /// 🔹 Top Row (fixed)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomGradientButton(
                  gradientColors: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  height: 44,
                  width: 160,
                  text: "Add Deliverable",
                  onPressed: () {
                    Get.to(() => const AddDeliverableScreen());
                  },
                ),
                _buildFilterButton(context, deliverablesOverviewProvider),
                _buildPageSizeDropdown(context, deliverablesOverviewProvider),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 Filters + Search + Employee List (scrollable)
            Expanded(
              child: ListView(
                children: [
                  if (deliverablesOverviewProvider.showFilters) ...[
                    _buildFiltersSection(deliverablesOverviewProvider),
                    const SizedBox(height: 20),
                  ],

                  /// 🔹 Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CustomSearchField(
                      controller:
                      deliverablesOverviewProvider
                          .serachFieldDateController,
                      hintText: "Search employees...",
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// 🔹 Professional Employee Cards
                  ...deliverablesOverviewProvider.employees.map((emp) {
                    return _buildProfessionalEmployeeCard(context, emp);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(
      BuildContext context,
      DeliverablesOverviewProvider provider,
      ) {
    return GestureDetector(
      onTap: () {
        provider.toggleFilters();
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.filter_list, color: Colors.grey[700], size: 18),
            const SizedBox(width: 6),
            Text(
              "Filter",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontFamily: AppFonts.poppins,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageSizeDropdown(
      BuildContext context,
      DeliverablesOverviewProvider provider,
      ) {
    return Container(
      width: MediaQuery.of(context).size.width / 4,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<int>(
          value: provider.pageSize,
          underline: const SizedBox(),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          items:
          [5, 10, 15, 20].map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(
                "$e",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontFamily: AppFonts.poppins,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              provider.setPageSize(val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFiltersSection(DeliverablesOverviewProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Filters",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              fontFamily: AppFonts.poppins,
            ),
          ),
          const SizedBox(height: 16),
          CustomSearchDropdownWithSearch(
            isMandatory: true,
            labelText: "Status",
            items: provider.status,
            selectedValue: provider.selectedstatus,
            onChanged: provider.setSelectedstatus,
            hintText: "Select Status",
          ),
          const SizedBox(height: 12),
          CustomSearchDropdownWithSearch(
            isMandatory: true,
            labelText: "Primary Location",
            items: provider.primarylocation,
            selectedValue: provider.selectedprimarylocation,
            onChanged: provider.setSelectedsprimarylocation,
            hintText: "Select location",
          ),
          const SizedBox(height: 12),
          CustomSearchDropdownWithSearch(
            isMandatory: true,
            labelText: "Date Type",
            items: provider.dateType,
            selectedValue: provider.selecteddateType,
            onChanged: (value) {
              provider.setSelectedsdateType(value);
            },
            hintText: "Select",
          ),
          const SizedBox(height: 12),
          if (provider.selecteddateType != null &&
              provider.selecteddateType!.isNotEmpty)
            CustomDateField(
              controller: provider.deliverableDateController,
              hintText: "Select date",
              labelText: "To Date",
              isMandatory: false,
            ),
          const SizedBox(height: 12),
          CustomSearchDropdownWithSearch(
            isMandatory: true,
            labelText: "Assigned Staff",
            items: provider.dateType,
            selectedValue: provider.selecteddateType,
            onChanged: (value) {
              provider.setSelectedsdateType(value);
            },
            hintText: "Select",
          ),
          const SizedBox(height: 12),
          CustomSearchDropdownWithSearch(
            isMandatory: true,
            labelText: "Job Title",
            items: provider.dateType,
            selectedValue: provider.selecteddateType,
            onChanged: (value) {
              provider.setSelectedsdateType(value);
            },
            hintText: "Select",
          ),
          const SizedBox(height: 12),
          if (provider.selecteddateType != null &&
              provider.selecteddateType!.isNotEmpty)
            CustomDateField(
              controller: provider.deliverableDateController,
              hintText: "Select date",
              labelText: "From Date",
              isMandatory: false,
            ),
        ],
      ),
    );
  }

  Widget _buildProfessionalEmployeeCard(
      BuildContext context,
      Map<String, dynamic> emp,
      ) {
    final empId = (emp["empId"] ?? "").toString();
    final String empPhoto = (emp["photo"] as String?) ?? "";
    final String empName = (emp["name"] as String?) ?? "N/A";
    final String empDesignation = (emp["designation"] as String?) ?? "N/A";
    final String empBranch = (emp["branch"] as String?) ?? "N/A";
    final String empTasks = (emp["task"] ?? "0").toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => EmployeeDetailsScreen(
                  empId: empId,
                  empPhoto: empPhoto,
                  empName: empName,
                  empDesignation: empDesignation,
                  empBranch: empBranch,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Professional Avatar with status indicator
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue[100]!, Colors.blue[50]!],
                        ),
                      ),
                      child:
                      empPhoto.isNotEmpty
                          ? Image.network(
                        empPhoto,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                            _buildDefaultAvatar(empName),
                      )
                          : _buildDefaultAvatar(empName),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Employee Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name with professional styling
                      Text(
                        empName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A365D),
                          fontFamily: AppFonts.poppins,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Designation with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.work_outline,
                              size: 14,
                              color: Colors.blue[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              empDesignation,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                                fontFamily: AppFonts.poppins,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Branch with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.green[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              empBranch,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                                fontFamily: AppFonts.poppins,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tasks count with professional badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange[400]!,
                                  Colors.orange[500]!,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "$empTasks Tasks",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String empName) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[400]!, Colors.blue[600]!],
        ),
      ),
      child: Center(
        child: Text(
          empName.isNotEmpty ? empName[0].toUpperCase() : "U",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ),
    );
  }
}