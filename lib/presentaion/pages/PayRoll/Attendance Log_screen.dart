import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/appcolor_dart.dart';

import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../provider/payroll_provider/Attendance_Log_provider.dart';
import '../../../widgets/custom_botton/custom_gradient_button.dart';
import '../../../widgets/custom_textfield/Custom_date_field.dart';
import '../../../widgets/custom_textfield/custom_dropdown_with_search.dart';

class AttendanceLogScreen extends StatefulWidget {
  const AttendanceLogScreen({super.key});

  @override
  State<AttendanceLogScreen> createState() => _AttendanceLogScreenState();
}

class _AttendanceLogScreenState extends State<AttendanceLogScreen> {
  @override
  void dispose() {
    Provider.of<AttendanceLogProvider>(
      context,
      listen: false,
    ).resetSelections();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceLogProvider = Provider.of<AttendanceLogProvider>(context);

    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Attendance Log"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 1.4,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: SingleChildScrollView(
                  // 👈 makes inside scrollable
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Attendance",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),

                      CustomSearchDropdownWithSearch(
                        isMandatory: true,
                        labelText: "Zones",
                        items: attendanceLogProvider.zones,
                        selectedValue: attendanceLogProvider.selectedZones,
                        onChanged: attendanceLogProvider.setSelectedZones,
                        hintText: "Select Zone..",
                      ),
                      const SizedBox(height: 10),

                      CustomSearchDropdownWithSearch(
                        isMandatory: true,
                        labelText: "Branches",
                        items: attendanceLogProvider.branches,
                        selectedValue: attendanceLogProvider.selectedBranches,
                        onChanged: attendanceLogProvider.setSelectedBranches,
                        hintText: "Select Branches..",
                      ),
                      const SizedBox(height: 10),

                      CustomSearchDropdownWithSearch(
                        isMandatory: true,
                        labelText: "Type",
                        items: attendanceLogProvider.type,
                        selectedValue: attendanceLogProvider.selectedType,
                        onChanged: attendanceLogProvider.setSelectedType,
                        hintText: "Select Type..",
                      ),
                      const SizedBox(height: 10),

                      Consumer<AttendanceLogProvider>(
                        builder: (context, attendanceLogProvider, child) {
                          return Column(
                            children: [
                              CustomSearchDropdownWithSearch(
                                isMandatory: true,
                                labelText: "Month / Day",
                                items: attendanceLogProvider.monDay,
                                selectedValue:
                                    attendanceLogProvider.selectedMonDay,
                                onChanged:
                                    attendanceLogProvider.setSelectedMonDay,
                                hintText: "Select Month / Day..",
                              ),
                              const SizedBox(height: 10),

                              if (attendanceLogProvider.selectedMonDay !=
                                      null &&
                                  attendanceLogProvider
                                      .selectedMonDay!
                                      .isNotEmpty)
                                CustomDateField(
                                  controller:
                                      attendanceLogProvider.dateController,
                                  hintText:
                                      attendanceLogProvider.selectedMonDay ==
                                              "Day"
                                          ? "Select Day"
                                          : "Select Month",
                                  labelText:
                                      attendanceLogProvider.selectedMonDay ==
                                              "Day"
                                          ? "Day"
                                          : "Month",
                                  isMandatory: false,
                                  onTap: () async {
                                    if (attendanceLogProvider.selectedMonDay ==
                                        "Month") {
                                      // Month picker
                                      final months = [
                                        "Jan",
                                        "Feb",
                                        "Mar",
                                        "Apr",
                                        "May",
                                        "Jun",
                                        "Jul",
                                        "Aug",
                                        "Sep",
                                        "Oct",
                                        "Nov",
                                        "Dec",
                                      ];

                                      String?
                                      selectedMonth = await showDialog<String>(
                                        context: context,
                                        builder: (ctx) {
                                          String? tempSelected;
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                title: Text(
                                                  "Select Month",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppFonts.poppins,
                                                  ),
                                                ),
                                                content: SizedBox(
                                                  width: double.maxFinite,
                                                  child: GridView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: months.length,
                                                    gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          childAspectRatio: 2,
                                                          crossAxisSpacing: 8,
                                                          mainAxisSpacing: 8,
                                                        ),
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      bool isSelected =
                                                          tempSelected ==
                                                          months[index];
                                                      return InkWell(
                                                        onTap: () {
                                                          setState(
                                                            () =>
                                                                tempSelected =
                                                                    months[index],
                                                          );
                                                          Future.delayed(
                                                            const Duration(
                                                              milliseconds: 200,
                                                            ),
                                                            () {
                                                              Navigator.pop(
                                                                ctx,
                                                                months[index],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color:
                                                                isSelected
                                                                    ? Colors
                                                                        .blue[100]
                                                                    : Colors
                                                                        .white,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            border: Border.all(
                                                              color:
                                                                  isSelected
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
                                                                          .grey,
                                                              width: 1.5,
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              months[index],
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    AppFonts
                                                                        .poppins,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    isSelected
                                                                        ? FontWeight
                                                                            .w700
                                                                        : FontWeight
                                                                            .w500,
                                                                color:
                                                                    isSelected
                                                                        ? Colors
                                                                            .blue[900]
                                                                        : Colors
                                                                            .black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );

                                      if (selectedMonth != null) {
                                        attendanceLogProvider
                                            .dateController
                                            .text = selectedMonth;
                                      }
                                    } else if (attendanceLogProvider
                                            .selectedMonDay ==
                                        "Day") {
                                      // Day picker
                                      DateTime? selectedDay =
                                          await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2100),
                                          );

                                      if (selectedDay != null) {
                                        attendanceLogProvider
                                                .dateController
                                                .text =
                                            "${selectedDay.day}-${selectedDay.month}-${selectedDay.year}";
                                      }
                                    }
                                  },
                                ),

                              const SizedBox(height: 20),

                              CustomGradientButton(
                                gradientColors: const [
                                  Color(0xFF1565C0),
                                  Color(0xFF0D47A1),
                                ],
                                text: "Go",
                                onPressed: () {},
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
