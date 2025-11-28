import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/PaySlipsDrawerProvider/PayrollDetailsProvider.dart';

class PayrollDetailsScreen extends StatefulWidget {
  final String payslipId;
  final String monthYear;

  const PayrollDetailsScreen({
    super.key,
    required this.payslipId,
    required this.monthYear,
  });

  @override
  State<PayrollDetailsScreen> createState() => _PayrollDetailsScreenState();
}

class _PayrollDetailsScreenState extends State<PayrollDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  bool _allowancesExpanded = true;
  bool _deductionsExpanded = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayrollDetailsProvider>().loadPayrollDetails(
            widget.payslipId,
          );
    });
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _headerFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Payslip Details"),
      body: Consumer<PayrollDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8E0E6B).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      color: Color(0xFF8E0E6B),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Loading Payslip...',
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with Net Salary
                _buildHeaderSection(provider),

                // Content Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Salary Overview Card
                      _buildAnimatedCard(
                        delay: 0,
                        child: _buildSalaryOverviewCard(provider),
                      ),

                      const SizedBox(height: 16),

                      // Allowances Section
                      _buildAnimatedCard(
                        delay: 1,
                        child: _buildAllowancesSection(provider),
                      ),

                      const SizedBox(height: 16),

                      // Deductions Section
                      _buildAnimatedCard(
                        delay: 2,
                        child: _buildDeductionsSection(provider),
                      ),

                      const SizedBox(height: 16),

                      // Final Summary Card
                      _buildAnimatedCard(
                        delay: 3,
                        child: _buildFinalSummaryCard(provider),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(PayrollDetailsProvider provider) {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlideAnimation.value),
          child: Opacity(
            opacity: _headerFadeAnimation.value,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Month Year Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.monthYear,
                              style: const TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Net Salary Label
                      Text(
                        'Net Salary',
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Net Salary Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹',
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatCurrency(provider.netSalary),
                            style: const TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status Badge
                      _buildStatusBadge(provider.status),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = const Color(0xFF4CAF50).withOpacity(0.2);
        textColor = Colors.white;
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'pending':
        bgColor = const Color(0xFFFFC107).withOpacity(0.2);
        textColor = Colors.white;
        icon = Icons.schedule_rounded;
        break;
      case 'rejected':
        bgColor = const Color(0xFFF44336).withOpacity(0.2);
        textColor = Colors.white;
        icon = Icons.cancel_outlined;
        break;
      default:
        bgColor = Colors.white.withOpacity(0.2);
        textColor = Colors.white;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 6),
          Text(
            status.isNotEmpty ? status : 'N/A',
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _contentAnimationController,
      builder: (context, _) {
        final delayedValue = (_contentAnimationController.value - (delay * 0.15))
            .clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 30 * (1 - delayedValue)),
          child: Opacity(
            opacity: delayedValue,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildSalaryOverviewCard(PayrollDetailsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Salary Overview',
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  'Gross Salary',
                  '₹ ${provider.grossSalary.toStringAsFixed(2)}',
                  Icons.monetization_on_outlined,
                  const Color(0xFF667eea),
                ),
                _buildDivider(),
                _buildInfoRow(
                  'Total Days',
                  provider.totalDays.toString(),
                  Icons.calendar_today_rounded,
                  const Color(0xFF764ba2),
                ),
                _buildDivider(),
                _buildInfoRow(
                  'Worked Days',
                  provider.workedDays.toString(),
                  Icons.work_history_rounded,
                  const Color(0xFF4CAF50),
                ),
                _buildDivider(),
                _buildInfoRow(
                  'LOP Days',
                  provider.lopDays.toString(),
                  Icons.event_busy_rounded,
                  const Color(0xFFFF5722),
                ),
                _buildDivider(),
                _buildInfoRow(
                  'LOP Amount',
                  '₹ ${provider.lop.toStringAsFixed(2)}',
                  Icons.money_off_rounded,
                  const Color(0xFFE91E63),
                ),
                _buildDivider(),
                _buildInfoRow(
                  'Earned Amount',
                  '₹ ${provider.earnedAmount.toStringAsFixed(2)}',
                  Icons.payments_rounded,
                  const Color(0xFF00BCD4),
                  isHighlighted: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllowancesSection(PayrollDetailsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _allowancesExpanded = !_allowancesExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Allowances',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹ ${provider.totalAllowance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _allowancesExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAllowanceItem('Basic', provider.basicAllowance),
                  _buildAllowanceItem('HRA', provider.hraAllowance),
                  _buildAllowanceItem(
                      'Incentive Bonus', provider.incentiveBonus),
                  _buildAllowanceItem('Claim', provider.claimAllowance),
                  _buildAllowanceItem(
                      'TDS Not Applicable', provider.tdsNotApplicableAllowance),
                  if (provider.allowanceComments.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCommentsBox(
                      'Allowance Comments',
                      provider.allowanceComments,
                      const Color(0xFF11998e),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildTotalRow(
                    'Total Allowance',
                    provider.totalAllowance,
                    const Color(0xFF11998e),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
            crossFadeState: _allowancesExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionsSection(PayrollDetailsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _deductionsExpanded = !_deductionsExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFeb3349), Color(0xFFf45c43)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                      Icons.remove_circle_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Deductions',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹ ${provider.totalDeductions.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _deductionsExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDeductionItem('Provident Fund', provider.providentFund),
                  _buildDeductionItem('Professional Tax (PT)', provider.pt),
                  _buildDeductionItem('ESI', provider.esi),
                  _buildDeductionItem(
                      'Security Deposit', provider.securityDeposit),
                  _buildDeductionItem('Loan & Advance', provider.loanAdvance),
                  _buildDeductionItem('Training', provider.training),
                  _buildDeductionItem('Others', provider.othersDeduction),
                  if (provider.othersComments.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCommentsBox(
                      'Deduction Comments',
                      provider.othersComments,
                      const Color(0xFFeb3349),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildTotalRow(
                    'Total Deductions',
                    provider.totalDeductions,
                    const Color(0xFFeb3349),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
            crossFadeState: _deductionsExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalSummaryCard(PayrollDetailsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E0E6B).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // TDS Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'TDS',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹ ${provider.tds.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 16),

            // Net Salary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Color(0xFF8E0E6B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Net Salary',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '₹ ${provider.netSalary.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8E0E6B),
                    ),
                  ),
                ),
              ],
            ),

            if (provider.statusComments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.comment_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        provider.statusComments,
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 13,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    Color iconColor, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            padding: isHighlighted
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                : EdgeInsets.zero,
            decoration: isHighlighted
                ? BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: isHighlighted ? 15 : 14,
                fontWeight: FontWeight.w600,
                color: isHighlighted ? iconColor : const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 50),
      height: 1,
      color: Colors.grey.withOpacity(0.15),
    );
  }

  Widget _buildAllowanceItem(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF11998e),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Text(
            '₹ ${value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionItem(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFeb3349),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Text(
            '- ₹ ${value.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFeb3349),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsBox(String title, String comments, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                color: accentColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comments.isNotEmpty ? comments : '-',
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            '₹ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(2)} Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(2)} L';
    } else if (value >= 1000) {
      return value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    return value.toStringAsFixed(2);
  }
}
