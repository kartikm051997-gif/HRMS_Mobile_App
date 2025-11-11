import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/fonts/fonts.dart';

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

  bool isScanning = false;
  bool isVerified = false;
  bool isProcessing = false;
  double scanProgress = 0.0;

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _errorMessage;

  // ✅ NEW: Face detection
  FaceDetector? _faceDetector;
  bool _isFaceDetected = false;
  String _faceStatus = 'Position your face in the frame';
  Timer? _faceDetectionTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFaceDetector();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
      setState(() => scanProgress = _scanController.value);
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

  // ✅ NEW: Initialize face detector
  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      minFaceSize: 0.15, // Minimum face size (15% of image)
      performanceMode: FaceDetectorMode.accurate,
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'No camera found on this device';
          });
        }
        return;
      }

      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _errorMessage = null;
        });

        // ✅ Start continuous face detection
        _startContinuousFaceDetection();
      }
    } catch (e) {
      debugPrint('❌ Camera initialization failed: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera initialization failed';
        });
      }
    }
  }

  // ✅ NEW: Continuous face detection
  void _startContinuousFaceDetection() {
    _faceDetectionTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      if (!_isCameraInitialized || isScanning || isVerified) return;

      await _detectFaceInCurrentFrame();
    });
  }

  // ✅ NEW: Detect face in current frame
  Future<void> _detectFaceInCurrentFrame() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector!.processImage(inputImage);

      if (mounted) {
        if (faces.isEmpty) {
          setState(() {
            _isFaceDetected = false;
            _faceStatus = 'No face detected';
          });
        } else if (faces.length > 1) {
          setState(() {
            _isFaceDetected = false;
            _faceStatus = 'Multiple faces detected. Show only one face';
          });
        } else {
          final face = faces.first;

          // ✅ Check face quality
          final isGoodQuality = _validateFaceQuality(face);

          if (isGoodQuality) {
            setState(() {
              _isFaceDetected = true;
              _faceStatus = 'Face detected! Ready to scan';
            });
          }
        }
      }

      // Clean up temporary image
      await File(image.path).delete();
    } catch (e) {
      debugPrint('❌ Face detection error: $e');
    }
  }

  // ✅ NEW: Validate face quality
  bool _validateFaceQuality(Face face) {
    // Check if face is centered and properly sized
    final boundingBox = face.boundingBox;

    // Face should not be too small
    if (boundingBox.width < 100 || boundingBox.height < 100) {
      if (mounted) {
        setState(() {
          _faceStatus = 'Move closer to the camera';
        });
      }
      return false;
    }

    // Face should not be too large (too close)
    if (boundingBox.width > 400 || boundingBox.height > 400) {
      if (mounted) {
        setState(() {
          _faceStatus = 'Move away from the camera';
        });
      }
      return false;
    }

    // Check head pose (optional - for front-facing detection)
    final headEulerAngleY = face.headEulerAngleY; // Left/Right rotation
    final headEulerAngleZ = face.headEulerAngleZ; // Tilt

    if (headEulerAngleY != null && (headEulerAngleY.abs() > 15)) {
      if (mounted) {
        setState(() {
          _faceStatus = 'Look straight at the camera';
        });
      }
      return false;
    }

    if (headEulerAngleZ != null && (headEulerAngleZ.abs() > 15)) {
      if (mounted) {
        setState(() {
          _faceStatus = 'Keep your head straight';
        });
      }
      return false;
    }

    // Check if eyes are open (optional)
    final leftEyeOpenProbability = face.leftEyeOpenProbability;
    final rightEyeOpenProbability = face.rightEyeOpenProbability;

    if (leftEyeOpenProbability != null && leftEyeOpenProbability < 0.5) {
      if (mounted) {
        setState(() {
          _faceStatus = 'Please open your eyes';
        });
      }
      return false;
    }

    if (rightEyeOpenProbability != null && rightEyeOpenProbability < 0.5) {
      if (mounted) {
        setState(() {
          _faceStatus = 'Please open your eyes';
        });
      }
      return false;
    }

    return true;
  }

  Future<String?> _captureAndSaveImage() async {
    if (!_isCameraInitialized || _cameraController == null) {
      debugPrint('❌ Camera not ready');
      return null;
    }

    try {
      setState(() => isProcessing = true);

      final XFile picture = await _cameraController!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = p.join(
        directory.path,
        'faces',
        'face_${widget.employeeId}_$timestamp.jpg',
      );

      final imageDir = Directory(p.dirname(imagePath));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      await picture.saveTo(imagePath);
      debugPrint('✅ Face captured: $imagePath');

      return imagePath;
    } catch (e) {
      debugPrint('❌ Capture failed: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to capture image');
      }
      return null;
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  // ✅ MODIFIED: Start scanning with face validation
  Future<void> _startScanning() async {
    if (!_isCameraInitialized) {
      _showErrorSnackBar('Camera not ready. Please wait...');
      return;
    }

    // ✅ CHECK: Face must be detected before scanning
    if (!_isFaceDetected) {
      _showErrorSnackBar('Please position your face properly in the frame');
      return;
    }

    if (isScanning || isVerified) return;

    // Stop face detection during scan
    _faceDetectionTimer?.cancel();

    setState(() {
      isScanning = true;
      _faceStatus = 'Scanning...';
    });

    // Start scan animation
    _scanController.reset();
    _scanController.forward();

    // Simulate face detection delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Capture image
    final imagePath = await _captureAndSaveImage();

    if (imagePath == null) {
      setState(() => isScanning = false);
      _startContinuousFaceDetection(); // Resume face detection
      return;
    }

    // ✅ VALIDATE: Final face check before proceeding
    final isValidFace = await _validateFinalCapture(imagePath);

    if (!isValidFace) {
      setState(() {
        isScanning = false;
        _faceStatus = 'Face validation failed. Please try again';
      });
      _showErrorSnackBar('Face not properly detected. Please try again');
      _startContinuousFaceDetection(); // Resume face detection
      return;
    }

    // Simulate API verification
    await _verifyFaceWithAPI(imagePath);

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        isVerified = true;
        isScanning = false;
        _faceStatus = 'Verified!';
      });

      // Save to database
      await _saveFaceDataToDatabase(imagePath);

      // Wait for animation
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  // ✅ NEW: Final validation of captured image
  Future<bool> _validateFinalCapture(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) {
        debugPrint('❌ No face detected in final capture');
        return false;
      }

      if (faces.length > 1) {
        debugPrint('❌ Multiple faces detected in final capture');
        return false;
      }

      final face = faces.first;
      final isGoodQuality = _validateFaceQuality(face);

      if (!isGoodQuality) {
        debugPrint('❌ Face quality check failed');
        return false;
      }

      debugPrint('✅ Face validation passed');
      return true;
    } catch (e) {
      debugPrint('❌ Final validation error: $e');
      return false;
    }
  }

  Future<void> _verifyFaceWithAPI(String imagePath) async {
    debugPrint('🔄 Verifying face with API...');
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('✅ Face verified successfully');
  }

  Future<void> _saveFaceDataToDatabase(String imagePath) async {
    debugPrint('💾 Saving to database...');
    debugPrint('Employee: ${widget.employeeId}');
    debugPrint('Image: $imagePath');
    debugPrint('Type: ${widget.isCheckIn ? 'Check In' : 'Check Out'}');
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
    _faceDetectionTimer?.cancel();
    _faceDetector?.close();
    _cameraController?.dispose();
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
                if (isScanning) _buildScanningAnimation(),
                _buildStatusText(),
                const SizedBox(height: 50),
                _buildActionButton(),
                if (_errorMessage != null && !_isCameraInitialized)
                  _buildRetryButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraFrame() {
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
                color: (isVerified
                        ? Colors.green
                        : _isFaceDetected
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
                  isVerified
                      ? Colors.greenAccent
                      : _isFaceDetected
                      ? Colors.blueAccent
                      : Colors.white,
              width: 4,
            ),
          ),
          child: ClipOval(child: _buildCameraPreviewContent()),
        ),
        if (!isVerified && !isScanning) _buildCornerIndicators(),
        if (isScanning) _buildScanningLine(),
        if (isVerified) _buildSuccessOverlay(),
        // ✅ Face detection indicator
        if (_isFaceDetected && !isScanning && !isVerified)
          Positioned(
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
          ),
      ],
    );
  }

  Widget _buildCameraPreviewContent() {
    if (_errorMessage != null) {
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
                  _errorMessage!,
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

    if (_isCameraInitialized && _cameraController != null) {
      return CameraPreview(_cameraController!);
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

  Widget _buildCornerIndicators() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: _buildCornerBracket(topLeft: true),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: _buildCornerBracket(topRight: true),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: _buildCornerBracket(bottomLeft: true),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _buildCornerBracket(bottomRight: true),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBracket({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top:
              (topLeft || topRight)
                  ? BorderSide(
                    color: _isFaceDetected ? Colors.blueAccent : Colors.white,
                    width: 3,
                  )
                  : BorderSide.none,
          left:
              (topLeft || bottomLeft)
                  ? BorderSide(
                    color: _isFaceDetected ? Colors.blueAccent : Colors.white,
                    width: 3,
                  )
                  : BorderSide.none,
          right:
              (topRight || bottomRight)
                  ? BorderSide(
                    color: _isFaceDetected ? Colors.blueAccent : Colors.white,
                    width: 3,
                  )
                  : BorderSide.none,
          bottom:
              (bottomLeft || bottomRight)
                  ? BorderSide(
                    color: _isFaceDetected ? Colors.blueAccent : Colors.white,
                    width: 3,
                  )
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

  Widget _buildScanningAnimation() {
    return SizedBox(
      width: 220,
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: scanProgress,
          color: Colors.blue,
          backgroundColor: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    return Container(
      height: 90,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _faceStatus,
            style: TextStyle(
              color:
                  isVerified
                      ? Colors.greenAccent
                      : _isFaceDetected
                      ? Colors.blueAccent
                      : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isScanning && !isVerified) ...[
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
  }

  Widget _buildActionButton() {
    final bool isButtonDisabled =
        isScanning ||
        isVerified ||
        !_isCameraInitialized ||
        isProcessing ||
        !_isFaceDetected;

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
        onPressed: isButtonDisabled ? null : _startScanning,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child:
            isProcessing
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                : Text(
                  isScanning
                      ? 'Scanning...'
                      : (isVerified ? 'Verified ✓' : 'Start Scan'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextButton.icon(
        onPressed: _initializeCamera,
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
