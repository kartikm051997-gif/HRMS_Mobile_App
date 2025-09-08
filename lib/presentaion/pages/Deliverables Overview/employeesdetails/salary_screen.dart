import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/salary_details_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/bank_details_provider.dart';
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

class _SalaryScreenState extends State<SalaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalaryDetailsProvider>().fetchSalaryDetails(widget.empId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final salaryDetailsProvider = context.watch<SalaryDetailsProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              "Bank Details",
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // ✅ Conditional UI
            Expanded(
              child:
                  salaryDetailsProvider.isLoading
                      ? const CustomCardShimmer(
                        itemCount: 1,
                      ) // ✅ Show shimmer when loading
                      : salaryDetailsProvider.salaryDetails.isEmpty
                      ? const Center(
                        child: Text(
                          "No salary details found.",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppFonts.poppins,
                            color: Colors.black54,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: salaryDetailsProvider.salaryDetails.length,
                        itemBuilder: (context, index) {
                          final salary =
                              salaryDetailsProvider.salaryDetails[index];
                          return Card(
                            color: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.grey.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ✅ Bank Name Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Annual CTC:",
                                        style: TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          salary["annual CTC"] ?? "420000",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontFamily: AppFonts.poppins,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // ✅ Account Number Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Monthly Salary:",
                                        style: TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          salary["monthly salary"] ?? "35000",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontFamily: AppFonts.poppins,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // ✅ IFSC Code Row
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
