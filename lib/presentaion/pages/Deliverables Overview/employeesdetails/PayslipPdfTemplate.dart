import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/fonts/fonts.dart';
import '../../../../model/EmployeeDetailsModel/employee_details_model.dart';

class PayslipPdfTemplate extends StatefulWidget {
  final PayslipItem payslip;
  final EmployeeDetailsData? employeeData;

  const PayslipPdfTemplate({
    super.key,
    required this.payslip,
    this.employeeData,
  });

  @override
  State<PayslipPdfTemplate> createState() => _PayslipPdfTemplateState();
}

class _PayslipPdfTemplateState extends State<PayslipPdfTemplate> {
  bool _isDownloading = false;

  // Get employee details safely
  String get employeeName => widget.employeeData?.basicInfo?.fullname ?? '-';
  String get designation =>
      widget.employeeData?.professionalInfo?.designation ?? '-';
  String get location => widget.employeeData?.professionalInfo?.branch ?? '-';
  String get empId => widget.employeeData?.basicInfo?.employmentId ?? '-';
  String get pfNumber => widget.employeeData?.salaryDetails?.pf ?? '-';
  String get esiNumber => widget.employeeData?.salaryDetails?.esi ?? '-';
  String get joiningDate =>
      widget.employeeData?.professionalInfo?.joiningDate ?? '-';

  @override
  void initState() {
    super.initState();
    // Debug: Print payslip data to see what we're getting
    debugPrint("📊 ===== PAYSLIP DATA DEBUG =====");
    debugPrint("Salary Month: ${widget.payslip.salaryMonth}");
    debugPrint("Basic: ${widget.payslip.basic}");
    debugPrint("HRA: ${widget.payslip.hra}");
    debugPrint("Allowance: ${widget.payslip.allowance}");
    debugPrint("Incentive/Bonus: ${widget.payslip.incentiveBonus}");
    debugPrint("Claim: ${widget.payslip.claim}");
    debugPrint("Total Allowances (API): ${widget.payslip.totalAllowances}");
    debugPrint("Gross Salary (API): ${widget.payslip.grossSalary}");
    debugPrint("---");
    debugPrint("PF: ${widget.payslip.pf}");
    debugPrint("ESI: ${widget.payslip.esi}");
    debugPrint("PT: ${widget.payslip.pt}");
    debugPrint("LOP: ${widget.payslip.lop}");
    debugPrint("Loan & Advance: ${widget.payslip.loanAdvance}");
    debugPrint("Training: ${widget.payslip.training}");
    debugPrint("Others: ${widget.payslip.others}");
    debugPrint("TDS: ${widget.payslip.tds}");
    debugPrint("Total Deductions (API): ${widget.payslip.totalDeductions}");
    debugPrint("---");
    debugPrint("Net Salary: ${widget.payslip.netSalary}");
    debugPrint("Worked Days: ${widget.payslip.workedDays}");
    debugPrint("LOP Days: ${widget.payslip.lopDays}");
    debugPrint("================================");
  }

  // Helper method to safely parse and calculate total earnings
  double _parseAmount(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    final cleanValue = value.replaceAll(',', '').trim();
    return double.tryParse(cleanValue) ?? 0.0;
  }

  // Calculate total earnings - use API total if individual components are missing
  String _calculateTotalEarnings() {
    // First check if API provides totalAllowances
    final apiTotalAllowances = _parseAmount(widget.payslip.totalAllowances);
    if (apiTotalAllowances > 0) {
      debugPrint("✅ Using API totalAllowances: $apiTotalAllowances");
      return apiTotalAllowances.toStringAsFixed(2);
    }

    // Otherwise calculate from individual components
    final basic = _parseAmount(widget.payslip.basic);
    final hra = _parseAmount(widget.payslip.hra);
    final allowance = _parseAmount(widget.payslip.allowance);
    final incentiveBonus = _parseAmount(widget.payslip.incentiveBonus);
    final claim = _parseAmount(widget.payslip.claim);

    final calculatedTotal = basic + hra + allowance + incentiveBonus + claim;

    // If still zero, try grossSalary
    if (calculatedTotal < 1.0) {
      final grossSalary = _parseAmount(widget.payslip.grossSalary);
      if (grossSalary > 0) {
        debugPrint("✅ Using grossSalary: $grossSalary");
        return grossSalary.toStringAsFixed(2);
      }
    }

    debugPrint("✅ Calculated from components: $calculatedTotal");
    return calculatedTotal.toStringAsFixed(2);
  }

