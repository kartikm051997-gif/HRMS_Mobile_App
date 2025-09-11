import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/Circular_Details_Provider.dart';

class CircularDetailsScreen extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;
  const CircularDetailsScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<CircularDetailsScreen> createState() => _CircularDetailsScreenState();
}

class _CircularDetailsScreenState extends State<CircularDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<CircularProvider>().fetchCircular(widget.empId);
    });
  }

  String _formatDate(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(
        dateString,
      ); // expects yyyy-MM-dd
      return DateFormat("dd-MM-yyyy").format(parsedDate);
    } catch (e) {
      return dateString; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CircularProvider>(
        builder: (context, paySlipProvider, child) {
          if (paySlipProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paySlipProvider.documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No payslips available",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.poppins,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                const SizedBox(height: 8),

                // Document List
                Expanded(
                  child: ListView.separated(
                    itemCount: paySlipProvider.documents.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final document = paySlipProvider.documents[index];
                      final isDownloading =
                          paySlipProvider.isDownloading &&
                          paySlipProvider.downloadingDocumentId == document.id;

                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.grey.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date
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
                                      document.date,
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

                              // Circular Name (long text will wrap)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Circular Name :",
                                    style: TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      document.circularName,
                                      textAlign: TextAlign.right,
                                      softWrap: true,
                                      style: const TextStyle(
                                        fontFamily: AppFonts.poppins,
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),

                              // Download button aligned right
                              Align(
                                alignment: Alignment.bottomRight,
                                child:
                                    isDownloading
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.green,
                                                ),
                                          ),
                                        )
                                        : InkWell(
                                          onTap: () async {
                                            final success =
                                                await paySlipProvider
                                                    .downloadDocument(document);

                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    success
                                                        ? "Downloaded: ${document.fileName}"
                                                        : "Failed to download",
                                                  ),
                                                  backgroundColor:
                                                      success
                                                          ? Colors.green
                                                          : Colors.red,
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 25,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(
                                                  Icons.download,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  "View",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily:
                                                        AppFonts.poppins,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
