import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/Deliverables_Overview_provider/automated_payroll_provider.dart';
import '../../../widgets/shimmer_custom_screen/shimmer_custom_screen.dart';

class AutomatedPayrollIndividualScreen extends StatefulWidget {
  final String empId;
  final String empPhoto;
  final String empName;
  final String empDesignation;
  final String empBranch;

  const AutomatedPayrollIndividualScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<AutomatedPayrollIndividualScreen> createState() =>
      _AutomatedPayrollIndividualScreenState();
}

class _AutomatedPayrollIndividualScreenState
    extends State<AutomatedPayrollIndividualScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AutomatedPayrollProvider>().fetchAutomatedPayroll(
        widget.empId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final payrollProvider = context.watch<AutomatedPayrollProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: const TabletMobileDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Automated Payroll",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body:
          payrollProvider.isLoading
              ? const CustomCardShimmer(itemCount: 4)
              : payrollProvider.payrollRecords.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: payrollProvider.payrollRecords.length,
                itemBuilder: (context, index) {
                  final record = payrollProvider.payrollRecords[index];
                  return _buildPayrollCard(record);
                },
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No Payroll Records Found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your payroll records will appear here",
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

  Widget _buildPayrollCard(Map<String, dynamic> record) {
    final status = record["status"] ?? "Pending";
    final statusColor =
        status == "Processed"
            ? const Color(0xFF059669)
            : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    record["month"] ?? "N/A",
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Salary Breakdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Gross Salary
                _buildSalaryRow(
                  "Gross Salary",
                  "₹ ${record["grossSalary"] ?? "0"}",
                  Icons.trending_up,
                  const Color(0xFF059669),
                ),
                const SizedBox(height: 12),

                // Deductions
                _buildSalaryRow(
                  "Deductions",
                  "₹ ${record["deductions"] ?? "0"}",
                  Icons.trending_down,
                  const Color(0xFFDC2626),
                ),
                const SizedBox(height: 16),

                // Divider
                Divider(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 16),

                // Net Salary (Highlighted)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 24,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Net Salary",
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
                        "₹ ${record["netSalary"] ?? "0"}",
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Details
                _buildInfoRow(
                  "Payment Method",
                  record["paymentMethod"] ?? "N/A",
                  Icons.payment,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  "Processed Date",
                  record["processedDate"] ?? "N/A",
                  Icons.calendar_today_outlined,
                ),

                if (record["transactionId"] != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    "Transaction ID",
                    record["transactionId"] ?? "N/A",
                    Icons.receipt_long_outlined,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryRow(
    String label,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
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
        Text(
          amount,
          style: TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
