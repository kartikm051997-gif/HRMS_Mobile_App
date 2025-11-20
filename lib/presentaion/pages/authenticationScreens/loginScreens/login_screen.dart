import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/appcolor_dart.dart';
import '../../../../core/fonts/fonts.dart';
import '../../../../provider/login_provider/login_provider.dart';
import 'forget_password_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ============================
                      // 🔥 LOGO ADDED HERE
                      // ============================
                      Center(
                        child: Image.asset(
                          "assets/images/logo.png",
                          // height: 110,
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text(
                        "Login to your account.",
                        style: TextStyle(
                          fontFamily: AppFonts.poppins,
                          fontSize: 25,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 15),
                      _label("Employee ID"),

                      modernTextField(
                        controller: provider.emailController,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? "Enter Employee ID"
                                    : null,
                        label: "Enter Employee ID",
                      ),

                      const SizedBox(height: 16),

                      _label("Password"),

                      modernTextField(
                        controller: provider.passwordController,
                        isPassword: true,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? "Enter Password"
                                    : null,
                        label: "Enter your Password",
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgetPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontFamily: AppFonts.poppins,
                              color: AppColor.primaryColor2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

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
                            backgroundColor: AppColor.primaryColor2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              provider.isLoading
                                  ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    "Login",
                                    style: TextStyle(
                                      fontFamily: AppFonts.poppins,
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.poppins,
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  //            Modern Text Field (With Border + Glow)
  // ============================================================
  Widget modernTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    required String? Function(String?) validator,
  }) {
    final ValueNotifier<bool> obscure = ValueNotifier<bool>(isPassword);

    return ValueListenableBuilder<bool>(
      valueListenable: obscure,
      builder: (_, obscureValue, __) {
        return TextFormField(
          controller: controller,
          obscureText: obscureValue,
          validator: validator,
          style: TextStyle(
            fontFamily: AppFonts.poppins,
            fontSize: 15,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontFamily: AppFonts.poppins,
            ),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),

            // ===== Default border (Grey)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),

            // ===== Focused border (Primary)
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColor.primaryColor1, width: 1.4),
            ),

            // ===== Error
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),

            // ===== Password Toggle
            suffixIcon:
                isPassword
                    ? IconButton(
                      onPressed: () {
                        obscure.value = !obscureValue;
                      },
                      icon: Icon(
                        obscureValue ? Icons.visibility_off : Icons.visibility,
                        color:
                            obscureValue ? Colors.grey : AppColor.primaryColor1,
                      ),
                    )
                    : null,
          ),
        );
      },
    );
  }
}
