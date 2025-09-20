import 'package:flutter/Material.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/NewEmployee_Bank_Details_Provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/fonts/fonts.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';

class NewEmployeeBankDetailsScreen extends StatefulWidget {
  final String empId;

  const NewEmployeeBankDetailsScreen({super.key, required this.empId});

  @override
  State<NewEmployeeBankDetailsScreen> createState() =>
      _NewEmployeeBankDetailsScreenState();
}

class _NewEmployeeBankDetailsScreenState
    extends State<NewEmployeeBankDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<NewEmployeeBankDetailsProvider>().fetchEmployeeDetails(
        widget.empId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final newEmployeeBankDetailsProvider =
        Provider.of<NewEmployeeBankDetailsProvider>(context);
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
                    newEmployeeBankDetailsProvider.toggleBankSection();
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
                          newEmployeeBankDetailsProvider.showBankSection
                              ? 0
                              : 8,
                        ),
                        bottomRight: Radius.circular(
                          newEmployeeBankDetailsProvider.showBankSection
                              ? 0
                              : 8,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Bank & Others",
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          newEmployeeBankDetailsProvider.showBankSection
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
              if (newEmployeeBankDetailsProvider.showBankSection) ...[
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
                      CustomTextField(
                        keyboardType: TextInputType.text,
                        controller:
                            newEmployeeBankDetailsProvider.bankNameController,
                        hintText: "",
                        labelText: "Bank Name",
                        isMandatory: true,
                        readOnly: false,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        keyboardType: TextInputType.text,
                        controller:
                            newEmployeeBankDetailsProvider
                                .bankIFSCCodeController,
                        hintText: "",
                        labelText: "Bank IFSC Code",
                        isMandatory: true,
                        readOnly: false,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        keyboardType: TextInputType.number,
                        controller:
                            newEmployeeBankDetailsProvider
                                .accountNumberController,
                        hintText: "",
                        labelText: "Account Number",
                        isMandatory: true,
                        readOnly: false,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        keyboardType: TextInputType.number,
                        controller:
                            newEmployeeBankDetailsProvider.eSINumberController,
                        hintText: "",
                        labelText: "ESI Number",
                        isMandatory: true,
                        readOnly: false,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        keyboardType: TextInputType.number,
                        controller:
                            newEmployeeBankDetailsProvider.pFNumberController,
                        hintText: "",
                        labelText: "PF Number",
                        isMandatory: true,
                        readOnly: false,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        keyboardType: TextInputType.number,
                        controller:
                            newEmployeeBankDetailsProvider
                                .aadhaarNumberController,
                        hintText: "",
                        labelText: "Aadhaar Number",
                        isMandatory: true,
                        readOnly: false,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        keyboardType: TextInputType.number,
                        controller:
                            newEmployeeBankDetailsProvider.panNumberController,
                        hintText: "",
                        labelText: "PAN Number",
                        isMandatory: true,
                        readOnly: false,
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
