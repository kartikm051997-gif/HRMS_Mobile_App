import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/letter_provider.dart';
import '../../../../provider/Deliverables_Overview_provider/Employee_Details_Provider.dart';
import '../../../../provider/login_provider/login_provider.dart';

class LetterScreen extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;

  const LetterScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen>
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

    Future.delayed(Duration.zero, () {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // ✅ Changed background color
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<EmployeeDetailsProvider>(
          builder: (context, detailsProvider, _) {
            return Consumer<DocumentListProvider>(
              builder: (context, documentProvider, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (detailsProvider.employeeDetails != null) {
                    documentProvider.loadLettersFromProvider(
                      detailsProvider.employeeDetails,
                    );
                  }
                });
                if (documentProvider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(
                            color: Color(0xFF10B981),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Loading letters...",
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (documentProvider.letter.isEmpty) {
                  return _buildEmptyState();
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Changed Header Design
                      Row(
                        children: [
                          const Text(
                            "Letters",
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const Spacer(),
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
                              "${documentProvider.letter.length}",
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

                      // Letter List
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: documentProvider.letter.length,
                          itemBuilder: (context, index) {
                            final document = documentProvider.letter[index];
                            final isDownloading =
                                documentProvider.isDownloading &&
                                documentProvider.downloadingLetterId ==
                                    document.id;

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 400 + (index * 100),
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: _buildLetterCard(
                                document,
                                isDownloading,
                                documentProvider,
                              ),
                            );
                          },
                        ),
                      ),
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
              color: const Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mail_outline,
              size: 64,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Letters Available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Letter documents will appear here",
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
  Widget _buildLetterCard(
    dynamic document,
    bool isDownloading,
    DocumentListProvider documentProvider,
  ) {
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
          onTap: () => _openLetterContent(context, document, documentProvider),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF10B981),
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
                        document.letterType,
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
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
                            document.date,
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Keep all original functions unchanged
  Future<void> _openLetterContent(
    BuildContext context,
    dynamic document,
    DocumentListProvider provider,
  ) async {
    final htmlContent = document.content ?? "";
    final title = "${document.letterType} - ${document.date}";
    await _showPdfViewer(context, title, htmlContent, document);
  }

  Future<void> _showPdfViewer(
    BuildContext context,
    String title,
    String htmlContent,
    dynamic document,
  ) async {
    final pdf = await _htmlToPdf(htmlContent, title);
    final pdfBytes = await pdf.save();
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(
      '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await tempFile.writeAsBytes(pdfBytes);

    if (!context.mounted) return;
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
                      color: const Color(0xFF10B981), // ✅ Changed color
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
                              final letterProvider =
                                  Provider.of<DocumentListProvider>(
                                    context,
                                    listen: false,
                                  );
                              final docId =
                                  "${document.id}_${DateTime.now().millisecondsSinceEpoch}";
                              final fileName =
                                  document.fileName.isNotEmpty
                                      ? document.fileName.replaceAll(
                                        '.html',
                                        '.pdf',
                                      )
                                      : "letter_${document.id}_${document.date.replaceAll('/', '_')}.pdf";

                              try {
                                final result = await letterProvider
                                    .downloadFile(docId, htmlContent, fileName);
                                final isSuccess = result.contains('✅');
                                _showSnackBar(context, isSuccess, result);
                              } catch (e) {
                                _showSnackBar(
                                  context,
                                  false,
                                  "Download failed: ${e.toString()}",
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
                                        color: Color(0xFF10B981),
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
                        _showSnackBar(
                          context,
                          false,
                          "Failed to load PDF: $error",
                        );
                        Navigator.pop(context);
                      },
                    ).fromPath(tempFile.path),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<pw.Document> _htmlToPdf(String htmlContent, String title) async {
    final textContent =
        htmlContent
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&nbsp;', ' ')
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .trim();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Expanded(
                child: pw.Text(
                  textContent,
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  Future<void> _downloadHtmlContent(
    BuildContext context,
    dynamic document,
    String htmlContent,
  ) async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          final downloadsDir = Directory('${directory.path}/Download');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          directory = downloadsDir;
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        _showSnackBar(context, false, "Could not access storage directory");
        return;
      }

      final fileName =
          document.fileName.isNotEmpty
              ? document.fileName
              : "letter_${document.id}_${document.date.replaceAll('/', '_')}.html";
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      await file.writeAsString(htmlContent);

      if (await file.exists()) {
        _showSnackBar(context, true, "✅ Downloaded: $fileName");
      } else {
        _showSnackBar(context, false, "Failed to save file");
      }
    } catch (e) {
      _showSnackBar(context, false, "Download failed: ${e.toString()}");
    }
  }

  void _showSnackBar(BuildContext context, bool success, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: AppFonts.poppins),
              ),
            ),
          ],
        ),
        backgroundColor:
            success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
