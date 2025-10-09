import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/PaySlipsDrawerProvider/PaySlipsDrawerProvider.dart';
import 'PayrollDetailsScreen.dart';

class PaySlipDrawerScreen extends StatefulWidget {
  const PaySlipDrawerScreen({super.key});

  @override
  State<PaySlipDrawerScreen> createState() => _PaySlipDrawerScreenState();
}

class _PaySlipDrawerScreenState extends State<PaySlipDrawerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaySlipsDrawerProvider>().loadEmployees();
      context.read<PaySlipsDrawerProvider>().loadLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "PaySlips Details"),
      body: Consumer<PaySlipsDrawerProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Type Dropdown
                  const Text(
                    'Search Type *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: provider.searchType,
                      hint: const Text(
                        'Select Search Type',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontFamily: AppFonts.poppins,
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      ),
                      items:
                          ['By Employee', 'By Month and Location']
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) provider.setSearchType(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Employee Search Section
                  if (provider.searchType == 'By Employee') ...[
                    const Text(
                      'Employee Name *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF424242),
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: provider.selectedEmployee,
                        hint: const Text(
                          'Select Employee',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontFamily: AppFonts.poppins,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                        items:
                            provider.employees
                                .map(
                                  (emp) => DropdownMenuItem(
                                    value: emp.id,
                                    child: Text(
                                      '${emp.id}-${emp.name} (${emp.designation})',
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          provider.setSelectedEmployee(value);
                        },
                      ),
                    ),
                  ],

                  // Location and Month Search Section
                  if (provider.searchType == 'By Month and Location') ...[
                    // Location Dropdown
                    const Text(
                      'Location *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF424242),
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: provider.selectedLocation,
                        hint: const Text(
                          'Select Location',
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontFamily: AppFonts.poppins,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                        items:
                            provider.locations
                                .map(
                                  (loc) => DropdownMenuItem(
                                    value: loc,
                                    child: Text(loc),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => provider.setSelectedLocation(value),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Month Picker
                    const Text(
                      'Select Month *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF424242),
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF9C27B0),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) provider.setSelectedMonth(date);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              provider.selectedMonth != null
                                  ? DateFormat(
                                    'MMMM yyyy',
                                  ).format(provider.selectedMonth!)
                                  : 'Select Month',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    provider.selectedMonth != null
                                        ? Colors.black87
                                        : Colors.grey,
                                fontFamily: AppFonts.poppins,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Color(0xFF9C27B0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Go Button (Always Visible)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (provider.searchType == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select search type',
                                style: TextStyle(fontFamily: AppFonts.poppins),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (provider.searchType == 'By Employee') {
                          if (provider.selectedEmployee != null) {
                            provider.searchPayslipsByEmployee(
                              provider.selectedEmployee!,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select an employee',
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          if (provider.selectedLocation != null &&
                              provider.selectedMonth != null) {
                            provider.searchPayslipsByLocationMonth(
                              provider.selectedLocation!,
                              provider.selectedMonth!,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select location and month',
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C6BC0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Go',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Loading or Payroll Summary
                  if (provider.isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF9C27B0),
                      ),
                    )
                  else if (provider.payslips.isNotEmpty) ...[
                    const Text(
                      'Payroll Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF424242),
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.payslips.length,
                      itemBuilder: (context, index) {
                        final payslip = provider.payslips[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            payslip.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF424242),
                                              fontFamily: AppFonts.poppins,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'ID: ${payslip.empId} • ${payslip.designation}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                              fontFamily: AppFonts.poppins,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF9C27B0,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        payslip.monthYear,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF9C27B0),
                                          fontFamily: AppFonts.poppins,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Divider(height: 1),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _InfoItem(
                                        label: 'Working Days',
                                        value: '${payslip.workingDays}',
                                        icon: Icons.calendar_today,
                                      ),
                                    ),
                                    Expanded(
                                      child: _InfoItem(
                                        label: 'LOP Days',
                                        value: '${payslip.lopDays}',
                                        icon: Icons.event_busy,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _InfoItem(
                                        label: 'Gross Salary',
                                        value:
                                            '₹${payslip.grossSalary.toStringAsFixed(2)}',
                                        icon: Icons.account_balance_wallet,
                                      ),
                                    ),
                                    Expanded(
                                      child: _InfoItem(
                                        label: 'Total Deductions',
                                        value:
                                            '₹${payslip.totalDeductions.toStringAsFixed(2)}',
                                        icon: Icons.remove_circle_outline,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Net Salary',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[800],
                                          fontFamily: AppFonts.poppins,
                                        ),
                                      ),
                                      Text(
                                        '₹${payslip.netSalary.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                          fontFamily: AppFonts.poppins,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        child:
                                            provider.isDownloadingPayslip(
                                                  payslip.id,
                                                )
                                                ? Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFF4CAF50,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Center(
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                              Color
                                                            >(Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                : ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final success =
                                                        await provider
                                                            .downloadPayslip(
                                                              payslip,
                                                            );
                                                    if (context.mounted) {
                                                      if (success) {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              "Payslip downloaded successfully: ${payslip.fileName}",
                                                              style: const TextStyle(
                                                                fontFamily:
                                                                    AppFonts
                                                                        .poppins,
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                Colors.green,
                                                            duration:
                                                                const Duration(
                                                                  seconds: 2,
                                                                ),
                                                          ),
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              "Failed to download payslip",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppFonts
                                                                        .poppins,
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                Colors.red,
                                                            duration: Duration(
                                                              seconds: 2,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  label: const Text(
                                                    'Download Payslip',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily:
                                                          AppFonts.poppins,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF4CAF50),
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 12,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    context,
                                                  ) => PayrollDetailsScreen(
                                                    payslipId: payslip.id,
                                                    monthYear:
                                                        payslip
                                                            .monthYear, // Adjust this field name as per your payslip model
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6A1B9A),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Text(
                                                'Payroll Details',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: AppFonts.poppins,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: AppFonts.poppins,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424242),
              fontFamily: AppFonts.poppins,
            ),
          ),
        ),
      ],
    );
  }
}
