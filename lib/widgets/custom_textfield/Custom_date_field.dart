import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/appcolor_dart.dart';
import '../../core/fonts/fonts.dart';

class CustomDateField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool isMandatory;
  final String? Function(String?)? validator;

  const CustomDateField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText = "",
    this.isMandatory = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + mandatory star
        Row(
          children: [
            if (isMandatory)
              const Text(
                "*",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            if (isMandatory) const SizedBox(width: 3),
            Text(
              labelText,
              style: TextStyle(
                fontSize: 14,
                color: AppColor.blackColor,
                fontFamily: AppFonts.poppins,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // FormField (same style as your textfield)
        FormField<String>(
          validator: (value) {
            if (isMandatory && (controller.text.isEmpty)) {
              return "Please select $labelText";
            }
            if (validator != null) {
              return validator!(controller.text);
            }
            return null;
          },
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  readOnly: true, // important for date field
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontFamily: AppFonts.poppins,
                      color: AppColor.hinttextblackColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColor.primaryColor2,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            state.hasError ? Colors.red : AppColor.blackColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            state.hasError ? Colors.red : AppColor.blackColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateFormat(
                        "dd-MM-yyyy",
                      ).format(pickedDate);
                      controller.text = formattedDate;
                      state.didChange(formattedDate);
                    }
                  },
                ),

                // Error message
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 8),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
