import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/payroll_provider/Mispunch_Reports_Provider.dart';
import '../../../widgets/custom_textfield/custom_dropdown_with_search.dart';

class MisPunchReportsScreen extends StatefulWidget {
  const MisPunchReportsScreen({super.key});

  @override
  State<MisPunchReportsScreen> createState() => _MisPunchReportsScreenState();
}

class _MisPunchReportsScreenState extends State<MisPunchReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showFilters = true;

  // Colors
  static const Color _primaryColor = Color(0xFF8E0E6B);
  static const Color _secondaryColor = Color(0xFFD4145A);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _successColor = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _searchFocusNode.unfocus();
        final dayFilter = _getDayFilterFromIndex(_tabController.index);
        final provider = context.read<MisPunchReportsProvider>();
        if (provider.hasSearched) {
          provider.fetchReports(dayFilter);
        }
      }
    });
  }

  int _getDayFilterFromIndex(int index) {
    switch (index) {
      case 0:
        return 3;
      case 1:
        return 2;
      case 2:
        return 1;
      default:
        return 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "MisPunch Reports"),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            // Filter Section
            _buildFilterSection(),

            // Content
            Expanded(
              child: Consumer<MisPunchReportsProvider>(
                builder: (context, provider, child) {
                  if (!provider.hasSearched) {
                    return _buildInitialState();
                  }

                  return FadeTransition(
                    opacity: _animationController,
                    child: Column(
                      children: [
                        // Tab Bar
                        _buildTabBar(),

                        // Summary Stats
                        _buildSummaryStats(provider),

                        // Search Bar
                        _buildSearchBar(provider),

                        // Reports List
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildReportsView(),
                              _buildReportsView(),
                              _buildReportsView(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
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
                          'Select Location',
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Consumer<MisPunchReportsProvider>(
                          builder: (context, provider, child) {
                            if (provider.selectedLocation != null) {
                              return Text(
                                provider.selectedLocation!,
                                style: TextStyle(
                                  fontFamily: AppFonts.poppins,
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _showFilters ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filters
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Consumer<MisPunchReportsProvider>(
                    builder: (context, provider, child) {
                      return CustomSearchDropdownWithSearch(
                        isMandatory: true,
                        labelText: "Location",
                        items: provider.locations,
                        selectedValue: provider.selectedLocation,
                        onChanged: (value) {
                          if (value != null) {
                            provider.setSelectedLocation(value);
                            provider.setHasSearched(false);
                          }
                        },
                        hintText: "Please select location",
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildGradientButton(
                    onPressed: () {
                      _searchFocusNode.unfocus();
                      final provider = context.read<MisPunchReportsProvider>();

                      if (provider.selectedLocation == null) {
                        _showSnackBar('Please select a location first', isError: true);
                        return;
                      }

                      final dayFilter = _getDayFilterFromIndex(_tabController.index);
                      provider.fetchReports(dayFilter);
                      provider.setHasSearched(true);
                      setState(() => _showFilters = false);
                    },
                    text: 'View Reports',
                    icon: Icons.visibility_rounded,
                  ),
                ],
              ),
            ),
            crossFadeState: _showFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_primaryColor, _secondaryColor],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(
          fontFamily: AppFonts.poppins,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AppFonts.poppins,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'Last 3 Days'),
          Tab(text: 'Last 2 Days'),
          Tab(text: 'Today'),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(MisPunchReportsProvider provider) {
    final mispunchCount = provider.filteredReports
        .where((r) => r.status == 'mispunch')
        .length;
    final absentCount = provider.filteredReports
        .where((r) => r.status == 'absent')
        .length;
    final totalCount = provider.filteredReports.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            label: 'Total',
            value: totalCount.toString(),
            icon: Icons.people_outline_rounded,
            color: _primaryColor,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'MisPunch',
            value: mispunchCount.toString(),
            icon: Icons.warning_amber_rounded,
            color: _warningColor,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'Absent',
            value: absentCount.toString(),
            icon: Icons.person_off_outlined,
            color: _errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildSearchBar(MisPunchReportsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              textInputAction: TextInputAction.done,
              style: const TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 14,
              ),
              onChanged: (value) {
                provider.searchReports(value);
              },
              onSubmitted: (_) => _searchFocusNode.unfocus(),
              decoration: InputDecoration(
                hintText: 'Search by name, ID, designation...',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: _primaryColor,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: Colors.grey.shade400),
                        onPressed: () {
                          _searchController.clear();
                          provider.searchReports('');
                          _searchFocusNode.unfocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _primaryColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // PDF Button
          Consumer<MisPunchReportsProvider>(
            builder: (context, provider, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: provider.isDownloading
                        ? null
                        : () async {
                            _searchFocusNode.unfocus();
                            final success = await provider.generateOverallPDF();
                            if (mounted) {
                              _showSnackBar(
                                success
                                    ? 'PDF generated successfully'
                                    : 'Failed to generate PDF',
                                isError: !success,
                              );
                            }
                          },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      child: provider.isDownloading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.picture_as_pdf_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportsView() {
    return Consumer<MisPunchReportsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState();
        }

        if (provider.filteredReports.isEmpty) {
          return _buildEmptyState(provider.searchQuery.isNotEmpty);
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: provider.filteredReports.length,
          itemBuilder: (context, index) {
            final report = provider.filteredReports[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 400 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: _buildReportCard(report, index),
            );
          },
        );
      },
    );
  }

  Widget _buildReportCard(MisPunchModel report, int index) {
    final isMispunch = report.status == 'mispunch';
    final statusColor = isMispunch ? _warningColor : _errorColor;
    final statusLabel = isMispunch ? 'MisPunch' : 'Absent';
    final statusIcon = isMispunch ? Icons.warning_amber_rounded : Icons.person_off_outlined;

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
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withOpacity(0.1),
                  statusColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withOpacity(0.7)],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Text(
                      report.name.isNotEmpty ? report.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.name,
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildInfoChip(Icons.badge_outlined, report.empId),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _buildInfoChip(Icons.work_outline_rounded, report.designation),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Date
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    value: report.date,
                    color: _primaryColor,
                  ),
                ),
                // In Time
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.login_rounded,
                    label: 'In Time',
                    value: report.inTime.isEmpty ? 'Not Punched' : report.inTime,
                    color: _successColor,
                    isHighlighted: report.inTime.isEmpty,
                  ),
                ),
                // Out Time
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.logout_rounded,
                    label: 'Out Time',
                    value: report.outTime.isEmpty || report.outTime == '-'
                        ? 'Not Punched'
                        : report.outTime,
                    color: _secondaryColor,
                    isHighlighted: report.outTime.isEmpty || report.outTime == '-',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isHighlighted
                ? _errorColor.withOpacity(0.1)
                : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isHighlighted ? _errorColor : color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isHighlighted ? _errorColor : Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.1),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _primaryColor.withOpacity(0.1),
                          _secondaryColor.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 56,
                      color: _primaryColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Select Location',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a location to view\nmispunch reports',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildGradientButton(
              onPressed: () => setState(() => _showFilters = true),
              text: 'Open Filters',
              icon: Icons.filter_list_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: _primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading reports...',
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isSearchResult) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearchResult ? Icons.search_off_rounded : Icons.check_circle_outline_rounded,
                size: 48,
                color: isSearchResult ? Colors.grey.shade400 : _successColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearchResult ? 'No Results Found' : 'No MisPunch Reports',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearchResult
                  ? 'Try a different search term'
                  : 'All employees have proper punch records',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryColor, _secondaryColor],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? _errorColor : _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
