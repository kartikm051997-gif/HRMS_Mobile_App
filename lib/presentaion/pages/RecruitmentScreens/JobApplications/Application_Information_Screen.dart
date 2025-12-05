import 'package:flutter/Material.dart';

import '../../../../core/fonts/fonts.dart';

class ApplicationInformationScreen extends StatefulWidget {
  const ApplicationInformationScreen({super.key});

  @override
  State<ApplicationInformationScreen> createState() =>
      _ApplicationInformationScreenState();
}

class _ApplicationInformationScreenState
    extends State<ApplicationInformationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF8F9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E0E6B).withOpacity(0.12),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8E0E6B),
                          Color(0xFFD4145A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Application Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8E0E6B),
                      fontFamily: AppFonts.poppins,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildInfoRow("Applied on", "24/09/2025"),
              _buildInfoRow("Interview Date", "-"),
              _buildInfoRow("Joining Date", "-"),
              _buildInfoRow("Total no .Of Experience", "-"),
              _buildAccessRow(),
              _buildAssignedRow(),
              _buildInfoRow("Remark", "-"),
            ],
          ),
        ),
      ],
      ),
    ));
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: AppFonts.poppins,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
              fontFamily: AppFonts.poppins,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        // optional background/border if you like:
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Access',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 40,
              width: 140,
              child: Stack(
                children: List.generate(4, (index) {
                  return Positioned(
                    left: index * 24,
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        // optional background/border if you like:
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Assigned',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 40,
              width: 140,
              child: Stack(
                children: List.generate(2, (index) {
                  return Positioned(
                    left: index * 24,
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
