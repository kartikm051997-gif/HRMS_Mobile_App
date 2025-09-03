
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appimages.dart';
import '../../../core/fonts/fonts.dart';
import '../../../widgets/custom_textfield/custom_textfield.dart';
import 'login_provider.dart';

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
                  child: Container(
                    height: 50,
                    width: 180,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppImages.logo),
                        fit: BoxFit.contain,
                      ),
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
                          const SizedBox(height: 24),

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

                          Center(
                            child: Text.rich(
                              TextSpan(
                                text:
                                'By logging into an account you are agreeing\nwith our ',
                                children: [
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontFamily: AppFonts.poppins,
                                        fontSize: 14

                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontFamily: AppFonts.poppins,

                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
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
