import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/constants/appcolor_dart.dart';
import '../../../provider/AdminTrackingProvider/AdminTrackingProvider.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      _tabController.animateTo(1); // Switch to Timeline tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminTrackingProvider(),
      child: Consumer<AdminTrackingProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            drawer: const TabletMobileDrawer(),
            appBar: const CustomAppBar(title: "Admin Tracking"),
            body: Column(
              children: [
                // Filter Toggle Button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: provider.toggleFilter,
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
                          const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Filter Options',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                          const Spacer(),
                          AnimatedRotation(
                            turns: provider.isFilterExpanded ? 0.5 : 0,
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

                // Filter Section (Expandable)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child:
                      provider.isFilterExpanded
                          ? Container(
                            color: Colors.white,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              children: [
                                _SearchableDropdown(
                                  label: 'Employee ID',
                                  value: provider.selectedEmployeeId,
                                  icon: Icons.person,
                                  onTap:
                                      () => _showEmployeeSearch(
                                        context,
                                        provider,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                _SearchableDropdown(
                                  label: 'Branch',
                                  value: provider.selectedBranch,
                                  icon: Icons.business,
                                  onTap:
                                      () =>
                                          _showBranchSearch(context, provider),
                                ),
                                const SizedBox(height: 12),
                                _SearchableDropdown(
                                  label: 'Designation',
                                  value: provider.selectedDesignation,
                                  icon: Icons.work,
                                  onTap:
                                      () => _showRoleSearch(context, provider),
                                ),
                                const SizedBox(height: 12),
                                _DatePickerField(provider: provider),
                                const SizedBox(height: 20),
                                _SearchButton(
                                  provider: provider,
                                  onSearch: () {
                                    if (!provider.isFiltersValid) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please select all filters',
                                            style: TextStyle(
                                              fontFamily: AppFonts.poppins,
                                            ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    provider.performSearch();
                                    setState(() {
                                      _selectedSession = null;
                                      _tabController.animateTo(
                                        0,
                                      ); // History tab
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                          : const SizedBox.shrink(),
                ),

                // Tabs (only show after search)
                if (provider.hasSearched && provider.isFiltersValid)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColor.primaryColor2,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF8E0E6B),
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        fontFamily: AppFonts.poppins,
                      ),
                      tabs: const [
                        Tab(icon: Icon(Icons.history), text: 'History'),
                        Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
                        Tab(icon: Icon(Icons.location_on), text: 'Map View'),
                      ],
                    ),
                  ),

                // Content Area
                Expanded(
                  child:
                      provider.isLoading
                          ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFF8E0E6B),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Loading tracking data...',
                                  style: TextStyle(
                                    fontFamily: AppFonts.poppins,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : provider.hasSearched && provider.isFiltersValid
                          ? TabBarView(
                            controller: _tabController,
                            children: [
                              _HistoryTab(
                                sessions: provider.trackingRecords,
                                onViewDetails: _onViewDetails,
                              ),
                              _TimelineTab(
                                session:
                                    _selectedSession ??
                                    (provider.trackingRecords.isNotEmpty
                                        ? provider.trackingRecords.first
                                        : null),
                              ),
                              _MapTab(
                                session:
                                    _selectedSession ??
                                    (provider.trackingRecords.isNotEmpty
                                        ? provider.trackingRecords.first
                                        : null),
                                onMapCreated: (controller) {
                                  _mapController = controller;
                                },
                              ),
                            ],
                          )
                          : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Select filters and search to view history',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEmployeeSearch(
    BuildContext context,
    AdminTrackingProvider provider,
  ) {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              final filteredEmployees = provider.getFilteredEmployees(
                searchQuery,
              );
              return DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                expand: false,
                builder:
                    (context, scrollController) => Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Search employee...',
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Color(0xFF8E0E6B),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF8E0E6B),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() => searchQuery = value);
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: filteredEmployees.length,
                            itemBuilder: (context, index) {
                              final emp = filteredEmployees[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(
                                    0xFF8E0E6B,
                                  ).withOpacity(0.1),
                                  child: Text(
                                    emp.name[0],
                                    style: const TextStyle(
                                      color: Color(0xFF8E0E6B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  emp.name,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                                subtitle: Text(
                                  emp.id,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                                onTap: () {
                                  provider.setEmployeeId(emp.id);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
    );
  }

  void _showBranchSearch(BuildContext context, AdminTrackingProvider provider) {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              final filteredBranches = provider.getFilteredBranches(
                searchQuery,
              );
              return DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.4,
                maxChildSize: 0.8,
                expand: false,
                builder:
                    (context, scrollController) => Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Search branch...',
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Color(0xFF8E0E6B),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF8E0E6B),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() => searchQuery = value);
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: filteredBranches.length,
                            itemBuilder: (context, index) {
                              final branch = filteredBranches[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.business,
                                  color: Color(0xFF8E0E6B),
                                ),
                                title: Text(
                                  branch,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                                onTap: () {
                                  provider.setBranch(branch);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
    );
  }

  void _showRoleSearch(BuildContext context, AdminTrackingProvider provider) {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              final filteredRoles = provider.getFilteredRoles(searchQuery);
              return DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.3,
                maxChildSize: 0.7,
                expand: false,
                builder:
                    (context, scrollController) => Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Search role...',
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Color(0xFF8E0E6B),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF8E0E6B),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() => searchQuery = value);
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: filteredRoles.length,
                            itemBuilder: (context, index) {
                              final role = filteredRoles[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.work,
                                  color: Color(0xFF8E0E6B),
                                ),
                                title: Text(
                                  role,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.poppins,
                                  ),
                                ),
                                onTap: () {
                                  provider.setRole(role);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
    );
  }
}

// ========== REUSABLE WIDGETS ==========

class _SearchableDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchableDropdown({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
            fontFamily: AppFonts.poppins,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF8E0E6B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value ?? 'Select $label',
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 14,
                      color: value != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                            ? Colors.black87
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

class _SearchButton extends StatelessWidget {
  final AdminTrackingProvider provider;
  final VoidCallback onSearch;

  const _SearchButton({required this.provider, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          onPressed: onSearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Search',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========== HISTORY TAB ==========

class _HistoryTab extends StatelessWidget {
  final List<TrackingRecord> sessions;
  final Function(TrackingRecord) onViewDetails;

  const _HistoryTab({required this.sessions, required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(
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
                          Text(
                            session.employeeName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontFamily: AppFonts.poppins,
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
                      child: ElevatedButton.icon(
                        onPressed: () => onViewDetails(session),
                        icon: const Icon(Icons.visibility),
                        label: const Text(
                          'View Details',
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E0E6B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
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

// ========== TIMELINE TAB ==========

class _TimelineTab extends StatelessWidget {
  final TrackingRecord? session;

  const _TimelineTab({required this.session});

  @override
  Widget build(BuildContext context) {
    if (session == null || session!.trackingPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No tracking data available',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a session from History to view details',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final points = session!.trackingPoints;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: points.length,
      itemBuilder: (context, index) {
        final point = points[index];
        final isCheckIn = index == 0;
        final isCheckOut = index == points.length - 1;

        if (isCheckIn) {
          return _CheckInCard(point: point);
        } else if (isCheckOut) {
          return _CheckOutCard(point: point);
        } else {
          return _TrackingPointCard(point: point, index: index);
        }
      },
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final TrackingPoint point;

  const _CheckInCard({required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.login, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Check In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                    fontFamily: AppFonts.poppins,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  point.time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        point.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontFamily: AppFonts.poppins,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
}

class _TrackingPointCard extends StatelessWidget {
  final TrackingPoint point;
  final int index;

  const _TrackingPointCard({required this.point, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFFF9800),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.poppins,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        point.address,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: AppFonts.poppins,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      point.time,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${point.distanceFromPrevious.toInt()} m',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontFamily: AppFonts.poppins,
                      ),
                    ),
                  ],
                ),
                if (point.waitTime != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'Waited: ${point.waitTime!.inMinutes} min',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.poppins,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckOutCard extends StatelessWidget {
  final TrackingPoint point;

  const _CheckOutCard({required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF44336), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF44336),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Check Out',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF44336),
                    fontFamily: AppFonts.poppins,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  point.time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: AppFonts.poppins,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        point.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontFamily: AppFonts.poppins,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
}

// ========== MAP TAB ==========

class _MapTab extends StatelessWidget {
  final TrackingRecord? session;
  final Function(GoogleMapController) onMapCreated;

  const _MapTab({required this.session, required this.onMapCreated});

  @override
  Widget build(BuildContext context) {
    if (session == null || session!.trackingPoints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No tracking data available',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a session from History to view map',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final points = session!.trackingPoints;
    final Set<Marker> markers = {};
    final Set<Polyline> polylines = {};

    // Create markers
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isCheckIn = i == 0;
      final isCheckOut = i == points.length - 1;

      markers.add(
        Marker(
          markerId: MarkerId('point_$i'),
          position: point.location,
          icon:
              isCheckIn
                  ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  )
                  : isCheckOut
                  ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  )
                  : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  ),
          infoWindow: InfoWindow(
            title:
                isCheckIn
                    ? 'Check In'
                    : isCheckOut
                    ? 'Check Out'
                    : 'Stop $i',
            snippet: '${point.time} - ${point.address}',
          ),
        ),
      );
    }

    // Create polyline
    polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: points.map((p) => p.location).toList(),
        color: const Color(0xFF8E0E6B),
        width: 5,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    );

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: points.first.location,
            zoom: 14,
          ),
          markers: markers,
          polylines: polylines,
          onMapCreated: (controller) {
            onMapCreated(controller);
            _fitMapBounds(controller, points);
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
        ),

        // Info Card
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session!.employeeName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                          Text(
                            session!.employeeId,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MapInfoItem(
                        icon: Icons.location_on,
                        label: 'Locations',
                        value: '${points.length}',
                      ),
                      Container(
                        width: 1,
                        height: 35,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _MapInfoItem(
                        icon: Icons.straighten,
                        label: 'Distance',
                        value:
                            '${(session!.totalDistance / 1000).toStringAsFixed(1)} km',
                      ),
                      Container(
                        width: 1,
                        height: 35,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _MapInfoItem(
                        icon: Icons.access_time,
                        label: 'Duration',
                        value: '${session!.totalDuration.inMinutes} min',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _fitMapBounds(
    GoogleMapController controller,
    List<TrackingPoint> points,
  ) {
    if (points.isEmpty) return;

    double minLat = points.first.location.latitude;
    double maxLat = points.first.location.latitude;
    double minLng = points.first.location.longitude;
    double maxLng = points.first.location.longitude;

    for (var point in points) {
      if (point.location.latitude < minLat) minLat = point.location.latitude;
      if (point.location.latitude > maxLat) maxLat = point.location.latitude;
      if (point.location.longitude < minLng) minLng = point.location.longitude;
      if (point.location.longitude > maxLng) maxLng = point.location.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
}

class _MapInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MapInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: AppFonts.poppins,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ],
    );
  }
}
