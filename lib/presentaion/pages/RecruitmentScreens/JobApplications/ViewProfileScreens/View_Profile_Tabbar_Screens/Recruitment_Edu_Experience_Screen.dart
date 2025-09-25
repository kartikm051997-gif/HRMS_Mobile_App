import 'package:flutter/Material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/appcolor_dart.dart';
import '../../../../../../core/fonts/fonts.dart';
import '../../../../../../provider/RecruitmentScreensProvider/Recruitment_Edu_Exp_Provider.dart';
import '../../../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../../../widgets/custom_textfield/custom_textfield.dart';

class RecruitmentEduExperienceScreen extends StatefulWidget {
  final String empId;
  const RecruitmentEduExperienceScreen({super.key, required this.empId});

  @override
  State<RecruitmentEduExperienceScreen> createState() =>
      _RecruitmentEduExperienceScreenState();
}

class _RecruitmentEduExperienceScreenState
    extends State<RecruitmentEduExperienceScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<RecruitmentEduExpProvider>().fetchEduExpDetails(
        widget.empId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final recruitmentEduExpProvider = Provider.of<RecruitmentEduExpProvider>(
      context,
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                controller: recruitmentEduExpProvider.qualificationController,
                hintText: "",
                labelText: "Qualification",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: recruitmentEduExpProvider.yearController,
                hintText: "",
                labelText: "Year",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller:
                    recruitmentEduExpProvider.nameOfInstitutionController,
                hintText: "",
                labelText: "Name of institution / University",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: recruitmentEduExpProvider.percentageController,
                hintText: "",
                labelText: "Percentage obtained",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: recruitmentEduExpProvider.organizationController,
                hintText: "",
                labelText: "Organization",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: recruitmentEduExpProvider.designationController,
                hintText: "",
                labelText: "Designation",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller:
                    recruitmentEduExpProvider.previousExperienceYearController,
                hintText: "",
                labelText: "Previous Experience Year",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller:
                    recruitmentEduExpProvider.salaryDrawnPerMonthController,
                hintText: "",
                labelText: "Salary Drawn per Month (INR)",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller:
                    recruitmentEduExpProvider.reasonForLeavingController,
                hintText: "",
                labelText: "Reason for Leaving",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller:
                    recruitmentEduExpProvider.computerLiteracyController,
                hintText: "",
                labelText: "Computer Literacy",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: recruitmentEduExpProvider.otherSkillsController,
                hintText: "",
                labelText: "Other Skills",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: recruitmentEduExpProvider.stayController,
                hintText: "",
                labelText: "Stay",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller:
                    recruitmentEduExpProvider
                        .minimumYearsGuaranteedToStayController,
                hintText: "",
                labelText: "Minimum Years Guaranteed to Stay ",
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
                            text:
                                "Acceptance of working Riles & Regulations / Notice period of 2 months",
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
                        groupValue: recruitmentEduExpProvider.selectedGender,
                        activeColor: AppColor.primaryColor2,
                        onChanged: (value) {
                          recruitmentEduExpProvider.setGender(value!);
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
                        groupValue: recruitmentEduExpProvider.selectedGender,
                        activeColor: AppColor.primaryColor2,
                        onChanged: (value) {
                          recruitmentEduExpProvider.setGender(value!);
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
              CustomTextField(
                controller:
                    recruitmentEduExpProvider.probableOfDateOfJoiningController,
                hintText: "",
                labelText: "Probable of Date of Joining",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomSearchDropdownWithSearch(
                isMandatory: true,
                labelText: "Expected Working Hours",
                items: recruitmentEduExpProvider.expectedWorkingHours,
                selectedValue:
                    recruitmentEduExpProvider.selectedexpectedWorkingHours,
                onChanged:
                    recruitmentEduExpProvider.setSelectedexpectedWorkingHours,
                hintText: "Select Priority..",
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: recruitmentEduExpProvider.salaryExpectedController,
                hintText: "",
                labelText: "Salary Expected ",
                isMandatory: true,
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
