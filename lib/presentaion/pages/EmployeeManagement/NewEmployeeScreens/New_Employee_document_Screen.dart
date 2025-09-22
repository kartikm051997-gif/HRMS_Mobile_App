import 'package:flutter/Material.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/New_Employee_document_Provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/fonts/fonts.dart';
import 'Document_Upload_Field_for_Joining_Letter_Screen.dart';

class NewEmployeeDocumentScreen extends StatefulWidget {
  final String empId;
  const NewEmployeeDocumentScreen({super.key, required this.empId});

  @override
  State<NewEmployeeDocumentScreen> createState() =>
      _NewEmployeeDocumentScreenState();
}

class _NewEmployeeDocumentScreenState extends State<NewEmployeeDocumentScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<NewEmployeeDocumentProvider>().fetchEmployeeDetails(
        widget.empId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final newEmployeeBankDetailsProvider =
        Provider.of<NewEmployeeDocumentProvider>(context);
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header with dropdown button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    newEmployeeBankDetailsProvider.toggleDocumentsSection();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(
                          newEmployeeBankDetailsProvider.showDocumentsSection
                              ? 0
                              : 8,
                        ),
                        bottomRight: Radius.circular(
                          newEmployeeBankDetailsProvider.showDocumentsSection
                              ? 0
                              : 8,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Employee Documents",
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          newEmployeeBankDetailsProvider.showDocumentsSection
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: const Color(0xFF6B7280),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Expandable content
              if (newEmployeeBankDetailsProvider.showDocumentsSection) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    children: [
                      DocumentUploadField(
                        labelText: "Joining Letter",
                        isMandatory: true,
                        selectedFile:
                            newEmployeeBankDetailsProvider
                                .selectedJoiningLetter,
                        allowedExtensions: ["pdf", "doc", "docx"],
                        onFilePicked: (file) {
                          if (file != null) {
                            newEmployeeBankDetailsProvider.setJoiningLetter(
                              file,
                            );
                          } else {
                            newEmployeeBankDetailsProvider.clearJoiningLetter();
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      DocumentUploadField(
                        labelText: "Contract Paper",
                        isMandatory: true,
                        selectedFile:
                            newEmployeeBankDetailsProvider
                                .selectedContractPaper,
                        allowedExtensions: ["pdf", "doc", "docx"],
                        onFilePicked: (file) {
                          if (file != null) {
                            newEmployeeBankDetailsProvider.setContractPaper(
                              file,
                            );
                          } else {
                            newEmployeeBankDetailsProvider.clearContractPaper();
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      DocumentUploadField(
                        labelText: "Aadhaar Card",
                        isMandatory: true,
                        selectedFile:
                            newEmployeeBankDetailsProvider.selectedAadhaarCard,
                        allowedExtensions: [
                          "pdf",
                          "doc",
                          "docx",
                          "jpg",
                          "jpeg",
                          "png",
                        ],
                        onFilePicked: (file) {
                          if (file != null) {
                            newEmployeeBankDetailsProvider.setAadhaarCard(file);
                          } else {
                            newEmployeeBankDetailsProvider.clearAadhaarCard();
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      DocumentUploadField(
                        labelText: "Pan card",
                        isMandatory: true,
                        selectedFile:
                            newEmployeeBankDetailsProvider.selectedPanCard,
                        allowedExtensions: ["pdf", "doc", "docx"],
                        onFilePicked: (file) {
                          if (file != null) {
                            newEmployeeBankDetailsProvider.setPanCard(file);
                          } else {
                            newEmployeeBankDetailsProvider.cleaPanCard();
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      DocumentUploadField(
                        labelText: "Bank passbook",
                        isMandatory: true,
                        selectedFile:
                            newEmployeeBankDetailsProvider.selectedBankPassbook,
                        allowedExtensions: ["pdf", "doc", "docx"],
                        onFilePicked: (file) {
                          if (file != null) {
                            newEmployeeBankDetailsProvider.setBankPassbook(
                              file,
                            );
                          } else {
                            newEmployeeBankDetailsProvider.cleaBankPassbook();
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      DocumentUploadField(
                        labelText: "Current address proof",
                        isMandatory: true,
                        selectedFile:
                            newEmployeeBankDetailsProvider
                                .selectedCurrentAddressProof,
                        allowedExtensions: ["pdf", "doc", "docx"],
                        onFilePicked: (file) {
                          if (file != null) {
                            newEmployeeBankDetailsProvider
                                .setCurrentAddressProof(file);
                          } else {
                            newEmployeeBankDetailsProvider
                                .cleaCurrentAddressProof();
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      DocumentUploadField(
                        labelText: "Driving licence",
                        isMandatory: true,
                        selectedFile:
                            newEmployeeBankDetailsProvider
                                .selectedDrivingLicence,
                        allowedExtensions: ["pdf", "doc", "docx"],
                        onFilePicked: (file) {
                          if (file != null) {
                            newEmployeeBankDetailsProvider.setDrivingLicence(
                              file,
                            );
                          } else {
                            newEmployeeBankDetailsProvider.cleaDrivingLicence();
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      DocumentUploadField(
                        labelText: "Passport",
                        isMandatory: true,
                        selectedFile:
                            newEmployeeBankDetailsProvider.selectedPassport,
                        allowedExtensions: ["pdf", "doc", "docx"],
                        onFilePicked: (file) {
                          if (file != null) {
                            newEmployeeBankDetailsProvider.setPassport(file);
                          } else {
                            newEmployeeBankDetailsProvider.cleaPassport();
                          }
                        },
                      ),
                      const SizedBox(height: 10),

                      DocumentUploadField(
                        labelText: "Other Document",
                        isMandatory: true,
                        selectedFile:
                            newEmployeeBankDetailsProvider
                                .selectedOtherDocument,
                        allowedExtensions: ["pdf", "doc", "docx"],
                        onFilePicked: (file) {
                          if (file != null) {
                            newEmployeeBankDetailsProvider.setOtherDocument(
                              file,
                            );
                          } else {
                            newEmployeeBankDetailsProvider.cleaOtherDocument();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
