import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../widgets/MultipleSelectDropDown/MultipleSelectDropDown.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../provider/Employee_management_Provider/Active_Provider.dart';
import 'active_employee_details_screen.dart';

class ActiveScreen extends StatefulWidget {
  const ActiveScreen({super.key});

  @override
  State<ActiveScreen> createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<ActiveScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActiveProvider>(context, listen: false).initializeEmployees();
    });
  }

  ImageProvider? _getAvatarImage(String? avatar) {
    if (avatar == null || avatar.isEmpty || avatar == 'null') return null;
    if (avatar.startsWith('http')) return NetworkImage(avatar);
    return NetworkImage('https://app.draravindsivf.com/hrms/$avatar');
  }

  @override
  Widget build(BuildContext context) {
    final activeProvider = Provider.of<ActiveProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // ════════════════════════════════════════════════════════════
          // LOADING STATE - SHOW ALL SHIMMER
          // ════════════════════════════════════════════════════════════
          if (activeProvider.isLoading && !activeProvider.initialLoadDone)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
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

                    // Grand Total Card Shimmer
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: 150,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Grid Cards Shimmer
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.2,
                      children: List.generate(4, (index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  width: 80,
                                  height: 12,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 8),
                                Container(
                                  width: 100,
                                  height: 18,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 20),

                    // Employee List Shimmer (using your CustomCardShimmer style)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                // Left bar
                                Container(
                                  width: 5,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      bottomLeft: Radius.circular(14),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                // Avatar
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12),
                                // Details
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 150,
                                          height: 16,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          width: 100,
                                          height: 14,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 6),
                                        Container(
                                          width: 120,
                                          height: 12,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                              ],
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
          if (!activeProvider.isLoading || activeProvider.initialLoadDone) ...[
            // SUMMARY CARDS SECTION
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
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
                            "Page ${activeProvider.currentPage} of ${activeProvider.totalPages}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Overall Total: ₹${activeProvider.grandTotalCTC} | Page Total: ₹${activeProvider.currentPageGrandTotal}",
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

                    // Grand Total Card
                    _buildSummaryCard(
                      title: "Grand Total",
                      value: "₹${activeProvider.currentPageGrandTotal}",
                      color1: Color(0xFFB91C7F),
                      color2: Color(0xFF9B1568),
                      icon: Icons.monetization_on,
                    ),
                    SizedBox(height: 16),

                    // Grid Cards
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.2,
                      children: [
                        _buildGridCard(
                          "Total Monthly CTC of Employees",
                          "₹${activeProvider.currentPageEmployeeCTC}",
                          Color(0xFF4A90E2),
                          Icons.people,
                        ),
                        _buildGridCard(
                          "Total Monthly CTC F11 Employees",
                          "₹${activeProvider.currentPageF11CTC}",
                          Color(0xFFFF9800),
                          Icons.business_center,
                        ),
                        _buildGridCard(
                          "Total Monthly Professional Fee",
                          "₹${activeProvider.currentPageProfessionalFee}",
                          Color(0xFF66BB6A),
                          Icons.card_giftcard,
                        ),
                        _buildGridCard(
                          "Total Monthly Student CTC",
                          "₹${activeProvider.currentPageStudentCTC}",
                          Color(0xFF9C27B0),
                          Icons.school,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // FILTER & SEARCH SECTION
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    InkWell(
                      onTap: activeProvider.toggleFilters,
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:
                              activeProvider.showFilters
                                  ? AppColor.primaryColor
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color:
                                  activeProvider.showFilters
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Filters",
                              style: TextStyle(
                                color:
                                    activeProvider.showFilters
                                        ? Colors.white
                                        : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Spacer(),
                            Icon(
                              activeProvider.showFilters
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color:
                                  activeProvider.showFilters
                                      ? Colors.white
                                      : Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: activeProvider.searchController,
                      onChanged: activeProvider.onSearchChanged,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontFamily: AppFonts.poppins),
                        hintText: "Search by name, ID...",
                        prefixIcon: Icon(Icons.search),
                        suffixIcon:
                            activeProvider.searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(Icons.clear),
                                  onPressed: activeProvider.clearSearch,
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // FILTERS DROPDOWN
            if (activeProvider.showFilters)
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (activeProvider.isLoadingFilters)
                        Center(child: CircularProgressIndicator())
                      else ...[
                        CustomSearchDropdownWithSearch(
                          labelText: "Company",
                          isMandatory: true,
                          items: activeProvider.company,
                          selectedValue: activeProvider.selectedCompany,
                          onChanged: activeProvider.setSelectedCompany,
                          hintText: "Select Company",
                        ),
                        SizedBox(height: 12),
                        MultiSelectDropdown(
                          label: "Zone",
                          items: activeProvider.zone,
                          selectedItems: activeProvider.selectedZones,
                          onChanged: activeProvider.setZones,
                        ),
                        SizedBox(height: 12),
                        MultiSelectDropdown(
                          label: "Branch",
                          items: activeProvider.branch,
                          selectedItems: activeProvider.selectedBranches,
                          onChanged: activeProvider.setBranches,
                        ),
                        SizedBox(height: 12),
                        CustomSearchDropdownWithSearch(
                          labelText: "Designation",
                          isMandatory: true,
                          items: activeProvider.designation,
                          selectedValue: activeProvider.selectedDesignation,
                          onChanged: activeProvider.setSelectedDesignation,
                          hintText: "Select Designation",
                        ),
                        SizedBox(height: 12),
                        CustomSearchDropdownWithSearch(
                          labelText: "CTC Range",
                          isMandatory: false,
                          items: activeProvider.ctc,
                          selectedValue: activeProvider.selectedCTC,
                          onChanged: activeProvider.setSelectedCTC,
                          hintText: "Select CTC Range",
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: activeProvider.clearAllFilters,
                                child: Text(
                                  "Clear",
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed:
                                    activeProvider.areAllFiltersSelected
                                        ? activeProvider.searchEmployees
                                        : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primaryColor,
                                  disabledBackgroundColor: AppColor.primaryColor
                                      .withOpacity(0.4),
                                ),
                                child:
                                    activeProvider.isLoading
                                        ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Text(
                                          "Apply Filters",
                                          style: TextStyle(
                                            fontFamily: AppFonts.poppins,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                activeProvider
                                                        .areAllFiltersSelected
                                                    ? Colors.white
                                                    : Colors
                                                        .white70, // slightly faded when disabled
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
            if (activeProvider.paginatedEmployees.isEmpty &&
                !activeProvider.isLoading &&
                activeProvider.initialLoadDone)
              SliverFillRemaining(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No employees found",
                          style: TextStyle(fontFamily: AppFonts.poppins),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ERROR STATE
            if (activeProvider.errorMessage != null &&
                !activeProvider.initialLoadDone)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(activeProvider.errorMessage ?? "Error"),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: activeProvider.fetchActiveUsers,
                        child: Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),

            // EMPLOYEE LIST
            if (activeProvider.paginatedEmployees.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          "${activeProvider.filteredEmployees.length} Employees Found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                      );
                    }
                    final user = activeProvider.paginatedEmployees[index - 1];
                    return _buildEmployeeCard(context, user);
                  }, childCount: activeProvider.paginatedEmployees.length + 1),
                ),
              ),

            // PAGINATION
            if (activeProvider.paginatedEmployees.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed:
                            activeProvider.currentPage > 1
                                ? activeProvider.previousPage
                                : null,
                        icon: Icon(Icons.chevron_left),
                      ),
                      ...List.generate(
                        activeProvider.totalPages > 5
                            ? 5
                            : activeProvider.totalPages,
                        (index) {
                          int pageNum;
                          if (activeProvider.totalPages <= 5) {
                            pageNum = index + 1;
                          } else {
                            if (activeProvider.currentPage <= 3) {
                              pageNum = index + 1;
                            } else if (activeProvider.currentPage >=
                                activeProvider.totalPages - 2) {
                              pageNum = activeProvider.totalPages - 4 + index;
                            } else {
                              pageNum = activeProvider.currentPage - 2 + index;
                            }
                          }
                          return InkWell(
                            onTap: () => activeProvider.goToPage(pageNum),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    activeProvider.currentPage == pageNum
                                        ? AppColor.primaryColor
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "$pageNum",
                                style: TextStyle(
                                  color:
                                      activeProvider.currentPage == pageNum
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
                            activeProvider.currentPage <
                                    activeProvider.totalPages
                                ? activeProvider.nextPage
                                : null,
                        icon: Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color1,
    required Color color2,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // smoother
        gradient: LinearGradient(colors: [color1, color2]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                  fontFamily: AppFonts.poppins,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: AppFonts.poppins,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.poppins,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, user) {
    final employeeId = user.employmentId ?? user.userId ?? "";
    final employeeName = user.fullname ?? user.username ?? "Unknown";

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EmployeeManagementDetailsScreen(user: user),
              ),
            );
          },
          child: Row(
            children: [
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                backgroundImage: _getAvatarImage(user.avatar),
                child:
                    _getAvatarImage(user.avatar) == null
                        ? Text(
                          employeeName.isNotEmpty
                              ? employeeName[0].toUpperCase()
                              : 'E',
                          style: TextStyle(
                            color: AppColor.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employeeName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.poppins,
                          color: AppColor.whiteColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "ID: $employeeId",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.whiteColor,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (user.designation != null &&
                                user.designation!.trim().isNotEmpty)
                            ? user.designation!
                            : "Unknown Designation",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.whiteColor,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),

                      if (user.locationName != null &&
                          user.locationName!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.locationName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.whiteColor,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
