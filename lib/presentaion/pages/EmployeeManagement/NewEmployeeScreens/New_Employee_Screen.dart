import 'package:flutter/Material.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/New_Employee_Provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../widgets/custom_botton/custom_gradient_button.dart';
import '../../../../widgets/custom_textfield/Custom_date_field.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../widgets/custom_textfield/custom_large_textfield.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';
import 'New_Emplo_Bank_Details_Screen.dart';
import 'New_Employee_document_Screen.dart';
import 'Payroll_category_type_screen.dart';
import 'Photo_Upload_screen.dart';

class NewEmployeeScreen extends StatefulWidget {
  final String empId;

  const NewEmployeeScreen({super.key, required this.empId});

  @override
  State<NewEmployeeScreen> createState() => _NewEmployeeScreenState();
}

class _NewEmployeeScreenState extends State<NewEmployeeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<NewEmployeeProvider>().fetchEmployeeDetails(widget.empId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final newEmployeeProvider = Provider.of<NewEmployeeProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Job Application ID",
                      items: newEmployeeProvider.jobApplicationID,
                      selectedValue:
                          newEmployeeProvider.selectedJobApplicationID,
                      onChanged:
                          newEmployeeProvider.setSelectedJobApplicationID,
                      hintText: "Select Job Application ID..",
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: newEmployeeProvider.fullNameController,
                      hintText: "",
                      labelText: "Full Name",
                      isMandatory: true,
                      readOnly: false,
                    ),
                    SizedBox(height: 10),

                    CustomTextField(
                      controller: newEmployeeProvider.employmentIDController,
                      hintText: "",
                      labelText: "Employment ID",
                      isMandatory: true,
                      readOnly: true,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: newEmployeeProvider.userNameController,
                      hintText: "",
                      labelText: "Full Name",
                      isMandatory: true,
                      readOnly: false,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: newEmployeeProvider.passwordController,
                      hintText: "",
                      labelText: "Password",
                      isMandatory: true,
                      readOnly: false,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: newEmployeeProvider.confirmPasswordController,
                      hintText: "",
                      labelText: "Confirm Password ",
                      isMandatory: true,
                      readOnly: false,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller:
                          newEmployeeProvider.highestQualificationController,
                      hintText: "",
                      labelText: "Highest qualification",
                      isMandatory: true,
                      readOnly: false,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      controller: newEmployeeProvider.emailController,
                      hintText: "",
                      labelText: "Email",
                      isMandatory: true,
                      readOnly: false,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      keyboardType: TextInputType.phone,
                      controller: newEmployeeProvider.officialMobileController,
                      hintText: "",
                      labelText: "Official Mobile",
                      isMandatory: true,
                      readOnly: false,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      keyboardType: TextInputType.phone,
                      controller: newEmployeeProvider.officialMobileController,
                      hintText: "",
                      labelText: "Emergency Contact Number ",
                      isMandatory: true,
                      readOnly: false,
                    ),
                    SizedBox(height: 10),

                    CustomLargeTextField(
                      controller: newEmployeeProvider.addressController,
                      hintText: "",
                      labelText: "Address",
                      isMandatory: false,
                    ),
                    SizedBox(height: 10),

                    CustomLargeTextField(
                      controller:
                          newEmployeeProvider.permanentAddressController,
                      hintText: "",
                      labelText: "permanent Address",
                      isMandatory: false,
                    ),
                    SizedBox(height: 10),

                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Job Location",
                      items: newEmployeeProvider.jobLocation,
                      selectedValue: newEmployeeProvider.selectedJobLocation,
                      onChanged: newEmployeeProvider.setSelectedJobLocation,
                      hintText: "",
                    ),
                    SizedBox(height: 10),

                    CustomDateField(
                      controller: newEmployeeProvider.dateController,
                      hintText: "",
                      labelText: "Date of Birth",
                      isMandatory: true,
                    ),
                    SizedBox(height: 10),

                    CustomDateField(
                      controller: newEmployeeProvider.dateOfJoiningController,
                      hintText: "",
                      labelText: "Date of Joining",
                      isMandatory: true,
                    ),
                    SizedBox(height: 10),
                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Gender",
                      items: newEmployeeProvider.gender,
                      selectedValue: newEmployeeProvider.selectedGender,
                      onChanged: newEmployeeProvider.setSelectedGender,
                      hintText: "",
                    ),
                    SizedBox(height: 10),
                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Married Status",
                      items: newEmployeeProvider.marriedStatus,
                      selectedValue: newEmployeeProvider.selectedMarriedStatus,
                      onChanged: newEmployeeProvider.setSelectedMarriedStatus,
                      hintText: "",
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      keyboardType: TextInputType.text,
                      controller: newEmployeeProvider.nomineeNameController,
                      hintText: "",
                      labelText: "Nominee Name",
                      isMandatory: true,
                      readOnly: false,
                    ),
                    SizedBox(height: 10),
                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Nominee Relationship",
                      items: newEmployeeProvider.nomineeRelationship,
                      selectedValue:
                          newEmployeeProvider.selectedNomineeRelationship,
                      onChanged:
                          newEmployeeProvider.setSelectedNomineeRelationship,
                      hintText: "",
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: newEmployeeProvider.officialEmailIdController,
                      hintText: "",
                      labelText: "Official Email ID",
                      isMandatory: true,
                      readOnly: false,
                    ),
                    SizedBox(height: 10),

                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Designation",
                      items: newEmployeeProvider.designation,
                      selectedValue: newEmployeeProvider.selectedDesignation,
                      onChanged: newEmployeeProvider.setSelectedDesignation,
                      hintText: "",
                    ),
                    SizedBox(height: 10),

                    CustomTextField(
                      keyboardType: TextInputType.text,
                      controller: newEmployeeProvider.allowedLeaveController,
                      hintText: "",
                      labelText: "Allowed Leave",
                      isMandatory: true,
                      readOnly: false,
                    ),
                    SizedBox(height: 10),

                    ProfilePhotoField(
                      labelText: "Upload Profile Photo",
                      isMandatory: true,
                      selectedFile: newEmployeeProvider.selectedFile,
                      onFilePicked: (file) {
                        if (file != null) {
                          newEmployeeProvider.setFile(file);
                        } else {
                          newEmployeeProvider
                              .clearFile(); // Use clearFile for null
                        }
                      },
                    ),
                    SizedBox(height: 10),

                    CustomSearchDropdownWithSearch(
                      isMandatory: true,
                      labelText: "Login Access For",
                      items: newEmployeeProvider.loginAccessFor,
                      selectedValue: newEmployeeProvider.selectedLoginAccessFor,
                      onChanged: newEmployeeProvider.setSelectedLoginAccessFor,
                      hintText: "",
                    ),
                    SizedBox(height: 10),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Do you need approval this user",
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
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            // Yes option
                            Row(
                              children: [
                                Radio<String>(
                                  value: "Yes",
                                  groupValue:
                                      newEmployeeProvider.selectedApprovalUser,
                                  activeColor: AppColor.primaryColor2,
                                  onChanged: (value) {
                                    newEmployeeProvider.setApprovalUser(value!);
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
                            const SizedBox(width: 20),

                            // No option
                            Row(
                              children: [
                                Radio<String>(
                                  value: "No",
                                  groupValue:
                                      newEmployeeProvider.selectedApprovalUser,
                                  activeColor: AppColor.primaryColor2,
                                  onChanged: (value) {
                                    newEmployeeProvider.setApprovalUser(value!);
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Training fee available",
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
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            // Yes option
                            Row(
                              children: [
                                Radio<String>(
                                  value: "Yes",
                                  groupValue:
                                      newEmployeeProvider.trainingFeeAvailable,
                                  activeColor: AppColor.primaryColor2,
                                  onChanged: (value) {
                                    newEmployeeProvider.setTrainingFeeAvailable(
                                      value!,
                                    );
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
                            const SizedBox(width: 20),

                            // No option
                            Row(
                              children: [
                                Radio<String>(
                                  value: "No",
                                  groupValue:
                                      newEmployeeProvider.trainingFeeAvailable,
                                  activeColor: AppColor.primaryColor2,
                                  onChanged: (value) {
                                    newEmployeeProvider.setTrainingFeeAvailable(
                                      value!,
                                    );
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "Need to Remote Attendance",
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

                        Row(
                          children: [
                            // Yes option
                            Row(
                              children: [
                                Radio<String>(
                                  value: "Yes",
                                  groupValue:
                                      newEmployeeProvider.needRemoteAttendance,
                                  activeColor: AppColor.primaryColor2,
                                  onChanged: (value) {
                                    newEmployeeProvider.setNeedRemoteAttendance(
                                      value!,
                                    );
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

                            // No option
                            Row(
                              children: [
                                Radio<String>(
                                  value: "No",
                                  groupValue:
                                      newEmployeeProvider.needRemoteAttendance,
                                  activeColor: AppColor.primaryColor2,
                                  onChanged: (value) {
                                    newEmployeeProvider.setNeedRemoteAttendance(
                                      value!,
                                    );
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
                    // Expandable Bank & Others Section
                    SizedBox(height: 10),

                    NewEmployeeBankDetailsScreen(empId: '12345'),
                    NewEmployeeDocumentScreen(empId: '12345'),
                    PayrollCategoryTypeScreen(empId: "12345"),
                  ],
                ),
              ),
            ),
            CustomGradientButton(
              gradientColors: const [Color(0xFF1565C0), Color(0xFF0D47A1)],
              height: 44,
              width: MediaQuery.of(context).size.width,
              text: "Create Employee",
              onPressed: () {},
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
