import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/document_provider.dart';
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
          style: const TextStyle(
            fontFamily: AppFonts.poppins,
            fontWeight: FontWeight.w500,
            color: Colors.white,
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
    String fileName = "${title.replaceAll(' ', '_').replaceAll('-', '_')}.$fileExtension";
    final result = await provider.downloadFile(docId, url, fileName);
    final isSuccess = result.contains('✅');
    _showSnackBar(result, isSuccess ? Colors.green : Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DocumentProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: provider.isLoading
                      ? const CustomCardShimmer(itemCount: 4)
                      : provider.documents.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No documents available",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.poppins,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                    itemCount: provider.documents.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doc = provider.documents[index];
                      final isDownloading = provider.isDocumentDownloading(doc["id"]);

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
                              // Document Title
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Document Name :",
                                    style: TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      doc["title"] ?? "Document",
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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

                              // Upload Date
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Upload Date :",
                                    style: TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      doc["uploadDate"] ?? "Unknown",
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
                              const SizedBox(height: 15),

                              // Action Buttons
                              Row(
                                children: [
                                  // View Button
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _openDocument(doc["url"]),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 25,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.visibility,
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
                                                fontFamily: AppFonts.poppins,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (doc["isDownloadable"] == true) ...[
                                    const SizedBox(width: 12),
                                    // Download Button
                                    Expanded(
                                      child: isDownloading
                                          ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                "Downloading",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: AppFonts.poppins,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                          : InkWell(
                                        onTap: () => _handleDownload(
                                          provider,
                                          doc["id"],
                                          doc["url"],
                                          doc["title"] ?? 'document',
                                          doc["fileExtension"] ?? 'pdf',
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.download,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  "Download",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: AppFonts.poppins,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Approve Button
                InkWell(
                  onTap: () {
                    _showSnackBar("Documents approved successfully!", Colors.green);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Approve Documents",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}