import 'package:flutter/Material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/appcolor_dart.dart';
import '../../../../../../core/fonts/fonts.dart';
import '../../../../../../provider/RecruitmentScreensProviders/Recruitment_Personal_Details_Provider.dart';
import '../../../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../../../widgets/custom_textfield/custom_large_textfield.dart';
import '../../../../../../widgets/custom_textfield/custom_textfield.dart';
import '../../../../EmployeeManagement/NewEmployeeScreens/Document_Upload_Field_for_Joining_Letter_Screen.dart';
import '../../../../EmployeeManagement/NewEmployeeScreens/Photo_Upload_screen.dart';

class RecruitmentPersonalDetailsScreen extends StatefulWidget {
  final String empId;

  const RecruitmentPersonalDetailsScreen({super.key, required this.empId});

  @override
  State<RecruitmentPersonalDetailsScreen> createState() =>
      _RecruitmentPersonalDetailsScreenState();
}

class _RecruitmentPersonalDetailsScreenState
    extends State<RecruitmentPersonalDetailsScreen> {
  @override
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context
          .read<RecruitmentEmpPersonalDetailsProvider>()
          .fetchEmployeeDetails(widget.empId);
    });
  }

  Widget build(BuildContext context) {
    final recruitmentEmpPersonalDetailsProvider =
        Provider.of<RecruitmentEmpPersonalDetailsProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomTextField(
              controller: recruitmentEmpPersonalDetailsProvider.emailController,
              hintText: "",
              labelText: "Email",
              isMandatory: true,
              readOnly: true,
            ),
            SizedBox(height: 10),
            CustomTextField(
              controller:
                  recruitmentEmpPersonalDetailsProvider.mobileController,
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
                              recruitmentEmpPersonalDetailsProvider
                                  .selectedGender,
                          activeColor: AppColor.primaryColor2,
                          onChanged: (value) {
                            recruitmentEmpPersonalDetailsProvider.setGender(
                              value!,
                            );
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
                              recruitmentEmpPersonalDetailsProvider
                                  .selectedGender,
                          activeColor: AppColor.primaryColor2,
                          onChanged: (value) {
                            recruitmentEmpPersonalDetailsProvider.setGender(
                              value!,
                            );
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
                  controller:
                      recruitmentEmpPersonalDetailsProvider
                          .experienceController,
                  hintText: "",
                  labelText: "Total Experience in Years ",
                  isMandatory: true,
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                DocumentUploadField(
                  labelText: "Resume",
                  isMandatory: true,
                  selectedFile:
                      recruitmentEmpPersonalDetailsProvider
                          .selectedJoiningLetter,
                  allowedExtensions: ["pdf", "doc", "docx"],
                  onFilePicked: (file) {
                    if (file != null) {
                      recruitmentEmpPersonalDetailsProvider.setJoiningLetter(
                        file,
                      );
                    } else {
                      recruitmentEmpPersonalDetailsProvider
                          .clearJoiningLetter();
                    }
                  },
                ),

                SizedBox(height: 10),
                ProfilePhotoField(
                  labelText: "Upload Profile Photo",
                  isMandatory: true,
                  selectedFile:
                      recruitmentEmpPersonalDetailsProvider.selectedFile,
                  onFilePicked: (file) {
                    if (file != null) {
                      recruitmentEmpPersonalDetailsProvider.setFile(file);
                    } else {
                      recruitmentEmpPersonalDetailsProvider
                          .clearFile(); // Use clearFile for null
                    }
                  },
                ),
                SizedBox(height: 10),

                CustomTextField(
                  controller:
                      recruitmentEmpPersonalDetailsProvider.dobController,
                  hintText: "",
                  labelText: "Date Of Birth",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      recruitmentEmpPersonalDetailsProvider.ageController,
                  hintText: "",
                  labelText: "Age",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      recruitmentEmpPersonalDetailsProvider.religionController,
                  hintText: "",
                  labelText: "Religion",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      recruitmentEmpPersonalDetailsProvider
                          .motherTongueController,
                  hintText: "",
                  labelText: "Mother Tongue",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      recruitmentEmpPersonalDetailsProvider.casteController,
                  hintText: "",
                  labelText: "Caste",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      recruitmentEmpPersonalDetailsProvider
                          .bloodGroupController,
                  hintText: "",
                  labelText: "Blood Group",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),

                CustomSearchDropdownWithSearch(
                  isMandatory: true,
                  labelText: "Marital Status",
                  items: recruitmentEmpPersonalDetailsProvider.materialStatus,
                  selectedValue:
                      recruitmentEmpPersonalDetailsProvider
                          .selectedmaterialStatus,
                  onChanged:
                      recruitmentEmpPersonalDetailsProvider
                          .setSelectedmaterialStatus,
                  hintText: "Single",
                  readOnly:
                      true, // ✅ Will show "Single" but user cannot change it
                ),
                SizedBox(height: 10),

                CustomLargeTextField(
                  readOnly: true, // ✅ Make it uneditable
                  controller:
                      recruitmentEmpPersonalDetailsProvider
                          .choiceOfWorkController,
                  hintText: "",
                  labelText: "Choice of work",
                  isMandatory: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      recruitmentEmpPersonalDetailsProvider
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
                      recruitmentEmpPersonalDetailsProvider
                          .secondaryContactRelationship,
                  selectedValue:
                      recruitmentEmpPersonalDetailsProvider
                          .selectedSecondaryContactRelationship,
                  onChanged:
                      recruitmentEmpPersonalDetailsProvider
                          .setSelectedSecondaryContactRelationship,
                  hintText: "mother",
                  readOnly:
                      true, // ✅ Will show "Single" but user cannot change it
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      recruitmentEmpPersonalDetailsProvider
                          .secondaryContactOccupationController,
                  hintText: "",
                  labelText: "Secondary Contact Occupation",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      recruitmentEmpPersonalDetailsProvider
                          .secondaryContactMobileController,
                  hintText: "",
                  labelText: "secondary Contact Number",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      recruitmentEmpPersonalDetailsProvider
                          .permanentAddressController,
                  hintText: "",
                  labelText: "Permanent Address",
                  isMandatory: true,
                  readOnly: true,
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller:
                      recruitmentEmpPersonalDetailsProvider
                          .presentAddressController,
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
                              recruitmentEmpPersonalDetailsProvider
                                  .selectedGender,
                          activeColor: AppColor.primaryColor2,
                          onChanged: (value) {
                            recruitmentEmpPersonalDetailsProvider.setGender(
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

                    // Female option
                    Row(
                      children: [
                        Radio<String>(
                          value: "No",
                          groupValue:
                              recruitmentEmpPersonalDetailsProvider
                                  .selectedGender,
                          activeColor: AppColor.primaryColor2,
                          onChanged: (value) {
                            recruitmentEmpPersonalDetailsProvider.setGender(
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
          ],
        ),
      ),
    );
  }
}
