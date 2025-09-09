import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/edu_exp_provider.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';

class EduExpDetailsScreen extends StatefulWidget {
  final String empId;
  const EduExpDetailsScreen({super.key, required this.empId});

  @override
  State<EduExpDetailsScreen> createState() => _EduExpDetailsScreenState();
}

class _EduExpDetailsScreenState extends State<EduExpDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<EduExpProvider>().fetchEduExpDetails(widget.empId);
    });
  }

  Widget build(BuildContext context) {
    final eduExpProvider = Provider.of<EduExpProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                controller: eduExpProvider.qualificationController,
                hintText: "",
                labelText: "Qualification",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: eduExpProvider.yearController,
                hintText: "",
                labelText: "Year",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: eduExpProvider.nameOfInstitutionController,
                hintText: "",
                labelText: "Name of institution / University",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: eduExpProvider.percentageController,
                hintText: "",
                labelText: "Percentage obtained",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: eduExpProvider.organizationController,
                hintText: "",
                labelText: "Organization",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: eduExpProvider.designationController,
                hintText: "",
                labelText: "Designation",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: eduExpProvider.previousExperienceYearController,
                hintText: "",
                labelText: "Previous Experience Year",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: eduExpProvider.salaryDrawnPerMonthController,
                hintText: "",
                labelText: "Salary Drawn per Month (INR)",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: eduExpProvider.reasonForLeavingController,
                hintText: "",
                labelText: "Reason for Leaving",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: eduExpProvider.computerLiteracyController,
                hintText: "",
                labelText: "Computer Literacy",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: eduExpProvider.otherSkillsController,
                hintText: "",
                labelText: "Other Skills",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller: eduExpProvider.stayController,
                hintText: "",
                labelText: "Stay",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10),
              CustomTextField(
                controller:
                    eduExpProvider.minimumYearsGuaranteedToStayController,
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
                        groupValue: eduExpProvider.selectedGender,
                        activeColor: AppColor.primaryColor2,
                        onChanged: (value) {
                          eduExpProvider.setGender(value!);
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
                        groupValue: eduExpProvider.selectedGender,
                        activeColor: AppColor.primaryColor2,
                        onChanged: (value) {
                          eduExpProvider.setGender(value!);
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
            ],
          ),
        ),
      ),
    );
  }
}
