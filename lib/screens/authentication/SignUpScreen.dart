// ignore_for_file: use_build_context_synchronously, avoid_print, file_names

import 'package:flutter/material.dart';
import 'package:ruprup/screens/authentication/LoginScreen.dart';
import 'package:ruprup/screens/authentication/VerificationScreen.dart';
import 'package:ruprup/services/auth_service.dart';
import 'package:ruprup/utils/validators.dart'; // Import validators.dart
import 'package:ruprup/widgets/auth/ButtonWidget.dart';
import 'package:ruprup/widgets/auth/FieldWidget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VerificationScreen()),
        );
      try {
        
        // Chuyển đến màn hình thông báo email đã được gửi
        
        await _authService.registerWithEmail(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 40, 40, 0),
          child: Form(
            key: _formKey,
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
                  "Sign up",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your credentials to continue",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                FieldWidget(
                  icon: const Icon(Icons.person_2_outlined),
                  nameField: 'Name',
                  isPass: false,
                  controller: _nameController,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 20),
                FieldWidget(
                  icon: const Icon(Icons.email_outlined),
                  nameField: 'Email',
                  isPass: false,
                  controller: _emailController,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 20),
                FieldWidget(
                    icon: const Icon(Icons.lock_outline),
                    nameField: 'Password',
                    isPass: true,
                    controller: _passwordController,
                    validator: Validators.validatePassword),
                const SizedBox(height: 30),
                ButtonWidget(nameButton: "Sign up", onTap: _handleRegister),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      ),
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
