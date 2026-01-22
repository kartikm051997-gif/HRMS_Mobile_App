import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';

class SimpleImageZoomViewer extends StatefulWidget {
  final String imageUrl;
  final String? employeeName;

  const SimpleImageZoomViewer({
    super.key,
    required this.imageUrl,
    this.employeeName,
  });

  @override
  State<SimpleImageZoomViewer> createState() => _SimpleImageZoomViewerState();
}

class _SimpleImageZoomViewerState extends State<SimpleImageZoomViewer> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            widget.employeeName != null
                ? Text(
                  widget.employeeName!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                  ),
                )
                : null,
      ),
      body: Center(
        child: GestureDetector(
          onScaleStart: (details) {
            _previousScale = _scale;
          },
          onScaleUpdate: (details) {
            setState(() {
              _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
            });
          },
          onScaleEnd: (details) {
            setState(() {
              if (_scale < 1.5) {
                _scale = 1.0;
              }
            });
          },
          onDoubleTap: () {
            setState(() {
              _scale = _scale > 1.0 ? 1.0 : 2.0;
            });
          },
          child: Transform.scale(
            scale: _scale,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                    color: Colors.white,
                  ),
                );
              },
              errorBuilder:
                  (context, error, stackTrace) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
