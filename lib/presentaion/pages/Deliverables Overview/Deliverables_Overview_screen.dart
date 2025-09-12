import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:hrms_mobile_app/widgets/custom_botton/custom_gradient_button.dart';
import 'package:provider/provider.dart';
import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../provider/Deliverables_Overview_provider/Deliverables_Overview_provider.dart';
import '../../../widgets/custom_serach_field/custom_serach_feild.dart';
import '../../../widgets/custom_textfield/Custom_date_field.dart';
import '../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import 'add_deliverable_screen.dart';
import 'employeesdetails/employee_detailsTabs_screen.dart';

class DeliverablesOverviewScreen extends StatelessWidget {
  const DeliverablesOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deliverablesOverviewProvider =
        Provider.of<DeliverablesOverviewProvider>(context);

    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Deliverables Overview"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          children: [
            /// 🔹 Top Row (fixed)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomGradientButton(
                  gradientColors: const [Color(0xFF42A5F5), Color(0xFF1565C0)],
                  height: 40,
                  width: 150,
                  text: "Add Deliverable",
                  onPressed: () {
                    Get.to(() => const AddDeliverableScreen());
                  },
                ),
                GestureDetector(
                  onTap: () {
                    deliverablesOverviewProvider.toggleFilters();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 4,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              " Filter ",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.blackColor,
                                fontFamily: AppFonts.poppins,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_outlined,
                              color: AppColor.blackColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      height: 35,
                      child: DropdownButton<int>(
                        value: deliverablesOverviewProvider.pageSize,
                        underline: const SizedBox(),
                        isExpanded: true,
                        items:
                            [5, 10, 15, 20].map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Text(
                                    "$e",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColor.blackColor,
                                      fontFamily: AppFonts.poppins,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            deliverablesOverviewProvider.setPageSize(val);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// 🔹 Filters + Search + Employee List (scrollable)
            Expanded(
              child: ListView(
                children: [
                  if (deliverablesOverviewProvider.showFilters) ...[
                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Status",
                      items: deliverablesOverviewProvider.status,
                      selectedValue:
                          deliverablesOverviewProvider.selectedstatus,
                      onChanged: deliverablesOverviewProvider.setSelectedstatus,
                      hintText: "Select Status",
                    ),
                    const SizedBox(height: 12),
                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Primary Location",
                      items: deliverablesOverviewProvider.primarylocation,
                      selectedValue:
                          deliverablesOverviewProvider.selectedprimarylocation,
                      onChanged:
                          deliverablesOverviewProvider
                              .setSelectedsprimarylocation,
                      hintText: "Select location",
                    ),
                    const SizedBox(height: 12),
                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Date Type",
                      items: deliverablesOverviewProvider.dateType,
                      selectedValue:
                          deliverablesOverviewProvider.selecteddateType,
                      onChanged: (value) {
                        deliverablesOverviewProvider.setSelectedsdateType(
                          value,
                        );
                      },
                      hintText: "Select",
                    ),
                    const SizedBox(height: 12),
                    if (deliverablesOverviewProvider.selecteddateType != null &&
                        deliverablesOverviewProvider
                            .selecteddateType!
                            .isNotEmpty)
                      CustomDateField(
                        controller:
                            deliverablesOverviewProvider
                                .deliverableDateController,
                        hintText: "Select date",
                        labelText: "To Date",
                        isMandatory: false,
                      ),
                    const SizedBox(height: 12),
                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Assigned Staff",
                      items: deliverablesOverviewProvider.dateType,
                      selectedValue:
                          deliverablesOverviewProvider.selecteddateType,
                      onChanged: (value) {
                        deliverablesOverviewProvider.setSelectedsdateType(
                          value,
                        );
                      },
                      hintText: "Select",
                    ),
                    const SizedBox(height: 12),
                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Job Title",
                      items: deliverablesOverviewProvider.dateType,
                      selectedValue:
                          deliverablesOverviewProvider.selecteddateType,
                      onChanged: (value) {
                        deliverablesOverviewProvider.setSelectedsdateType(
                          value,
                        );
                      },
                      hintText: "Select",
                    ),
                    const SizedBox(height: 12),
                    if (deliverablesOverviewProvider.selecteddateType != null &&
                        deliverablesOverviewProvider
                            .selecteddateType!
                            .isNotEmpty)
                      CustomDateField(
                        controller:
                            deliverablesOverviewProvider
                                .deliverableDateController,
                        hintText: "Select date",
                        labelText: "From Date",
                        isMandatory: false,
                      ),
                    const SizedBox(height: 12),
                  ],

                  /// 🔹 Search Field
                  CustomSearchField(
                    controller:
                        deliverablesOverviewProvider.serachFieldDateController,
                    hintText: "search..",
                  ),

                  const SizedBox(height: 10),

                  /// 🔹 Employee Cards
                  ...deliverablesOverviewProvider.employees.map((emp) {
                    final empId = (emp["empId"] ?? "").toString();
                    final String empPhoto = (emp["photo"] as String?) ?? "";
                    final String empName = (emp["name"] as String?) ?? "N/A";
                    final String empDesignation =
                        (emp["designation"] as String?) ?? "N/A";
                    final String empBranch =
                        (emp["branch"] as String?) ?? "N/A";

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.grey.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundImage:
                              empPhoto.isNotEmpty
                                  ? NetworkImage(empPhoto)
                                  : const NetworkImage(
                                    "https://cdn-icons-png.flaticon.com/512/847/847969.png",
                                  ),
                        ),

                        title: Text(
                          empName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A237E),
                            fontFamily: AppFonts.poppins,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Designation: $empDesignation",
                                style: TextStyle(fontFamily: AppFonts.poppins),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Branch: $empBranch",
                                style: TextStyle(fontFamily: AppFonts.poppins),
                              ),
                              SizedBox(height: 5),

                              Text(
                                "Tasks: ${emp["task"] ?? "0"}",
                                style: TextStyle(fontFamily: AppFonts.poppins),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => EmployeeDetailsScreen(
                                    empId: empId,
                                    empPhoto: empPhoto,
                                    empName: empName,
                                    empDesignation: empDesignation,
                                    empBranch: empBranch,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
