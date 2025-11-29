import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

class _DocumentsScreenState extends State<DocumentsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Gradient colors - Light attractive theme
  static const Color primaryColor = Color(0xFF7C3AED);
  static const Color secondaryColor = Color(0xFFEC4899);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    Future.microtask(() {
      context.read<DocumentProvider>().initializeDocuments();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _openDocument(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar("Failed to open document", false);
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
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
    final isSuccess = result.contains('✅');
    _showSnackBar(result, isSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<DocumentProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primaryColor, secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.folder_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          "Documents",
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      if (!provider.isLoading && provider.documents.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${provider.documents.length} Files",
                            style: const TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Content
                  Expanded(
                    child: provider.isLoading
                        ? const CustomCardShimmer(itemCount: 4)
                        : provider.documents.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: provider.documents.length,
                                itemBuilder: (context, index) {
                                  final doc = provider.documents[index];
                                  final isDownloading =
                                      provider.isDocumentDownloading(doc["id"]);

                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(
                                        milliseconds: 400 + (index * 100)),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _buildDocumentCard(
                                      doc,
                                      isDownloading,
                                      provider,
                                    ),
                                  );
                                },
                              ),
                  ),

                  const SizedBox(height: 16),

                  // Approve Button
                  _buildApproveButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  secondaryColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_off_rounded,
              size: 48,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Documents Available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Document files will appear here",
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    Map<String, dynamic> doc,
    bool isDownloading,
    DocumentProvider provider,
  ) {
    final title = doc["title"] ?? "Document";
    final uploadDate = doc["uploadDate"] ?? "Unknown";
    final isDownloadable = doc["isDownloadable"] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDocumentIcon(doc["fileExtension"]),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            uploadDate,
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (doc["fileExtension"] ?? "PDF").toString().toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Document Info
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.insert_drive_file_rounded,
                          color: Color(0xFF3B82F6),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "File Type",
                              style: TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              "${(doc["fileExtension"] ?? "PDF").toString().toUpperCase()} Document",
                              style: const TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Row(
                  children: [
                    // View Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openDocument(doc["url"]),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.visibility_rounded,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    if (isDownloadable) ...[
                      const SizedBox(width: 10),
                      // Download Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isDownloading
                              ? null
                              : () => _handleDownload(
                                    provider,
                                    doc["id"],
                                    doc["url"],
                                    doc["title"] ?? 'document',
                                    doc["fileExtension"] ?? 'pdf',
                                  ),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [primaryColor, secondaryColor],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: isDownloading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.download_rounded,
                                    color: Colors.white,
                                    size: 20,
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
        ],
      ),
    );
  }

  Widget _buildApproveButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showSnackBar("Documents approved successfully!", true);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryColor, secondaryColor],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                "Approve Documents",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}
