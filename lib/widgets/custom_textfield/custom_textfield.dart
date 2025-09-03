
// import 'package:crm_draivfmobileapp/core/constatnts/appcolors.dart';
// import 'package:crm_draivfmobileapp/core/fonts/fonts.dart';
// import 'package:flutter/material.dart';
// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final String labelText;
//   final bool isMandatory;
//   final String? Function(String?)? validator;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final bool readOnly;   // ✅ new field

//   const CustomTextField({
//     super.key,
//     required this.controller,
//     required this.hintText,
//     this.labelText = "",
//     this.isMandatory = false,
//     this.validator,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.readOnly = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             if (isMandatory)
//               const Text("*", style: TextStyle(fontSize: 16, color: Colors.red)),
//             if (isMandatory) const SizedBox(width: 3),
//             Text(
//               labelText,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: AppColor.blackColor,
//                 fontFamily: AppFonts.poppins,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),

//         FormField<String>(
//           validator: (value) {
//             if (isMandatory && (controller.text.isEmpty)) {
//               return "Please enter $labelText";
//             }
//             if (validator != null) {
//               return validator!(controller.text);
//             }
//             return null;
//           },
//           builder: (FormFieldState<String> state) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextFormField(
//                   controller: controller,
//                   readOnly: readOnly,   // ✅ now supports read-only
//                   obscureText: obscureText,
//                   keyboardType: keyboardType,
//                   decoration: InputDecoration(
//                     hintText: hintText,
//                     hintStyle: const TextStyle(
//                       fontSize: 14,
//                       fontFamily: AppFonts.poppins,
//                       color: AppColor.hinttextblackColor,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 14),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: BorderSide(
//                         color: state.hasError
//                             ? Colors.red
//                             : AppColor.blackColor,
//                       ),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: BorderSide(
//                         color: state.hasError
//                             ? Colors.red
//                             : AppColor.blackColor,
//                       ),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: const BorderSide(
//                         color: AppColor.primaryColor2,
//                         width: 1.5,
//                       ),
//                     ),
//                   ),
//                   onChanged: (val) => state.didChange(val),
//                 ),
//                 if (state.hasError)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 5, left: 8),
//                     child: Text(
//                       state.errorText!,
//                       style: const TextStyle(color: Colors.red, fontSize: 12),
//                     ),
//                   ),
//               ],
//             );
//           },
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../core/constants/appcolor_dart.dart';
import '../../core/fonts/fonts.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool isMandatory;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText = "",
    this.isMandatory = false,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.isMandatory)
              const Text("*", style: TextStyle(fontSize: 16, color: Colors.red)),
            if (widget.isMandatory) const SizedBox(width: 3),
            Text(
              widget.labelText,
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
            if (widget.isMandatory && (widget.controller.text.isEmpty)) {
              return "Please enter ${widget.labelText}";
            }
            if (widget.validator != null) {
              return widget.validator!(widget.controller.text);
            }
            return null;
          },
          builder: (FormFieldState<String> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: widget.controller,
                  readOnly: widget.readOnly,
                  obscureText: _isObscured,
                  keyboardType: widget.keyboardType,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontFamily: AppFonts.poppins,
                      color: AppColor.hinttextblackColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                        color: AppColor.primaryColor2,
                        width: 1.5,
                      ),
                    ),
                    // 👁 Add eye icon if it's a password field
                    suffixIcon: widget.obscureText
                        ? IconButton(
                      icon: Icon(
                        _isObscured
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColor.blackColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    )
                        : null,
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
