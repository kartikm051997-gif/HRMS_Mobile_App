import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomGradientButton(
                  gradientColors: const [Color(0xFF42A5F5), Color(0xFF1565C0)],
                  height: 40,
                  width: 150, // ✅ Increased width for better UI
                  text: "Add Deliverable",
                  onPressed: () {
                    Get.to(() => AddDeliverableScreen());
                  },
                ),
                GestureDetector(
                  onTap: () {
                    deliverablesOverviewProvider.toggleFilters();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SizedBox(
                        height: 35,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
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
                ),
                SizedBox(height: 20),
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
                        isExpanded: true, // ✅ Makes dropdown take full width
                        items:
                            [5, 10, 15, 20].map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                  ), // ✅ Added left spacing
                                  child: Text(
                                    "$e",
                                    style: TextStyle(
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
            SizedBox(height: 15),
            if (deliverablesOverviewProvider.showFilters) ...[
              CustomSearchDropdownWithSearch(
                isMandatory: true,
                labelText: "Status",
                items: deliverablesOverviewProvider.status,
                selectedValue: deliverablesOverviewProvider.selectedstatus,
                onChanged: deliverablesOverviewProvider.setSelectedstatus,
                hintText: "Select Status",
              ),
              SizedBox(height: 12),
              CustomSearchDropdownWithSearch(
                isMandatory: true,
                labelText: "Primary Location",
                items: deliverablesOverviewProvider.primarylocation,
                selectedValue:
                    deliverablesOverviewProvider.selectedprimarylocation,
                onChanged:
                    deliverablesOverviewProvider.setSelectedsprimarylocation,
                hintText: "Select location",
              ),
              SizedBox(height: 12),
              CustomSearchDropdownWithSearch(
                isMandatory: true,
                labelText: "Date Type",
                items: deliverablesOverviewProvider.dateType,
                selectedValue: deliverablesOverviewProvider.selecteddateType,
                onChanged: (value) {
                  deliverablesOverviewProvider.setSelectedsdateType(value);
                },
                hintText: "Select",
              ),

              const SizedBox(height: 12),

              // Show "To Date" Field ONLY IF Date Type is selected ✅
              if (deliverablesOverviewProvider.selecteddateType != null &&
                  deliverablesOverviewProvider.selecteddateType!.isNotEmpty)
                CustomDateField(
                  controller:
                      deliverablesOverviewProvider.deliverableDateController,
                  hintText: "Select date",
                  labelText: "To Date",
                  isMandatory: false,
                ),
              const SizedBox(height: 12),
              CustomSearchDropdownWithSearch(
                isMandatory: true,
                labelText: "Assigned Staff",
                items: deliverablesOverviewProvider.dateType,
                selectedValue: deliverablesOverviewProvider.selecteddateType,
                onChanged: (value) {
                  deliverablesOverviewProvider.setSelectedsdateType(value);
                },
                hintText: "Select",
              ),
              const SizedBox(height: 12),
              CustomSearchDropdownWithSearch(
                isMandatory: true,
                labelText: "Job Title",
                items: deliverablesOverviewProvider.dateType,
                selectedValue: deliverablesOverviewProvider.selecteddateType,
                onChanged: (value) {
                  deliverablesOverviewProvider.setSelectedsdateType(value);
                },
                hintText: "Select",
              ),
              const SizedBox(height: 12),
              if (deliverablesOverviewProvider.selecteddateType != null &&
                  deliverablesOverviewProvider.selecteddateType!.isNotEmpty)
                CustomDateField(
                  controller:
                      deliverablesOverviewProvider.deliverableDateController,
                  hintText: "Select date",
                  labelText: "From Date",
                  isMandatory: false,
                ),
            ],
            SizedBox(height: 10),
            CustomSearchField(
              controller:
                  deliverablesOverviewProvider.serachFieldDateController,
              hintText: "serach..",
            ),
            Expanded(
              child: ListView.builder(
                itemCount: deliverablesOverviewProvider.employees.length,
                itemBuilder: (context, index) {
                  final emp = deliverablesOverviewProvider.employees[index];
                  return GestureDetector(
                    onTap: () {
                      final empId =
                          (emp["empId"] ?? "")
                              .toString(); // ✅ Use empId, not id
                      final String empPhoto = (emp["photo"] as String?) ?? "";
                      final String empName = (emp["name"] as String?) ?? "N/A";
                      final String empDesignation =
                          (emp["designation"] as String?) ?? "N/A";
                      final String empBranch =
                          (emp["branch"] as String?) ?? "N/A";

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

                    child: Card(
                      color: Colors.white,
                      elevation: 2, // ✅ Light shadow for better design
                      shadowColor: Colors.grey.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ Employee Photo
                            CircleAvatar(
                              radius: 28,
                              backgroundImage:
                                  emp["photo"]!.isNotEmpty
                                      ? NetworkImage(emp["photo"]!)
                                      : const NetworkImage(
                                        "https://cdn-icons-png.flaticon.com/512/847/847969.png",
                                      ),
                            ),
                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name
                                  InkWell(
                                    onTap: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Clicked on ${emp["name"]}",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      emp["name"] ?? "N/A",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Color(
                                          0xFF1A237E,
                                        ), // ✅ Dark Indigo for Name
                                        fontFamily: AppFonts.poppins,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // Designation
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Designation: ",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(
                                              0xFF37474F,
                                            ), // ✅ Slightly dark grey
                                            fontFamily: AppFonts.poppins,
                                          ),
                                        ),
                                        TextSpan(
                                          text: emp["designation"] ?? "N/A",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Color(
                                              0xFF616161,
                                            ), // ✅ Soft grey for value
                                            fontFamily: AppFonts.poppins,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // Location
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Location: ",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF37474F),
                                            fontFamily: AppFonts.poppins,
                                          ),
                                        ),
                                        TextSpan(
                                          text: emp["location"] ?? "N/A",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xFF616161),
                                            fontFamily: AppFonts.poppins,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // ✅ Task Count
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Tasks: ",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF37474F),
                                            fontFamily: AppFonts.poppins,
                                          ),
                                        ),
                                        TextSpan(
                                          text: emp["task"] ?? "0",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: Color(
                                              0xFF1565C0,
                                            ), // ✅ Highlight in blue
                                            fontFamily: AppFonts.poppins,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
