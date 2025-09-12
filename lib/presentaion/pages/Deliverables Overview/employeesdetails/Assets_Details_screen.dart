import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/Assets_Details_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../widgets/shimmer_custom_screen/shimmer_custom_screen.dart';

class AssetsDetailsScreen extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;

  const AssetsDetailsScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<AssetsDetailsScreen> createState() => _AssetsDetailsScreenState();
}

class _AssetsDetailsScreenState extends State<AssetsDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetsDetailsProvider>().fetchAssetsDetails(widget.empId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final assetsDetailsProvider = Provider.of<AssetsDetailsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Assets Details",
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),

            // ✅ Conditional UI
            Expanded(
              child:
                  assetsDetailsProvider.isLoading
                      ? const CustomCardShimmer(
                        itemCount: 1,
                      ) // ✅ Show shimmer when loading
                      : assetsDetailsProvider.assetsDetails.isEmpty
                      ? const Center(
                        child: Text(
                          "No Assets details found.",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: AppFonts.poppins,
                            color: Colors.black54,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: assetsDetailsProvider.assetsDetails.length,
                        itemBuilder: (context, index) {
                          final assetsDetails =
                              assetsDetailsProvider.assetsDetails[index];
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
                                          assetsDetails["date"] ?? "11-02-2025",
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
                                        "Laptop :",
                                        style: TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          assetsDetails.containsKey("Laptop") &&
                                                  assetsDetails["Laptop"] !=
                                                      null
                                              ? assetsDetails["Laptop"]
                                                  .toString()
                                              : "not found",
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
                                        "Sim Number :",
                                        style: TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          assetsDetails.containsKey(
                                                    "Sim Number",
                                                  ) &&
                                                  assetsDetails["Sim Number"] !=
                                                      null &&
                                                  assetsDetails["Sim Number"]
                                                      .toString()
                                                      .trim()
                                                      .isNotEmpty
                                              ? assetsDetails["Sim Number"]
                                                  .toString()
                                              : "not found",

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
                                        "Tablet :",
                                        style: TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A237E),
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          assetsDetails.containsKey("Tablet") &&
                                                  assetsDetails["Tablet"] !=
                                                      null &&
                                                  assetsDetails["Tablet"]
                                                      .toString()
                                                      .trim()
                                                      .isNotEmpty
                                              ? assetsDetails["Tablet"]
                                                  .toString()
                                              : "not found",

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
