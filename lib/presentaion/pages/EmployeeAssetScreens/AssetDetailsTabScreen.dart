import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/appcolor_dart.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/EmployeeAssetProvider/EmployeeAssetProvider.dart';

class AssetDetailsTab extends StatefulWidget {
  const AssetDetailsTab({super.key});

  @override
  State<AssetDetailsTab> createState() => _AssetDetailsTabState();
}

class _AssetDetailsTabState extends State<AssetDetailsTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeAssetProvider>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade50, Colors.grey.shade100],
        ),
      ),
      child:
          provider.assetList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                itemCount: provider.assetList.length,
                itemBuilder: (context, index) {
                  final emp = provider.assetList[index];

                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final delay = index * 0.15;
                      final animationValue = Curves.easeOutCubic.transform(
                        ((_animationController.value - delay) / (1 - delay))
                            .clamp(0.0, 1.0),
                      );

                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - animationValue)),
                        child: Opacity(opacity: animationValue, child: child),
                      );
                    },
                    child: _buildAssetCard(context, emp, provider, index),
                  );
                },
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Assets Found',
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Employee assets will appear here',
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(
    BuildContext context,
    EmployeeAssetModel emp,
    EmployeeAssetProvider provider,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColor.primaryColor2.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            provider.selectEmployee(emp);
            DefaultTabController.of(context).animateTo(1);
          },
          child: Column(
            children: [
              // Header Section
              _buildCardHeader(context, emp, provider),

              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.grey.shade100,
              ),

              // Assets Section
              _buildAssetsSection(emp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(
    BuildContext context,
    EmployeeAssetModel emp,
    EmployeeAssetProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile Avatar with Gradient Border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Hero(
              tag: 'avatar_${emp.empId}',
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: AssetImage(emp.photo),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Employee Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emp.empName,
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip(icon: Icons.badge_outlined, text: emp.empId),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      icon: Icons.work_outline,
                      text: emp.designation,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit Button
          Container(
            decoration: BoxDecoration(
              color: AppColor.primaryColor2.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                provider.selectEmployee(emp);
                DefaultTabController.of(context).animateTo(1);
              },
              icon: Icon(
                Icons.edit_outlined,
                color: AppColor.primaryColor2,
                size: 22,
              ),
              tooltip: 'Edit Asset',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsSection(EmployeeAssetModel emp) {
    final assets = <Map<String, dynamic>>[];

    if (emp.mobile != '-') {
      assets.add({
        'icon': Icons.phone_android_rounded,
        'label': 'Mobile',
        'value': emp.mobile,
        'color': const Color(0xFF4CAF50),
      });
    }
    if (emp.sim != '-') {
      assets.add({
        'icon': Icons.sim_card_rounded,
        'label': 'SIM',
        'value': emp.sim,
        'color': const Color(0xFF2196F3),
      });
    }
    if (emp.laptop != '-') {
      assets.add({
        'icon': Icons.laptop_mac_rounded,
        'label': 'Laptop',
        'value': emp.laptop,
        'color': const Color(0xFF9C27B0),
      });
    }
    if (emp.tablet != '-') {
      assets.add({
        'icon': Icons.tablet_android_rounded,
        'label': 'Tablet',
        'value': emp.tablet,
        'color': const Color(0xFFFF9800),
      });
    }

    if (assets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(
              'No assets assigned',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 13,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children:
            assets.map((asset) {
              return _buildAssetChip(
                icon: asset['icon'] as IconData,
                label: asset['label'] as String,
                value: asset['value'] as String,
                color: asset['color'] as Color,
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAssetChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
