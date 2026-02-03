import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/model/Employee_management/InActiveUserListModelClass.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../widgets/MultipleSelectDropDown/MultipleSelectDropDown.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../provider/Employee_management_Provider/InActiveProvider.dart';
import 'InActiveDetailsScreen.dart';

class InActiveScreen extends StatefulWidget {
  const InActiveScreen({super.key});

  @override
  State<InActiveScreen> createState() => _InActiveScreenState();
}

class _InActiveScreenState extends State<InActiveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InActiveProvider>(
        context,
        listen: false,
      ).initializeEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final inActiveProvider = Provider.of<InActiveProvider>(context);
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Shimmer during initial load (same concept as Active screen)
          if (inActiveProvider.isLoading && !inActiveProvider.initialLoadDone)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Page Info Shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 16,
                              width: 150,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 14,
                              width: 250,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // List Shimmer
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Name
                                        Container(
                                          width: 150,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // ID Badge
                                        Container(
                                          width: 80,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Designation Row
                                        Row(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              width: 100,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        // Location Row
                                        Row(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              width: 120,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Arrow Icon
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

          // ════════════════════════════════════════════════════════════
          // ACTUAL CONTENT (When Data Loaded)
          // ════════════════════════════════════════════════════════════
          if (!inActiveProvider.isLoading ||
              inActiveProvider.initialLoadDone) ...[
            // SUMMARY CARDS SECTION
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Page info
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Page ${inActiveProvider.currentPage} of ${inActiveProvider.totalPages}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Total Inactive Employees: ${inActiveProvider.filteredEmployees.length}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // FILTER & SEARCH SECTION
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    InkWell(
                      onTap: inActiveProvider.toggleFilters,
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              inActiveProvider.showFilters
                                  ? AppColor.primaryColor
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color:
                                  inActiveProvider.showFilters
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Filters",
                              style: TextStyle(
                                color:
                                    inActiveProvider.showFilters
                                        ? Colors.white
                                        : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              inActiveProvider.showFilters
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color:
                                  inActiveProvider.showFilters
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      style: TextStyle(fontFamily: AppFonts.poppins),
                      controller: inActiveProvider.searchController,
                      onChanged: inActiveProvider.onSearchChanged,
                      onSubmitted: (value) {
                        // Immediate search on Enter - show matching cards
                        inActiveProvider.performSearchWithQuery(value);
                      },
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontFamily: AppFonts.poppins),
                        hintText: "Search by name, ID...",
                        prefixIcon: Icon(Icons.search),
                        suffixIcon:
                            inActiveProvider.searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: inActiveProvider.clearSearch,
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // FILTERS DROPDOWN
            if (inActiveProvider.showFilters)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (inActiveProvider.isLoadingFilters)
                        Center(child: CircularProgressIndicator())
                      else ...[
                        CustomSearchDropdownWithSearch(
                          labelText: "Zone *",
                          isMandatory: true,
                          items: inActiveProvider.zone,
                          selectedValue: inActiveProvider.selectedZone,
                          onChanged: inActiveProvider.setSelectedZone,
                          hintText: "Select Zone",
                        ),

                        SizedBox(height: 12),

                        MultiSelectDropdown(
                          label: "Branch",
                          items: inActiveProvider.branch,
                          selectedItems: inActiveProvider.selectedBranches,
                          onChanged: inActiveProvider.setSelectedBranches,
                          zoneEnableSelectAll: true,

                        ),

                        SizedBox(height: 12),
                        MultiSelectDropdown(
                          label: "Designation",
                          items: inActiveProvider.designation,
                          selectedItems: inActiveProvider.selectedDesignations,
                          onChanged: inActiveProvider.setSelectedDesignations,
                          designationEnableSelectAll: true,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            // Clear Button
                            Expanded(
                              child: InkWell(
                                onTap: inActiveProvider.clearAllFilters,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.clear_all,
                                        size: 18,
                                        color: Colors.grey[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Clear",
                                        style: TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Apply Filters Button
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap:
                                    inActiveProvider.areAllFiltersSelected
                                        ? inActiveProvider.searchEmployees
                                        : null,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient:
                                        inActiveProvider.areAllFiltersSelected
                                            ? const LinearGradient(
                                              colors: [
                                                Color(0xFF8E0E6B),
                                                Color(0xFFD4145A),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            )
                                            : null,
                                    color:
                                        inActiveProvider.areAllFiltersSelected
                                            ? null
                                            : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow:
                                        inActiveProvider.areAllFiltersSelected
                                            ? [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF8E0E6B,
                                                ).withOpacity(0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                            : [],
                                  ),
                                  child: Center(
                                    child:
                                        inActiveProvider.isLoading
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.filter_alt,
                                                  size: 18,
                                                  color:
                                                      inActiveProvider
                                                              .areAllFiltersSelected
                                                          ? Colors.white
                                                          : Colors.grey[600],
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Apply Filters",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppFonts.poppins,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        inActiveProvider
                                                                .areAllFiltersSelected
                                                            ? Colors.white
                                                            : Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // EMPTY STATE
            if (inActiveProvider.paginatedEmployees.isEmpty &&
                !inActiveProvider.isLoading &&
                inActiveProvider.initialLoadDone)
              SliverFillRemaining(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No inactive employees found",
                          style: TextStyle(fontFamily: AppFonts.poppins),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ERROR STATE
            if (inActiveProvider.errorMessage != null &&
                !inActiveProvider.initialLoadDone)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(inActiveProvider.errorMessage ?? "Error"),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: inActiveProvider.fetchInActiveUsers,
                        child: Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),

            // EMPLOYEE LIST
            if (inActiveProvider.paginatedEmployees.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "${inActiveProvider.filteredEmployees.length} Inactive Employees Found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                      );
                    }
                    final user = inActiveProvider.paginatedEmployees[index - 1];
                    return _buildEmployeeCard(context, user);
                  }, childCount: inActiveProvider.paginatedEmployees.length + 1),
                ),
              ),

            // PAGINATION
            if (inActiveProvider.paginatedEmployees.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed:
                            inActiveProvider.currentPage > 1
                                ? inActiveProvider.previousPage
                                : null,
                        icon: Icon(Icons.chevron_left),
                      ),
                      ...List.generate(
                        inActiveProvider.totalPages > 5
                            ? 5
                            : inActiveProvider.totalPages,
                        (index) {
                          int pageNum;
                          if (inActiveProvider.totalPages <= 5) {
                            pageNum = index + 1;
                          } else {
                            if (inActiveProvider.currentPage <= 3) {
                              pageNum = index + 1;
                            } else if (inActiveProvider.currentPage >=
                                inActiveProvider.totalPages - 2) {
                              pageNum = inActiveProvider.totalPages - 4 + index;
                            } else {
                              pageNum =
                                  inActiveProvider.currentPage - 2 + index;
                            }
                          }
                          return InkWell(
                            onTap: () => inActiveProvider.goToPage(pageNum),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    inActiveProvider.currentPage == pageNum
                                        ? AppColor.primaryColor
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "$pageNum",
                                style: TextStyle(
                                  color:
                                      inActiveProvider.currentPage == pageNum
                                          ? Colors.white
                                          : Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        onPressed:
                            inActiveProvider.currentPage <
                                    inActiveProvider.totalPages
                                ? inActiveProvider.nextPage
                                : null,
                        icon: Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: 35), // Bottom spacing
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, InActiveUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                      (_) => InActiveDetailsScreen(
                        empId: user.employmentId ?? user.userId ?? '',
                        employee: user,
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF8E0E6B).withOpacity(0.1),
                    backgroundImage:
                        (user.avatar != null && user.avatar!.isNotEmpty)
                            ? NetworkImage(user.avatar!)
                            : null,
                    child:
                        (user.avatar == null || user.avatar!.isEmpty)
                            ? Text(
                              (user.fullname ?? user.username ?? 'E')[0]
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF8E0E6B),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 14),

                  // Employee Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          user.fullname ?? 'Employee',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                            fontFamily: AppFonts.poppins,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Employee ID
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8E0E6B).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "ECI ID: ${user.employmentId ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8E0E6B),
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Designation
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.work_outline,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                user.designation?.trim().isNotEmpty == true
                                    ? user.designation!
                                    : "Unknown Designation",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontFamily: AppFonts.poppins,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // Branch/Location
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                (user.locationName ?? user.location ?? '')
                                        .trim()
                                        .isNotEmpty
                                    ? (user.locationName ?? user.location ?? '')
                                    : "Unknown Branch",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontFamily: AppFonts.poppins,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // Relieving Date (if available)
                        if (user.relievingDate != null &&
                            user.relievingDate!.isNotEmpty)
                          const SizedBox(height: 4),
                        if (user.relievingDate != null &&
                            user.relievingDate!.isNotEmpty)
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: Colors.red[600],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Relieved: ${user.relievingDate}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red[700],
                                    fontFamily: AppFonts.poppins,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
