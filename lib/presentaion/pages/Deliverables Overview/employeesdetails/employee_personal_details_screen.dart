import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../provider/Deliverables_Overview_provider/employee_personal_details_provider.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../widgets/custom_textfield/custom_large_textfield.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';
import '../../EmployeeManagement/NewEmployeeScreens/Document_Upload_Field_for_Joining_Letter_Screen.dart';
import '../../EmployeeManagement/NewEmployeeScreens/Photo_Upload_screen.dart';

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

                    // Male option
                    Row(
                      children: [
                        Radio<String>(
                          value: "Male",
                          groupValue:
                              employeeInformationProvider.selectedGender,
                          activeColor: AppColor.primaryColor2,
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
                          activeColor: AppColor.primaryColor2,
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
                  labelText: "Caste",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller: employeeInformationProvider.bloodGroupController,
                  hintText: "",
                  labelText: "Blood Group",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),

                CustomSearchDropdownWithSearch(
                  isMandatory: true,
                  labelText: "Marital Status",
                  items: employeeInformationProvider.materialStatus,
                  selectedValue:
                      employeeInformationProvider.selectedmaterialStatus,
                  onChanged:
                      employeeInformationProvider.setSelectedmaterialStatus,
                  hintText: "Single",
                  readOnly:
                      true, // ✅ Will show "Single" but user cannot change it
                ),
                SizedBox(height: 10),

                CustomLargeTextField(
                  readOnly: true, // ✅ Make it uneditable
                  controller:
                      employeeInformationProvider.choiceOfWorkController,
                  hintText: "",
                  labelText: "Choice of work",
                  isMandatory: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      employeeInformationProvider
                          .secondaryContactNumberController,
                  hintText: "",
                  labelText: "secondary Contact Number",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),

                CustomSearchDropdownWithSearch(
                  isMandatory: true,
                  labelText: "Secondary Contact Relationship",
                  items:
                      employeeInformationProvider.secondaryContactRelationship,
                  selectedValue:
                      employeeInformationProvider
                          .selectedSecondaryContactRelationship,
                  onChanged:
                      employeeInformationProvider
                          .setSelectedSecondaryContactRelationship,
                  hintText: "mother",
                  readOnly:
                      true, // ✅ Will show "Single" but user cannot change it
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      employeeInformationProvider
                          .secondaryContactOccupationController,
                  hintText: "",
                  labelText: "Secondary Contact Occupation",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      employeeInformationProvider
                          .secondaryContactMobileController,
                  hintText: "",
                  labelText: "secondary Contact Number",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      employeeInformationProvider.permanentAddressController,
                  hintText: "",
                  labelText: "Permanent Address",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      employeeInformationProvider.presentAddressController,
                  hintText: "",
                  labelText: "Present Address",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Wrap the text inside Expanded so it can wrap on multiple lines
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Are you a physically challenged person ",
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
                    ),
                    const SizedBox(width: 20),

                    // Male option
                    Row(
                      children: [
                        Radio<String>(
                          value: "Yes",
                          groupValue:
                              employeeInformationProvider.selectedGender,
                          activeColor: AppColor.primaryColor2,
                          onChanged: (value) {
                            employeeInformationProvider.setGender(value!);
                          },
                        ),
                        Text(
                          "Yes",
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
                          value: "No",
                          groupValue:
                              employeeInformationProvider.selectedGender,
                          activeColor: AppColor.primaryColor2,
                          onChanged: (value) {
                            employeeInformationProvider.setGender(value!);
                          },
                        ),
                        Text(
                          "No",
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
                SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
