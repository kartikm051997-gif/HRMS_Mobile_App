import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/provider/Deliverables_Overview_provider/Assets_Details_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../widgets/shimmer_custom_screen/shimmer_custom_screen.dart';

class AssetsDetailsScreen extends StatefulWidget {
  final String empId, empPhoto, empName, empDesignation, empBranch;

  const AssetsDetailsScreen({
    super.key,
    required this.empId,
    required this.empPhoto,
    required this.empName,
    required this.empDesignation,
    required this.empBranch,
  });

  @override
  State<AssetsDetailsScreen> createState() => _AssetsDetailsScreenState();
}

class _AssetsDetailsScreenState extends State<AssetsDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Gradient colors - Light attractive theme
  static const Color primaryColor = Color(0xFF7C3AED);
  static const Color secondaryColor = Color(0xFFEC4899);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetsDetailsProvider>().fetchAssetsDetails(widget.empId);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetsDetailsProvider = Provider.of<AssetsDetailsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryColor, secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.devices_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      "Assets Details",
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  if (!assetsDetailsProvider.isLoading &&
                      assetsDetailsProvider.assetsDetails.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${assetsDetailsProvider.assetsDetails.length} Items",
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Content
              Expanded(
                child: assetsDetailsProvider.isLoading
                    ? const CustomCardShimmer(itemCount: 1)
                    : assetsDetailsProvider.assetsDetails.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount:
                                assetsDetailsProvider.assetsDetails.length,
                            itemBuilder: (context, index) {
                              final asset =
                                  assetsDetailsProvider.assetsDetails[index];
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration:
                                    Duration(milliseconds: 400 + (index * 100)),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildAssetCard(asset, index),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
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
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.1),
                  secondaryColor.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.devices_other_rounded,
              size: 48,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No Assets Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Asset information will appear here",
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset, int index) {
    final date = asset["date"] ?? "N/A";
    final laptop = _getAssetValue(asset, "Laptop");
    final simNumber = _getAssetValue(asset, "Sim Number");
    final tablet = _getAssetValue(asset, "Tablet");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Assigned Assets",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Issued on: $date",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Card Content - Asset Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildAssetItem(
                        Icons.laptop_mac_rounded,
                        "Laptop",
                        laptop,
                        const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAssetItem(
                        Icons.sim_card_rounded,
                        "SIM Number",
                        simNumber,
                        const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildAssetItem(
                        Icons.tablet_mac_rounded,
                        "Tablet",
                        tablet,
                        const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAssetItem(
                        Icons.calendar_today_rounded,
                        "Issue Date",
                        date,
                        primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final bool hasValue = value != "Not Found" && value != "N/A";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              if (hasValue)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: hasValue ? const Color(0xFF1E293B) : Colors.grey[400],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getAssetValue(Map<String, dynamic> asset, String key) {
    if (asset.containsKey(key) &&
        asset[key] != null &&
        asset[key].toString().trim().isNotEmpty) {
      return asset[key].toString();
    }
    return "Not Found";
  }
}
