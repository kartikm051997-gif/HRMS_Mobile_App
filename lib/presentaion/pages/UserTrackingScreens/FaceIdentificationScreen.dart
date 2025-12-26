// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../../core/fonts/fonts.dart';
//
// class FaceIdentificationScreen extends StatefulWidget {
//   final String? employeeId;
//   final String? employeeName;
//   final bool isCheckIn;
//   final bool
//   displayOnly; // If true, only display face for identification, no capture required
//
//   const FaceIdentificationScreen({
//     super.key,
//     this.employeeId,
//     this.employeeName,
//     this.isCheckIn = true,
//     this.displayOnly = false,
//   });
//
//   @override
//   State<FaceIdentificationScreen> createState() =>
//       _FaceIdentificationScreenState();
// }
//
// class _FaceIdentificationScreenState extends State<FaceIdentificationScreen> {
//   CameraController? _cameraController;
//   bool _isCameraInitialized = false;
//   bool _isCapturing = false;
//   String? _errorMessage;
//
//   // Colors
//   static const Color primaryColor = Color(0xFF8E0E6B);
//   static const Color secondaryColor = Color(0xFFD4145A);
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }
//
//   Future<void> _initializeCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final frontCamera = cameras.firstWhere(
//         (camera) => camera.lensDirection == CameraLensDirection.front,
//         orElse: () => cameras.first,
//       );
//
//       _cameraController = CameraController(
//         frontCamera,
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );
//
//       await _cameraController!.initialize();
//
//       if (mounted) {
//         setState(() {
//           _isCameraInitialized = true;
//           _errorMessage = null;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Camera error: ${e.toString()}';
//       });
//     }
//   }
//
//   Future<void> _capturePhoto() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       _showMessage('Camera not ready');
//       return;
//     }
//
//     if (_isCapturing) return;
//
//     setState(() {
//       _isCapturing = true;
//     });
//
//     try {
//       if (widget.displayOnly) {
//         // In display-only mode, just verify face without capturing
//         _showMessage('Face identified successfully');
//         await Future.delayed(const Duration(milliseconds: 500));
//
//         if (mounted) {
//           Navigator.pop(context, true);
//         }
//       } else {
//         // In capture mode, take a photo
//         final image = await _cameraController!.takePicture();
//
//         // Here you can send the image to your backend
//         // For now, just show success and go back
//         _showMessage('Photo captured successfully');
//
//         await Future.delayed(const Duration(milliseconds: 500));
//
//         if (mounted) {
//           Navigator.pop(context, true);
//         }
//       }
//     } catch (e) {
//       _showMessage(
//         'Failed to ${widget.displayOnly ? "identify" : "capture"}: ${e.toString()}',
//       );
//       setState(() {
//         _isCapturing = false;
//       });
//     }
//   }
//
//   void _showMessage(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // Background Gradient
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [primaryColor, secondaryColor],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//
//           // Main Content
//           SafeArea(
//             child: Column(
//               children: [
//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       // Back Button
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.3),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: IconButton(
//                           icon: const Icon(
//                             Icons.arrow_back,
//                             color: Colors.white,
//                           ),
//                           onPressed: () => Navigator.pop(context, false),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//
//                       // Title
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               widget.isCheckIn ? 'Check In' : 'Check Out',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: AppFonts.poppins,
//                               ),
//                             ),
//                             Text(
//                               widget.displayOnly
//                                   ? 'Face Identification'
//                                   : 'Capture your face',
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.7),
//                                 fontSize: 14,
//                                 fontFamily: AppFonts.poppins,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 // Camera Preview
//                 Expanded(
//                   child: Center(
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         // Camera Frame
//                         Container(
//                           width: 320,
//                           height: 400,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(30),
//                             border: Border.all(color: Colors.white, width: 3),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.white.withOpacity(0.3),
//                                 blurRadius: 20,
//                                 spreadRadius: 5,
//                               ),
//                             ],
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(27),
//                             child: _buildCameraPreview(),
//                           ),
//                         ),
//
//                         // Face Oval Overlay
//                         CustomPaint(
//                           size: const Size(320, 400),
//                           painter: FaceOvalPainter(),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // Instructions
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 32,
//                     vertical: 16,
//                   ),
//                   child: Text(
//                     widget.displayOnly
//                         ? 'Position your face for identification'
//                         : 'Position your face within the oval frame',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.8),
//                       fontSize: 15,
//                       fontFamily: AppFonts.poppins,
//                     ),
//                   ),
//                 ),
//
//                 // Capture/Verify Button
//                 Padding(
//                   padding: const EdgeInsets.all(32),
//                   child: _buildCaptureButton(),
//                 ),
//
//                 // Timestamp
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   margin: const EdgeInsets.only(bottom: 20),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     DateFormat('hh:mm a • dd MMM yyyy').format(DateTime.now()),
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 13,
//                       fontFamily: AppFonts.poppins,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCameraPreview() {
//     if (_errorMessage != null) {
//       return Container(
//         color: Colors.black87,
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(
//                   Icons.camera_alt_outlined,
//                   color: Colors.white54,
//                   size: 48,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   _errorMessage!,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                     fontFamily: AppFonts.poppins,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _initializeCamera,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryColor,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     if (!_isCameraInitialized || _cameraController == null) {
//       return Container(
//         color: Colors.black87,
//         child: const Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
//               SizedBox(height: 16),
//               Text(
//                 'Starting camera...',
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 14,
//                   fontFamily: AppFonts.poppins,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return CameraPreview(_cameraController!);
//   }
//
//   Widget _buildCaptureButton() {
//     return GestureDetector(
//       onTap: _isCapturing ? null : _capturePhoto,
//       child: Container(
//         width: 80,
//         height: 80,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.white,
//           border: Border.all(color: Colors.white, width: 4),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.white.withOpacity(0.5),
//               blurRadius: 20,
//               spreadRadius: 2,
//             ),
//           ],
//         ),
//         child:
//             _isCapturing
//                 ? const Padding(
//                   padding: EdgeInsets.all(20),
//                   child: CircularProgressIndicator(
//                     strokeWidth: 3,
//                     color: primaryColor,
//                   ),
//                 )
//                 : Icon(
//                   widget.displayOnly ? Icons.face : Icons.camera_alt,
//                   color: primaryColor,
//                   size: 40,
//                 ),
//       ),
//     );
//   }
// }
//
// // Custom painter for face oval overlay
// class FaceOvalPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint =
//         Paint()
//           ..color = Colors.black.withOpacity(0.5)
//           ..style = PaintingStyle.fill;
//
//     final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
//
//     final ovalPath =
//         Path()..addOval(
//           Rect.fromCenter(
//             center: Offset(size.width / 2, size.height / 2),
//             width: size.width * 0.7,
//             height: size.height * 0.55,
//           ),
//         );
//
//     final transparentPath = Path.combine(
//       PathOperation.difference,
//       path,
//       ovalPath,
//     );
//
//     canvas.drawPath(transparentPath, paint);
//
//     // Draw oval border
//     final borderPaint =
//         Paint()
//           ..color = Colors.white
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 3;
//
//     canvas.drawOval(
//       Rect.fromCenter(
//         center: Offset(size.width / 2, size.height / 2),
//         width: size.width * 0.7,
//         height: size.height * 0.55,
//       ),
//       borderPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
