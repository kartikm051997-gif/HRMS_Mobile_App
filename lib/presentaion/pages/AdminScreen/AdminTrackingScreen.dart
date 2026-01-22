import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/constants/appcolor_dart.dart';
import '../../../provider/AdminTrackingProvider/AdminTrackingProvider.dart';
import '../../../widgets/MultipleSelectDropDown/MultipleSelectDropDown.dart';
import 'HistoryTabScreen.dart';
import 'MapTabScreen.dart';
import 'TimeLineScreen.dart';

class AdminTrackingScreen extends StatefulWidget {
  const AdminTrackingScreen({super.key});

  @override
  State<AdminTrackingScreen> createState() => _AdminTrackingScreenState();
}

class _AdminTrackingScreenState extends State<AdminTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  GoogleMapController? _mapController;
  TrackingRecord? _selectedSession;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminTrackingProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onViewDetails(TrackingRecord session) {
    setState(() {
      _selectedSession = session;
      _tabController.animateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminTrackingProvider = Provider.of<AdminTrackingProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[50],
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Admin Tracking"),
      body: Column(
        children: [
          // HEADER SECTION
          Column(
            children: [
              // Filter Toggle Button
              Container(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: adminTrackingProvider.toggleFilter,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8E0E6B).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list, color: Colors.white),
                        const SizedBox(width: 12),
                        const Text(
                          'Filter Options',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        AnimatedRotation(
                          turns:
                              adminTrackingProvider.isFilterExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Expandable Filter Section
              if (adminTrackingProvider.isFilterExpanded)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final keyboardHeight =
                        MediaQuery.of(context).viewInsets.bottom;
                    final screenHeight = MediaQuery.of(context).size.height;
                    final appBarHeight =
                        MediaQuery.of(context).padding.top + kToolbarHeight;
                    final filterButtonHeight = 100.0;
                    final tabBarHeight =
                        adminTrackingProvider.hasSearched ? 48.0 : 0.0;

                    final maxFilterHeight =
                        screenHeight -
                        appBarHeight -
                        filterButtonHeight -
                        tabBarHeight -
                        keyboardHeight -
                        50;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      constraints: BoxConstraints(
                        maxHeight:
                            maxFilterHeight > 200 ? maxFilterHeight : 200,
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: [
                              SimpleSearchDropdown(
                                label: "Employee",
                                value: adminTrackingProvider.selectedEmployeeId,
                                items:
                                    adminTrackingProvider
                                        .getFilteredEmployees("")
                                        .map((e) => "${e.name} (${e.id})")
                                        .toList(),
                                onChanged: (selectedText) {
                                  final id =
                                      selectedText
                                          .split("(")
                                          .last
                                          .replaceAll(")", "")
                                          .trim();
                                  adminTrackingProvider.setEmployeeId(id);
                                },
                              ),
                              const SizedBox(height: 12),

                              // Multi-select Zone Dropdown
                              MultiSelectDropdown(
                                label: "Zone",
                                selectedItems:
                                    adminTrackingProvider.selectedZones,
                                items: adminTrackingProvider.zoneNames,
                                onChanged: (selected) {
                                  adminTrackingProvider.setZones(selected);
                                },
                              ),
                              const SizedBox(height: 12),

                              // Multi-select Branch Dropdown
                              MultiSelectDropdown(
                                label: "Branch",
                                selectedItems:
                                    adminTrackingProvider.selectedBranches,
                                items: adminTrackingProvider.branchNames,
                                onChanged: (selected) {
                                  adminTrackingProvider.setBranches(selected);
                                },
                              ),
                              const SizedBox(height: 12),

                              SimpleSearchDropdown(
                                label: "Role",
                                value:
                                    adminTrackingProvider.selectedDesignation,
                                items: adminTrackingProvider.getFilteredRoles(
                                  "",
                                ),
                                onChanged: (value) {
                                  adminTrackingProvider.setRole(value);
                                },
                              ),
                              const SizedBox(height: 12),
                              _DatePickerField(provider: adminTrackingProvider),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  // CLEAR BUTTON
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        context
                                            .read<AdminTrackingProvider>()
                                            .clearFilters();
                                      },
                                      child: Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Text(
                                          "Clear",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: AppFonts.poppins,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // SEARCH BUTTON
                                  Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap:
                                          _isSearching
                                              ? null
                                              : () async {
                                                final provider =
                                                    context
                                                        .read<
                                                          AdminTrackingProvider
                                                        >();

                                                if (!provider.isFiltersValid) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Please select all filters',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                setState(
                                                  () => _isSearching = true,
                                                );
                                                await provider.performSearch();
                                                setState(() {
                                                  _isSearching = false;
                                                  _selectedSession = null;
                                                  _tabController.animateTo(0);
                                                });
                                              },
                                      child: Container(
                                        height: 48,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColor.primaryColor2,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child:
                                            _isSearching
                                                ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                                : const Text(
                                                  "Search",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    fontFamily:
                                                        AppFonts.poppins,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // TabBar (only show when search is done)
              if (adminTrackingProvider.hasSearched)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8E0E6B).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black54,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: const TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                      tabs: const [
                        Tab(height: 44, text: "History"),
                        Tab(height: 44, text: "Timeline"),
                        Tab(height: 44, text: "Map View"),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // CONTENT AREA - Fixed the logic here divya
          Expanded(
            child:
                adminTrackingProvider.hasSearched
                    ? (adminTrackingProvider.isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFF8E0E6B),
                            ),
                          ),
                        )
                        : adminTrackingProvider.trackingRecords.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tracking records found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try different filter criteria',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                            ],
                          ),
                        )
                        : TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            HistoryTabScreen(
                              sessions: adminTrackingProvider.trackingRecords,
                              onViewDetails: _onViewDetails,
                            ),
                            TimelineTabScreen(
                              session:
                                  _selectedSession ??
                                  (adminTrackingProvider
                                          .trackingRecords
                                          .isNotEmpty
                                      ? adminTrackingProvider
                                          .trackingRecords
                                          .first
                                      : null),
                            ),
                            MapTabScreen(
                              session:
                                  _selectedSession ??
                                  (adminTrackingProvider
                                          .trackingRecords
                                          .isNotEmpty
                                      ? adminTrackingProvider
                                          .trackingRecords
                                          .first
                                      : null),
                              onMapCreated: (c) => _mapController = c,
                            ),
                          ],
                        ))
                    : Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_alt_outlined,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Select filters and search',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use the filter button above to get started',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                  fontFamily: AppFonts.poppins,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

// Simple Search Dropdown (for single select) with Search
class SimpleSearchDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String) onChanged;

  const SimpleSearchDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<SimpleSearchDropdown> createState() => _SimpleSearchDropdownState();
}

class _SimpleSearchDropdownState extends State<SimpleSearchDropdown> {
  bool _isExpanded = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredItems {
    if (_searchQuery.isEmpty) return widget.items;
    return widget.items
        .where(
          (item) => item.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontFamily: AppFonts.poppins,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
              if (!_isExpanded) {
                _searchQuery = '';
                _searchController.clear();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value ?? 'Select ${widget.label}',
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 14,
                      color:
                          widget.value != null
                              ? AppColor.primaryColor1
                              : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF8E0E6B),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search TextField
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.label}...',
                      hintStyle: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 13,
                        color: Colors.grey[400],
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF8E0E6B)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 14,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                // List of items
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child:
                      _filteredItems.isEmpty
                          ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No ${widget.label.toLowerCase()} found',
                              style: TextStyle(
                                fontFamily: AppFonts.poppins,
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                          : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  item,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    fontSize: 14,
                                  ),
                                ),
                                onTap: () {
                                  widget.onChanged(item);
                                  setState(() {
                                    _isExpanded = false;
                                    _searchQuery = '';
                                    _searchController.clear();
                                  });
                                },
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final AdminTrackingProvider provider;

  const _DatePickerField({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontFamily: AppFonts.poppins,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: provider.selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF8E0E6B),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    textTheme: const TextTheme(
                      headlineLarge: TextStyle(fontFamily: AppFonts.poppins),
                      headlineMedium: TextStyle(fontFamily: AppFonts.poppins),
                      headlineSmall: TextStyle(fontFamily: AppFonts.poppins),
                      titleLarge: TextStyle(fontFamily: AppFonts.poppins),
                      bodyLarge: TextStyle(fontFamily: AppFonts.poppins),
                      bodyMedium: TextStyle(fontFamily: AppFonts.poppins),
                      bodySmall: TextStyle(fontFamily: AppFonts.poppins),
                      labelLarge: TextStyle(fontFamily: AppFonts.poppins),
                    ),
                    datePickerTheme: const DatePickerThemeData(
                      headerHeadlineStyle: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      dayStyle: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 14,
                      ),
                      yearStyle: TextStyle(fontFamily: AppFonts.poppins),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              provider.setDate(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Color(0xFF8E0E6B),
                ),
                const SizedBox(width: 12),
                Text(
                  provider.selectedDate != null
                      ? DateFormat('dd MMM yyyy').format(provider.selectedDate!)
                      : 'Select Date',
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 14,
                    color:
                        provider.selectedDate != null
                            ? AppColor.primaryColor1
                            : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
