import 'package:flutter/material.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/AdminTrackingProvider/AdminTrackingProvider.dart';

class TimelineTabScreen extends StatelessWidget {
  final TrackingRecord? session;

  const TimelineTabScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    if (session == null || session!.trackingPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Icon(
                Icons.timeline_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No tracking data available',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a session from History to view details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 13,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    final points = session!.trackingPoints;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: points.length,
      itemBuilder: (context, index) {
        final point = points[index];
        final isCheckIn = index == 0;
        final isCheckOut = index == points.length - 1;
        final isLast = index == points.length - 1;

        return _AnimatedTimelineItem(
          index: index,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Line + Dot
              _TimelineIndicator(
                isCheckIn: isCheckIn,
                isCheckOut: isCheckOut,
                isLast: isLast,
                index: index,
              ),
              const SizedBox(width: 16),

              // Content Card
              Expanded(
                child:
                    isCheckIn
                        ? _CheckInCard(point: point)
                        : isCheckOut
                        ? _CheckOutCard(point: point)
                        : _TrackingPointCard(point: point, index: index),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ✅ Animated Timeline Item
class _AnimatedTimelineItem extends StatefulWidget {
  final Widget child;
  final int index;

  const _AnimatedTimelineItem({required this.child, required this.index});

  @override
  State<_AnimatedTimelineItem> createState() => _AnimatedTimelineItemState();
}

class _AnimatedTimelineItemState extends State<_AnimatedTimelineItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Staggered animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

// ✅ Timeline Indicator (Line + Dot)
class _TimelineIndicator extends StatelessWidget {
  final bool isCheckIn;
  final bool isCheckOut;
  final bool isLast;
  final int index;

  const _TimelineIndicator({
    required this.isCheckIn,
    required this.isCheckOut,
    required this.isLast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    IconData icon;

    if (isCheckIn) {
      dotColor = const Color(0xFF4CAF50);
      icon = Icons.play_arrow_rounded;
    } else if (isCheckOut) {
      dotColor = const Color(0xFFF44336);
      icon = Icons.stop_rounded;
    } else {
      dotColor = const Color(0xFFFF9800);
      icon = Icons.location_on;
    }

    return SizedBox(
      width: 40,
      child: Column(
        children: [
          // Animated Dot
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 500 + (index * 50)),
            curve: Curves.elasticOut,
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              );
            },
          ),

          // Connecting Line
          if (!isLast)
            Container(
              width: 2,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    dotColor.withOpacity(0.6),
                    dotColor.withOpacity(0.2),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ✅ Check-In Card
class _CheckInCard extends StatelessWidget {
  final TrackingPoint point;

  const _CheckInCard({required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.1),
            const Color(0xFF81C784).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'START',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                point.time,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  point.address,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.grey[800],
                    fontFamily: AppFonts.poppins,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ✅ Tracking Point Card
class _TrackingPointCard extends StatelessWidget {
  final TrackingPoint point;
  final int index;

  const _TrackingPointCard({required this.point, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Point $index',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF9800),
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                point.time,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.place_rounded, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  point.address,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.grey[800],
                    fontFamily: AppFonts.poppins,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Stats Row
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _StatChip(
                icon: Icons.straighten_rounded,
                label: '${point.distanceFromPrevious.toInt()} m',
                color: Colors.blue,
              ),
              if (point.waitTime != null)
                _StatChip(
                  icon: Icons.timer_rounded,
                  label: 'waited ${point.waitTime!.inMinutes} min',
                  color: Colors.blue,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ✅ Stat Chip
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ],
    );
  }
}

// ✅ Check-Out Card
class _CheckOutCard extends StatelessWidget {
  final TrackingPoint point;

  const _CheckOutCard({required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF44336).withOpacity(0.1),
            const Color(0xFFE57373).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF44336).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'END',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                point.time,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC62828),
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  point.address,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.grey[800],
                    fontFamily: AppFonts.poppins,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
