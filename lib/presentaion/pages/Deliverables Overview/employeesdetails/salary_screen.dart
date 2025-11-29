import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/salary_details_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../widgets/shimmer_custom_screen/shimmer_custom_screen.dart';

class SalaryScreen extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;

  const SalaryScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Gradient colors - Light attractive theme
  static const Color primaryColor = Color(0xFF7C3AED);
  static const Color secondaryColor = Color(0xFFEC4899);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalaryDetailsProvider>().fetchSalaryDetails(widget.empId);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salaryDetailsProvider = context.watch<SalaryDetailsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryColor, secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    "Salary Details",
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Content
              Expanded(
                child: salaryDetailsProvider.isLoading
                    ? const CustomCardShimmer(itemCount: 1)
                    : salaryDetailsProvider.salaryDetails.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: salaryDetailsProvider.salaryDetails.length,
                            itemBuilder: (context, index) {
                              final salary =
                                  salaryDetailsProvider.salaryDetails[index];
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration:
                                    Duration(milliseconds: 400 + (index * 100)),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildSalaryCard(salary, index),
                              );
                            },
                          ),
              ),
            ],
          ),
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
              Icons.payments_outlined,
              size: 48,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Salary Details Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Salary information will appear here",
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryCard(Map<String, dynamic> salary, int index) {
    final annualCTC = salary["annual CTC"] ?? "0";
    final monthlySalary = salary["monthly salary"] ?? "0";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Salary Information",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Current Package",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Salary Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Annual CTC Card
                _buildSalaryInfoCard(
                  "Annual CTC",
                  "₹ $annualCTC",
                  Icons.calendar_today_rounded,
                  const Color(0xFF10B981),
                ),
                const SizedBox(height: 12),
                // Monthly Salary Card
                _buildSalaryInfoCard(
                  "Monthly Salary",
                  "₹ $monthlySalary",
                  Icons.today_rounded,
                  primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
