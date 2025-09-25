import 'package:flutter/material.dart';

import '../../../../core/fonts/fonts.dart';
import 'ViewProfileScreens/View_Profile_Tabbar_Screens/View_Profile_Tabbar_Screens.dart';

class StatusTrackingScreen extends StatefulWidget {
  const StatusTrackingScreen({super.key});

  @override
  State<StatusTrackingScreen> createState() => _StatusTrackingScreenState();
}

class _StatusTrackingScreenState extends State<StatusTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showStatusTrackingDialog(context);
                },
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text(
                  "Status Tracking",
                  style: TextStyle(fontFamily: AppFonts.poppins),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 20),
        // You can add more content below if needed
      ],
    );
  }

  void _showStatusTrackingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'TimeLine',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontFamily: AppFonts.poppins,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Table Header
                    Container(
                      color: const Color(0xFF9333EA),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Date&Time',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'HR Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Status & Description',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Table Row
                    Container(
                      color: const Color(0xFFF9FAFB),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                '25 Sep, 25',
                                style: const TextStyle(
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text('-'),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: GestureDetector(
                                onTap: () => _showStatusAlert(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Applied',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B7280),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _showStatusAlert(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Status Details',
              style: TextStyle(fontFamily: AppFonts.poppins),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Status: Applied',
                  style: TextStyle(fontFamily: AppFonts.poppins),
                ),
                SizedBox(height: 8),
                Text(
                  'Date & Time: 25 Sep, 25',
                  style: TextStyle(fontFamily: AppFonts.poppins),
                ),
                SizedBox(height: 8),
                Text(
                  'HR Name: -',
                  style: TextStyle(fontFamily: AppFonts.poppins),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(fontFamily: AppFonts.poppins),
                ),
              ),
            ],
          ),
    );
  }
}
