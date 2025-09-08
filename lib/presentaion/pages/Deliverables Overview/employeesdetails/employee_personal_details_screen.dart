import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:provider/provider.dart';
import '../../../../provider/Deliverables_Overview_provider/employee_personal_details_provider.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';

class EmployeePersonalDetailsScreen extends StatefulWidget {
  final String empId;

  const EmployeePersonalDetailsScreen({super.key, required this.empId});

  @override
  State<EmployeePersonalDetailsScreen> createState() =>
      _EmployeePersonalDetailsScreenState();
}

class _EmployeePersonalDetailsScreenState
    extends State<EmployeePersonalDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<EmployeeInformationProvider>().fetchEmployeeDetails(
        widget.empId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeInformationProvider =
        Provider.of<EmployeeInformationProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomTextField(
              controller: employeeInformationProvider.emailController,
              hintText: "",
              labelText: "Email",
              isMandatory: true,
              readOnly: true,
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller: employeeInformationProvider.mobileController,
              hintText: "",
              labelText: "Mobile",
              isMandatory: true,
              readOnly: true,

            ),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Gender label with red asterisk
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Gender ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: "Poppins",
                            ),
                          ),
                          TextSpan(
                            text: "*",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Male option
                    Row(
                      children: [
                        Radio<String>(
                          value: "Male",
                          groupValue:
                              employeeInformationProvider.selectedGender,
                          activeColor: Colors.blue,
                          onChanged: (value) {
                            employeeInformationProvider.setGender(value!);
                          },
                        ),
                        Text(
                          "Male",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.poppins,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    // Female option
                    Row(
                      children: [
                        Radio<String>(
                          value: "Female",
                          groupValue:
                              employeeInformationProvider.selectedGender,
                          activeColor: Colors.blue,
                          onChanged: (value) {
                            employeeInformationProvider.setGender(value!);
                          },
                        ),
                        Text(
                          "Female",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFonts.poppins,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                CustomTextField(
                  controller: employeeInformationProvider.experienceController,
                  hintText: "",
                  labelText: "Total Experience in Years ",
                  isMandatory: true,
                  readOnly: true,

                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller: employeeInformationProvider.dobController,
                  hintText: "",
                  labelText: "Date Of Birth",
                  isMandatory: true,
                  readOnly: true,

                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller: employeeInformationProvider.ageController,
                  hintText: "",
                  labelText: "Age",
                  isMandatory: true,
                  readOnly: true,

                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller: employeeInformationProvider.religionController,
                  hintText: "",
                  labelText: "Religion",
                  isMandatory: true,
                  readOnly: true,

                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      employeeInformationProvider.motherTongueController,
                  hintText: "",
                  labelText: "Mother Tongue",
                  isMandatory: true,
                  readOnly: true,

                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller: employeeInformationProvider.casteController,
                  hintText: "",
                  labelText: "Caste ",
                  isMandatory: true,
                  readOnly: true,

                ),SizedBox(height: 10),
                CustomTextField(
                  controller: employeeInformationProvider.bloodGroupController,
                  hintText: "",
                  labelText: "Blood Group ",
                  isMandatory: true,
                  readOnly: true,

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
