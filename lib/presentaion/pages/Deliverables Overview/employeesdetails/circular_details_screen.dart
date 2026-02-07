import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/Circular_Details_Provider.dart';
import '../../../../provider/Deliverables_Overview_provider/Employee_Details_Provider.dart';
import '../../../../provider/login_provider/login_provider.dart';
import '../../../../widgets/shimmer_custom_screen/shimmer_custom_screen.dart';

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

class _CircularDetailsScreenState extends State<CircularDetailsScreen>
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
      context.read<CircularProvider>().fetchCircular(widget.empId);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(String dateString) {
    try {
      final DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat("dd MMM yyyy").format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<EmployeeDetailsProvider>(
          builder: (context, detailsProvider, _) {
            return Consumer<CircularProvider>(
              builder: (context, circularProvider, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (detailsProvider.employeeDetails != null) {
                    circularProvider.loadCircularsFromProvider(
                      detailsProvider.employeeDetails,
                    );
                  }
                });
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Circulars",
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const Spacer(),
                          if (!circularProvider.isLoading &&
                              circularProvider.circular.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B7FFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${circularProvider.circular.length}",
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

                      Expanded(
                        child:
                            circularProvider.isLoading
                                ? const CustomCardShimmer(itemCount: 4)
                                : circularProvider.circular.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: circularProvider.circular.length,
                                  itemBuilder: (context, index) {
                                    final document =
                                        circularProvider.circular[index];

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
                                      child: _buildCircularCard(
                                        document,
                                        circularProvider,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Color(0xFF5B7FFF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Circulars Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Circular notices will appear here",
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

  Widget _buildCircularCard(
    dynamic document,
    CircularProvider circularProvider,
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
          onTap:
              () => _openCircularContent(context, document, circularProvider),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.article_outlined,
                    color: Color(0xFF5B7FFF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.circularName,
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

  Future<void> _openCircularContent(
    BuildContext context,
    dynamic document,
    CircularProvider provider,
  ) async {
    try {
      final htmlContent = document.content ?? "";
      final title = document.circularName;

      if (kDebugMode) {
        print("Opening circular: $title");
        print("Content length: ${htmlContent.length}");
      }

      await _showPdfViewer(context, title, htmlContent, document);
    } catch (e) {
      if (kDebugMode) {
        print("Error opening circular: $e");
      }
      if (context.mounted) {
        _showSnackBar(
          context,
          false,
          "Failed to open circular: ${e.toString()}",
        );
      }
    }
  }

  Future<void> _showPdfViewer(
    BuildContext context,
    String title,
    String htmlContent,
    dynamic document,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B7FFF)),
            ),
      );

      final pdf = await _htmlToPdf(htmlContent, title, document);
      final pdfBytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await tempFile.writeAsBytes(pdfBytes);

      if (!context.mounted) return;

      // Close loading indicator
      Navigator.pop(context);

      // Show PDF viewer
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
                        color: const Color(0xFF5B7FFF),
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
                                final circularProvider =
                                    Provider.of<CircularProvider>(
                                      context,
                                      listen: false,
                                    );
                                final docId =
                                    "${document.id}_${DateTime.now().millisecondsSinceEpoch}";
                                final fileName =
                                    document.fileName.isNotEmpty
                                        ? document.fileName.replaceAll(
                                          '.pdf',
                                          '.pdf',
                                        )
                                        : "circular_${document.id}_${document.date.replaceAll('/', '_')}.pdf";

                                try {
                                  final result = await circularProvider
                                      .downloadFile(
                                        docId,
                                        htmlContent,
                                        fileName,
                                      );
                                  final isSuccess = result.contains('✅');
                                  if (context.mounted) {
                                    _showSnackBar(context, isSuccess, result);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    _showSnackBar(
                                      context,
                                      false,
                                      "Download failed: ${e.toString()}",
                                    );
                                  }
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
                                          color: Color(0xFF5B7FFF),
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
                          if (kDebugMode) {
                            print("PDF Error: $error");
                          }
                          if (context.mounted) {
                            _showSnackBar(
                              context,
                              false,
                              "Failed to load PDF: $error",
                            );
                            Navigator.pop(context);
                          }
                        },
                      ).fromPath(tempFile.path),
                    ),
                  ],
                ),
              ),
            ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error in _showPdfViewer: $e");
      }
      if (context.mounted) {
        Navigator.pop(context);
        _showSnackBar(
          context,
          false,
          "Failed to generate PDF: ${e.toString()}",
        );
      }
    }
  }

  Future<pw.Document> _htmlToPdf(
    String htmlContent,
    String title,
    dynamic document,
  ) async {
    // Clean HTML content
    String cleanContent =
        htmlContent
            .replaceAll(RegExp(r'<o:p></o:p>'), '')
            .replaceAll(RegExp(r'<o:p>'), '')
            .replaceAll(RegExp(r'</o:p>'), '')
            .replaceAll(RegExp(r'<br\s*/?>'), '\n')
            .replaceAll(RegExp(r'<p[^>]*>'), '\n')
            .replaceAll(RegExp(r'</p>'), '')
            .replaceAll(RegExp(r'<b>'), '')
            .replaceAll(RegExp(r'</b>'), '')
            .replaceAll(RegExp(r'<span[^>]*>'), '')
            .replaceAll(RegExp(r'</span>'), '')
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
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER: Company Name + Date/ID
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 12),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 1.5),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Dr. ARAVIND's IVF",
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#E91E8C'),
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'FERTILITY & PREGNANCY CENTRE',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          document.date ?? "",
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.black,
                          ),
                        ),
                        if (document.id != null && document.id.isNotEmpty)
                          pw.Text(
                            'CR${document.id}',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.black,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              // TITLE: Circular - Title
              pw.Center(
                child: pw.Text(
                  'Circular - $title',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),

              pw.SizedBox(height: 20),

              // BODY CONTENT (justified text)
              pw.Text(
                cleanContent,
                style: const pw.TextStyle(
                  fontSize: 10,
                  lineSpacing: 1.4,
                  color: PdfColors.black,
                ),
                textAlign: pw.TextAlign.justify,
              ),

              pw.Spacer(),

              // SIGNATURE SECTION
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 20),
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Regards,',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 30),
                    pw.Text(
                      'Chandra Kumar',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      'HR Payroll Head',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
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
