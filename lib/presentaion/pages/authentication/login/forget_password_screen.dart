import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:hrms_mobile_app/core/fonts/fonts.dart';
import 'package:provider/provider.dart';

import '../../../../provider/forget_password_provider/forget_password_provider_screen.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';
import '../../dashborad/dashboard_screen.dart';
import 'login_screen.dart';

class ForgetPasswordScreen extends StatelessWidget {
   ForgetPasswordScreen({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    final forgetEmailPasswordProvider = Provider.of<ForgetPasswordProvider>(
      context,
    );
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 8,
                  ),
                  child: SizedBox(
                    height: 50,
                    width: 180,
                    child: Image.asset(
                      "assets/images/login_logo_image.jpg",
                      height: 50,
                      width: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.70,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Password Reset",
                      style: TextStyle(
                        fontFamily: AppFonts.poppins,
                        fontSize: 16,
                        color: AppColor.blackColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 16,
                          color: AppColor.gryColor,
                        ),
                        children: const [
                          TextSpan(
                            text:
                                "Fill with your mail to receive instructions on",
                          ),
                          TextSpan(
                            text: " how to reset your password",
                            style: TextStyle(
                              fontWeight: FontWeight.w500, // ✅ Highlighted part
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    CustomTextField(
                      labelText: "Email",
                      controller:
                          forgetEmailPasswordProvider.forgetPasswordController,
                      hintText: "Enter Email Id",
                      validator:
                          (val) =>
                              val == null || val.isEmpty ? "Enter Email" : null,
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // if (_formKey.currentState!.validate()) {
                          //   ForgetPasswordProvider.LoginScreen(context);
                          // }
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder:
                                  (context) =>
                                  LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E0E6B), Color(0xFFD4145A)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child:
                                ForgetPasswordProvider()
                                        .isLoading // ✅ Corrected spelling
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                    : Text(
                                      "Sumbit",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: AppFonts.poppins,
                                      ),
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
