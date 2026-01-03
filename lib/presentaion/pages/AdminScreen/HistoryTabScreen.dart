import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/fonts/fonts.dart';
import '../../../provider/AdminTrackingProvider/AdminTrackingProvider.dart';
import '../../../provider/login_provider/login_provider.dart';

class HistoryTabScreen extends StatelessWidget {
  final List<TrackingRecord> sessions;
  final Function(TrackingRecord) onViewDetails;

  const HistoryTabScreen({
    super.key,
    required this.sessions,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    final user = loginProvider.loginData?.user;
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          'No history data available',
          style: TextStyle(fontFamily: AppFonts.poppins),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'EEEE, dd MMM yyyy',
                            ).format(session.date),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            user?.fullname ?? "Welcome!",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              fontFamily: AppFonts.poppins,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user?.username ?? "Welcome!",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Check In
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.login,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Check In',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                session.checkInTime,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.trackingPoints.first.address,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontFamily: AppFonts.poppins,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Check Out
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Check Out',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                session.checkOutTime ?? 'Not checked out',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (session.trackingPoints.isNotEmpty)
                                Text(
                                  session.trackingPoints.last.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontFamily: AppFonts.poppins,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Stats
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.location_on,
                            label: 'Locations',
                            value: '${session.trackingPoints.length}',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          _StatItem(
                            icon: Icons.straighten,
                            label: 'Distance',
                            value:
                                '${(session.totalDistance / 1000).toStringAsFixed(1)} km',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          _StatItem(
                            icon: Icons.access_time,
                            label: 'Duration',
                            value:
                                '${session.totalDuration.inHours}h ${session.totalDuration.inMinutes % 60}m',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // View Details Button
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => onViewDetails(session),
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'View Details',
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.transparent, // remove default color
                            shadowColor: Colors.transparent, // remove shadow
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF8E0E6B)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontFamily: AppFonts.poppins,
          ),
        ),
      ],
    );
  }
}
