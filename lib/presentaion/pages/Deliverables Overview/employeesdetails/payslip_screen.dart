import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/payslip_provider.dart';
import '../../../../model/deliverables_model/payslip_model.dart';
import '../../../../servicesAPI/LogInService/LogIn_Service.dart';

class PaySlipScreen extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;

  const PaySlipScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<PaySlipScreen> createState() => _PaySlipScreenState();
}

class _PaySlipScreenState extends State<PaySlipScreen>
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
      context.read<PaySlipProvider>().fetchPaySlip(widget.empId);
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<PaySlipProvider>(
          builder: (context, paySlipProvider, child) {
            if (paySlipProvider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF5B7FFF),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Loading payslips...",
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (paySlipProvider.payslip.isEmpty) {
              return _buildEmptyState();
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Simple Header
                  Row(
                    children: [
                      const Text(
                        "Payslip",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B7FFF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${paySlipProvider.payslip.length}",
                          style: const TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payslip List
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: paySlipProvider.payslip.length,
                      itemBuilder: (context, index) {
                        final document = paySlipProvider.payslip[index];
                        return _buildPayslipCard(document, paySlipProvider);
                      },
                    ),
                  ),
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Color(0xFF5B7FFF),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Payslips",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Payslip records will appear here",
            style: TextStyle(
              fontSize: 13,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipCard(
    PaySlipModel document,
    PaySlipProvider paySlipProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPayslipPdf(context, document, paySlipProvider),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF5B7FFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.salaryMonth,
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            document.date,
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontSize: 12,
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
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPayslipPdf(
    BuildContext context,
    PaySlipModel document,
    PaySlipProvider provider,
  ) async {
    if (document.documentUrl.isEmpty) {
      _showSnackBar(context, false, 'Payslip PDF URL not available');
      return;
    }

    if (!context.mounted) return;

    final title = "${document.salaryMonth} - ${document.date}";

    String pdfUrl = document.documentUrl;

    if (!pdfUrl.toLowerCase().endsWith('.pdf')) {
      pdfUrl = '${document.documentUrl}/pdf';
    }

    try {
      final loginService = LoginService();
      final token = await loginService.getValidToken();

      if (token != null && token.isNotEmpty) {
        final uri = Uri.parse(pdfUrl);
        if (uri.queryParameters.isEmpty) {
          pdfUrl = '$pdfUrl?token=$token';
        } else {
          pdfUrl =
              uri
                  .replace(
                    queryParameters: {...uri.queryParameters, 'token': token},
                  )
                  .toString();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error appending token: $e');
    }

    debugPrint('📄 Opening payslip PDF URL: $pdfUrl');

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => Dialog(
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
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF5B7FFF),
                      borderRadius: BorderRadius.only(
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
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            final success = await provider.downloadDocument(
                              document,
                            );
                            if (context.mounted) {
                              _showSnackBar(
                                context,
                                success,
                                success
                                    ? 'Downloaded successfully'
                                    : 'Download failed',
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // PDF viewer
                  Expanded(
                    child: PDF(
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: false,
                      pageFling: true,
                      pageSnap: true,
                      onError: (error) {
                        debugPrint('❌ PDF Error: $error');
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          _showSnackBar(
                            context,
                            false,
                            "Could not open PDF. Try downloading instead.",
                          );
                        }
                      },
                      onPageError: (page, error) {
                        debugPrint('❌ Page $page Error: $error');
                      },
                    ).cachedFromUrl(
                      pdfUrl,
                      placeholder:
                          (progress) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF5B7FFF),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Loading... ${(progress * 100).toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      errorWidget:
                          (error) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 42,
                                    color: Color(0xFFEF4444),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Could not load PDF",
                                    style: TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    error.toString(),
                                    style: TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      Navigator.pop(dialogContext);
                                      final success = await provider
                                          .downloadDocument(document);
                                      if (context.mounted) {
                                        _showSnackBar(
                                          context,
                                          success,
                                          success
                                              ? 'Downloaded successfully'
                                              : 'Download failed',
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5B7FFF),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.download,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      "Download Instead",
                                      style: TextStyle(
                                        fontFamily: AppFonts.poppins,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

  void _showSnackBar(BuildContext context, bool success, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
