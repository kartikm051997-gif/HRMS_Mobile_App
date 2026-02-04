import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/document_provider.dart';
import '../../../../provider/Deliverables_Overview_provider/Employee_Details_Provider.dart';
import '../../../../provider/login_provider/login_provider.dart';
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
      context.read<EmployeeDetailsProvider>().fetchEmployeeDetails(
        widget.empId,
      );
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _openDocument(String url, String title) async {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final bool isAdmin = loginProvider.userRole == "1";

    if (!isAdmin) {
      _showSnackBar("Only admin users can view documents", false);
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35), // ✅ Orange theme
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white,
                          ),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) async {
                            if (value == 'download') {
                              Navigator.pop(context);
                              final docProvider = Provider.of<DocumentProvider>(
                                context,
                                listen: false,
                              );
                              final docId =
                                  "${title}_${DateTime.now().millisecondsSinceEpoch}";
                              final fileExtension =
                                  url
                                      .split('.')
                                      .last
                                      .split('?')
                                      .first
                                      .toLowerCase();
                              final fileName =
                                  "${title.replaceAll(' ', '_').replaceAll('-', '_')}.$fileExtension";

                              try {
                                final result = await docProvider.downloadFile(
                                  docId,
                                  url,
                                  fileName,
                                );
                                final isSuccess = result.contains('✅');
                                _showSnackBar(result, isSuccess);
                              } catch (e) {
                                _showSnackBar(
                                  "Download failed: ${e.toString()}",
                                  false,
                                );
                              }
                            }
                          },
                          itemBuilder:
                              (BuildContext context) => [
                                PopupMenuItem<String>(
                                  value: 'download',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.download_rounded,
                                        color: Color(0xFFFF6B35),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Download",
                                        style: TextStyle(
                                          fontFamily: AppFonts.poppins,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PDF(
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: false,
                      pageFling: true,
                      onError: (error) {
                        _showSnackBar("Failed to load PDF: $error", false);
                        Navigator.pop(context);
                      },
                    ).cachedFromUrl(
                      url,
                      placeholder:
                          (progress) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: progress,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFFFF6B35),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Loading PDF... ${(progress * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      errorWidget:
                          (error) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 48,
                                  color: Color(0xFFEF4444),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Failed to load PDF",
                                  style: const TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  error.toString(),
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFF6B35),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    "Close",
                                    style: TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      color: Colors.white,
                                    ),
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
          ),
    );
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

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final bool isAdmin = loginProvider.userRole == "1";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // ✅ Changed background
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<EmployeeDetailsProvider>(
          builder: (context, detailsProvider, _) {
            return Consumer<DocumentProvider>(
              builder: (context, docProvider, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (detailsProvider.employeeDetails != null) {
                    docProvider.loadDocumentsFromProvider(
                      detailsProvider.employeeDetails,
                    );
                  }
                });

                final provider = docProvider;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Changed Header Design
                      Row(
                        children: [
                          const Text(
                            "Documents",
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const Spacer(),
                          if (!provider.isLoading &&
                              provider.documents.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${provider.documents.length}",
                                style: const TextStyle(
                                  fontFamily: AppFonts.poppins,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Content
                      Expanded(
                        child:
                            provider.isLoading
                                ? const CustomCardShimmer(itemCount: 4)
                                : provider.documents.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: provider.documents.length,
                                  itemBuilder: (context, index) {
                                    final doc = provider.documents[index];

                                    return TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      duration: Duration(
                                        milliseconds: 400 + (index * 100),
                                      ),
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
                                        provider,
                                        isAdmin,
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
            );
          },
        ),
      ),
    );
  }

  // ✅ Changed Empty State Design
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8DB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_off_rounded,
              size: 64,
              color: Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Documents Available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Document files will appear here",
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Changed Card Design ONLY - Same function signature
  Widget _buildDocumentCard(
    Map<String, dynamic> doc,
    DocumentProvider provider,
    bool isAdmin,
  ) {
    final title = doc["title"] ?? "Document";
    final uploadDate = doc["uploadDate"] ?? "Available";
    final fileExtension =
        (doc["fileExtension"] ?? "PDF").toString().toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAdmin ? () => _openDocument(doc["url"] ?? "", title) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE8DB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDocumentIcon(doc["fileExtension"]),
                    color: const Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
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
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            uploadDate,
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE8DB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              fileExtension,
                              style: const TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow or Admin badge
                if (isAdmin)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Admin",
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Keep approve button (changed to match theme)
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
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
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
