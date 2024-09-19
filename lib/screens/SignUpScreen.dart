import 'package:flutter/material.dart';
import 'package:ruprup/screens/VerificationScreen.dart';
import 'package:ruprup/services/auth_service.dart';
import 'package:ruprup/utils/validators.dart';

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

  bool isLoading = false;

  Future<void> _register() async {
    // Chuyển đến màn hình thông báo email đã được gửi
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => VerificationScreen()),
    );
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        await _authService.registerWithEmail(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          // Canh giữa toàn bộ nội dung
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Canh giữa các phần tử
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: size.height / 20),
                Container(
                  alignment: Alignment.centerLeft,
                  width: size.width / 1.2,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                ),
                SizedBox(height: size.height / 50),
                Container(
                  width: size.width / 1.3,
                  child: const Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: size.width / 1.3,
                  child: const Text(
                    "Sign Up to continue!",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: size.height / 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: _buildTextField(size, "Fullname",
                      Icons.account_balance, _nameController, validateName),
                ),
                _buildTextField(
                  size,
                  "Email",
                  Icons.email,
                  _emailController,
                  validateEmail,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: _buildTextField(
                    size,
                    "Password",
                    Icons.lock,
                    _passwordController,
                    validatePassword,
                  ),
                ),
                SizedBox(height: size.height / 10),
                _buildCustomButton(size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton(Size size) {
    return GestureDetector(
      onTap: _register,
      child: Container(
        height: size.height / 14,
        width: size.width / 1.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue,
        ),
        alignment: Alignment.center,
        child: const Text(
          "Sign up",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }

  Widget _buildTextField(Size size, String hintText, IconData icon,
      TextEditingController controller, String? Function(String?) validator) {
    return Container(
      height: size.height / 15,
      width: size.width / 1.2,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
