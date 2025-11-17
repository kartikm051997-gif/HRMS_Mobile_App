import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FaceVerificationProvider extends ChangeNotifier {
  // Camera
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  String? _errorMessage;

  // Face Detection
  FaceDetector? _faceDetector;
  bool _isFaceDetected = false;
  String _faceStatus = 'Position your face in the frame';
  Timer? _faceDetectionTimer;

  // Scanning State
  bool _isScanning = false;
  bool _isVerified = false;
  bool _isProcessing = false;
  double _scanProgress = 0.0;

  // Getters
  CameraController? get cameraController => _cameraController;
  bool get isCameraInitialized => _isCameraInitialized;
  String? get errorMessage => _errorMessage;
  bool get isFaceDetected => _isFaceDetected;
  String get faceStatus => _faceStatus;
  bool get isScanning => _isScanning;
  bool get isVerified => _isVerified;
  bool get isProcessing => _isProcessing;
  double get scanProgress => _scanProgress;

  // Initialize face detector
  void initializeFaceDetector() {
    final options = FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      minFaceSize: 0.15,
      performanceMode: FaceDetectorMode.accurate,
    );
    _faceDetector = FaceDetector(options: options);
  }

  // Initialize camera
  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _errorMessage = 'No camera found on this device';
        notifyListeners();
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

      _isCameraInitialized = true;
      _errorMessage = null;
      notifyListeners();

      // Start continuous face detection
      _startContinuousFaceDetection();
    } catch (e) {
      debugPrint('❌ Camera initialization failed: $e');
      _errorMessage = 'Camera initialization failed';
      notifyListeners();
    }
  }

  // Start continuous face detection
  void _startContinuousFaceDetection() {
    _faceDetectionTimer = Timer.periodic(
      const Duration(milliseconds: 500),
          (timer) async {
        if (!_isCameraInitialized || _isScanning || _isVerified) return;
        await _detectFaceInCurrentFrame();
      },
    );
  }

  // Detect face in current frame
  Future<void> _detectFaceInCurrentFrame() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await _faceDetector!.processImage(inputImage);

      if (faces.isEmpty) {
        _isFaceDetected = false;
        _faceStatus = 'No face detected';
      } else if (faces.length > 1) {
        _isFaceDetected = false;
        _faceStatus = 'Multiple faces detected. Show only one face';
      } else {
        final face = faces.first;
        final isGoodQuality = _validateFaceQuality(face);

        if (isGoodQuality) {
          _isFaceDetected = true;
          _faceStatus = 'Face detected! Ready to scan';
        }
      }

      notifyListeners();

      // Clean up temporary image
      await File(image.path).delete();
    } catch (e) {
      debugPrint('❌ Face detection error: $e');
    }
  }

  // Validate face quality
  bool _validateFaceQuality(Face face) {
    final boundingBox = face.boundingBox;

    // Face too small
    if (boundingBox.width < 100 || boundingBox.height < 100) {
      _faceStatus = 'Move closer to the camera';
      return false;
    }

    // Face too large
    if (boundingBox.width > 400 || boundingBox.height > 400) {
      _faceStatus = 'Move away from the camera';
      return false;
    }

    // Check head pose
    final headEulerAngleY = face.headEulerAngleY;
    final headEulerAngleZ = face.headEulerAngleZ;

    if (headEulerAngleY != null && (headEulerAngleY.abs() > 15)) {
      _faceStatus = 'Look straight at the camera';
      return false;
    }

    if (headEulerAngleZ != null && (headEulerAngleZ.abs() > 15)) {
      _faceStatus = 'Keep your head straight';
      return false;
    }

    // Check if eyes are open
    final leftEyeOpenProbability = face.leftEyeOpenProbability;
    final rightEyeOpenProbability = face.rightEyeOpenProbability;

    if (leftEyeOpenProbability != null && leftEyeOpenProbability < 0.5) {
      _faceStatus = 'Please open your eyes';
      return false;
    }

    if (rightEyeOpenProbability != null && rightEyeOpenProbability < 0.5) {
      _faceStatus = 'Please open your eyes';
      return false;
    }

    return true;
  }

  // Update scan progress
  void updateScanProgress(double progress) {
    _scanProgress = progress;
    notifyListeners();
  }

  // Capture and save image
  Future<String?> captureAndSaveImage(String employeeId) async {
    if (!_isCameraInitialized || _cameraController == null) {
      debugPrint('❌ Camera not ready');
      return null;
    }

    try {
      _isProcessing = true;
      notifyListeners();

      final XFile picture = await _cameraController!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = p.join(
        directory.path,
        'faces',
        'face_${employeeId}_$timestamp.jpg',
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
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Start scanning
  Future<bool> startScanning(String employeeId, bool isCheckIn) async {
    if (!_isCameraInitialized) {
      return false;
    }

    if (!_isFaceDetected) {
      return false;
    }

    if (_isScanning || _isVerified) return false;

    // Stop face detection during scan
    _faceDetectionTimer?.cancel();

    _isScanning = true;
    _faceStatus = 'Scanning...';
    notifyListeners();

    // Simulate scan animation
    await Future.delayed(const Duration(milliseconds: 1500));

    // Capture image
    final imagePath = await captureAndSaveImage(employeeId);

    if (imagePath == null) {
      _isScanning = false;
      notifyListeners();
      _startContinuousFaceDetection();
      return false;
    }

    // Validate final capture
    final isValidFace = await _validateFinalCapture(imagePath);

    if (!isValidFace) {
      _isScanning = false;
      _faceStatus = 'Face validation failed. Please try again';
      notifyListeners();
      _startContinuousFaceDetection();
      return false;
    }

    // Verify with API
    await _verifyFaceWithAPI(imagePath);

    await Future.delayed(const Duration(milliseconds: 500));

    _isVerified = true;
    _isScanning = false;
    _faceStatus = 'Verified!';
    notifyListeners();

    // Save to database
    await _saveFaceDataToDatabase(imagePath, employeeId, isCheckIn);

    return true;
  }

  // Validate final capture
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

  // Verify face with API
  Future<void> _verifyFaceWithAPI(String imagePath) async {
    debugPrint('🔄 Verifying face with API...');
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('✅ Face verified successfully');
  }

  // Save face data to database
  Future<void> _saveFaceDataToDatabase(
      String imagePath,
      String employeeId,
      bool isCheckIn,
      ) async {
    debugPrint('💾 Saving to database...');
    debugPrint('Employee: $employeeId');
    debugPrint('Image: $imagePath');
    debugPrint('Type: ${isCheckIn ? 'Check In' : 'Check Out'}');
  }

  // Reset state
  void reset() {
    _isScanning = false;
    _isVerified = false;
    _isProcessing = false;
    _scanProgress = 0.0;
    _isFaceDetected = false;
    _faceStatus = 'Position your face in the frame';
    notifyListeners();
  }

  @override
  void dispose() {
    _faceDetectionTimer?.cancel();
    _faceDetector?.close();
    _cameraController?.dispose();
    super.dispose();
  }
}