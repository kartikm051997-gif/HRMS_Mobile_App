import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/FaceIdentificationProvider/Face_Identification_Provider_Screen.dart';

class FaceIdentificationScreen extends StatefulWidget {
  final String? employeeId;
  final String? employeeName;
  final bool isCheckIn;

  const FaceIdentificationScreen({
    super.key,
    this.employeeId,
    this.employeeName,
    this.isCheckIn = true,
  });

  @override
  State<FaceIdentificationScreen> createState() =>
      _FaceIdentificationScreenState();
}

class _FaceIdentificationScreenState extends State<FaceIdentificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeProvider();
  }

  void _initializeAnimations() {
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
      context.read<FaceVerificationProvider>().updateScanProgress(
        _scanController.value,
      );
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  void _initializeProvider() {
    final provider = context.read<FaceVerificationProvider>();
    provider.initializeFaceDetector();
    provider.initializeCamera();
  }

  Future<void> _handleStartScanning() async {
    final provider = context.read<FaceVerificationProvider>();

    if (!provider.isCameraInitialized) {
      _showErrorSnackBar('Camera not ready. Please wait...');
      return;
    }

    if (!provider.isFaceDetected) {
      _showErrorSnackBar('Please position your face properly in the frame');
      return;
    }

    // Start scan animation
    _scanController.reset();
    _scanController.forward();

    final success = await provider.startScanning(
      widget.employeeId ?? 'EMP001',
      widget.isCheckIn,
    );

    if (success && mounted) {
      // Wait for animation
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } else if (mounted) {
      _showErrorSnackBar('Face not properly detected. Please try again');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildBackButton(),
          _buildMainContent(),
          _buildTimestamp(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    final pulseValue = 1 + (_pulseController.value * 0.08);

    return AnimatedScale(
      scale: pulseValue,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8E0E6B),
              const Color(0xFFD4145A),
              Colors.purple.shade900,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.isCheckIn ? 'Check In' : 'Check Out',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.poppins,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Face Verification',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
                const SizedBox(height: 50),
                _buildCameraFrame(),
                const SizedBox(height: 40),
                Consumer<FaceVerificationProvider>(
                  builder: (context, provider, child) {
                    if (provider.isScanning) {
                      return _buildScanningAnimation(provider.scanProgress);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                _buildStatusText(),
                const SizedBox(height: 50),
                _buildActionButton(),
                Consumer<FaceVerificationProvider>(
                  builder: (context, provider, child) {
                    if (provider.errorMessage != null &&
                        !provider.isCameraInitialized) {
                      return _buildRetryButton();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraFrame() {
    return Consumer<FaceVerificationProvider>(
      builder: (context, provider, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (provider.isVerified
                            ? Colors.green
                            : provider.isFaceDetected
                            ? Colors.blue
                            : Colors.pink)
                        .withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      provider.isVerified
                          ? Colors.greenAccent
                          : provider.isFaceDetected
                          ? Colors.blueAccent
                          : Colors.white,
                  width: 4,
                ),
              ),
              child: ClipOval(child: _buildCameraPreviewContent(provider)),
            ),
            if (!provider.isVerified && !provider.isScanning)
              _buildCornerIndicators(provider.isFaceDetected),
            if (provider.isScanning) _buildScanningLine(),
            if (provider.isVerified) _buildSuccessOverlay(),
            if (provider.isFaceDetected &&
                !provider.isScanning &&
                !provider.isVerified)
              _buildFaceDetectedBadge(),
          ],
        );
      },
    );
  }

  Widget _buildCameraPreviewContent(FaceVerificationProvider provider) {
    if (provider.errorMessage != null) {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white54,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.isCameraInitialized && provider.cameraController != null) {
      return CameraPreview(provider.cameraController!);
    }

    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: AppFonts.poppins,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerIndicators(bool isFaceDetected) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: _buildCornerBracket(isFaceDetected, topLeft: true),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: _buildCornerBracket(isFaceDetected, topRight: true),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: _buildCornerBracket(isFaceDetected, bottomLeft: true),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildCornerBracket(isFaceDetected, bottomRight: true),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBracket(
    bool isFaceDetected, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    final color = isFaceDetected ? Colors.blueAccent : Colors.white;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top:
              (topLeft || topRight)
                  ? BorderSide(color: color, width: 3)
                  : BorderSide.none,
          left:
              (topLeft || bottomLeft)
                  ? BorderSide(color: color, width: 3)
                  : BorderSide.none,
          right:
              (topRight || bottomRight)
                  ? BorderSide(color: color, width: 3)
                  : BorderSide.none,
          bottom:
              (bottomLeft || bottomRight)
                  ? BorderSide(color: color, width: 3)
                  : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildScanningLine() {
    return AnimatedBuilder(
      animation: _scanLineController,
      builder: (context, child) {
        return Positioned(
          top: 280 * _scanLineController.value,
          child: Container(
            width: 280,
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.blue.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green.withOpacity(0.3),
      ),
      child: const Center(
        child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
      ),
    );
  }

  Widget _buildFaceDetectedBadge() {
    return Positioned(
      top: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              'Face Detected',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.poppins,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningAnimation(double progress) {
    return SizedBox(
      width: 220,
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: progress,
          color: Colors.blue,
          backgroundColor: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    return Consumer<FaceVerificationProvider>(
      builder: (context, provider, child) {
        return Container(
          height: 90,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.faceStatus,
                style: TextStyle(
                  color:
                      provider.isVerified
                          ? Colors.greenAccent
                          : provider.isFaceDetected
                          ? Colors.blueAccent
                          : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                ),
                textAlign: TextAlign.center,
              ),
              if (!provider.isScanning && !provider.isVerified) ...[
                const SizedBox(height: 8),
                Text(
                  'Make sure your face is clearly visible',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    fontFamily: AppFonts.poppins,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton() {
    return Consumer<FaceVerificationProvider>(
      builder: (context, provider, child) {
        final bool isButtonDisabled =
            provider.isScanning ||
            provider.isVerified ||
            !provider.isCameraInitialized ||
            provider.isProcessing ||
            !provider.isFaceDetected;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 200,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient:
                isButtonDisabled
                    ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                    : const LinearGradient(
                      colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                    ),
            boxShadow:
                isButtonDisabled
                    ? []
                    : [
                      BoxShadow(
                        color: const Color(0xFF8E0E6B).withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
          ),
          child: ElevatedButton(
            onPressed: isButtonDisabled ? null : _handleStartScanning,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child:
                provider.isProcessing
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                    : Text(
                      provider.isScanning
                          ? 'Scanning...'
                          : (provider.isVerified ? 'Verified ✓' : 'Start Scan'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
          ),
        );
      },
    );
  }

  Widget _buildRetryButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextButton.icon(
        onPressed: () {
          context.read<FaceVerificationProvider>().initializeCamera();
        },
        icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
        label: const Text(
          'Retry Camera',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 15,
            fontFamily: AppFonts.poppins,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildTimestamp() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            DateFormat('hh:mm a • EEE, dd MMM yyyy').format(DateTime.now()),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontFamily: AppFonts.poppins,
            ),
          ),
        ),
      ),
    );
  }
}
