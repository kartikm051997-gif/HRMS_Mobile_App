import 'package:flutter/Material.dart';

import '../../../../core/fonts/fonts.dart';

class ApplicationInformationScreen extends StatefulWidget {
  const ApplicationInformationScreen({super.key});

  @override
  State<ApplicationInformationScreen> createState() =>
      _ApplicationInformationScreenState();
}

class _ApplicationInformationScreenState
    extends State<ApplicationInformationScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Application Information",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontFamily: AppFonts.poppins,
                ),
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
    );
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
