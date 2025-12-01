import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../widgets/custom_textfield/Custom_date_field.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../provider/Employee_management_Provider/Active_Provider.dart';
import 'active_employee_details_screen.dart';

class ActiveScreen extends StatefulWidget {
  const ActiveScreen({super.key});

  @override
  State<ActiveScreen> createState() => _ActiveScreenState();
}

class _ActiveScreenState extends State<ActiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Modern gradient colors
  static const Color primaryColor = Color(0xFF8E0E6B);
  static const Color secondaryColor = Color(0xFFD4145A);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

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
      Provider.of<ActiveProvider>(context, listen: false).initializeEmployees();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeProvider = Provider.of<ActiveProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: _buildHeaderSection(activeProvider),
            ),

            // Filter Section
            if (activeProvider.showFilters)
              SliverToBoxAdapter(
                child: _buildFilterSection(activeProvider),
              ),

            // Results Section
            _buildResultsSection(activeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ActiveProvider activeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
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
                // Filter Toggle Button
                Expanded(
                  child: _buildFilterToggleButton(activeProvider),
                ),
                const SizedBox(width: 12),
                // Page Size Dropdown
                _buildPageSizeDropdown(activeProvider),
              ],
            ),
            const SizedBox(height: 16),

            // Search Field
            _buildSearchField(activeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToggleButton(ActiveProvider activeProvider) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: activeProvider.toggleFilters,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: activeProvider.showFilters
                  ? const LinearGradient(colors: [primaryColor, secondaryColor])
                  : null,
              color: activeProvider.showFilters ? null : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: activeProvider.showFilters
                    ? Colors.transparent
                    : borderColor,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: activeProvider.showFilters ? Colors.white : textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  "Filters",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                    color: activeProvider.showFilters ? Colors.white : textSecondary,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: activeProvider.showFilters ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: activeProvider.showFilters ? Colors.white : textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageSizeDropdown(ActiveProvider activeProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
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
          value: activeProvider.pageSize,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: textSecondary),
          items: [5, 10, 15, 20].map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(
                "$e",
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: AppFonts.poppins,
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
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

  Widget _buildSearchField(ActiveProvider activeProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: TextField(
          controller: activeProvider.searchController,
          onChanged: (value) {
            activeProvider.onSearchChanged(value);
          },
          style: const TextStyle(
            fontSize: 15,
            fontFamily: AppFonts.poppins,
            color: textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            hintText: "Search employees by name, ID...",
            hintStyle: TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.poppins,
              color: textSecondary.withOpacity(0.7),
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.search_rounded,
                color: textSecondary,
                size: 22,
              ),
            ),
            suffixIcon: activeProvider.searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () => activeProvider.clearSearch(),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: textSecondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: textSecondary,
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

  Widget _buildFilterSection(ActiveProvider activeProvider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          bottom: BorderSide(color: borderColor.withOpacity(0.5)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            Divider(color: borderColor.withOpacity(0.5), height: 1),
            const SizedBox(height: 12),

            // First Row - Company and Zone
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomSearchDropdownWithSearch(
                    labelText: "Company *",
                    items: activeProvider.company,
                    selectedValue: activeProvider.selectedCompany,
                    onChanged: activeProvider.setSelectedCompany,
                    hintText: "Select",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomSearchDropdownWithSearch(
                    labelText: "Zone *",
                    items: activeProvider.zone,
                    selectedValue: activeProvider.selectedZone,
                    onChanged: activeProvider.setSelectedZone,
                    hintText: "Select",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Second Row - Branch and Designation
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomSearchDropdownWithSearch(
                    labelText: "Branch *",
                    items: activeProvider.branch,
                    selectedValue: activeProvider.selectedBranch,
                    onChanged: activeProvider.setSelectedBranch,
                    hintText: "Select",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomSearchDropdownWithSearch(
                    labelText: "Designation *",
                    items: activeProvider.designation,
                    selectedValue: activeProvider.selectedDesignation,
                    onChanged: activeProvider.setSelectedDesignation,
                    hintText: "Select",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Third Row - Date Fields
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomDateField(
                    controller: activeProvider.dojFromController,
                    hintText: "From",
                    labelText: "DOJ From",
                    isMandatory: false,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomDateField(
                    controller: activeProvider.fojToController,
                    hintText: "To",
                    labelText: "DOJ To",
                    isMandatory: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Fourth Row - CTC Range
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomSearchDropdownWithSearch(
                    labelText: "CTC Range",
                    items: activeProvider.ctc,
                    selectedValue: activeProvider.selectedCTC,
                    onChanged: activeProvider.setSelectedCTC,
                    hintText: "Select",
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildClearButton(activeProvider),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildApplyButton(activeProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton(ActiveProvider activeProvider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => activeProvider.clearAllFilters(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              "Clear",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.poppins,
                color: textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplyButton(ActiveProvider activeProvider) {
    final bool canApply = activeProvider.areAllFiltersSelected;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canApply ? () => activeProvider.searchEmployees() : null,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: canApply
                  ? const LinearGradient(colors: [primaryColor, secondaryColor])
                  : null,
              color: canApply ? null : borderColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: canApply
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: canApply ? Colors.white : textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    canApply ? "Apply Filters" : "Select All Filters",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.poppins,
                      color: canApply ? Colors.white : textSecondary,
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

  Widget _buildResultsSection(ActiveProvider activeProvider) {
    // Show message if filters not applied yet
    if (!activeProvider.hasAppliedFilters) {
      return SliverFillRemaining(
        child: _buildSelectFiltersMessage(),
      );
    }

    // Show loading
    if (activeProvider.isLoading) {
      return SliverFillRemaining(
        child: _buildLoadingState(),
      );
    }

    // Show empty state
    if (activeProvider.filteredEmployees.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    // Show employee list
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return _buildResultsHeader(activeProvider);
            }
            final employee = activeProvider.filteredEmployees[index - 1];
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
          },
          childCount: activeProvider.filteredEmployees.length + 1,
        ),
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
                      primaryColor.withOpacity(0.1),
                      secondaryColor.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.filter_list_rounded,
                  size: 48,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Select Filters to View Employees",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Please select Company, Zone, Branch, and Designation\nto view the employee list",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppFonts.poppins,
                  color: textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_rounded, size: 18, color: primaryColor),
                    SizedBox(width: 8),
                    Text(
                      "Tap 'Filters' above to start",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                        color: primaryColor,
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
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Loading employees...",
            style: TextStyle(
              color: textSecondary,
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
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_search_rounded,
                size: 48,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No employees found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.poppins,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Try adjusting your filters",
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppFonts.poppins,
                color: textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader(ActiveProvider activeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryColor, secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${activeProvider.filteredEmployees.length}",
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
                  color: textPrimary,
                ),
              ),
            ],
          ),
          if (activeProvider.showFilters)
            TextButton.icon(
              onPressed: () => activeProvider.toggleFilters(),
              icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 18),
              label: const Text(
                "Hide",
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: AppFonts.poppins,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(dynamic employee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
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
                pageBuilder: (_, __, ___) => EmployeeManagementDetailsScreen(
                  empId: employee.employeeId,
                  employee: employee,
                ),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
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
                    colors: [primaryColor, secondaryColor],
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
                          employee.name.isNotEmpty
                              ? employee.name[0].toUpperCase()
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
                            employee.name,
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
                              "ID: ${employee.employeeId}",
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

                    // Arrow
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 16,
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
                    // Designation
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.work_outline_rounded,
                        label: "DESIGNATION",
                        value: employee.designation,
                        color: primaryColor,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: borderColor,
                    ),
                    const SizedBox(width: 16),
                    // Branch
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.location_on_outlined,
                        label: "BRANCH",
                        value: employee.branch,
                        color: secondaryColor,
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
                  color: textSecondary.withOpacity(0.7),
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
                  color: textPrimary,
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
