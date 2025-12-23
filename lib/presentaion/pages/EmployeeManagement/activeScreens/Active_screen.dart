import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
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

  // Colors
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
            // ═══════════════════════════════════════════════════════════
            // HEADER SECTION
            // ═══════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Grand Total - Featured Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB91C7F), Color(0xFF9B1568)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB91C7F).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    "G",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Grand Total",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹${activeProvider.grandTotalCTC.toString()}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Grid of smaller cards
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.85,
                          children: [
                            // Employee Monthly CTC
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4A90E2),
                                          Color(0xFF357ABD),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF4A90E2,
                                          ).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.people,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "Employee Monthly",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                      height: 1.3,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => const LinearGradient(
                                          colors: [
                                            Color(0xFF4A90E2),
                                            Color(0xFF357ABD),
                                          ],
                                        ).createShader(bounds),
                                    child: Text(
                                      "₹${activeProvider.totalEmployeeCTC.toString()}",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // F11 Monthly CTC
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF9800),
                                          Color(0xFFF57C00),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFFFF9800,
                                          ).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.business_center,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "F11 Monthly",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                      height: 1.3,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => const LinearGradient(
                                          colors: [
                                            Color(0xFFFF9800),
                                            Color(0xFFF57C00),
                                          ],
                                        ).createShader(bounds),
                                    child: Text(
                                      "₹${activeProvider.totalF11CTC.toString()}",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Professional Fee
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF66BB6A),
                                          Color(0xFF43A047),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF66BB6A,
                                          ).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.card_giftcard,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "Professional Fee",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                      height: 1.3,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => const LinearGradient(
                                          colors: [
                                            Color(0xFF66BB6A),
                                            Color(0xFF43A047),
                                          ],
                                        ).createShader(bounds),
                                    child: Text(
                                      "₹${activeProvider.totalProfessionalFee.toString()}",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Student Monthly CTC
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF9C27B0),
                                          Color(0xFF7B1FA2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(
                                            0xFF9C27B0,
                                          ).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    "Student Monthly",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                      height: 1.3,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => const LinearGradient(
                                          colors: [
                                            Color(0xFF9C27B0),
                                            Color(0xFF7B1FA2),
                                          ],
                                        ).createShader(bounds),
                                    child: Text(
                                      "₹${activeProvider.totalStudentCTC.toString()}",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Container(
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
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: activeProvider.toggleFilters,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient:
                                            activeProvider.showFilters
                                                ? const LinearGradient(
                                                  colors: [
                                                    primaryColor,
                                                    secondaryColor,
                                                  ],
                                                )
                                                : null,
                                        color:
                                            activeProvider.showFilters
                                                ? null
                                                : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              activeProvider.showFilters
                                                  ? Colors.transparent
                                                  : borderColor,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.tune_rounded,
                                            size: 20,
                                            color:
                                                activeProvider.showFilters
                                                    ? Colors.white
                                                    : textSecondary,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Filters",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppFonts.poppins,
                                              color:
                                                  activeProvider.showFilters
                                                      ? Colors.white
                                                      : textSecondary,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color:
                                                activeProvider.showFilters
                                                    ? Colors.white
                                                    : textSecondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Page Size Dropdown
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Summary Section

                          // Search Field
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: TextField(
                              controller: activeProvider.searchController,
                              onChanged:
                                  (value) =>
                                      activeProvider.onSearchChanged(value),
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
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: textSecondary,
                                  size: 22,
                                ),
                                suffixIcon:
                                    activeProvider
                                            .searchController
                                            .text
                                            .isNotEmpty
                                        ? IconButton(
                                          onPressed:
                                              () =>
                                                  activeProvider.clearSearch(),
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            color: textSecondary,
                                            size: 18,
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
                ],
              ),
            ),

            // ═══════════════════════════════════════════════════════════
            // FILTER SECTION
            // ═══════════════════════════════════════════════════════════
            if (activeProvider.showFilters)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ══════════════════════════════════════════════
                      // LOADING FILTERS STATE
                      // ══════════════════════════════════════════════
                      if (activeProvider.isLoadingFilters)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text("Loading filter options..."),
                            ],
                          ),
                        )
                      // ══════════════════════════════════════════════
                      // FILTERS LOADED - SHOW DROPDOWNS
                      // ══════════════════════════════════════════════
                      else ...[
                        // Company and Zone Row
                        Column(
                          children: [
                            // ================= COMPANY =================
                            CustomSearchDropdownWithSearch(
                              labelText: "Company",
                              isMandatory: true,
                              items: activeProvider.company,
                              selectedValue: activeProvider.selectedCompany,
                              onChanged: activeProvider.setSelectedCompany,
                              hintText: "Select Company",
                            ),

                            const SizedBox(height: 12),

                            // ================= ZONE =================
                            CustomSearchDropdownWithSearch(
                              labelText: "Zone",
                              isMandatory: true,
                              items: activeProvider.zone,
                              selectedValue: activeProvider.selectedZone,
                              onChanged: activeProvider.setSelectedZone,
                              hintText: "Select Zone",
                            ),

                            const SizedBox(height: 12),

                            // ================= BRANCH =================
                            CustomSearchDropdownWithSearch(
                              labelText: "Branch",
                              isMandatory: true,
                              items: activeProvider.branch,
                              selectedValue: activeProvider.selectedBranch,
                              onChanged: activeProvider.setSelectedBranch,
                              hintText:
                                  activeProvider.selectedZone == null
                                      ? "Select zone first"
                                      : "Select Branch",
                              readOnly: activeProvider.selectedZone == null,
                            ),

                            const SizedBox(height: 12),

                            // ================= DESIGNATION =================
                            CustomSearchDropdownWithSearch(
                              labelText: "Designation",
                              isMandatory: true,
                              items: activeProvider.designation,
                              selectedValue: activeProvider.selectedDesignation,
                              onChanged: activeProvider.setSelectedDesignation,
                              hintText: "Select Designation",
                            ),

                            const SizedBox(height: 12),

                            // ================= CTC RANGE (OPTIONAL) =================
                            CustomSearchDropdownWithSearch(
                              labelText: "CTC Range",
                              isMandatory: false,
                              items: activeProvider.ctc,
                              selectedValue: activeProvider.selectedCTC,
                              onChanged: activeProvider.setSelectedCTC,
                              hintText: "Select CTC Range",
                            ),
                          ],
                        ),

                        SizedBox(height: 15),
                        // Action Buttons
                        Row(
                          children: [
                            // ================= CLEAR BUTTON =================
                            Expanded(
                              child: InkWell(
                                onTap: () => activeProvider.clearAllFilters(),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
                            ),

                            const SizedBox(width: 10),

                            // ================= APPLY FILTER BUTTON =================
                            Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: activeProvider.areAllFiltersSelected && !activeProvider.isLoading
                                    ? () => activeProvider.searchEmployees()
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: activeProvider.areAllFiltersSelected &&
                                        !activeProvider.isLoading
                                        ? const LinearGradient(
                                      colors: [primaryColor, secondaryColor],
                                    )
                                        : null,
                                    color: activeProvider.areAllFiltersSelected
                                        ? (activeProvider.isLoading ? borderColor : null)
                                        : borderColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: activeProvider.isLoading
                                    // ================= LOADER =================
                                        ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                    // ================= NORMAL CONTENT =================
                                        : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_rounded,
                                          size: 18,
                                          color: activeProvider.areAllFiltersSelected
                                              ? Colors.white
                                              : textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          activeProvider.areAllFiltersSelected
                                              ? "Apply Filters"
                                              : "Select All Filters",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: AppFonts.poppins,
                                            color: activeProvider.areAllFiltersSelected
                                                ? Colors.white
                                                : textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // ═══════════════════════════════════════════════════════════
            // RESULTS SECTION
            // ═══════════════════════════════════════════════════════════

            // Loading State
            if (activeProvider.isLoading && !activeProvider.initialLoadDone)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
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
                ),
              ),

            // Error State
            if (activeProvider.errorMessage != null &&
                !activeProvider.initialLoadDone &&
                !activeProvider.isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Failed to Load Employees",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.poppins,
                            color: textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          activeProvider.errorMessage ?? "Unknown error",
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: AppFonts.poppins,
                            color: textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => activeProvider.fetchActiveUsers(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Empty State
            if (activeProvider.filteredEmployees.isEmpty &&
                !activeProvider.isLoading &&
                activeProvider.initialLoadDone)
              SliverFillRemaining(
                child: Center(
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
              ),

            // Employee List
            if (activeProvider.filteredEmployees.isNotEmpty &&
                !activeProvider.isLoading)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    // Results Header
                    if (index == 0) {
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
                          ],
                        ),
                      );
                    }

                    // Employee Card
                    final user = activeProvider.filteredEmployees[index - 1];
                    final employeeId = user.employmentId ?? user.userId ?? "";
                    final employeeName =
                        user.fullname ?? user.username ?? "Unknown";

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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => EmployeeManagementDetailsScreen(
                                    user: user,
                                  ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            // Header
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
                                    child: ClipOval(
                                      child: _getAvatarWidget(
                                        user,
                                        employeeName,
                                        employeeId,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Name and ID
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          employeeName,
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
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            "ID: $employeeId",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppFonts.poppins,
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Arrow
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),

                            // Bottom Info
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Designation
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.work_outline_rounded,
                                            size: 16,
                                            color: primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "DESIGNATION",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: AppFonts.poppins,
                                                  color: textSecondary
                                                      .withOpacity(0.7),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                user.designation ?? "N/A",
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
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: secondaryColor.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.location_on_outlined,
                                            size: 16,
                                            color: secondaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "BRANCH",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: AppFonts.poppins,
                                                  color: textSecondary
                                                      .withOpacity(0.7),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                user.locationName ?? "N/A",
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: activeProvider.filteredEmployees.length + 1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════

  Widget _summaryItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.poppins,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: AppFonts.poppins,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAvatarWidget(dynamic user, String name, String employeeId) {
    final avatar = user.avatar;
    String? imageUrl;

    if (avatar != null &&
        avatar.isNotEmpty &&
        avatar != 'null' &&
        avatar != 'none') {
      if (avatar.startsWith('http://') || avatar.startsWith('https://')) {
        imageUrl = avatar;
      } else {
        final cleanPath = avatar.startsWith('/') ? avatar.substring(1) : avatar;
        imageUrl = 'http://192.168.0.11/hrms/$cleanPath';
      }
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        errorWidget: (context, url, error) {
          return _getDefaultAvatar(name, employeeId);
        },
      );
    }

    return _getDefaultAvatar(name, employeeId);
  }

  Widget _getDefaultAvatar(String name, String employeeId) {
    String displayLetter = "E";
    if (name.isNotEmpty && name != "Unknown") {
      displayLetter = name[0].toUpperCase();
    } else if (employeeId.isNotEmpty) {
      displayLetter = employeeId[0].toUpperCase();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
      ),
      child: Center(
        child: Text(
          displayLetter,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ),
    );
  }
}
