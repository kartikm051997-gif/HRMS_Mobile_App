import 'package:flutter/material.dart';

class SegmentedSwipeButton extends StatefulWidget {
  final String page1;
  final String page2;
  final List<Color> gradientColors;
  final TextStyle textStyle;
  final double height;
  final double width;
  final double borderRadius;
  final VoidCallback onPage1;
  final VoidCallback onPage2;

  const SegmentedSwipeButton({
    super.key,
    required this.page1,
    required this.page2,
    required this.gradientColors,
    required this.textStyle,
    required this.onPage1,
    required this.onPage2,
    this.height = 50,
    this.width = 250,
    this.borderRadius = 12,
  });

  @override
  State<SegmentedSwipeButton> createState() => _SegmentedSwipeButtonState();
}

class _SegmentedSwipeButtonState extends State<SegmentedSwipeButton> {
  bool _isPage1Active = true;

  void _togglePage() {
    setState(() {
      _isPage1Active = !_isPage1Active;
    });
    if (_isPage1Active) {
      widget.onPage1();
    } else {
      widget.onPage2();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        _togglePage(); // swipe left or right toggles the page
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      _isPage1Active
                          ? Colors.white.withOpacity(0.3)
                          : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(widget.borderRadius),
                    bottomLeft: Radius.circular(widget.borderRadius),
                  ),
                ),
                child: Text(
                  widget.page1,
                  style: widget.textStyle.copyWith(
                    fontWeight:
                        _isPage1Active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      !_isPage1Active
                          ? Colors.white.withOpacity(0.3)
                          : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(widget.borderRadius),
                    bottomRight: Radius.circular(widget.borderRadius),
                  ),
                ),
                child: Text(
                  widget.page2,
                  style: widget.textStyle.copyWith(
                    fontWeight:
                        !_isPage1Active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
