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
      backgroundColor: const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple Header
              Row(
                children: [
                  const Text(
                    "Assets Details",
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  if (!assetsDetailsProvider.isLoading &&
                      assetsDetailsProvider.assetsDetails.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${assetsDetailsProvider.assetsDetails.length}",
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

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
                    return _buildAssetCard(asset);
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.devices_other_rounded,
              size: 48,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Assets",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.poppins,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Asset information will appear here",
            style: TextStyle(
              fontSize: 13,
              fontFamily: AppFonts.poppins,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    final date = asset["date"] ?? "N/A";
    final laptop = _getAssetValue(asset, "Laptop");
    final simNumber = _getAssetValue(asset, "Sim Number");
    final tablet = _getAssetValue(asset, "Tablet");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  "Assigned Assets",
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Assets Grid
            _buildAssetItem(
              Icons.laptop_mac,
              "Laptop",
              laptop,
              const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 12),
            _buildAssetItem(
              Icons.sim_card,
              "SIM Number",
              simNumber,
              const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            _buildAssetItem(
              Icons.tablet_mac,
              "Tablet",
              tablet,
              const Color(0xFFF59E0B),
            ),
          ],
        ),
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

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: hasValue ? const Color(0xFF1A1A1A) : Colors.grey[400],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (hasValue)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
      ],
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