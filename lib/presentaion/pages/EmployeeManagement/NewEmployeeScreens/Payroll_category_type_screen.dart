import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Employee_management_Provider/Payroll_Category_Type_provider.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';


class PayrollCategoryTypeScreen extends StatefulWidget {
  final String empId;

  const PayrollCategoryTypeScreen({super.key, required this.empId});

  @override
  State<PayrollCategoryTypeScreen> createState() =>
      _PayrollCategoryTypeScreenState();
}

class _PayrollCategoryTypeScreenState extends State<PayrollCategoryTypeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<PayrollCategoryTypeProvider>().fetchEmployeeDetails(
        widget.empId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final newEmployeeBankDetailsProvider =
        Provider.of<PayrollCategoryTypeProvider>(context);

    return Column(
      children: [
        // Salary Calculation Section
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header with dropdown button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    newEmployeeBankDetailsProvider.toggleSalarySection();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(
                          newEmployeeBankDetailsProvider.showSalarySection
                              ? 0
                              : 8,
                        ),
                        bottomRight: Radius.circular(
                          newEmployeeBankDetailsProvider.showSalarySection
                              ? 0
                              : 8,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Salary",
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          newEmployeeBankDetailsProvider.showSalarySection
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF6B7280),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Expandable content
              if (newEmployeeBankDetailsProvider.showSalarySection) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Payroll Category Type Dropdown
                      CustomSearchDropdownWithSearch(
                        isMandatory: true,
                        labelText: "Payroll category type",
                        items:
                            newEmployeeBankDetailsProvider.payrollCategoryType,
                        selectedValue:
                            newEmployeeBankDetailsProvider
                                .selectedPayrollCategoryType,
                        onChanged: (value) {
                          newEmployeeBankDetailsProvider
                              .setSelectedPayrollCategoryType(value);
                        },
                        hintText: "Select Payroll Category Type..",
                      ),
                      const SizedBox(height: 16),

                      // Dynamic fields based on selection
                      if (newEmployeeBankDetailsProvider
                              .selectedPayrollCategoryType ==
                          "By professional") ...[
                        // Professional Fields
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.end, // Add this line
                          children: [
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                controller:
                                    newEmployeeBankDetailsProvider
                                        .annualProfessionalFeeController,
                                labelText: "Annual professional Fee",
                                isMandatory: true,
                                keyboardType: TextInputType.number,
                                hintText: '',
                                readOnly: false,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1565C0),
                                      Color(0xFF0D47A1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    newEmployeeBankDetailsProvider
                                        .calculateProfessionalFee();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors
                                            .transparent, // Make background transparent
                                    shadowColor:
                                        Colors.transparent, // Remove shadow
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Calculate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Calculated Professional Values (Read-only)
                        _buildCalculatedField(
                          "Monthly Professional Fee (Before TDS)",
                          newEmployeeBankDetailsProvider
                              .monthlyProfessionalFeeBeforeTDS,
                        ),
                        _buildCalculatedField(
                          "Monthly TDS",
                          "₹ ${newEmployeeBankDetailsProvider.tdsAmount}",
                        ),
                        _buildCalculatedField(
                          "Monthly Professional Fee (After TDS)",
                          newEmployeeBankDetailsProvider
                              .monthlyProfessionalFeeAfterTDS,
                        ),

                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.end, // Add this line

                          children: [
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                controller:
                                    newEmployeeBankDetailsProvider
                                        .annualTravelAllowanceController,
                                labelText: "Annual Travel Allowance",
                                isMandatory: true,
                                keyboardType: TextInputType.number,
                                hintText: '',
                                readOnly: false,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1565C0),
                                      Color(0xFF0D47A1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    newEmployeeBankDetailsProvider
                                        .calculateTravelAllowance();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors
                                            .transparent, // Make background transparent
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Calculate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Calculated Travel Values (Read-only)
                        _buildCalculatedField(
                          "Monthly Travel Allowance (Before TDS)",
                          newEmployeeBankDetailsProvider
                              .monthlyTravelAllowanceBeforeTDS,
                        ),
                        _buildCalculatedField(
                          "TDS",
                          newEmployeeBankDetailsProvider.travelTdsAmount,
                        ),
                        _buildCalculatedField(
                          "Monthly Travel Allowance (After TDS)",
                          newEmployeeBankDetailsProvider
                              .monthlyTravelAllowanceAfterTDS,
                        ),
                      ] else if (newEmployeeBankDetailsProvider
                              .selectedPayrollCategoryType ==
                          "By student") ...[
                        // Student Fields
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                controller:
                                    newEmployeeBankDetailsProvider
                                        .annualStipendController,
                                labelText: "Annual Stipend",
                                isMandatory: true,
                                keyboardType: TextInputType.number,
                                hintText: '',
                                readOnly: false,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1565C0),
                                      Color(0xFF0D47A1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    newEmployeeBankDetailsProvider
                                        .calculateStipend();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors
                                            .transparent, // Make background transparent
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Calculate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Calculated Stipend Value (Read-only)
                        _buildCalculatedField(
                          "Monthly Stipend",
                          newEmployeeBankDetailsProvider.monthlyStipend,
                        ),
                      ] else if (newEmployeeBankDetailsProvider
                              .selectedPayrollCategoryType ==
                          "By Employee") ...[
                        // Employee Fields
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .end, // Change this from mainAxisAlignment
                          children: [
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                controller:
                                    newEmployeeBankDetailsProvider
                                        .ctcController,
                                labelText: "CTC",
                                isMandatory: true,
                                keyboardType: TextInputType.number,
                                hintText: '',
                                readOnly: false,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 20,
                                ), // Add padding to push button down
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1565C0),
                                        Color(0xFF0D47A1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      newEmployeeBankDetailsProvider
                                          .calculateEmployeeSalary();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors
                                              .transparent, // Make background transparent
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text(
                                      'Calculate',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Calculated Employee Values (Read-only)
                        _buildCalculatedField(
                          "Monthly Salary",
                          newEmployeeBankDetailsProvider.monthlySalary,
                        ),
                        _buildCalculatedField(
                          "Monthly (Basic)",
                          newEmployeeBankDetailsProvider.monthlyBasic,
                        ),
                        _buildCalculatedField(
                          "HRA",
                          "₹${newEmployeeBankDetailsProvider.hraAmount}",
                        ),
                        _buildCalculatedField(
                          "Allowance",
                          "₹${newEmployeeBankDetailsProvider.allowanceAmount}",
                        ),
                        _buildCalculatedField(
                          "PF",
                          "₹${newEmployeeBankDetailsProvider.pfAmount}",
                        ),
                        _buildCalculatedField(
                          "ESI",
                          newEmployeeBankDetailsProvider.esiAmount,
                        ),
                        _buildCalculatedField(
                          "Monthly Take-Home Salary",
                          newEmployeeBankDetailsProvider.monthlyTakeHomeSalary,
                        ),
                      ] else if (newEmployeeBankDetailsProvider
                              .selectedPayrollCategoryType ==
                          "By Employee F-11") ...[
                        // Employee F-11 Fields
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                controller:
                                    newEmployeeBankDetailsProvider
                                        .ctcF11Controller,
                                labelText: "CTC",
                                isMandatory: true,
                                keyboardType: TextInputType.number,
                                hintText: '',
                                readOnly: false,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1565C0),
                                        Color(0xFF0D47A1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      newEmployeeBankDetailsProvider
                                          .calculateF11Salary();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors
                                              .transparent, // Make background transparent
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text(
                                      'Calculate',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Calculated F-11 Values (Read-only)
                        _buildCalculatedField(
                          "Monthly Salary",
                          newEmployeeBankDetailsProvider.monthlyF11Salary,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build calculated fields - MOVED OUTSIDE build method
  Widget _buildCalculatedField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontFamily: AppFonts.poppins,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
              fontFamily: AppFonts.poppins,
            ),
          ),
        ],
      ),
    );
  }
}
