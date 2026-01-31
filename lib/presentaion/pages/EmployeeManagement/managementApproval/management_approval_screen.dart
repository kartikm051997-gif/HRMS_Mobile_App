import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Employee_management_Provider/management_approval_provider.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../widgets/MultipleSelectDropDown/MultipleSelectDropDown.dart';
import 'Emp_management_details.dart';

class ManagementApprovalScreen extends StatefulWidget {
  const ManagementApprovalScreen({super.key});

  @override
  State<ManagementApprovalScreen> createState() =>
      _ManagementApprovalScreenState();
}

class _ManagementApprovalScreenState extends State<ManagementApprovalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ManagementApprovalProvider>(
        context,
        listen: false,
      ).initializeEmployees();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ManagementApprovalProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ✅ ALWAYS show header (no shimmer blocking it)
            SliverToBoxAdapter(child: _buildHeaderSection(provider)),

            // ✅ Show filters if toggled
            if (provider.showFilters)
              SliverToBoxAdapter(child: _buildFilterSection(provider)),

            // ✅ Show shimmer ONLY during initial filter load
            if (provider.isLoadingFilters && !provider.initialLoadDone)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildShimmerCard(),
                    childCount: 5,
                  ),
                ),
              ),

            // ✅ Show results section when filters loaded
            if (!provider.isLoadingFilters || provider.initialLoadDone)
              _buildResultsSection(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ManagementApprovalProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
              // Filter Toggle Button
              Row(
                children: [Expanded(child: _buildFilterToggleButton(provider))],
              ),
              const SizedBox(height: 16),

              // Search Field
              _buildSearchField(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterToggleButton(ManagementApprovalProvider provider) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: provider.toggleFilters,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient:
                  provider.showFilters
                      ? const LinearGradient(
                        colors: [
                          AppColor.primaryColor,
                          AppColor.secondaryColor,
                        ],
                      )
                      : null,
              color: provider.showFilters ? null : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    provider.showFilters
                        ? Colors.transparent
                        : AppColor.borderColor,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color:
                      provider.showFilters
                          ? Colors.white
                          : AppColor.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  "Filters",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                    color:
                        provider.showFilters
                            ? Colors.white
                            : AppColor.textSecondary,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: provider.showFilters ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color:
                        provider.showFilters
                            ? Colors.white
                            : AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(ManagementApprovalProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
      ),
      child: TextField(
        controller: provider.searchController,
        onChanged: provider.onSearchChanged,
        onSubmitted: (value) {
          // Immediate search on Enter — show matching cards (same as Active screen)
          provider.performSearchWithQuery(value);
        },
        style: const TextStyle(
          fontSize: 15,
          fontFamily: AppFonts.poppins,
          color: AppColor.textPrimary,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          hintText: "Search employees...",
          hintStyle: TextStyle(
            fontSize: 14,
            fontFamily: AppFonts.poppins,
            color: AppColor.textSecondary.withOpacity(0.7),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColor.textSecondary,
            size: 22,
          ),
          suffixIcon:
              provider.searchController.text.isNotEmpty
                  ? IconButton(
                    onPressed: () => provider.clearSearch(),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColor.textSecondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColor.textSecondary,
                        size: 16,
                      ),
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

  Widget _buildFilterSection(ManagementApprovalProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: AppColor.cardColor,
        border: Border(
          bottom: BorderSide(color: AppColor.borderColor.withOpacity(0.5)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Divider(color: AppColor.borderColor.withOpacity(0.5), height: 1),
            const SizedBox(height: 12),

            // Zone
            MultiSelectDropdown(
              label: "Zone *",
              items: provider.zone,
              selectedItems: provider.selectedZones,
              onChanged: provider.setSelectedZones,
            ),
            const SizedBox(height: 12),

            // Branch
            MultiSelectDropdown(
              label: "Branch *",
              items: provider.branch,
              selectedItems: provider.selectedBranches,
              onChanged: provider.setSelectedBranches,
              designationEnableSelectAll: true,
            ),
            const SizedBox(height: 12),

            // Designation
            MultiSelectDropdown(
              label: "Designation *",
              items: provider.designation,
              selectedItems: provider.selectedDesignations,
              onChanged: provider.setSelectedDesignations,
              designationEnableSelectAll: true,
            ),
            const SizedBox(height: 16),

            // Clear and Apply buttons
            Row(
              children: [
                Expanded(child: _buildClearButton(provider)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: _buildApplyButton(provider)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton(ManagementApprovalProvider provider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => provider.clearAllFilters(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              "Clear",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.poppins,
                color: AppColor.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplyButton(ManagementApprovalProvider provider) {
    final bool canApply = provider.areAllFiltersSelected;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canApply ? () => provider.searchEmployees() : null,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient:
                  canApply
                      ? const LinearGradient(
                        colors: [
                          AppColor.primaryColor,
                          AppColor.secondaryColor,
                        ],
                      )
                      : null,
              color: canApply ? null : AppColor.borderColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  canApply
                      ? [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                      : null,
            ),
            child: Center(
              child:
              provider.isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: canApply ? Colors.white : AppColor.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canApply ? "Apply Filters" : "Select All Filters",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.poppins,
                      color: canApply ? Colors.white : AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildResultsSection(ManagementApprovalProvider provider) {
    // ✅ Show loading during data fetch (not filter load)
    if (provider.isLoading && !provider.initialLoadDone) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColor.primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Loading approvals...",
                style: TextStyle(
                  color: AppColor.textSecondary,
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Show empty state
    if (provider.paginatedEmployees.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    // ✅ Show employee list
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return _buildResultsHeader(provider);
          }
          if (index == provider.paginatedEmployees.length + 1) {
            return _buildPaginationControls(provider);
          }
          final employee = provider.paginatedEmployees[index - 1];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: _buildEmployeeCard(employee),
          );
        }, childCount: provider.paginatedEmployees.length + 2),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 100, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 40, color: Colors.white)),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 40, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search_rounded,
              size: 48,
              color: AppColor.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No pending approvals",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Try adjusting your filters",
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.poppins,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(ManagementApprovalProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColor.primaryColor, AppColor.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${provider.totalRecords ?? provider.paginatedEmployees.length}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFonts.poppins,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Pending Approvals",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                  color: AppColor.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(ManagementApprovalProvider provider) {
    if (provider.totalPages <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: provider.currentPage > 1 ? provider.previousPage : null,
            icon: const Icon(Icons.chevron_left),
            color:
                provider.currentPage > 1
                    ? AppColor.primaryColor
                    : AppColor.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            "Page ${provider.currentPage} of ${provider.totalPages}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: AppColor.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed:
                provider.currentPage < provider.totalPages
                    ? provider.nextPage
                    : null,
            icon: const Icon(Icons.chevron_right),
            color:
                provider.currentPage < provider.totalPages
                    ? AppColor.primaryColor
                    : AppColor.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(dynamic employee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColor.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
              PageRouteBuilder(
                pageBuilder:
                    (_, __, ___) => EmployeeManagementApprovalDetailsScreen(
                      empId: employee.employmentId ?? employee.userId ?? '',
                      employee: employee,
                    ),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Column(
            children: [
              // Header with Gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColor.primaryColor, AppColor.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          (employee.fullname ?? '').isNotEmpty
                              ? (employee.fullname ?? '')[0].toUpperCase()
                              : "E",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name and ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.fullname ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.poppins,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "ID: ${employee.employmentId ?? employee.userId ?? ''}",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFonts.poppins,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pending Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        employee.approvalStatus ?? "Pending",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFonts.poppins,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.work_outline_rounded,
                        label: "DESIGNATION",
                        value: employee.designation ?? '',
                        color: AppColor.primaryColor,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: AppColor.borderColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.location_on_outlined,
                        label: "LOCATION",
                        value: employee.location ?? 'N/A',
                        color: AppColor.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                  color: AppColor.textSecondary.withOpacity(0.7),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                  color: AppColor.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
