import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../provider/PaySlipsDrawerProvider/PaySlipsDrawerProvider.dart';

class PaySlipDrawerScreen extends StatefulWidget {
  const PaySlipDrawerScreen({super.key});

  @override
  State<PaySlipDrawerScreen> createState() => _PaySlipDrawerScreenState();
}

class _PaySlipDrawerScreenState extends State<PaySlipDrawerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaySlipsDrawerProvider>().loadEmployees();
      context.read<PaySlipsDrawerProvider>().loadLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: "PaySlips"),
      drawer: const TabletMobileDrawer(),

      body: Consumer<PaySlipsDrawerProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchTypeDropdown(provider),
                  const SizedBox(height: 20),
                  if (provider.searchType == 'By Employee')
                    _buildEmployeeSearchSection(provider)
                  else
                    _buildLocationMonthSearchSection(provider),
                  const SizedBox(height: 24),
                  if (provider.isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFAB47BC),
                      ),
                    )
                  else if (provider.payslips.isNotEmpty)
                    _buildPayrollSummary(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchTypeDropdown(PaySlipsDrawerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Type *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: provider.searchType,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items:
                ['By Employee', 'By Month and Location']
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type, style: const TextStyle(fontSize: 15)),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) provider.setSearchType(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeSearchSection(PaySlipsDrawerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Employee Name *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: provider.selectedEmployee,
            hint: const Text(
              'Select Employee',
              style: TextStyle(color: Colors.grey),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items:
                provider.employees
                    .map(
                      (emp) => DropdownMenuItem(
                        value: emp.id,
                        child: Text(
                          '${emp.id}-${emp.name} (${emp.designation})',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              provider.setSelectedEmployee(value);
              if (value != null) {
                provider.searchPayslipsByEmployee(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationMonthSearchSection(PaySlipsDrawerProvider provider) {
    return Column(
      children: [
        _buildLocationDropdown(provider),
        const SizedBox(height: 20),
        _buildMonthPicker(provider),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (provider.selectedLocation != null &&
                  provider.selectedMonth != null) {
                provider.searchPayslipsByLocationMonth(
                  provider.selectedLocation!,
                  provider.selectedMonth!,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select location and month'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C6BC0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Go',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationDropdown(PaySlipsDrawerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: provider.selectedLocation,
            hint: const Text(
              'Select Location',
              style: TextStyle(color: Colors.grey),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items:
                provider.locations
                    .map(
                      (loc) => DropdownMenuItem(
                        value: loc,
                        child: Text(loc, style: const TextStyle(fontSize: 14)),
                      ),
                    )
                    .toList(),
            onChanged: (value) => provider.setSelectedLocation(value),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthPicker(PaySlipsDrawerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Month *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFFAB47BC),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) provider.setSelectedMonth(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  provider.selectedMonth != null
                      ? DateFormat('MMMM yyyy').format(provider.selectedMonth!)
                      : 'Select Month',
                  style: TextStyle(
                    fontSize: 15,
                    color:
                        provider.selectedMonth != null
                            ? Colors.black87
                            : Colors.grey,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Color(0xFFAB47BC),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayrollSummary(PaySlipsDrawerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payroll Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF5F5F5),
              ),
              columnSpacing: 20,
              columns: const [
                DataColumn(
                  label: Text(
                    'Month & Year',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'EMP ID',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Designation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Working Days',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'LOP Days',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Gross Salary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Deductions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Net Salary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Actions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
              rows:
                  provider.payslips.map((payslip) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            payslip.monthYear,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            payslip.empId,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            payslip.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            payslip.designation,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${payslip.workingDays}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${payslip.lopDays}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${payslip.grossSalary.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${payslip.totalDeductions.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${payslip.netSalary.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Payslip',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class EmployeeManagementScreen extends StatefulWidget {
  const EmployeeManagementScreen({super.key});

  @override
  State<EmployeeManagementScreen> createState() =>
      _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Employees Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFAB47BC), Color(0xFFEC407A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<EmployeeProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildTabBar(provider),
              _buildSearchAndFilter(provider),
              if (provider.showFilters) _buildFilterSection(provider),
              Expanded(
                child:
                    provider.isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFAB47BC),
                          ),
                        )
                        : _buildEmployeeList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar(EmployeeProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildTab('Active', provider),
          _buildTab('Management Approval', provider),
          _buildTab('Abscond', provider),
        ],
      ),
    );
  }

  Widget _buildTab(String label, EmployeeProvider provider) {
    final isSelected = provider.selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setSelectedTab(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFAB47BC) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(EmployeeProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                onChanged: (value) => provider.setSearchQuery(value),
                decoration: InputDecoration(
                  hintText: 'Search employees by name, ID, design...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => provider.toggleFilters(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    provider.showFilters
                        ? const Color(0xFFAB47BC)
                        : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFAB47BC)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color:
                        provider.showFilters
                            ? Colors.white
                            : const Color(0xFFAB47BC),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filters',
                    style: TextStyle(
                      color:
                          provider.showFilters
                              ? Colors.white
                              : const Color(0xFFAB47BC),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(EmployeeProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Zone',
                  provider.selectedZone,
                  ['South', 'North', 'West', 'East'],
                  (val) => provider.setSelectedZone(val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  'Branch',
                  provider.selectedBranch,
                  ['chengalpattu', 'bangalore', 'mumbai', 'hyderabad'],
                  (val) => provider.setSelectedBranch(val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Designation',
                  provider.selectedDesignation,
                  ['Admin', 'Manager', 'Developer', 'HR Manager', 'Team Lead'],
                  (val) => provider.setSelectedDesignation(val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => provider.clearFilters(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFAB47BC),
                    side: const BorderSide(color: Color(0xFFAB47BC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => provider.toggleFilters(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C6BC0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            hint: Text(
              'Select $label',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items:
                items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item, style: const TextStyle(fontSize: 13)),
                      ),
                    )
                    .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeList(EmployeeProvider provider) {
    final employees = provider.filteredEmployees;

    if (employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No employees found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${employees.length} Employees Found',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242),
                ),
              ),
              if (provider.showFilters)
                TextButton(
                  onPressed: () => provider.toggleFilters(),
                  child: const Text(
                    'Hide Filters',
                    style: TextStyle(
                      color: Color(0xFFAB47BC),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];
              return _buildEmployeeCard(employee);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFAB47BC), Color(0xFFEC407A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFAB47BC).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate to employee details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://ui-avatars.com/api/?name=${employee.name}&background=AB47BC&color=fff&bold=true',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 30,
                          color: Color(0xFFAB47BC),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${employee.id}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.business_center,
                            employee.designation,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.location_on, employee.branch),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
