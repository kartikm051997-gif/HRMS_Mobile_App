import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/payroll_provider/Attendance_Log_provider.dart';
import '../../../widgets/custom_textfield/Custom_date_field.dart';
import '../../../widgets/custom_textfield/custom_dropdown_with_search.dart';

class AttendanceLogScreen extends StatefulWidget {
  const AttendanceLogScreen({super.key});

  @override
  State<AttendanceLogScreen> createState() => _AttendanceLogScreenState();
}

class _AttendanceLogScreenState extends State<AttendanceLogScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _employeeSearchController = TextEditingController();
  late AnimationController _animationController;
  bool _showFilters = true;

  // Colors
  static const Color _primaryColor = Color(0xFF8E0E6B);
  static const Color _secondaryColor = Color(0xFFD4145A);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _errorColor = Color(0xFFEF4444);
  static const Color _infoColor = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _employeeSearchController.dispose();
    _animationController.dispose();
    Provider.of<AttendanceLogProvider>(context, listen: false).resetSelections();
    super.dispose();
  }

  void _resetFilters() {
    Provider.of<AttendanceLogProvider>(context, listen: false).resetSelections();
    _employeeSearchController.clear();
    setState(() => _showFilters = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Attendance Log"),
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),

          // Results Section
          Expanded(
            child: Consumer<AttendanceLogProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return _buildLoadingState();
                }

                if (provider.attendanceData.isEmpty) {
                  return _buildEmptyState();
                }

                _animationController.forward();
                return FadeTransition(
                  opacity: _animationController,
                  child: _buildResultsSection(provider),
                );
              },
            ),
          ),
        ],
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
                      Icons.tune_rounded,
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
                          'Attendance Filters',
                          style: TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Consumer<AttendanceLogProvider>(
                          builder: (context, provider, child) {
                            if (provider.selectedZones != null) {
                              return Text(
                                '${provider.selectedZones} • ${provider.dateController.text}',
                                style: TextStyle(
                                  fontFamily: AppFonts.poppins,
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                                overflow: TextOverflow.ellipsis,
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

          // Filters Content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildFiltersContent(),
            crossFadeState: _showFilters
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersContent() {
    return Consumer<AttendanceLogProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // Zone & Branch Row
              Row(
                children: [
                  Expanded(
                    child: _buildCompactDropdown(
                      label: 'Zone',
                      icon: Icons.map_outlined,
                      items: provider.zones,
                      value: provider.selectedZones,
                      onChanged: provider.setSelectedZones,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactDropdown(
                      label: 'Branch',
                      icon: Icons.business_rounded,
                      items: provider.branches,
                      value: provider.selectedBranches,
                      onChanged: provider.setSelectedBranches,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Type & Category Row
              Row(
                children: [
                  Expanded(
                    child: _buildCompactDropdown(
                      label: 'Type',
                      icon: Icons.category_rounded,
                      items: provider.type,
                      value: provider.selectedType,
                      onChanged: provider.setSelectedType,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCompactDropdown(
                      label: 'Category',
                      icon: Icons.group_outlined,
                      items: provider.employeeSalaryCategory,
                      value: provider.selectedEmployeeSalaryCategory,
                      onChanged: provider.setSelectedEmployeeSalaryCategory,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Period Selection
              Row(
                children: [
                  Expanded(
                    child: _buildCompactDropdown(
                      label: 'Period',
                      icon: Icons.date_range_rounded,
                      items: provider.monDay,
                      value: provider.selectedMonDay,
                      onChanged: provider.setSelectedMonDay,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(provider),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildOutlinedButton(
                      onPressed: _resetFilters,
                      text: 'Reset',
                      icon: Icons.refresh_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildGradientButton(
                      onPressed: () => _handleSearch(provider),
                      text: 'Search Attendance',
                      icon: Icons.search_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _primaryColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select...',
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 13,
                  color: Colors.grey.shade400,
                ),
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(AttendanceLogProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_rounded, size: 14, color: _primaryColor),
            const SizedBox(width: 6),
            Text(
              provider.selectedMonDay == 'Day' ? 'Select Day' : 'Select Month',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _handleDateSelection(provider),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    provider.dateController.text.isEmpty
                        ? 'Select...'
                        : provider.dateController.text,
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 13,
                      color: provider.dateController.text.isEmpty
                          ? Colors.grey.shade400
                          : Colors.grey.shade800,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleDateSelection(AttendanceLogProvider provider) async {
    if (provider.selectedMonDay == 'Month') {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      
      String? selectedMonth = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _buildMonthPickerSheet(months),
      );

      if (selectedMonth != null) {
        provider.dateController.text = selectedMonth;
        setState(() {});
      }
    } else if (provider.selectedMonDay == 'Day') {
      DateTime? selectedDay = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: _primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: _primaryColor),
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedDay != null) {
        provider.dateController.text = '${selectedDay.day}-${selectedDay.month}-${selectedDay.year}';
        setState(() {});
      }
    }
  }

  Widget _buildMonthPickerSheet(List<String> months) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: _primaryColor),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Month',
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          // Month Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: months.length,
              itemBuilder: (context, index) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context, months[index]),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _primaryColor.withOpacity(0.2)),
                      ),
                      child: Center(
                        child: Text(
                          months[index],
                          style: const TextStyle(
                            fontFamily: AppFonts.poppins,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleSearch(AttendanceLogProvider provider) {
    if (provider.selectedZones != null &&
        provider.selectedBranches != null &&
        provider.selectedType != null &&
        provider.selectedEmployeeSalaryCategory != null &&
        provider.selectedMonDay != null &&
        provider.dateController.text.isNotEmpty) {
      provider.fetchAttendanceData(
        zones: provider.selectedZones!,
        branches: provider.selectedBranches!,
        type: provider.selectedType!,
        salaryCategory: provider.selectedEmployeeSalaryCategory!,
        period: provider.selectedMonDay!,
        date: provider.dateController.text,
        employeeSearch: _employeeSearchController.text,
      );
      setState(() => _showFilters = false);
    } else {
      _showSnackBar('Please fill all required fields', isError: true);
    }
  }

  Widget _buildResultsSection(AttendanceLogProvider provider) {
    // Filter data based on search
    final filteredData = _employeeSearchController.text.isEmpty
        ? provider.attendanceData
        : provider.attendanceData.where((item) {
            final query = _employeeSearchController.text.toLowerCase();
            final empId = (item['empId'] ?? '').toString().toLowerCase();
            final name = (item['name'] ?? '').toString().toLowerCase();
            return empId.contains(query) || name.contains(query);
          }).toList();

    return Column(
      children: [
        // Summary Stats
        _buildSummaryStats(provider),

        // Search Bar
        _buildSearchBar(provider),

        // Results Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Attendance Records',
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${filteredData.length}',
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Records List
        Expanded(
          child: filteredData.isEmpty
              ? _buildNoResultsState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 400 + (index * 50)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: _buildAttendanceCard(filteredData[index], index),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(AttendanceLogProvider provider) {
    final totalEmployees = provider.attendanceData.length;
    final checkedIn = provider.attendanceData
        .where((e) => e['inTime'] != null && e['inTime'] != '-')
        .length;
    final checkedOut = provider.attendanceData
        .where((e) => e['outTime'] != null && e['outTime'] != '-')
        .length;
    final pending = totalEmployees - checkedOut;

    return Container(
      margin: const EdgeInsets.all(16),
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
            value: totalEmployees.toString(),
            icon: Icons.people_outline_rounded,
            color: _primaryColor,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'Checked In',
            value: checkedIn.toString(),
            icon: Icons.login_rounded,
            color: _successColor,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'Checked Out',
            value: checkedOut.toString(),
            icon: Icons.logout_rounded,
            color: _infoColor,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'Pending',
            value: pending.toString(),
            icon: Icons.pending_outlined,
            color: _warningColor,
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildSearchBar(AttendanceLogProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _employeeSearchController,
        style: const TextStyle(
          fontFamily: AppFonts.poppins,
          fontSize: 14,
        ),
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search by employee ID or name...',
          hintStyle: TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 14,
            color: Colors.grey.shade400,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: _primaryColor),
          suffixIcon: _employeeSearchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _employeeSearchController.clear();
                    setState(() {});
                  },
                  icon: Icon(Icons.clear_rounded, color: Colors.grey.shade400),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> item, int index) {
    final hasCheckedOut = item['outTime'] != null && item['outTime'] != '-';
    final statusColor = hasCheckedOut ? _successColor : _warningColor;
    final statusLabel = hasCheckedOut ? 'Complete' : 'Pending';

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
                      colors: [_primaryColor, _secondaryColor],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Text(
                      (item['name'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _primaryColor,
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
                        item['name'] ?? '-',
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
                          _buildInfoChip(Icons.badge_outlined, item['empId'] ?? '-'),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _buildInfoChip(
                              Icons.work_outline_rounded,
                              item['designation'] ?? '-',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Branch
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['branch'] ?? '-',
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Time Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeBox(
                        title: 'Check In',
                        time: item['inTime'] ?? '-',
                        icon: Icons.login_rounded,
                        color: _successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeBox(
                        title: 'Check Out',
                        time: item['outTime'] ?? '-',
                        icon: Icons.logout_rounded,
                        color: _secondaryColor,
                        isHighlighted: item['outTime'] == '-',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeBox(
                        title: 'Duration',
                        time: item['hoursWorked'] ?? '-',
                        icon: Icons.timer_outlined,
                        color: _infoColor,
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

  Widget _buildTimeBox({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? _errorColor.withOpacity(0.08)
            : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? _errorColor.withOpacity(0.2)
              : color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: isHighlighted ? _errorColor : color,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isHighlighted ? _errorColor : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
  }) {
    return Container(
      height: 48,
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
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 14,
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

  Widget _buildOutlinedButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
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
                Icon(icon, color: Colors.grey.shade600, size: 18),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
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
            'Loading attendance data...',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_note_rounded,
                size: 56,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No Attendance Data',
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the filters above to search\nfor attendance records',
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
              icon: Icons.tune_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No matching records',
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search term',
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