  // Get total deductions - use API total
  String _getTotalDeductions() {
    final apiTotal = _parseAmount(widget.payslip.totalDeductions);
    if (apiTotal > 0) {
      return apiTotal.toStringAsFixed(2);
    }

    // Calculate manually if API doesn't provide
    final pf = _parseAmount(widget.payslip.pf);
    final esi = _parseAmount(widget.payslip.esi);
    final pt = _parseAmount(widget.payslip.pt);
    final lop = _parseAmount(widget.payslip.lop);
    final loan = _parseAmount(widget.payslip.loanAdvance);
    final training = _parseAmount(widget.payslip.training);
    final others = _parseAmount(widget.payslip.others);
    final tds = _parseAmount(widget.payslip.tds);

    final total = pf + esi + pt + lop + loan + training + others + tds;
    return total.toStringAsFixed(2);
  }

  // Helper method to format amount with commas (Indian format)
  String _formatAmount(String? amount) {
    if (amount == null || amount.isEmpty) return '0.00';

    final cleanValue = amount.replaceAll(',', '').trim();
    final numValue = double.tryParse(cleanValue) ?? 0.0;

    final formatted = numValue.toStringAsFixed(2);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Indian numbering system
    String result = '';
    int count = 0;
    bool firstGroup = true;

    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count == 3 && firstGroup) {
        result = ',$result';
        count = 0;
        firstGroup = false;
      } else if (count == 2 && !firstGroup) {
        result = ',$result';
        count = 0;
      }
      result = intPart[i] + result;
      count++;
    }

    return '₹$result.$decPart';
  }

  // Helper method to check if value is non-zero
  bool _isNonZero(String? value) {
    if (value == null || value.isEmpty) return false;
    final num = _parseAmount(value);
    return num > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B7FFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.payslip.salaryMonth ?? 'Payslip',
          style: const TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_isDownloading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () => _downloadPdf(context),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => _sharePdf(context),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildPayslipContent(),
      ),
    );
  }

  Widget _buildPayslipContent() {
    final totalEarnings = _calculateTotalEarnings();
    final totalDeductions = _getTotalDeductions();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Logo
          _buildHeader(),

          // Company Address
          _buildCompanyAddress(),

          const Divider(height: 1, thickness: 1),

          // Employee Details
          _buildEmployeeDetailsSection(),

          const Divider(height: 1, thickness: 2, color: Color(0xFFE5E7EB)),

          // Earnings Section
          _buildEarningsSection(totalEarnings),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

          // Deductions Section
          _buildDeductionsSection(totalDeductions),

          const Divider(height: 1, thickness: 2, color: Color(0xFFE5E7EB)),

          // Net Pay
          _buildNetPaySection(),

          // Footer Note
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  "This is a system generated payslip",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'assets/logo/company_logo.png',
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Dr.ARAVIND's IVF",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.pink.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "FERTILITY CENTRE",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 6,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Dr.ARAVIND's ",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.pink.shade700,
                        ),
                      ),
                      TextSpan(
                        text: "IVF",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.purple.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "FERTILITY & PREGNANCY CENTRE",
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyAddress() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Dr. Aravind's IVF Pvt Ltd",
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Administrative Office: 94-95, Guindy Industrial Estate,",
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
          Text(
            "Thiru Vi Ka Industrial Estate, Guindy, Chennai - 600032.",
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Employee Information",
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Employee Name", employeeName, "Emp ID", empId),
          const SizedBox(height: 12),
          _buildInfoRow("Designation", designation, "Location", location),
          const SizedBox(height: 12),
          _buildInfoRow(
            "Pay Period",
            widget.payslip.salaryMonth ?? "-",
            "Date of Joining",
            joiningDate,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            "Worked Days",
            widget.payslip.workedDays ?? "-",
            "LOP Days",
            widget.payslip.lopDays ?? "0",
          ),
          const SizedBox(height: 12),
          _buildInfoRow("PF Number", pfNumber, "ESI Number", esiNumber),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value1,
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value2,
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsSection(String totalEarnings) {
    // Check if we have individual breakdown or just total
    final hasBreakdown =
        _isNonZero(widget.payslip.basic) ||
        _isNonZero(widget.payslip.hra) ||
        _isNonZero(widget.payslip.allowance);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Earnings",
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.green[700],
                ),
              ),
              Text(
                "Amount",
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),

          // Show breakdown if available, otherwise show total directly
          if (hasBreakdown) ...[
            if (_isNonZero(widget.payslip.basic))
              _buildEarningItem("Basic Salary", widget.payslip.basic),
            if (_isNonZero(widget.payslip.hra))
              _buildEarningItem(
                "House Rent Allowance (HRA)",
                widget.payslip.hra,
              ),
            if (_isNonZero(widget.payslip.allowance))
              _buildEarningItem("Other Allowance", widget.payslip.allowance),
            if (_isNonZero(widget.payslip.incentiveBonus))
              _buildEarningItem(
                "Incentive/Bonus",
                widget.payslip.incentiveBonus,
              ),
            if (_isNonZero(widget.payslip.claim))
              _buildEarningItem("Claim", widget.payslip.claim),
          ] else ...[
            // If no breakdown, show gross salary or total allowances
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Gross Salary",
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    _formatAmount(totalEarnings),
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 20, thickness: 1),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Earnings",
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.green[700],
                ),
              ),
              Text(
                _formatAmount(totalEarnings),
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionsSection(String totalDeductions) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Deductions",
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.red[700],
                ),
              ),
              Text(
                "Amount",
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1),

          // Deduction Items (only show non-zero)
          if (_isNonZero(widget.payslip.pf))
            _buildDeductionItem("Provident Fund (PF)", widget.payslip.pf),
          if (_isNonZero(widget.payslip.esi))
            _buildDeductionItem(
              "Employee State Insurance (ESI)",
              widget.payslip.esi,
            ),
          if (_isNonZero(widget.payslip.pt))
            _buildDeductionItem("Professional Tax (PT)", widget.payslip.pt),
          if (_isNonZero(widget.payslip.lop))
            _buildDeductionItem("Loss of Pay (LOP)", widget.payslip.lop),
          if (_isNonZero(widget.payslip.loanAdvance))
            _buildDeductionItem("Loan & Advance", widget.payslip.loanAdvance),
          if (_isNonZero(widget.payslip.training))
            _buildDeductionItem("Training", widget.payslip.training),
          if (_isNonZero(widget.payslip.others))
            _buildDeductionItem("Others", widget.payslip.others),
          if (_isNonZero(widget.payslip.tds))
            _buildDeductionItem("TDS", widget.payslip.tds),

          const Divider(height: 20, thickness: 1),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Deductions",
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.red[700],
                ),
              ),
              Text(
                _formatAmount(totalDeductions),
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningItem(String label, String? amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            _formatAmount(amount),
            style: const TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionItem(String label, String? amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            _formatAmount(amount),
            style: const TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetPaySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF5B7FFF).withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Net Salary",
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Amount to be credited",
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            _formatAmount(widget.payslip.netSalary),
            style: const TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5B7FFF),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    setState(() => _isDownloading = true);

    try {
      final pdf = await _generatePdf();
      final bytes = await pdf.save();

      // Get downloads directory
      final directory = await getExternalStorageDirectory();
      final downloadsPath = Directory('/storage/emulated/0/Download');

      // Create file name
      final fileName =
          'Payslip_${widget.payslip.salaryMonth?.replaceAll(' ', '_') ?? 'Unknown'}.pdf';
      final file = File('${downloadsPath.path}/$fileName');

      // Write file
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Payslip downloaded to Downloads folder',
                    style: const TextStyle(fontFamily: AppFonts.poppins),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error downloading PDF: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final pdf = await _generatePdf();

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'Payslip_${widget.payslip.salaryMonth?.replaceAll(' ', '_') ?? 'Unknown'}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PDF: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    final totalEarnings = _calculateTotalEarnings();
    final totalDeductions = _getTotalDeductions();

    // Build earnings data (only non-zero items)
    List<List<String>> earningsData = [];

    final hasBreakdown =
        _isNonZero(widget.payslip.basic) ||
        _isNonZero(widget.payslip.hra) ||
        _isNonZero(widget.payslip.allowance);

    if (hasBreakdown) {
      if (_isNonZero(widget.payslip.basic)) {
        earningsData.add([
          'Basic Salary',
          _formatAmount(widget.payslip.basic).replaceAll('₹', ''),
        ]);
      }
      if (_isNonZero(widget.payslip.hra)) {
        earningsData.add([
          'House Rent Allowance',
          _formatAmount(widget.payslip.hra).replaceAll('₹', ''),
        ]);
      }
      if (_isNonZero(widget.payslip.allowance)) {
        earningsData.add([
          'Other Allowance',
          _formatAmount(widget.payslip.allowance).replaceAll('₹', ''),
        ]);
      }
      if (_isNonZero(widget.payslip.incentiveBonus)) {
        earningsData.add([
          'Incentive/Bonus',
          _formatAmount(widget.payslip.incentiveBonus!).replaceAll('₹', ''),
        ]);
      }
      if (_isNonZero(widget.payslip.claim)) {
        earningsData.add([
          'Claim',
          _formatAmount(widget.payslip.claim!).replaceAll('₹', ''),
        ]);
      }
    } else {
      earningsData.add([
        'Gross Salary',
        _formatAmount(totalEarnings).replaceAll('₹', ''),
      ]);
    }

    // Build deductions data (only non-zero items)
    List<List<String>> deductionsData = [];
    if (_isNonZero(widget.payslip.pf)) {
      deductionsData.add([
        'Provident Fund',
        _formatAmount(widget.payslip.pf).replaceAll('₹', ''),
      ]);
    }
    if (_isNonZero(widget.payslip.esi)) {
      deductionsData.add([
        'ESI',
        _formatAmount(widget.payslip.esi).replaceAll('₹', ''),
      ]);
    }
    if (_isNonZero(widget.payslip.pt)) {
      deductionsData.add([
        'Professional Tax',
        _formatAmount(widget.payslip.pt!).replaceAll('₹', ''),
      ]);
    }
    if (_isNonZero(widget.payslip.lop)) {
      deductionsData.add([
        'Loss of Pay (LOP)',
        _formatAmount(widget.payslip.lop!).replaceAll('₹', ''),
      ]);
    }
    if (_isNonZero(widget.payslip.loanAdvance)) {
      deductionsData.add([
        'Loan & Advance',
        _formatAmount(widget.payslip.loanAdvance!).replaceAll('₹', ''),
      ]);
    }
    if (_isNonZero(widget.payslip.training)) {
      deductionsData.add([
        'Training',
        _formatAmount(widget.payslip.training!).replaceAll('₹', ''),
      ]);
    }
    if (_isNonZero(widget.payslip.others)) {
      deductionsData.add([
        'Others',
        _formatAmount(widget.payslip.others!).replaceAll('₹', ''),
      ]);
    }
    if (_isNonZero(widget.payslip.tds)) {
      deductionsData.add([
        'TDS',
        _formatAmount(widget.payslip.tds!).replaceAll('₹', ''),
      ]);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Dr.ARAVIND's IVF",
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#E91E63'),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "FERTILITY & PREGNANCY CENTRE",
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // Company Address
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      "Dr. Aravind's IVF Pvt Ltd",
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      "Administrative Office: 94-95, Guindy Industrial Estate,",
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      "Thiru Vi Ka Industrial Estate, Guindy, Chennai - 600032.",
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 12),

              // Employee Details Header
              pw.Text(
                "Employee Information",
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
              pw.SizedBox(height: 12),

              // Employee Details Table
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(10),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                data: [
                  ['Employee Name', employeeName, 'Emp ID', empId],
                  ['Designation', designation, 'Location', location],
                  [
                    'Pay Period',
                    widget.payslip.salaryMonth ?? '-',
                    'Date of Joining',
                    joiningDate,
                  ],
                  [
                    'Worked Days',
                    widget.payslip.workedDays ?? '-',
                    'LOP Days',
                    widget.payslip.lopDays ?? '0',
                  ],
                  ['PF Number', pfNumber, 'ESI Number', esiNumber],
                ],
              ),

              pw.SizedBox(height: 20),

              // Earnings Section
              pw.Text(
                "Earnings",
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#059669'),
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(10),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headers: ['Component', 'Amount (₹)'],
                data: earningsData,
              ),

              pw.SizedBox(height: 8),

              // Total Earnings
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#D1FAE5'),
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Earnings',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '₹${_formatAmount(totalEarnings).replaceAll('₹', '')}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Deductions Section
              pw.Text(
                "Deductions",
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#DC2626'),
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.all(10),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: const pw.TextStyle(fontSize: 10),
                headers: ['Component', 'Amount (₹)'],
                data: deductionsData,
              ),

              pw.SizedBox(height: 8),

              // Total Deductions
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FEE2E2'),
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Deductions',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '₹${_formatAmount(totalDeductions).replaceAll('₹', '')}',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 12),

              // Net Pay
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#EEF2FF'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Net Salary',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Amount to be credited',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      _formatAmount(widget.payslip.netSalary),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#5B7FFF'),
                      ),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'This is a system generated payslip',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
