import 'package:flutter/Material.dart';
import 'package:provider/provider.dart';
import '../../../../core/components/appbar/appbar.dart';
import '../../../../core/components/drawer/drawer.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/RecruitmentScreensProviders/Resume_Management_Provider.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import 'ResumeMangaement_details_Screen.dart';

class ResumeManagementScreens extends StatefulWidget {
  const ResumeManagementScreens({super.key});

  @override
  State<ResumeManagementScreens> createState() =>
      _ResumemanagementscreensState();
}

class _ResumemanagementscreensState extends State<ResumeManagementScreens>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Initialize employee data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ResumeManagementProvider>(
        context,
        listen: false,
      ).initializeEmployees();
      _listAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resumeManagementProvider = Provider.of<ResumeManagementProvider>(
      context,
    );
    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Resume Management"),
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Header Section - Fixed header
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
                      // Filter Toggle and Page Size Row
                      Row(
                        children: [
                          // Filter Toggle
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8E0E6B),
                                    Color(0xFFD4145A),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF8E0E6B,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap:
                                  resumeManagementProvider
                                      .toggleFilters,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.tune,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Filters",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: AppFonts.poppins,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          resumeManagementProvider
                                              .showFilters
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Page Size Dropdown
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
                                value: resumeManagementProvider.pageSize,
                                items:
                                    [5, 10, 15, 20].map((e) {
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
                                    resumeManagementProvider.setPageSize(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Field
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
                          controller: resumeManagementProvider.searchController,
                          onChanged: (value) {
                            resumeManagementProvider.onSearchChanged(value);
                          },
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppFonts.poppins,
                            color: const Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            hintText:
                                "Search employees by name, ID, designation...",
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
                            suffixIcon:
                                resumeManagementProvider
                                        .searchController
                                        .text
                                        .isNotEmpty
                                    ? IconButton(
                                      onPressed: () {
                                        resumeManagementProvider.clearSearch();
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

          // Filter Section - Only shows when expanded
          if (resumeManagementProvider.showFilters)
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // First Row - Company and Zone
                    Row(
                      children: [
                        Expanded(
                          child: CustomSearchDropdownWithSearch(
                            labelText: "Primary Branch ",
                            items: resumeManagementProvider.primaryBranch,
                            selectedValue:
                                resumeManagementProvider.selectedPrimaryBranch,
                            onChanged:
                                resumeManagementProvider
                                    .setSelectedPrimaryBranch,
                            hintText: "Select Primary Branch ",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Second Row - Branch and Designation
                    Row(
                      children: [
                        Expanded(
                          child: CustomSearchDropdownWithSearch(
                            labelText: "Job Title ",
                            items: resumeManagementProvider.jobTitle,
                            selectedValue:
                                resumeManagementProvider.selectedJobTitle,
                            onChanged:
                                resumeManagementProvider.setSelectedJobTitle,
                            hintText: "Select Branch",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomSearchDropdownWithSearch(
                            labelText: "Designation",
                            items: resumeManagementProvider.uploadedBy,
                            selectedValue:
                                resumeManagementProvider.selectedUploadedBy,
                            onChanged:
                                resumeManagementProvider.setSelectedUploadedBy,
                            hintText: "Select Designation",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Go and Clear Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              resumeManagementProvider
                                  .clearAllFilters(); // You'll need to implement this
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
                          child: Container(
                            decoration: BoxDecoration(
                              gradient:
                              resumeManagementProvider
                                  .areAllFiltersSelected
                                  ? const LinearGradient(
                                colors: [
                                  Color(0xFF8E0E6B),
                                  Color(0xFFD4145A),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                                  : null,
                              color:
                              resumeManagementProvider
                                  .areAllFiltersSelected
                                  ? null
                                  : Colors.grey[400],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow:
                              resumeManagementProvider
                                  .areAllFiltersSelected
                                  ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF8E0E6B,
                                  ).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                                  : null,
                            ),
                            child: ElevatedButton(
                              onPressed:
                              resumeManagementProvider
                                  .areAllFiltersSelected
                                  ? () {
                                resumeManagementProvider
                                    .searchEmployees();
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                disabledBackgroundColor: Colors.transparent,
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Employee Count Header - Only show if filters are applied
          if (resumeManagementProvider.hasAppliedFilters)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${resumeManagementProvider.filteredEmployees.length} Employees Found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    // Optional: Add a collapse filters button here
                    if (resumeManagementProvider.showFilters)
                      TextButton.icon(
                        onPressed: () {
                          resumeManagementProvider.toggleFilters();
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

          // Employee List - Only show if filters are applied
          if (resumeManagementProvider.hasAppliedFilters)
            resumeManagementProvider.isLoading
                ? const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: const Color(0xFF8E0E6B),
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
                : resumeManagementProvider.filteredEmployees.isEmpty
                ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: const Color(0xFF8E0E6B).withOpacity(0.3),
                        ),
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final employee =
                            resumeManagementProvider.filteredEmployees[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 400 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: Transform.scale(
                                  scale: 0.95 + (0.05 * value),
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8E0E6B).withOpacity(0.15),
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => ResumeManagementDetailsScreen(
                                            cvId: employee.cvId,
                                            employee: employee,
                                          ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    // Top Half - Purple Gradient Section
                                    Container(
                                      width: double.infinity,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF8E0E6B),
                                            Color(0xFFD4145A),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF8E0E6B)
                                                .withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            // Employee Name and ID
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                    "CVID: ${employee.cvId}",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: AppFonts.poppins,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Arrow Icon
                                            const Icon(
                                              Icons.chevron_right,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Bottom Half - White Section
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColor.whiteColor,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                // Designation Section
                                                Expanded(
                                                  flex: 3,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.blue[50],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons.work_outline,
                                                          size: 14,
                                                          color: Colors.blue[600],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "job Title",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight.w600,
                                                                color:
                                                                    Colors.grey[500],
                                                                letterSpacing: 0.5,
                                                                fontFamily:
                                                                    AppFonts.poppins,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Text(
                                                              employee.jobTitle,
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight.w500,
                                                                fontFamily:
                                                                    AppFonts.poppins,
                                                                color: const Color(
                                                                  0xFF374151,
                                                                ),
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Branch Section
                                                Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.all(4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green[50],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 14,
                                                          color: Colors.green[600],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),

                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "primary Location",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight.w600,
                                                                color:
                                                                    Colors.grey[500],
                                                                letterSpacing: 0.5,
                                                                fontFamily:
                                                                    AppFonts.poppins,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Text(
                                                              employee
                                                                  .primaryLocation,
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight.w500,
                                                                fontFamily:
                                                                    AppFonts.poppins,
                                                                color: const Color(
                                                                  0xFF374151,
                                                                ),
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              height: 40,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    const Color(0xFF8E0E6B)
                                                        .withOpacity(0.1),
                                                    const Color(0xFFD4145A)
                                                        .withOpacity(0.1),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                  12,
                                                ),
                                                border: Border.all(
                                                  color: const Color(0xFF8E0E6B)
                                                      .withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.phone_outlined,
                                                    color: const Color(0xFF8E0E6B),
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    employee.phone,
                                                    style: TextStyle(
                                                      color: const Color(0xFF8E0E6B),
                                                      fontFamily: AppFonts.poppins,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
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
                          ),
                        );
                      },
                      childCount:
                          resumeManagementProvider.filteredEmployees.length,
                    ),
                  ),
                )
          // Show message when no filters are applied
          else
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.filter_list_outlined,
                      size: 80,
                      color: const Color(0xFF8E0E6B).withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Select all filters to view resumes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                        color: const Color(0xFF8E0E6B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Please select Primary Branch, Job Title, and\nDesignation, then click 'Apply Filters'",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppFonts.poppins,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
