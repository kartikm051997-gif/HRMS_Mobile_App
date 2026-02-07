import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:provider/provider.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/Employee_Details_Provider.dart';
import '../../../../provider/Deliverables_Overview_provider/payslip_provider.dart';
import '../../../../model/EmployeeDetailsModel/employee_details_model.dart';
import 'PayslipPdfTemplate.dart';

class PaySlipScreen extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;

  const PaySlipScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<PaySlipScreen> createState() => _PaySlipScreenState();
}

class _PaySlipScreenState extends State<PaySlipScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    Future.delayed(Duration.zero, () {
      // Fetch payslips
      context.read<PaySlipProvider>().fetchPaySlip(widget.empId);

      // Fetch employee details
      context.read<EmployeeDetailsProvider>().fetchEmployeeDetails(
        widget.empId,
      );

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer2<PaySlipProvider, EmployeeDetailsProvider>(
          builder: (context, paySlipProvider, employeeProvider, child) {
            if (paySlipProvider.isLoading || employeeProvider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF5B7FFF),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      employeeProvider.isLoading
                          ? "Loading employee details..."
                          : "Loading payslips...",
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (paySlipProvider.payslip.isEmpty) {
              return _buildEmptyState();
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "Payslip History",
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor1,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5B7FFF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "${paySlipProvider.payslip.length} ${paySlipProvider.payslip.length == 1 ? 'Payslip' : 'Payslips'}",
                            style: const TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payslip List
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: paySlipProvider.payslip.length,
                      itemBuilder: (context, index) {
                        final payslipItem = paySlipProvider.payslip[index];
                        return _buildPayslipCard(
                          payslipItem,
                          index,
                          employeeProvider,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
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
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5B7FFF).withOpacity(0.1),
                  const Color(0xFF9333EA).withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Color(0xFF5B7FFF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Payslips Available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your payslip records will appear here",
            style: TextStyle(
              fontSize: 13,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipCard(
    PayslipItem payslipItem,
    int index,
    EmployeeDetailsProvider employeeProvider,
  ) {
    // Calculate colors based on index for variety
    final cardColors = [
      [const Color(0xFF5B7FFF), const Color(0xFF9333EA)],
      [const Color(0xFF10B981), const Color(0xFF059669)],
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
    ];

    final colorSet = cardColors[index % cardColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorSet[0].withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorSet[0].withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              () =>
                  _openPayslipTemplate(context, payslipItem, employeeProvider),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor1,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorSet[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payslipItem.salaryMonth ?? 'Unknown',
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  payslipItem.createdDate ?? '-',
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  size: 12,
                                  color: AppColor.primaryColor1,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "₹${payslipItem.netSalary ?? '0'}",
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primaryColor1,
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
                // Arrow Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorSet[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: colorSet[0],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPayslipTemplate(
    BuildContext context,
    PayslipItem payslipItem,
    EmployeeDetailsProvider employeeProvider,
  ) {
    // Create EmployeeDetailsData from provider's structured getters
    final employeeData = EmployeeDetailsData(
      basicInfo: employeeProvider.basicInfo,
      professionalInfo: employeeProvider.professionalInfo,
      bankDetails: employeeProvider.bankDetails,
      salaryDetails: employeeProvider.salaryDetails,
      addressInfo: employeeProvider.addressInfo,
      recruiter: employeeProvider.recruiter,
      createdBy: employeeProvider.createdBy,
      documents: employeeProvider.documents,
      letters: employeeProvider.letters,
      circulars: employeeProvider.circulars,
      payslips: employeeProvider.payslips,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PayslipPdfTemplate(
              payslip: payslipItem,
              employeeData: employeeData,
            ),
      ),
    );
  }
}
