import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/fonts/fonts.dart';
import '../../../model/UserTrackingModel/UserTrackingModel.dart';
import '../../../provider/UserTrackingProvider/TrackingDetailProvider.dart';

class TrackingTimelineTab extends StatelessWidget {
  const TrackingTimelineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingDetailProvider>(context);
    final addressCheckpoints = provider.record.addressCheckpoints ?? [];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Check-In
        _AnimatedTimelineItem(
          index: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimelineIndicator(
                isCheckIn: true,
                isCheckOut: false,
                isLast: false,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CheckInCard(
                  time: provider.record.checkInTime,
                  address: provider.record.checkInAddress,
                ),
              ),
            ],
          ),
        ),

        // Checkpoints
        ...addressCheckpoints.asMap().entries.map((entry) {
          int index = entry.key;
          AddressCheckpoint checkpoint = entry.value;

          Duration? waitTime;
          if (index > 0) {
            waitTime = checkpoint.timestamp.difference(
              addressCheckpoints[index - 1].timestamp,
            );
          }

          return _AnimatedTimelineItem(
            index: index + 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TimelineIndicator(
                  isCheckIn: false,
                  isCheckOut: false,
                  isLast: false,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TrackingPointCard(
                    checkpoint: checkpoint,
                    index: index + 1,
                    waitTime: waitTime,
                  ),
                ),
              ],
            ),
          );
        }),

        // Check-Out
        _AnimatedTimelineItem(
          index: addressCheckpoints.length + 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TimelineIndicator(
                isCheckIn: false,
                isCheckOut: true,
                isLast: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CheckOutCard(
                  time: provider.record.checkOutTime,
                  address: provider.record.checkOutAddress,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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

class _TimelineIndicator extends StatelessWidget {
  final bool isCheckIn;
  final bool isCheckOut;
  final bool isLast;

  const _TimelineIndicator({
    required this.isCheckIn,
    required this.isCheckOut,
    required this.isLast,
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
          Container(
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

class _CheckInCard extends StatelessWidget {
  final String time;
  final String address;

  const _CheckInCard({required this.time, required this.address});

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
                time,
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
                  address,
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

class _TrackingPointCard extends StatelessWidget {
  final AddressCheckpoint checkpoint;
  final int index;
  final Duration? waitTime;

  const _TrackingPointCard({
    required this.checkpoint,
    required this.index,
    this.waitTime,
  });

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours h $minutes min';
    }
    return '$minutes min';
  }

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
                _formatTime(checkpoint.timestamp),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.place_rounded, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  checkpoint.address,
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
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (checkpoint.distanceFromPrevious > 0)
                _StatChip(
                  icon: Icons.straighten_rounded,
                  label: _formatDistance(checkpoint.distanceFromPrevious),
                  color: Colors.blue,
                ),
              if (waitTime != null)
                _StatChip(
                  icon: Icons.timer_rounded,
                  label: 'waited ${_formatDuration(waitTime!)}',
                  color: Colors.blue,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

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

class _CheckOutCard extends StatelessWidget {
  final String time;
  final String address;

  const _CheckOutCard({required this.time, required this.address});

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
                time,
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
                  address,
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