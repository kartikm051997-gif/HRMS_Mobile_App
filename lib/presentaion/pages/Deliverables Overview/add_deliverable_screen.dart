import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import '../../../core/components/appbar/appbar.dart';
import '../../../core/components/drawer/drawer.dart';
import '../../../core/constants/appcolor_dart.dart';
import '../../../provider/Deliverables_Overview_provider/add_deliverable_provider.dart';
import '../../../widgets/custom_botton/custom_gradient_button.dart';
import '../../../widgets/custom_filechooser_field/custom_file_chooser_field.dart';
import '../../../widgets/custom_textfield/Custom_date_field.dart';
import '../../../widgets/custom_textfield/custom_dropdown_with_search.dart';
import '../../../widgets/custom_textfield/custom_large_textfield.dart';
import '../../../widgets/custom_textfield/custom_textfield.dart';

class AddDeliverableScreen extends StatelessWidget {
  const AddDeliverableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final addDeliverableProvider = Provider.of<AddDeliverableProvider>(context);
    return Scaffold(
      drawer: const TabletMobileDrawer(),
      appBar: const CustomAppBar(title: "Add Deliverables Form"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                controller: addDeliverableProvider.titleTaskController,
                hintText: "",
                labelText: "Task Title",
                isMandatory: true,
              ),
              SizedBox(height: 10),
              CustomSearchDropdownWithSearch(
                isMandatory: true,
                labelText: "Employee Name",
                items: addDeliverableProvider.employeeName,
                selectedValue: addDeliverableProvider.selectedemployeeName,
                onChanged: addDeliverableProvider.setSelectedemployeeName,
                hintText: "Select Employee..",
              ),
              SizedBox(height: 10),
          
              CustomDateField(
                controller: addDeliverableProvider.endDateController,
                hintText: "Select date",
                labelText: "To Date",
                isMandatory: true,
              ),
              SizedBox(height: 10),
          
              CustomTextField(
                controller: addDeliverableProvider.titleTaskController,
                hintText: "",
                labelText: "Location",
                isMandatory: true,
                readOnly: true,
              ),
              SizedBox(height: 10,),
              CustomSearchDropdownWithSearch(
                isMandatory: true,
                labelText: "Priority",
                items: addDeliverableProvider.priority,
                selectedValue: addDeliverableProvider.selectedpriority,
                onChanged: addDeliverableProvider.setSelectedpriority,
                hintText: "Select Priority..",
              ),
              SizedBox(height: 10,),
              CustomFileChooserField(
                labelText: "Attachment",
                isMandatory: true,
                selectedFile: addDeliverableProvider.selectedFile,
                allowedExtensions: ["csv"], //  pass dynamically
                onFilePicked: (file) {
                  if (file != null) {
                    addDeliverableProvider.setFile(file);
                  }
                },
              ),
              SizedBox(height: 10,),
              CustomLargeTextField(
                readOnly: false, // ✅ Make it uneditable
                controller:
                addDeliverableProvider.descriptionController,
                hintText: "",
                labelText: "Description",
                isMandatory: true,
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomGradientButton(
                      text: "Cancel",
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontFamily: AppFonts.poppins,
                        color: AppColor.blackColor,
                      ),
                      gradientColors: [
                        const Color.fromARGB(255, 200, 200, 200),
                        const Color.fromARGB(255, 224, 224, 224),
                      ],
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                  const SizedBox(width: 12), // space between buttons
                  Expanded(
                    child: CustomGradientButton(
                      text: "Submit",
                      onPressed: () {
                        // submit action
                      },
                    ),
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
