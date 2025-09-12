import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/Deliverables_Overview_provider/document_provider.dart';
import '../../../../widgets/custom_botton/custom_gradient_button.dart';
import '../../../../widgets/shimmer_custom_screen/shimmer_custom_screen.dart';

class DocumentsScreen extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;

  const DocumentsScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize documents when screen loads
    Future.microtask(() {
      context.read<DocumentProvider>().initializeDocuments();
    });
  }

  Future<void> _openDocument(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar("Failed to open document", Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: AppFonts.poppins,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleDownload(
    DocumentProvider provider,
    String docId,
    String url,
    String title,
    String fileExtension,
  ) async {
    String fileName =
        "${title.replaceAll(' ', '_').replaceAll('-', '_')}.$fileExtension";
    final result = await provider.downloadFile(docId, url, fileName);

    // Show result message
    final isSuccess = result.contains('✅');
    _showSnackBar(result, isSuccess ? Colors.green : Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DocumentProvider>(
        builder: (context, provider, child) {
          if (provider.documents.isEmpty) {
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
            child: Column(
              children: [
                Expanded(
                  child:
                  provider.isLoading
                      ? const CustomCardShimmer(
                    itemCount: 4,
                  ) // ✅ Show shimmer when loading
                      : provider.documents.isEmpty
                      ? const Center(
                    child: Text(
                      "No PF details found.",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: AppFonts.poppins,
                        color: Colors.black54,
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.documents.length,
                    itemBuilder: (context, index) {
                      final doc = provider.documents[index];
                      final isDownloading = provider.isDocumentDownloading(
                        doc["id"],
                      );

                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Document header
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: provider
                                          .getTypeColor(doc["type"])
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      provider.getFileIcon(doc["type"]),
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doc["title"] ?? "Document",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: AppFonts.poppins,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A237E),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            // Container(
                                            //   padding: const EdgeInsets.symmetric(
                                            //     horizontal: 8,
                                            //     vertical: 4,
                                            //   ),
                                            //   decoration: BoxDecoration(
                                            //     color: provider.getTypeColor(doc["type"]),
                                            //     borderRadius: BorderRadius.circular(12),
                                            //   ),
                                            //   child: Text(
                                            //     doc["type"].toString().toUpperCase(),
                                            //     style: const TextStyle(
                                            //       fontSize: 10,
                                            //       fontFamily: AppFonts.poppins,
                                            //       fontWeight: FontWeight.w600,
                                            //       color: Colors.white,
                                            //     ),
                                            //   ),
                                            // ),
                                            Text(
                                              doc["size"] ?? "",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: AppFonts.poppins,
                                                color: Color(0xFF37474F),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Uploaded: ${doc["uploadDate"] ?? "Unknown"}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: AppFonts.poppins,
                                            color: Color(0xFF37474F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Action buttons
                              Row(
                                children: [
                                  // View Button
                                  Expanded(
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF42A5F5),
                                            Color(0xFF1565C0),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            () => _openDocument(doc["url"]),
                                        icon: const Icon(
                                          Icons.visibility,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          "View",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: AppFonts.poppins,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors
                                                  .transparent, // 👈 Transparent to show gradient
                                          shadowColor:
                                              Colors
                                                  .transparent, // 👈 Remove default shadow
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          elevation:
                                              0, // Optional: Remove default elevation
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Download Button
                                  if (doc["isDownloadable"] == true)
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            isDownloading
                                                ? null
                                                : () => _handleDownload(
                                                  provider,
                                                  doc["id"],
                                                  doc["url"],
                                                  doc["title"] ?? 'document',
                                                  doc["fileExtension"] ?? 'pdf',
                                                ),
                                        icon:
                                            isDownloading
                                                ? SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.green.shade700),
                                                  ),
                                                )
                                                : const Icon(
                                                  Icons.download,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                        label: Text(
                                          isDownloading
                                              ? provider
                                                      .downloadProgress
                                                      .isNotEmpty
                                                  ? provider.downloadProgress
                                                  : "Downloading..."
                                              : "Download",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: AppFonts.poppins,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              isDownloading
                                                  ? Colors.grey
                                                  : Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          elevation: 2,
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
                ),
                SizedBox(height: 5),
                CustomGradientButton(
                  width: MediaQuery.of(context).size.width / 3,
                  height: 40,
                  text: "Approved",
                  gradientColors: const [Color(0xFF42A5F5), Color(0xFF1565C0)],
                  onPressed: () {},
                ),

                SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
