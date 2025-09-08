import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomCardShimmer extends StatelessWidget {
  final int itemCount;

  const CustomCardShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            color: Colors.white,
            elevation: 2,
            shadowColor: Colors.grey.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar shimmer
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name shimmer
                        Container(
                          height: 16,
                          width: 150,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),

                        // Designation shimmer
                        Container(
                          height: 14,
                          width: 120,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),

                        // Location shimmer
                        Container(
                          height: 14,
                          width: 100,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),

                        // Task shimmer
                        Container(
                          height: 14,
                          width: 80,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
