
import 'package:flutter/material.dart';
import '../../core/constants/appcolor_dart.dart';
import '../../core/fonts/fonts.dart';

class CustomLargeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool isMandatory;
  final String? Function(String?)? validator;
  final bool readOnly;

  const CustomLargeTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText = "",
    this.isMandatory = false,
    this.validator,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isMandatory)
              const Text("*", style: TextStyle(fontSize: 16, color: Colors.red)),
            if (isMandatory) const SizedBox(width: 3),
            Text(
              labelText,
              style:  TextStyle(
                fontSize: 14,
                color: AppColor.blackColor,
                fontFamily: AppFonts.poppins,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        FormField<String>(
          validator: (value) {
            if (isMandatory && (controller.text.isEmpty)) {
              return "Please enter $labelText";
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
                  readOnly: readOnly,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5, // ✅ Large field
                  minLines: 3,
                  style: const TextStyle(
                    // ✅ Add this for input text font
                    fontSize: 14,
                    fontFamily: AppFonts.poppins,
                    color: AppColor.blackColor,
                  ),// ✅ Ensures initial height
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
                        horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: state.hasError
                            ? Colors.red
                            : AppColor.blackColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: state.hasError
                            ? Colors.red
                            : AppColor.blackColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColor.primaryColor2,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (val) => state.didChange(val),
                ),
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
