import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/Deliverables_Overview_provider/reference_details_provider.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';

class ReferenceDetailsScreen extends StatefulWidget {
  final String empId;
  const ReferenceDetailsScreen({super.key, required this.empId});

  @override
  State<ReferenceDetailsScreen> createState() => _ReferenceDetailsScreenState();
}

class _ReferenceDetailsScreenState extends State<ReferenceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<ReferenceDetailsProvider>().fetchReferenceDetails(
        widget.empId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final referenceDetailsProvider = Provider.of<ReferenceDetailsProvider>(
      context,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              CustomTextField(
                controller: referenceDetailsProvider.nameController,
                hintText: "Name",
                labelText: "Name",
                isMandatory: true,
                readOnly: true,
              ),
              const SizedBox(height: 10),

              // Contact Number Field
              CustomTextField(
                controller: referenceDetailsProvider.contactNumberController,
                hintText: "Contact Number",
                labelText: "Contact Number",
                isMandatory: true,
                readOnly: true,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),

              // Designation Field
              CustomTextField(
                controller: referenceDetailsProvider.designationController,
                hintText: "Designation",
                labelText: "Designation",
                isMandatory: true,
                readOnly: true,
              ),
              const SizedBox(height: 10),

              // Institution Field
              CustomTextField(
                controller: referenceDetailsProvider.institutionController,
                hintText: "Institution",
                labelText: "Institution",
                isMandatory: true,
                readOnly: true,
              ),
              const SizedBox(height: 20),

              // Reference Details Section Header
              Text(
                "Reference Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.poppins,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),

              // Are you convicted of any Offence
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Are you convicted of any Offence",
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
                                referenceDetailsProvider
                                    .selectedOffenceConviction,
                            activeColor: AppColor.primaryColor2,
                            onChanged: null, // Readonly
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
                                referenceDetailsProvider
                                    .selectedOffenceConviction,
                            activeColor: AppColor.primaryColor2,
                            onChanged: null, // Readonly
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
              const SizedBox(height: 20),

              // Are there any Court / Police Case Pending Against you
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "Are there any Court / Police Case Pending Against you",
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
                                referenceDetailsProvider
                                    .selectedCourtPoliceCase,
                            activeColor: AppColor.primaryColor2,
                            onChanged: null, // Readonly
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
                                referenceDetailsProvider
                                    .selectedCourtPoliceCase,
                            activeColor: AppColor.primaryColor2,
                            onChanged: null, // Readonly
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
              const SizedBox(height: 20),

              // Case Type (conditional - only show if court/police case is Yes)
              // if (referenceDetailsProvider.selectedCourtPoliceCase == "Yes")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "if Yes",
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
                      // Criminal option
                      Row(
                        children: [
                          Radio<String>(
                            value: "Criminal",
                            groupValue:
                                referenceDetailsProvider.selectedCaseType,
                            activeColor: AppColor.primaryColor2,
                            onChanged: null, // Readonly
                          ),
                          Text(
                            "Criminal",
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

                      // Civil option
                      Row(
                        children: [
                          Radio<String>(
                            value: "Civil",
                            groupValue:
                                referenceDetailsProvider.selectedCaseType,
                            activeColor: AppColor.primaryColor2,
                            onChanged: null, // Readonly
                          ),
                          Text(
                            "Civil",
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
            ],
          ),
        ),
      ),
    );
  }
}
