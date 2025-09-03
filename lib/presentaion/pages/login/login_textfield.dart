// import 'package:crm_draivfmobileapp/core/fonts/fonts.dart';
// import 'package:flutter/material.dart';

// class LoginCustomTextField extends StatefulWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final bool isPassword;

//   const LoginCustomTextField({
//     Key? key,
//     required this.controller,
//     required this.label,
//     required this.icon,
//     this.isPassword = false,
//   }) : super(key: key);

//   @override
//   State<LoginCustomTextField> createState() => _LoginCustomTextFieldState();
// }

// class _LoginCustomTextFieldState extends State<LoginCustomTextField> {
//   bool _obscureText = true;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(
//         vertical: MediaQuery.of(context).size.width >= 600
//             ? 20 // Tablets → bigger margin
//             : MediaQuery.of(context).size.width < 380
//             ? 5 // Small phones → very small margin
//             : 10, // Normal phones → default margin
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: TextField(
//         controller: widget.controller,
//         obscureText: widget.isPassword ? _obscureText : false,
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: MediaQuery.of(context).size.width >= 600 ? 20 : 16, // Responsive font size
//           fontWeight: FontWeight.w500,
//           fontFamily: AppFonts.poppins, // ✅ Added custom font family

//         ),
//         decoration: InputDecoration(
//           prefixIcon: Icon(widget.icon, color: Colors.white, size: MediaQuery.of(context).size.width >= 600 ? 28 : 24),
//           labelText: widget.label,
//           labelStyle: TextStyle(
//             color: Colors.white,
//             fontSize: MediaQuery.of(context).size.width >= 600 ? 18 : 16,
//             fontWeight: FontWeight.w400,
//             fontFamily: AppFonts.poppins, // ✅ Added custom font family

//           ),
//           hintText: "Enter your ${widget.label}",
//           hintStyle: TextStyle(
//             color: Colors.white.withOpacity(0.5),
//             fontFamily: AppFonts.poppins,
//             fontSize: MediaQuery.of(context).size.width >= 600 ? 18 : 14,
//           ),
//           filled: true,
//           fillColor: Colors.transparent,
//           suffixIcon: widget.isPassword
//               ? IconButton(
//             icon: Icon(
//               _obscureText ? Icons.visibility_off : Icons.visibility,
//               color: Colors.white,
//               size: MediaQuery.of(context).size.width >= 600 ? 26 : 22,
//             ),
//             onPressed: () {
//               setState(() {
//                 _obscureText = !_obscureText;
//               });
//             },
//           )
//               : null,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(
//               color: Colors.white.withOpacity(0.6),
//               width: MediaQuery.of(context).size.width >= 600 ? 2 : 1.5,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(
//               color: Colors.white.withOpacity(0.4),
//               width: MediaQuery.of(context).size.width >= 600 ? 2 : 1.5,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(
//               color: Colors.white,
//               width: MediaQuery.of(context).size.width >= 600 ? 2.5 : 2,
//             ),
//           ),
//           contentPadding: EdgeInsets.symmetric(
//             vertical: MediaQuery.of(context).size.width >= 600 ? 20 : 16,
//             horizontal: MediaQuery.of(context).size.width >= 600 ? 18 : 14,
//           ),
//         ),
//       ),
//     );

//   }
// }
import 'package:flutter/material.dart';

import '../../../core/fonts/fonts.dart';

class LoginCustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final bool isMandatory;
  final String? Function(String?)? validator;

  const LoginCustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.isMandatory = false, // ✅ new field
    this.validator, // ✅ custom validator
  }) : super(key: key);

  @override
  State<LoginCustomTextField> createState() => _LoginCustomTextFieldState();
}

class _LoginCustomTextFieldState extends State<LoginCustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical:
            MediaQuery.of(context).size.width >= 600
                ? 20
                : MediaQuery.of(context).size.width < 380
                ? 5
                : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FormField<String>(
        validator: (value) {
          if (widget.isMandatory && widget.controller.text.isEmpty) {
            return "Please enter ${widget.label}";
          }
          if (widget.validator != null) {
            return widget.validator!(widget.controller.text);
          }
          return null;
        },
        builder: (state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: widget.controller,
                obscureText: widget.isPassword ? _obscureText : false,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.width >= 600 ? 20 : 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.poppins,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width >= 600 ? 28 : 24,
                  ),
                  labelText: widget.label,
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize:
                        MediaQuery.of(context).size.width >= 600 ? 18 : 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFonts.poppins,
                  ),
                  hintText: "Enter your ${widget.label}",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontFamily: AppFonts.poppins,
                    fontSize:
                        MediaQuery.of(context).size.width >= 600 ? 18 : 14,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  suffixIcon:
                      widget.isPassword
                          ? IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                              size:
                                  MediaQuery.of(context).size.width >= 600
                                      ? 26
                                      : 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          state.hasError
                              ? Colors.red
                              : Colors.white.withOpacity(0.6),
                      width: MediaQuery.of(context).size.width >= 600 ? 2 : 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          state.hasError
                              ? Colors.red
                              : Colors.white.withOpacity(0.4),
                      width: MediaQuery.of(context).size.width >= 600 ? 2 : 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical:
                        MediaQuery.of(context).size.width >= 600 ? 20 : 16,
                    horizontal:
                        MediaQuery.of(context).size.width >= 600 ? 18 : 14,
                  ),
                ),
                onChanged: (val) => state.didChange(val),
              ),

              // ✅ Error message
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
    );
  }
}
