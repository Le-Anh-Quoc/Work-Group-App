// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, file_names, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/screens/authentication/LoginScreen.dart';
import 'package:ruprup/widgets/auth/ButtonWidget.dart';
import 'package:ruprup/widgets/auth/FieldWidget.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Password reset link sent! Check your email'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              Center(
                child: Container(
                  width: 90, // Chiều rộng của container
                  height: 90, // Chiều cao của container
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30), // Bo tròn
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://www.workingskills.net/wp-content/plugins/profilegrid-user-profiles-groups-and-communities/public/partials/images/default-group.png'), // Hình ảnh logo ngẫu nhiên
                      fit: BoxFit
                          .cover, // Chỉnh kích thước hình ảnh phù hợp với container
                    ),
                  ),
                ),
              ),
              const Text(
                "Rup Rup",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Promote the spirit of Teamwork",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              const Text(
                "Reset Password",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Enter the email you used to reset your password",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              FieldWidget(
                icon: const Icon(Icons.email_outlined),
                nameField: 'Email',
                isPass: false,
                controller: _emailController,
              ),
              const SizedBox(height: 30),
              ButtonWidget(nameButton: "Reset", onTap: passwordReset),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "You remember your password? ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
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
