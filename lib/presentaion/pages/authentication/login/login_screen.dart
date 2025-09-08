import 'package:flutter/material.dart';
import 'package:hrms_mobile_app/core/constants/appcolor_dart.dart';
import 'package:hrms_mobile_app/presentaion/pages/authentication/login/forget_password_screen.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/appimages.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';
import '../../../../provider/login_provider/login_provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);
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
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Enter your details below",
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: AppFonts.poppins,
                            ),
                          ),

                          const SizedBox(height: 24),

                          CustomTextField(
                            labelText: "Email",
                            controller: provider.emailcontroller,
                            hintText: "Enter Email Id",
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? "Enter Email"
                                        : null,
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            labelText: "Password",
                            obscureText: true,
                            controller: provider.passwordcontroller,
                            hintText: "Enter password",
                            validator:
                                (val) =>
                                    val == null || val.isEmpty
                                        ? 'Enter password'
                                        : null,
                          ),
                          SizedBox(height: 15),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => ForgetPasswordScreen(),
                                ),
                              );
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Forget Password?",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: AppFonts.poppins,
                                  color: AppColor.primaryColor2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  provider.login(context);
                                }
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
                                    colors: [
                                      Color(0xFF8E0E6B),
                                      Color(0xFFD4145A),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child:
                                      provider.isloading
                                          ? Text(
                                            "Loading...",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontFamily: AppFonts.poppins,
                                            ),
                                          )
                                          : Text(
                                            "SignIn",
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

                          const SizedBox(height: 20),
                        ],
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
