import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/ESI_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/fonts/fonts.dart';
import '../../../../widgets/shimmer_custom_screen/shimmer_custom_screen.dart';

class ESIScreen extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;

  const ESIScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<ESIScreen> createState() => _ESIScreenState();
}

class _ESIScreenState extends State<ESIScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ESIProvider>().fetchESIDetails(widget.empId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final esiProvider = context.watch<ESIProvider>();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "ESI Details",
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
                  esiProvider.isLoading
                      ? const CustomCardShimmer(
                        itemCount: 1,
                      ) // ✅ Show shimmer when loading
                      : esiProvider.ESIDetails.isEmpty
                      ? const Center(
                        child: Text(
                          "No ESI details found.",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppFonts.poppins,
                            color: Colors.black54,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: esiProvider.ESIDetails.length,
                        itemBuilder: (context, index) {
                          final salary = esiProvider.ESIDetails[index];
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
                                        "Date :",
                                        style: TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          salary["date"] ?? "11-02-2025	",
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
                                        "ESI Month	:",
                                        style: TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          salary["esi Month	"] ??
                                              "January 2025	",
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "ESI Amount :",
                                        style: TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          salary["esi Amount"] ?? "0.00",
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
