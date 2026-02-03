import 'package:flutter/material.dart';
import '../../../../core/components/drawer/drawer.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../model/AllEmployeeDetailsModel/Employee_Basic_Details.dart';
import '../../Deliverables Overview/employeesdetails/employee_detailsTabs_screen.dart';
import '../../MyDetailsScreens/admin_my_details_menu_screen.dart';

class EmployeeInsideDetailsScreen extends StatefulWidget {
  final String empId;
  final EmployeeBasicModel employee;
  const EmployeeInsideDetailsScreen({
    super.key,
    required this.empId,
    required this.employee,
  });

  @override
  State<EmployeeInsideDetailsScreen> createState() =>
      _EmployeeInsideDetailsScreenState();
}

class _EmployeeInsideDetailsScreenState
    extends State<EmployeeInsideDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const TabletMobileDrawer(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom Gradient App Bar
          _buildGradientAppBar(),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Employee Header Card
                      _buildProfileHeader(),
                      const SizedBox(height: 16),

                      // Quick Stats
                      _buildQuickStats(),
                      const SizedBox(height: 16),

                      // Professional Information
                      _buildProfessionalDetails(),
                      const SizedBox(height: 16),

                      // Salary Details
                      _buildSalaryDetails(),
                      const SizedBox(height: 16),

                      // Deductions & Take Home
                      _buildDeductionsDetails(),
                      const SizedBox(height: 16),

                      // Professional Fee Details
                      _buildProfessionalFeeDetails(),
                      const SizedBox(height: 16),

                      // Travel Allowance Details
                      _buildTravelAllowanceDetails(),
                      const SizedBox(height: 16),

                      // Additional Information
                      _buildAdditionalInfo(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryColor,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(60, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Employee Details",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppFonts.poppins,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "View complete profile information",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: AppFonts.poppins,
                      color: Colors.white.withOpacity(0.8),
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

  Widget _buildProfileHeader() {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gradient Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Profile Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        widget.employee.photoUrl != null &&
                                widget.employee.photoUrl!.isNotEmpty
                            ? Image.network(
                              widget.employee.photoUrl!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar(
                                  widget.employee.name,
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 3,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                );
                              },
                            )
                            : _buildDefaultAvatar(widget.employee.name),
                  ),
                ),
                const SizedBox(height: 16),
                // Employee Name
                Text(
                  widget.employee.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFonts.poppins,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Employee ID Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "ID: ${widget.employee.employeeId}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.poppins,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Designation
                Text(
                  widget.employee.designation,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.poppins,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 8),
                // Branch
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.employee.branch,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bottom Section with Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => AdminMyDetailsMenuScreen(
                            empId: widget.employee.employeeId,
                            empPhoto: widget.employee.photoUrl ?? "",
                            empName: widget.employee.name,
                            empDesignation: widget.employee.designation,
                            empBranch: widget.employee.branch,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "View Profile Details",
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
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: "Branch",
            value: widget.employee.branch,
            icon: Icons.location_on_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: "Joined",
            value: widget.employee.doj,
            icon: Icons.calendar_today_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  secondaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: primaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: AppFonts.poppins,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDetails() {
    return _buildInfoSection(
      title: "Professional Information",
      icon: Icons.work_outline,
      children: [
        _buildDetailItem(
          "Branch",
          widget.employee.branch,
          Icons.location_on_outlined,
        ),
        _buildDetailItem(
          "Date of Joining",
          widget.employee.doj,
          Icons.calendar_today_outlined,
        ),
        _buildDetailItem(
          "Designation",
          widget.employee.designation,
          Icons.badge_outlined,
        ),
      ],
    );
  }

  Widget _buildSalaryDetails() {
    return _buildInfoSection(
      title: "Salary Components",
      icon: Icons.account_balance_wallet_outlined,
      children: [
        _buildDetailItem(
          "Gross Salary",
          "₹${widget.employee.monthlyCTC}",
          Icons.currency_rupee,
        ),
        _buildDetailItem(
          "Annual CTC",
          "₹${widget.employee.annualCTC}",
          Icons.account_balance,
        ),
        _buildDetailItem(
          "Monthly CTC",
          "₹${widget.employee.monthlyCTC}",
          Icons.currency_rupee,
        ),
        _buildDetailItem(
          "Basic Salary",
          "₹${widget.employee.basic}",
          Icons.account_balance_outlined,
        ),
        _buildDetailItem("HRA", "₹${widget.employee.hra}", Icons.home_outlined),
        _buildDetailItem(
          "Allowances",
          "₹${widget.employee.allowance}",
          Icons.add_circle_outline,
        ),
      ],
    );
  }

  Widget _buildDeductionsDetails() {
    return _buildInfoSection(
      title: "Deductions & Take Home",
      icon: Icons.receipt_long_outlined,
      children: [
        _buildDetailItem(
          "Provident Fund (PF)",
          "₹${widget.employee.pf}",
          Icons.savings_outlined,
        ),
        _buildDetailItem(
          "ESI",
          "₹${widget.employee.esi}",
          Icons.medical_services_outlined,
        ),
        const Divider(height: 24, color: borderColor),
        _buildDetailItem(
          "Monthly Take Home",
          "₹${widget.employee.monthlyTakeHome}",
          Icons.account_balance,
          isHighlight: true,
        ),
      ],
    );
  }

  Widget _buildProfessionalFeeDetails() {
    return _buildInfoSection(
      title: "Professional Fee Details",
      icon: Icons.business_center_outlined,
      children: [
        _buildDetailItem(
          "Annual Professional Fee",
          "₹${widget.employee.annualProfessionalFee}",
          Icons.currency_rupee,
        ),
        _buildDetailItem(
          "Monthly Professional Fee",
          "₹${widget.employee.monthlyProfessionalFee}",
          Icons.account_balance_outlined,
        ),
        _buildDetailItem(
          "Monthly Professional TDS",
          "₹${widget.employee.monthlyProfessionalTds}",
          Icons.receipt_outlined,
        ),
      ],
    );
  }

  Widget _buildTravelAllowanceDetails() {
    return _buildInfoSection(
      title: "Travel Allowance Details",
      icon: Icons.flight_outlined,
      children: [
        _buildDetailItem(
          "Annual Travel Allowance",
          "₹${widget.employee.annualTravelAllowance}",
          Icons.flight_outlined,
        ),
        _buildDetailItem(
          "Monthly Travel Allowance",
          "₹${widget.employee.monthlyTravelAllowance}",
          Icons.directions_car_outlined,
        ),
        _buildDetailItem(
          "Monthly Travel TDS",
          "₹${widget.employee.monthlyTravelTds}",
          Icons.receipt_long_outlined,
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return _buildInfoSection(
      title: "Additional Information",
      icon: Icons.info_outline,
      children: [
        _buildDetailItem(
          "Department",
          widget.employee.department,
          Icons.business_outlined,
        ),
        _buildDetailItem(
          "Payroll Category",
          widget.employee.payrollCategory,
          Icons.category_outlined,
        ),
        _buildDetailItem(
          "Status",
          widget.employee.status,
          Icons.check_circle_outline,
        ),
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  secondaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isHighlight
                          ? primaryColor.withOpacity(0.1)
                          : primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isHighlight ? primaryColor : primaryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isHighlight ? FontWeight.w700 : FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                        color: isHighlight ? primaryColor : textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isHighlight)
          Divider(color: borderColor.withOpacity(0.5), height: 1),
      ],
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "E",
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ),
    );
  }
}
