import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../model/Employee_management/Employee_management.dart';
import '../../../../widgets/custom_textfield/Custom_date_field.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../provider/Employee_management_Provider/Active_Provider.dart';
import '../../Deliverables Overview/employeesdetails/employee_detailsTabs_screen.dart';
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
    // Initialize employee data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActiveProvider>(context, listen: false).initializeEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeProvider = Provider.of<ActiveProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildFilterToggle(activeProvider)),
                        const SizedBox(width: 16),
                        _buildPageSizeDropdown(context, activeProvider),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildSearchField(activeProvider),
                  ],
                ),
              ),
            ),

            // Filter Section
            if (activeProvider.showFilters)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 16),
                      _buildFiltersGrid(activeProvider),
                      const SizedBox(height: 16),
                      _buildSearchButton(activeProvider),
                    ],
                  ),
                ),
              ),

            // Employee List Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildListHeader(activeProvider),
              ),
            ),

            // Employee List
            _buildEmployeeSliverList(activeProvider),
          ],
        ),
      ),
    );
  }
}

Widget _buildSearchField(ActiveProvider activeProvider) {
  return Container(
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
      controller: activeProvider.searchController,
      onChanged: (value) {
        activeProvider.onSearchChanged(value);
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
        suffixIcon:
        activeProvider.searchController.text.isNotEmpty
            ? IconButton(
          onPressed: () {
            activeProvider.clearSearch();
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
  );
}

Widget _buildFilterToggle(ActiveProvider activeProvider) {
  return InkWell(
    onTap: activeProvider.toggleFilters,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(Icons.tune, size: 20, color: const Color(0xFF475569)),
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
            activeProvider.showFilters ? Icons.expand_less : Icons.expand_more,
            color: const Color(0xFF475569),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPageSizeDropdown(
    BuildContext context,
    ActiveProvider activeProvider,
    ) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: activeProvider.pageSize,
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
            activeProvider.setPageSize(val);
          }
        },
      ),
    ),
  );
}

Widget _buildFiltersGrid(ActiveProvider activeProvider) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Expanded(
            child: CustomSearchDropdownWithSearch(
              labelText: "Company",
              items: activeProvider.company,
              selectedValue: activeProvider.selectedCompany,
              onChanged: activeProvider.setSelectedCompany,
              hintText: "Select Company",
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomSearchDropdownWithSearch(
              labelText: "Zone",
              items: activeProvider.zone,
              selectedValue: activeProvider.selectedZone,
              onChanged: activeProvider.setSelectedZone,
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
              items: activeProvider.branch,
              selectedValue: activeProvider.selectedBranch,
              onChanged: activeProvider.setSelectedBranch,
              hintText: "Select Branch",
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomSearchDropdownWithSearch(
              labelText: "Designation",
              items: activeProvider.designation,
              selectedValue: activeProvider.selectedDesignation,
              onChanged: activeProvider.setSelectedDesignation,
              hintText: "Select Designation",
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: CustomDateField(
              controller: activeProvider.dojFromController,
              hintText: "From Date",
              labelText: "DOJ From",
              isMandatory: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomDateField(
              controller: activeProvider.fojToController,
              hintText: "To Date",
              labelText: "DOJ To",
              isMandatory: false,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: CustomSearchDropdownWithSearch(
              labelText: "CTC Range",
              items: activeProvider.ctc,
              selectedValue: activeProvider.selectedCTC,
              onChanged: activeProvider.setSelectedCTC,
              hintText: "Select CTC Range",
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Container()), // Empty space for alignment
        ],
      ),
    ],
  );
}

Widget _buildSearchButton(ActiveProvider activeProvider) {
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              activeProvider.searchEmployees();
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
              "Go",
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
  );
}

Widget _buildListHeader(ActiveProvider activeProvider) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "${activeProvider.filteredEmployees.length} Employees Found",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.poppins,
          color: const Color(0xFF1E293B),
        ),
      ),
    ],
  );
}

Widget _buildEmployeeSliverList(ActiveProvider activeProvider) {
  if (activeProvider.isLoading) {
    return const SliverFillRemaining(
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
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  if (activeProvider.filteredEmployees.isEmpty) {
    return SliverFillRemaining(
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
    );
  }

  return SliverList(
    delegate: SliverChildBuilderDelegate((context, index) {
      final employee = activeProvider.filteredEmployees[index];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildEmployeeCard(context, employee),
      );
    }, childCount: activeProvider.filteredEmployees.length),
  );
}

Widget _buildEmployeeCard(BuildContext context, Employee employee) {
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
              builder:
                  (_) => EmployeeManagementDetailsScreen(
                empId: employee.employeeId,
                employee: employee,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Enhanced circular avatar with better error handling
              _buildEmployeeAvatar(employee),

              const SizedBox(width: 16),

              // Employee information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      employee.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                        color: const Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // ID
                    Text(
                      "ID: ${employee.employeeId}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                        color: const Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Designation and Branch in one line
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.designation,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFonts.poppins,
                              color: const Color(0xFF374151),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          employee.branch,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.poppins,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Simple arrow
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildEmployeeAvatar(Employee employee) {
  return Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF6366F1),
      // Add a subtle border for better visual separation
      border: Border.all(
        color: const Color(0xFFE5E7EB),
        width: 2,
      ),
    ),
    child: ClipOval(
      child: _buildAvatarContent(employee),
    ),
  );
}

Widget _buildAvatarContent(Employee employee) {
  // Check if photoUrl exists and is not empty
  if (employee.photoUrl != null &&
      employee.photoUrl!.isNotEmpty &&
      employee.photoUrl != "https://example.com/photo1.jpg") { // Avoid known invalid URLs

    return Image.network(
      employee.photoUrl!,
      fit: BoxFit.cover,
      width: 52,
      height: 52,
      // Handle network image errors gracefully
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackAvatar(employee);
      },
      // Show loading indicator while image loads
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 52,
          height: 52,
          color: const Color(0xFF6366F1),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  // Return fallback avatar if no valid photo URL
  return _buildFallbackAvatar(employee);
}

Widget _buildFallbackAvatar(Employee employee) {
  return Container(
    width: 52,
    height: 52,
    color: const Color(0xFF6366F1),
    child: Center(
      child: Text(
        employee.name.isNotEmpty
            ? employee.name[0].toUpperCase()
            : "E",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}