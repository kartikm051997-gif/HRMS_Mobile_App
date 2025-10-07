import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

class _PayrollDetailsScreenState extends State<PayrollDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayrollDetailsProvider>().loadPayrollDetails(
        widget.payslipId,
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6A1B9A),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payroll Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Consumer<PayrollDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B9A)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Payroll Details
                _buildDetailRow(
                  'Gross Salary',
                  provider.grossSalary.toStringAsFixed(2),
                ),
                _buildDetailRow('Total Days', provider.totalDays.toString()),
                _buildDetailRow('Worked Days', provider.workedDays.toString()),
                _buildDetailRow('LOP Days', provider.lopDays.toString()),
                _buildDetailRow('LOP', provider.lop.toStringAsFixed(2)),
                _buildDetailRow(
                  'Earned Amount',
                  provider.earnedAmount.toStringAsFixed(2),
                ),

                // Allowances Section
                _buildSectionTitle('Allowances :'),
                _buildDetailRow(
                  'Basic',
                  provider.basicAllowance.toStringAsFixed(2),
                ),
                _buildDetailRow(
                  'HRA',
                  provider.hraAllowance.toStringAsFixed(2),
                ),
                _buildDetailRow(
                  'Incentive Bonus',
                  provider.incentiveBonus.toStringAsFixed(2),
                ),
                _buildDetailRow(
                  'Claim',
                  provider.claimAllowance.toStringAsFixed(2),
                ),
                _buildDetailRow(
                  'Allowance(TDS Not applicable)',
                  provider.tdsNotApplicableAllowance.toStringAsFixed(2),
                ),
                const SizedBox(height: 12),
                _buildTextField('Allowance Comments', maxLines: 3),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Total Allowance',
                  provider.totalAllowance.toString(),
                ),

                // Deductions Section
                _buildSectionTitle('Deductions :'),
                _buildDetailRow(
                  'Provident Fund',
                  provider.providentFund.toStringAsFixed(2),
                ),
                _buildDetailRow('PT', provider.pt.toStringAsFixed(2)),
                _buildDetailRow('ESI', provider.esi.toStringAsFixed(2)),
                _buildDetailRow(
                  'Security Deposit',
                  provider.securityDeposit.toStringAsFixed(2),
                ),
                _buildDetailRow(
                  'Loan & Advance',
                  provider.loanAdvance.toStringAsFixed(2),
                ),
                _buildDetailRow(
                  'Training',
                  provider.training.toStringAsFixed(2),
                ),
                _buildDetailRow(
                  'Others',
                  provider.othersDeduction.toStringAsFixed(2),
                ),
                const SizedBox(height: 12),
                _buildTextField('Others Comments', maxLines: 3),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Total Deductions',
                  provider.totalDeductions.toString(),
                ),

                // Final Details
                const SizedBox(height: 20),
                _buildDetailRow('TDS', provider.tds.toString()),
                _buildDetailRow(
                  'Net Salary',
                  provider.netSalary.toStringAsFixed(2),
                ),

                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.status.isEmpty
                                ? '-Select-'
                                : provider.status,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF666666),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                _buildTextField('Status Comments', maxLines: 3),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
