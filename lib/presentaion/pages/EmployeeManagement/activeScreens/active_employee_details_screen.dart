import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../model/Employee_management/ActiveUserListModel.dart'
    as models;
import '../../../../provider/Employee_management_Provider/Active_Provider.dart';
import '../../../../apibaseScreen/Api_Base_Screens.dart';
import '../../../../widgets/avatarZoomIn/SimpleImageZoomViewer.dart';
import '../../Deliverables Overview/employeesdetails/employee_detailsTabs_screen.dart';

class EmployeeManagementDetailsScreen extends StatefulWidget {
  final models.Users user;

  const EmployeeManagementDetailsScreen({super.key, required this.user});

  @override
  State<EmployeeManagementDetailsScreen> createState() =>
      _EmployeeManagementDetailsScreenState();
}

class _EmployeeManagementDetailsScreenState
    extends State<EmployeeManagementDetailsScreen> {
  // Colors

  @override
  Widget build(BuildContext context) {
    final activeProvider = Provider.of<ActiveProvider>(context);
    final bool isActive =
        (widget.user.status ?? "Active").toLowerCase() == 'active';
    final employeeName =
        widget.user.fullname ?? widget.user.username ?? "Unknown";

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Employee Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.poppins,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ═══════════════════════════════════════════════════════════
            // EMPLOYEE HEADER CARD
            // ═══════════════════════════════════════════════════════════
            Container(
              decoration: BoxDecoration(
                color: AppColor.cardColor,
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
                  // Header with Avatar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.primaryColor,
                          AppColor.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        GestureDetector(
                          onTap: () {
                            final imageUrl = getAvatarUrl(widget.user.avatar);
                            if (imageUrl.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => SimpleImageZoomViewer(
                                        imageUrl: imageUrl,
                                        employeeName: employeeName,
                                      ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Builder(
                                builder: (_) {
                                  final imageUrl = getAvatarUrl(
                                    widget.user.avatar,
                                  );
                                  if (kDebugMode) {
                                    print('FINAL AVATAR URL 👉 $imageUrl');
                                  }

                                  return imageUrl.isNotEmpty
                                      ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) =>
                                                _defaultAvatar(employeeName),
                                      )
                                      : _defaultAvatar(employeeName);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Text(
                          widget.user.fullname.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.poppins,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // ID Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "ID: ${widget.user.employmentId ?? widget.user.userId ?? ""}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.poppins,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Designation
                        Text(
                          widget.user.designation ?? "N/A",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.poppins,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status and Actions
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Status Badge and Action Button Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isActive
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isActive
                                          ? const Color(0xFFBBF7D0)
                                          : const Color(0xFFFECACA),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          isActive
                                              ? const Color(0xFF059669)
                                              : const Color(0xFFDC2626),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    widget.user.status ?? "Active",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppFonts.poppins,
                                      color:
                                          isActive
                                              ? const Color(0xFF059669)
                                              : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action Button
                            InkWell(
                              onTap:
                                  () => _showStatusDialog(
                                    context,
                                    widget.user,
                                    activeProvider,
                                    isActive,
                                  ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isActive
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isActive
                                              ? const Color(0xFFDC2626)
                                              : const Color(0xFF059669))
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isActive
                                          ? Icons.person_remove_rounded
                                          : Icons.person_add_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isActive ? "Deactivate" : "Activate",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AppFonts.poppins,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // View Profile Button
                        InkWell(
                          onTap: () {
                            final avatar = widget.user.avatar;
                            String? imageUrl;
                            if (avatar != null &&
                                avatar.isNotEmpty &&
                                avatar != 'null' &&
                                avatar != 'none') {
                              if (avatar.startsWith('http://') ||
                                  avatar.startsWith('https://')) {
                                imageUrl = avatar;
                              } else {
                                final cleanPath =
                                    avatar.startsWith('/')
                                        ? avatar.substring(1)
                                        : avatar;
                                imageUrl = '${ApiBase.baseUrl}$cleanPath';
                              }
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => EmployeeDetailsScreen(
                                      empId:
                                          widget.user.employmentId ??
                                          widget.user.userId ??
                                          "",
                                      empPhoto: imageUrl ?? "",
                                      empName: employeeName,
                                      empDesignation:
                                          widget.user.designation ?? "N/A",
                                      empBranch:
                                          widget.user.locationName ?? "N/A",
                                    ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColor.primaryColor,
                                  AppColor.secondaryColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.visibility_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "View Profile Details",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFonts.poppins,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ═══════════════════════════════════════════════════════════
            // PROFESSIONAL INFORMATION CARD
            // ═══════════════════════════════════════════════════════════
            Container(
              decoration: BoxDecoration(
                color: AppColor.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.primaryColor.withOpacity(0.1),
                          AppColor.secondaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.business_center_rounded,
                          color: AppColor.primaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Professional Information",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.poppins,
                            color: AppColor.textPrimary,
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
                        _detailRow(
                          "Department",
                          widget.user.department ?? "N/A",
                          Icons.business_rounded,
                        ),
                        _detailRow(
                          "Branch",
                          widget.user.locationName ?? "N/A",
                          Icons.location_on_rounded,
                        ),
                        _detailRow(
                          "Date of Joining",
                          widget.user.joiningDate ?? "N/A",
                          Icons.calendar_today_rounded,
                        ),
                        if (widget.user.email != null &&
                            widget.user.email!.isNotEmpty)
                          _detailRow(
                            "Email",
                            widget.user.email!,
                            Icons.email_rounded,
                          ),
                        if (widget.user.mobile != null &&
                            widget.user.mobile!.isNotEmpty)
                          _detailRow(
                            "Mobile",
                            widget.user.mobile!,
                            Icons.phone_rounded,
                          ),
                        _detailRow(
                          "Monthly CTC",
                          "₹${widget.user.monthlyCtc ?? "0"}",
                          Icons.account_balance_wallet_rounded,
                        ),
                        if (widget.user.annualCtc != null &&
                            widget.user.annualCtc!.isNotEmpty)
                          _detailRow(
                            "Annual CTC",
                            "₹${widget.user.annualCtc}",
                            Icons.currency_rupee_rounded,
                          ),
                        _detailRow(
                          "Payroll Category",
                          widget.user.payrollCategory ?? "N/A",
                          Icons.category_rounded,
                        ),
                        _detailRow(
                          "Recent Punch",
                          widget.user.recentPunchDate ?? "N/A",
                          Icons.access_time_rounded,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ═══════════════════════════════════════════════════════════
            // TEAM INFORMATION CARD
            // ═══════════════════════════════════════════════════════════
            Container(
              decoration: BoxDecoration(
                color: AppColor.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.secondaryColor.withOpacity(0.1),
                          AppColor.primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          color: AppColor.secondaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Additional Information",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: AppFonts.poppins,
                            color: AppColor.textPrimary,
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
                        _infoCard("User ID", widget.user.userId ?? "N/A"),
                        const SizedBox(height: 12),
                        _infoCard(
                          "Employment ID",
                          widget.user.employmentId ?? "N/A",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════

  Widget _detailRow(
    String label,
    String value,
    IconData icon, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColor.primaryColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.poppins,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                        color: AppColor.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(color: AppColor.borderColor.withOpacity(0.5), height: 1),
      ],
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.poppins,
                    color: AppColor.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFonts.poppins,
                    color: AppColor.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(
    BuildContext context,
    models.Users user,
    ActiveProvider provider,
    bool isActive,
  ) {
    final employeeId = user.employmentId ?? user.userId ?? "";
    final employeeName = user.fullname ?? user.username ?? "Unknown";

    showDialog(
      context: context,
      builder:
          (dialogContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors:
                            isActive
                                ? [
                                  const Color(0xFFFEE2E2),
                                  const Color(0xFFFECACA),
                                ]
                                : [
                                  const Color(0xFFDCFCE7),
                                  const Color(0xFFBBF7D0),
                                ],
                      ),
                    ),
                    child: Icon(
                      isActive
                          ? Icons.person_remove_rounded
                          : Icons.person_add_rounded,
                      size: 36,
                      color:
                          isActive
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    isActive ? "Deactivate Employee" : "Activate Employee",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppFonts.poppins,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message
                  Text(
                    isActive
                        ? "Are you sure you want to deactivate $employeeName?"
                        : "Are you sure you want to activate $employeeName?",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: AppFonts.poppins,
                      color: AppColor.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: AppColor.borderColor),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.poppins,
                              color: AppColor.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            provider.toggleEmployeeStatus(employeeId);
                            Navigator.pop(dialogContext);
                            Navigator.pop(context);

                            Get.snackbar(
                              isActive ? "Deactivated" : "Activated",
                              isActive
                                  ? "$employeeName has been deactivated"
                                  : "$employeeName has been activated",
                              backgroundColor:
                                  isActive
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF059669),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isActive
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isActive ? "Deactivate" : "Activate",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.poppins,
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
  }

  String getAvatarUrl(String? avatar) {
    if (avatar == null || avatar.isEmpty || avatar == 'null') {
      return '';
    }

    // If backend already sends full URL
    if (avatar.startsWith('http')) {
      // Replace localhost for real device access
      return avatar.replaceFirst('http://localhost', 'http://192.168.0.100');
    }

    // Relative path case
    return 'http://192.168.0.100/hrms/$avatar';
  }

  Widget _defaultAvatar(String employeeName) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primaryColor, AppColor.secondaryColor],
        ),
      ),
      child: Center(
        child: Text(
          employeeName.isNotEmpty ? employeeName[0].toUpperCase() : 'E',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: AppFonts.poppins,
          ),
        ),
      ),
    );
  }
}
