import 'package:flutter/Material.dart';
import 'package:hrms_mobile_app/provider/Employee_management_Provider/New_Employee_Provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/components/appbar/appbar.dart';
import '../../../../core/components/drawer/drawer.dart';
import '../../../../widgets/custom_textfield/Custom_date_field.dart';
import '../../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../../widgets/custom_textfield/custom_large_textfield.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';

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

  Widget build(BuildContext context) {
    final newEmployeeProvider = Provider.of<NewEmployeeProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomSearchDropdownWithSearch(
                isMandatory: true,
                labelText: "Job Application ID",
                items: newEmployeeProvider.jobApplicationID,
                selectedValue: newEmployeeProvider.selectedJobApplicationID,
                onChanged: newEmployeeProvider.setSelectedJobApplicationID,
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
                controller: newEmployeeProvider.highestQualificationController,
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
                controller: newEmployeeProvider.permanentAddressController,
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
            ],
          ),
        ),
      ),
    );
  }
}
