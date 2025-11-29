import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Employee_management_Provider/Notice_Period_Provider.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import 'Notice_Period_details_screen.dart';

class NoticePeriodScreen extends StatefulWidget {
  const NoticePeriodScreen({super.key});

  @override
  State<NoticePeriodScreen> createState() => _NoticePeriodScreenState();
}

class _NoticePeriodScreenState extends State<NoticePeriodScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoticePeriodProvider>(
        context,
        listen: false,
      ).initializeEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final noticePeriodScreen = Provider.of<NoticePeriodProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: noticePeriodScreen.toggleFilters,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.tune,
                                      size: 20,
                                      color: const Color(0xFF475569),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Filters",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AppFonts.poppins,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      noticePeriodScreen.showFilters
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: const Color(0xFF475569),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: noticePeriodScreen.pageSize,
                                items: [5, 10, 15, 20].map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(
                                      "$e per page",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: AppFonts.poppins,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    noticePeriodScreen.setPageSize(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: noticePeriodScreen.searchController,
                          onChanged: (value) {
                            noticePeriodScreen.onSearchChanged(value);
                          },
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppFonts.poppins,
                            color: const Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            hintText: "Search employees by name, ID, designation...",
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontFamily: AppFonts.poppins,
                              color: const Color(0xFF94A3B8),
                            ),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: const Icon(
                                Icons.search_rounded,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                            ),
                            suffixIcon: noticePeriodScreen.searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      noticePeriodScreen.clearSearch();
                                    },
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      color: Color(0xFF94A3B8),
                                      size: 20,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (noticePeriodScreen.showFilters)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomSearchDropdownWithSearch(
                            labelText: "Zone",
                            items: noticePeriodScreen.zone,
                            selectedValue: noticePeriodScreen.selectedZone,
                            onChanged: noticePeriodScreen.setSelectedZone,
                            hintText: "Select Zone",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomSearchDropdownWithSearch(
                            labelText: "Branch",
                            items: noticePeriodScreen.branch,
                            selectedValue: noticePeriodScreen.selectedBranch,
                            onChanged: noticePeriodScreen.setSelectedBranch,
                            hintText: "Select Branch",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomSearchDropdownWithSearch(
                            labelText: "Designation",
                            items: noticePeriodScreen.designation,
                            selectedValue: noticePeriodScreen.selectedDesignation,
                            onChanged: noticePeriodScreen.setSelectedDesignation,
                            hintText: "Select Designation",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              noticePeriodScreen.clearAllFilters();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6B7280),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Clear",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFonts.poppins,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              noticePeriodScreen.searchEmployees();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Apply Filters",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFonts.poppins,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${noticePeriodScreen.filteredEmployees.length} Employees Found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.poppins,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  if (noticePeriodScreen.showFilters)
                    TextButton.icon(
                      onPressed: () {
                        noticePeriodScreen.toggleFilters();
                      },
                      icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                      label: Text(
                        "Hide Filters",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                      ),
                    ),
                ],
              ),
            ),
          ),
          noticePeriodScreen.isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF3B82F6),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Loading employees...",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : noticePeriodScreen.filteredEmployees.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 16),
                            Text(
                              "No employees found",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFonts.poppins,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Try adjusting your filters or search criteria",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: AppFonts.poppins,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final employee = noticePeriodScreen.filteredEmployees[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.08),
                                  spreadRadius: 0,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NoticePeriodDetailsScreen(
                                        empId: employee.employeeId,
                                        employee: employee,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Color(0xffb85a89),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Colors.white.withOpacity(0.2),
                                              backgroundImage: NetworkImage(
                                                "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face",
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    employee.name,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: AppFonts.poppins,
                                                      color: Colors.white,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "ID: ${employee.employeeId}",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: AppFonts.poppins,
                                                      color: Colors.white.withOpacity(0.8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColor.whiteColor,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue[50],
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Icon(Icons.work_outline, size: 14, color: Colors.blue[600]),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("DESIGNATION", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5)),
                                                        const SizedBox(height: 2),
                                                        Text(employee.designation, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: AppFonts.poppins, color: const Color(0xFF374151)), overflow: TextOverflow.ellipsis),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green[50],
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Icon(Icons.location_on_outlined, size: 14, color: Colors.green[600]),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("BRANCH", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[500], letterSpacing: 0.5)),
                                                        const SizedBox(height: 2),
                                                        Text(employee.branch, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: AppFonts.poppins, color: const Color(0xFF374151)), overflow: TextOverflow.ellipsis),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }, childCount: noticePeriodScreen.filteredEmployees.length),
                      ),
                    ),
        ],
      ),
    );
  }
}
