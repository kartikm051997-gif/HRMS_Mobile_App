import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../core/constants/appcolor_dart.dart';
import '../../../core/fonts/fonts.dart';
import '../../../provider/EmployeeAssetProvider/EmployeeAssetProvider.dart';

class AssetUpdateTab extends StatefulWidget {
  const AssetUpdateTab({super.key});

  @override
  State<AssetUpdateTab> createState() => _AssetUpdateTabState();
}

class _AssetUpdateTabState extends State<AssetUpdateTab>
    with SingleTickerProviderStateMixin {
  String? selectedAsset;
  EmployeeAssetModel? selectedEmployee;
  
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController simCtrl = TextEditingController();
  final TextEditingController laptopCtrl = TextEditingController();
  final TextEditingController tabletCtrl = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEmployeeData();
  }

  void _loadEmployeeData() {
    final provider = Provider.of<EmployeeAssetProvider>(context, listen: false);

    if (provider.selectedEmployee != null) {
      final emp = provider.selectedEmployee!;
      selectedEmployee = emp;
      selectedAsset = emp.assetType;
      mobileCtrl.text = emp.mobile == '-' ? '' : emp.mobile;
      simCtrl.text = emp.sim == '-' ? '' : emp.sim;
      laptopCtrl.text = emp.laptop == '-' ? '' : emp.laptop;
      tabletCtrl.text = emp.tablet == '-' ? '' : emp.tablet;
    } else {
      selectedEmployee = null;
      selectedAsset = null;
      mobileCtrl.clear();
      simCtrl.clear();
      laptopCtrl.clear();
      tabletCtrl.clear();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    mobileCtrl.dispose();
    simCtrl.dispose();
    laptopCtrl.dispose();
    tabletCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeAssetProvider>(context);
    final emp = provider.selectedEmployee;
    final isEditMode = emp != null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Employee Header (Edit mode)
                if (isEditMode) ...[
                  _buildSelectedEmployeeCard(emp),
                  const SizedBox(height: 24),
                ],

                // Employee Selection Section
                _buildSectionCard(
                  title: 'Select Employee',
                  icon: Icons.person_search_rounded,
                  child: _buildEmployeeDropdown(provider),
                ),
                const SizedBox(height: 20),

                // Asset Type Section
                _buildSectionCard(
                  title: 'Asset Type',
                  icon: Icons.category_rounded,
                  child: _buildAssetTypeDropdown(),
                ),
                const SizedBox(height: 20),

                // Asset Details Section
                _buildSectionCard(
                  title: 'Asset Details',
                  icon: Icons.inventory_2_rounded,
                  child: _buildAssetFields(),
                ),
                const SizedBox(height: 32),

                // Update Button
                _buildUpdateButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedEmployeeCard(EmployeeAssetModel emp) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E0E6B).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: Hero(
                tag: 'avatar_${emp.empId}',
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(emp.photo),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emp.empName,
                    style: const TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildHeaderChip(Icons.badge_outlined, emp.empId),
                      const SizedBox(width: 8),
                      _buildHeaderChip(Icons.work_outline, emp.designation),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor2.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColor.primaryColor2,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppFonts.poppins,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.grey.shade100,
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeDropdown(EmployeeAssetProvider provider) {
    return DropdownSearch<EmployeeAssetModel>(
      selectedItem: selectedEmployee,
      items: (filter, infiniteScrollProps) => provider.assetList,
      compareFn: (item1, item2) => item1.empId == item2.empId,
      itemAsString: (item) => '${item.empId} - ${item.empName}',
      filterFn: (item, filter) {
        final query = filter.toLowerCase();
        return item.empId.toLowerCase().contains(query) ||
               item.empName.toLowerCase().contains(query) ||
               item.department.toLowerCase().contains(query) ||
               item.designation.toLowerCase().contains(query);
      },
      popupProps: PopupProps.modalBottomSheet(
        showSearchBox: true,
        modalBottomSheetProps: ModalBottomSheetProps(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        searchFieldProps: TextFieldProps(
          style: const TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Search by ID or Name...',
            hintStyle: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColor.primaryColor2,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColor.primaryColor2, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        containerBuilder: (context, popupWidget) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle Bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_search_rounded,
                        color: AppColor.primaryColor2,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Select Employee',
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
                Expanded(child: popupWidget),
              ],
            ),
          );
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColor.primaryColor2.withOpacity(0.08) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: isSelected 
                  ? Border.all(color: AppColor.primaryColor2.withOpacity(0.3))
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                        )
                      : null,
                  border: !isSelected
                      ? Border.all(color: Colors.grey.shade300, width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage(item.photo),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              title: Text(
                item.empName,
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColor.primaryColor2 : Colors.grey.shade800,
                ),
              ),
              subtitle: Text(
                '${item.empId} • ${item.designation}',
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              trailing: isSelected
                  ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor2,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
      dropdownBuilder: (context, selectedItem) {
        if (selectedItem == null) {
          return Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: Colors.grey.shade400,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                'Tap to select employee',
                style: TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(selectedItem.photo),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedItem.empName,
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    '${selectedItem.empId} • ${selectedItem.designation}',
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColor.primaryColor2, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      onChanged: (employee) {
        if (employee == null) return;
        Provider.of<EmployeeAssetProvider>(context, listen: false)
            .selectEmployee(employee);

        setState(() {
          selectedEmployee = employee;
          _loadEmployeeData();
        });
      },
    );
  }

  Widget _buildAssetTypeDropdown() {
    final assetTypes = [
      {'value': 'Mobile, SIM', 'label': 'Mobile & SIM', 'icon': Icons.phone_android_rounded},
      {'value': 'Laptop', 'label': 'Laptop', 'icon': Icons.laptop_mac_rounded},
      {'value': 'Tablet', 'label': 'Tablet', 'icon': Icons.tablet_android_rounded},
      {'value': 'Mobile,SIM,Tablet', 'label': 'Mobile, SIM & Tablet', 'icon': Icons.devices_rounded},
    ];

    return DropdownButtonFormField<String>(
      value: selectedAsset,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
      style: const TextStyle(
        fontFamily: AppFonts.poppins,
        fontSize: 14,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        hintText: 'Select asset type',
        hintStyle: TextStyle(
          fontFamily: AppFonts.poppins,
          fontSize: 14,
          color: Colors.grey.shade400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColor.primaryColor2, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: assetTypes.map((type) {
        return DropdownMenuItem(
          value: type['value'] as String,
          child: Row(
            children: [
              Icon(
                type['icon'] as IconData,
                size: 20,
                color: AppColor.primaryColor2,
              ),
              const SizedBox(width: 12),
              Text(
                type['label'] as String,
                style: const TextStyle(
                  fontFamily: AppFonts.poppins,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => selectedAsset = v),
    );
  }

  Widget _buildAssetFields() {
    return Column(
      children: [
        _buildModernTextField(
          controller: mobileCtrl,
          label: 'Mobile',
          hint: 'Enter mobile model',
          icon: Icons.phone_android_rounded,
          iconColor: const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: simCtrl,
          label: 'SIM Number',
          hint: 'Enter SIM number',
          icon: Icons.sim_card_rounded,
          iconColor: const Color(0xFF2196F3),
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: laptopCtrl,
          label: 'Laptop',
          hint: 'Enter laptop model',
          icon: Icons.laptop_mac_rounded,
          iconColor: const Color(0xFF9C27B0),
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: tabletCtrl,
          label: 'Tablet',
          hint: 'Enter tablet model',
          icon: Icons.tablet_android_rounded,
          iconColor: const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.poppins,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: AppFonts.poppins,
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: iconColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.95, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E0E6B).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _handleUpdate,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.save_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Update Asset',
                    style: TextStyle(
                      fontFamily: AppFonts.poppins,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleUpdate() {
    final provider = Provider.of<EmployeeAssetProvider>(context, listen: false);

    if (selectedEmployee == null || selectedAsset == null) {
      _showSnackBar(
        message: 'Please select employee and asset type',
        isError: true,
      );
      return;
    }

    provider.selectEmployee(selectedEmployee!);

    provider.updateAsset(
      assetType: selectedAsset!,
      mobile: mobileCtrl.text.isEmpty ? '-' : mobileCtrl.text,
      sim: simCtrl.text.isEmpty ? '-' : simCtrl.text,
      laptop: laptopCtrl.text.isEmpty ? '-' : laptopCtrl.text,
      tablet: tabletCtrl.text.isEmpty ? '-' : tabletCtrl.text,
    );

    _showSnackBar(
      message: 'Asset updated successfully!',
      isError: false,
    );

    DefaultTabController.of(context).animateTo(0);
    provider.clearSelected();
  }

  void _showSnackBar({required String message, required bool isError}) {
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
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
