// ignore_for_file: avoid_print, use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/screens/authentication/SignUpScreen.dart';
import 'package:ruprup/screens/MainScreen.dart';
import 'package:ruprup/services/auth_service.dart';
import 'package:ruprup/widgets/auth/ButtonWidget.dart';
import 'package:ruprup/widgets/auth/FieldWidget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool isLoading = false;

  void _handleLogin() {
    print('nhấn nút đăng nhập');
    if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      _auth.logIn(_email.text, _password.text).then((user) {
        if (user != null) {
          setState(() {
            isLoading = false;
          });

          Provider.of<UserProvider>(context, listen: false).setUser(user);
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen(selectedIndex: 0)),
          );
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    } else {
      print("Please fill form correctly");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: SizedBox(
                height: size.height / 20,
                width: size.width / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
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
                      "Login",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Enter your email and password",
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
                      controller: _email,
                    ),
                    const SizedBox(height: 20),
                    FieldWidget(
                        icon: const Icon(Icons.lock_outline),
                        nameField: 'Password',
                        isPass: true,
                        controller: _password),
                    //const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Add functionality for forgot password
                          },
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ButtonWidget(nameButton: "Log in", onTap: _handleLogin),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
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
    );
  }

  // Widget customButton(Size size) {
  //   return GestureDetector(
  //     onTap: () {
  //       if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
  //         setState(() {
  //           isLoading = true;
  //         });
  //         _auth.logIn(_email.text, _password.text).then((user) {
  //           if (user != null) {
  //             setState(() {
  //               isLoading = false;
  //             });
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (_) => const HomeScreen()),
  //             );
  //           } else {
  //             setState(() {
  //               isLoading = false;
  //             });
  //           }
  //         });
  //       } else {
  //         print("Please fill form correctly");
  //       }
  //     },
  //     child: Container(
  //       height: size.height / 14,
  //       width: size.width / 1.2,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //         color: Colors.blue,
  //       ),
  //       alignment: Alignment.center,
  //       child: const Text(
  //         "Login",
  //         style: TextStyle(color: Colors.white, fontSize: 22),
  //       ),
  //     ),
  //   );
  // }
}
