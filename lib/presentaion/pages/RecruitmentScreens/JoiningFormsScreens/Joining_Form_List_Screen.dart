import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/RecruitmentScreensProviders/JoiningFormsScreenProvider.dart';

class JoiningFormListScreen extends StatefulWidget {
  final String empId;

  const JoiningFormListScreen({super.key, required this.empId});

  @override
  State<JoiningFormListScreen> createState() => _JoiningFormListScreenState();
}

class _JoiningFormListScreenState extends State<JoiningFormListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JoiningFormsScreenProvider>(
        context,
        listen: false,
      ).initializeEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final joiningFormsScreenProvider = Provider.of<JoiningFormsScreenProvider>(
      context,
    );
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${joiningFormsScreenProvider.filteredEmployees.length} Employees Found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.poppins,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  if (joiningFormsScreenProvider.showFilters)
                    TextButton.icon(
                      onPressed: () {
                        joiningFormsScreenProvider.toggleFilters();
                      },
                      icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                      label: Text(
                        "Hide Filters",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (joiningFormsScreenProvider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Loading employees...",
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else if (joiningFormsScreenProvider.filteredEmployees.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Color(0xFFCBD5E1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No employees found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFonts.poppins,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Try adjusting your filters or search criteria",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppFonts.poppins,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final employee =
                        joiningFormsScreenProvider.filteredEmployees[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.12),
                            spreadRadius: 0,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          children: [
                            // Top Section - Purple Header
                            Container(
                              width: double.infinity,
                              height: 75,
                              decoration: BoxDecoration(
                                color: Color(0xffa14f79),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            employee.empName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppFonts.poppins,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            employee.empDesignation,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: AppFonts.poppins,
                                              color: Colors.white.withOpacity(
                                                0.85,
                                              ),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        employee.empJoiningDate,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppFonts.poppins,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Middle Section - Employee Details
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColor.whiteColor,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // First Row - Branch and Salary
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[50],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.location_on_outlined,
                                                  size: 16,
                                                  color: Colors.blue[600],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Branch",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                        fontFamily:
                                                            AppFonts.poppins,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      employee.branch,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            AppFonts.poppins,
                                                        color: const Color(
                                                          0xFF374151,
                                                        ),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green[50],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .monetization_on_outlined,
                                                  size: 16,
                                                  color: Colors.green[600],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Salary",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey[500],
                                                        fontFamily:
                                                            AppFonts.poppins,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      employee.empSalary,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            AppFonts.poppins,
                                                        color: const Color(
                                                          0xFF374151,
                                                        ),
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Second Row - Emp Category and Unique ID
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[50],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.orange
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.category_outlined,
                                                  color: Colors.orange[700],
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Category",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Colors.grey[600],
                                                          fontFamily:
                                                              AppFonts.poppins,
                                                        ),
                                                      ),
                                                      Text(
                                                        employee.uniqueId
                                                                .startsWith(
                                                                  'JF',
                                                                )
                                                            ? "PROFESSIONAL"
                                                            : "EMPLOYEE",
                                                        style: TextStyle(
                                                          color:
                                                              Colors
                                                                  .orange[700],
                                                          fontFamily:
                                                              AppFonts.poppins,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.purple[50],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Color(
                                                  0xffa14f79,
                                                ).withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.badge_outlined,
                                                  color: Color(0xffa14f79),
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Unique ID",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                              Colors.grey[600],
                                                          fontFamily:
                                                              AppFonts.poppins,
                                                        ),
                                                      ),
                                                      Text(
                                                        employee.uniqueId,
                                                        style: TextStyle(
                                                          color: Color(
                                                            0xffa14f79,
                                                          ),
                                                          fontFamily:
                                                              AppFonts.poppins,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Bottom Section - Action Buttons
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Edit action
                                        },
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                        ),
                                        label: Text(
                                          "Edit",
                                          style: TextStyle(
                                            fontFamily: AppFonts.poppins,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[600],
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Generate action
                                        },
                                        icon: Icon(
                                          Icons.description_outlined,
                                          size: 16,
                                        ),
                                        label: Text(
                                          "Generate",
                                          style: TextStyle(
                                            fontFamily: AppFonts.poppins,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xffa14f79),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount:
                      joiningFormsScreenProvider.filteredEmployees.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
