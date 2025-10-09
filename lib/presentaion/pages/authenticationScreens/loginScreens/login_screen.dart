// lib/screens/auth/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/login_provider/login_provider.dart';
import '../../../../widgets/custom_textfield/custom_textfield.dart';
import 'forget_password_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          /// 🌈 Top Gradient Background
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
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
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

          /// 🧾 Login Form Section
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.70,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Welcome Back 👋",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Sign in to continue",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: AppFonts.poppins,
                        ),
                      ),
                      const SizedBox(height: 30),

                      /// Email Field
                      CustomTextField(
                        labelText: "Employee ID",
                        controller: provider.emailController,
                        hintText: "Enter your Employee ID",
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? "Enter Employee ID"
                                    : null,
                      ),
                      const SizedBox(height: 20),

                      /// Password Field
                      CustomTextField(
                        labelText: "Password",
                        obscureText: true,
                        controller: provider.passwordController,
                        hintText: "Enter password",
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? 'Enter password'
                                    : null,
                      ),
                      const SizedBox(height: 15),

                      /// Forgot password
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgetPasswordScreen(),
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: AppFonts.poppins,
                              color: AppColor.primaryColor2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      /// 🔘 Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              provider.isLoading
                                  ? null
                                  : () {
                                    if (_formKey.currentState!.validate()) {
                                      provider.login(context);
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.grey.shade400,
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient:
                                  provider.isLoading
                                      ? null
                                      : const LinearGradient(
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
                                  provider.isLoading
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            "Logging in...",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: AppFonts.poppins,
                                            ),
                                          ),
                                        ],
                                      )
                                      : const Text(
                                        "Sign In",
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
