import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../model/Employee_management/NoticePeriodUserListModel.dart';
import '../../../../provider/Employee_management_Provider/Notice_Period_Provider.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../widgets/MultipleSelectDropDown/MultipleSelectDropDown.dart';
import 'Notice_Period_details_screen.dart';

class NoticePeriodScreen extends StatefulWidget {
  const NoticePeriodScreen({super.key});

  @override
  State<NoticePeriodScreen> createState() => _NoticePeriodScreenState();
}

class _NoticePeriodScreenState extends State<NoticePeriodScreen>
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
      Provider.of<NoticePeriodProvider>(
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
    final provider = Provider.of<NoticePeriodProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Shimmer during initial load (same concept as Active screen)
            if (provider.isLoading && !provider.initialLoadDone)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          padding: const EdgeInsets.all(12),
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
                              const SizedBox(height: 8),
                              Container(
                                height: 14,
                                width: 250,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 150,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: 80,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
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
            if (!provider.isLoading || provider.initialLoadDone) ...[
              SliverToBoxAdapter(child: _buildHeaderSection(provider)),
              if (provider.showFilters)
                SliverToBoxAdapter(child: _buildFilterSection(provider)),
              _buildResultsSection(provider),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(NoticePeriodProvider provider) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Toggle and Page Size Row
            Row(
              children: [
                Expanded(child: _buildFilterToggleButton(provider)),
                const SizedBox(width: 12),
                _buildPageSizeDropdown(provider),
              ],
            ),
            const SizedBox(height: 16),
            _buildSearchField(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToggleButton(NoticePeriodProvider provider) {
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

  Widget _buildPageSizeDropdown(NoticePeriodProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: provider.pageSize,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColor.textSecondary,
          ),
          items:
              [5, 10, 15, 20].map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(
                    "$e",
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: AppFonts.poppins,
                      color: AppColor.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (val) {
            if (val != null) provider.setPageSize(val);
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(NoticePeriodProvider provider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.borderColor),
        ),
        child: TextField(
          controller: provider.searchController,
          onChanged: (value) => provider.onSearchChanged(value),
          style: const TextStyle(
            fontSize: 15,
            fontFamily: AppFonts.poppins,
            color: AppColor.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            hintText: "Search employees by name, ID...",
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
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(NoticePeriodProvider provider) {
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
          children: [
            Divider(color: AppColor.borderColor.withOpacity(0.5), height: 1),
            const SizedBox(height: 12),
            CustomSearchDropdownWithSearch(
              labelText: "Zone *",
              items: provider.zone,
              selectedValue: provider.selectedZone,
              onChanged: provider.setSelectedZone,
              hintText: "Select",
            ),
            const SizedBox(height: 8),

            MultiSelectDropdown(
              label: "Branch *",
              items: provider.branch,
              selectedItems: provider.selectedBranches,
              onChanged: provider.setSelectedBranches,
              designationEnableSelectAll: true,
            ),
            const SizedBox(height: 12),

            MultiSelectDropdown(
              label: "Designation *",
              items: provider.designation,
              selectedItems: provider.selectedDesignations,
              onChanged: provider.setSelectedDesignations,
              designationEnableSelectAll: true,
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildClearButton(provider)),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: _buildApplyButton(provider)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton(NoticePeriodProvider provider) {
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

  Widget _buildApplyButton(NoticePeriodProvider provider) {
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
                  :Center(
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

  Widget _buildResultsSection(NoticePeriodProvider provider) {
    if (!provider.hasAppliedFilters) {
      return SliverFillRemaining(child: _buildSelectFiltersMessage());
    }

    if (provider.isLoading && provider.paginatedEmployees.isEmpty) {
      return SliverFillRemaining(child: _buildLoadingState());
    }

    if (provider.errorMessage != null && !provider.initialLoadDone) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage ?? 'Error',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => provider.loadAllFilters(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.paginatedEmployees.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) return _buildPageInfo(provider);
          if (index == 1) return _buildResultsHeader(provider);
          if (index == provider.paginatedEmployees.length + 2) {
            return _buildPagination(provider);
          }
          final user = provider.paginatedEmployees[index - 2];
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
            child: _buildEmployeeCard(user),
          );
        }, childCount: provider.paginatedEmployees.length + 3),
      ),
    );
  }

  Widget _buildPageInfo(NoticePeriodProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              "Page ${provider.currentPage} of ${provider.totalPages}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.poppins,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Total: ${provider.paginatedEmployees.length} on this page",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontFamily: AppFonts.poppins,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(NoticePeriodProvider provider) {
    if (provider.totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: provider.currentPage > 1 ? provider.previousPage : null,
            icon: const Icon(Icons.chevron_left),
          ),
          ...List.generate(provider.totalPages > 5 ? 5 : provider.totalPages, (
            i,
          ) {
            int pageNum;
            if (provider.totalPages <= 5) {
              pageNum = i + 1;
            } else {
              if (provider.currentPage <= 3) {
                pageNum = i + 1;
              } else if (provider.currentPage >= provider.totalPages - 2) {
                pageNum = provider.totalPages - 4 + i;
              } else {
                pageNum = provider.currentPage - 2 + i;
              }
            }
            return InkWell(
              onTap: () => provider.goToPage(pageNum),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      provider.currentPage == pageNum
                          ? AppColor.primaryColor
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pageNum',
                  style: TextStyle(
                    color:
                        provider.currentPage == pageNum
                            ? Colors.white
                            : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ),
            );
          }),
          IconButton(
            onPressed:
                provider.currentPage < provider.totalPages
                    ? provider.nextPage
                    : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectFiltersMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor.withOpacity(0.1),
                      AppColor.secondaryColor.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  size: 48,
                  color: AppColor.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Select Filters to View Employees",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                  color: AppColor.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Please select Zone, Branch, and Designation\nto view employees on notice period",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppFonts.poppins,
                  color: AppColor.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColor.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 18,
                      color: AppColor.primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Tap 'Filters' above to start",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                        color: AppColor.primaryColor,
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Loading notice period employees...",
            style: TextStyle(
              color: AppColor.textSecondary,
              fontSize: 15,
              fontFamily: AppFonts.poppins,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
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
              "No employees found",
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
      ),
    );
  }

  Widget _buildResultsHeader(NoticePeriodProvider provider) {
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
                  "${provider.paginatedEmployees.length}",
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
                "Employees Found",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                  color: AppColor.textPrimary,
                ),
              ),
            ],
          ),
          if (provider.showFilters)
            TextButton.icon(
              onPressed: () => provider.toggleFilters(),
              icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 18),
              label: const Text(
                "Hide",
                style: TextStyle(fontSize: 13, fontFamily: AppFonts.poppins),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColor.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(NoticePeriodUser user) {
    final name = user.fullname ?? user.username ?? 'Employee';
    final empId = user.employmentId ?? user.userId ?? '';
    final designation =
        user.designation?.trim().isNotEmpty == true ? user.designation! : '—';
    final branch =
        (user.locationName ?? user.location ?? '').trim().isNotEmpty
            ? (user.locationName ?? user.location)!
            : '—';

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
                    (_, __, ___) => NoticePeriodDetailsScreen(
                      empId: empId,
                      noticePeriodUser: user,
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
                          name.isNotEmpty ? name[0].toUpperCase() : "E",
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
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
                              "ID: $empId",
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
                    // Notice Period Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFED7AA).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: Color(0xFFEA580C),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Notice",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.poppins,
                              color: Color(0xFFEA580C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.work_outline_rounded,
                        label: "DESIGNATION",
                        value: designation,
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
                        label: "BRANCH",
                        value: branch,
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
