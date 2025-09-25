import 'package:flutter/Material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/constants/appcolor_dart.dart';
import '../../../../../../core/fonts/fonts.dart';
import '../../../../../../provider/RecruitmentScreensProvider/Recruitment_Others_Provider.dart';
import '../../../../../../widgets/custom_textfield/custom_textfield.dart';

class RecruitmentOtherDetailsScreen extends StatefulWidget {
  final String empId;
  const RecruitmentOtherDetailsScreen({super.key, required this.empId});

  @override
  State<RecruitmentOtherDetailsScreen> createState() =>
      _RecruitmentOtherDetailsScreenState();
}

class _RecruitmentOtherDetailsScreenState
    extends State<RecruitmentOtherDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<RecruitmentOthersProvider>().fetchPersonalDetails(
        widget.empId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final recruitmentOthersProvider = Provider.of<RecruitmentOthersProvider>(
      context,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Identification Marks
              CustomTextField(
                controller:
                    recruitmentOthersProvider
                        .personalIdentificationMarksController,
                hintText: "Enter personal identification marks",
                labelText: "Personal Identification Marks",
                isMandatory: true,
                readOnly: true,
              ),
              const SizedBox(height: 15),

              // Height in cm
              CustomTextField(
                controller: recruitmentOthersProvider.heightController,
                hintText: "Enter height in cm",
                labelText: "Height in cm",
                isMandatory: true,
                readOnly: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),

              // Weight in kg
              CustomTextField(
                controller: recruitmentOthersProvider.weightController,
                hintText: "Enter weight in kg",
                labelText: "Weight in kg",
                isMandatory: true,
                readOnly: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // Chronic Illness Radio Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Are you suffering from any chronic illness",
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
                                recruitmentOthersProvider
                                    .selectedChronicIllness,
                            activeColor: AppColor.primaryColor2,
                            onChanged: (value) {
                              recruitmentOthersProvider.setChronicIllness(
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
                                recruitmentOthersProvider
                                    .selectedChronicIllness,
                            activeColor: AppColor.primaryColor2,
                            onChanged: (value) {
                              recruitmentOthersProvider.setChronicIllness(
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
                ],
              ),
              const SizedBox(height: 15),

              // Treatment Details (conditional)
              CustomTextField(
                controller:
                    recruitmentOthersProvider.treatmentDetailsController,
                hintText: "If Yes Details & Nature of Treatment",
                labelText: "If Yes Details & Nature of Treatment",
                isMandatory: true,
                readOnly: true,
              ),

              const SizedBox(height: 30),

              // Save Button (Optional)
            ],
          ),
        ),
      ),
    );
  }
}
