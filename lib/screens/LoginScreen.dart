import 'package:flutter/material.dart';
import 'package:ruprup/screens/SignUpScreen.dart';
import 'package:ruprup/screens/HomeScreen.dart';
import 'package:ruprup/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        body: isLoading
            ? Center(
                child: Container(
                    height: size.height / 20,
                    width: size.width / 20,
                    child: CircularProgressIndicator()))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height / 20,
                    ),
                    SizedBox(
                      height: size.height / 50,
                    ),
                    Container(
                      width: size.width / 1.3,
                      child: const Text("Welcome",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    Container(
                        width: size.width / 1.3,
                        child: const Text(
                          "Sign In to continue!",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        )),
                    SizedBox(
                      height: size.height / 10,
                    ),
                    Container(
                        width: size.width,
                        alignment: Alignment.center,
                        child: field(size, "email", Icons.account_box, _email)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Container(
                          width: size.width,
                          alignment: Alignment.center,
                          child:
                              field(size, "password", Icons.lock, _password)),
                    ),
                    SizedBox(
                      height: size.height / 10,
                    ),
                    customButton(size),
                    SizedBox(
                      height: size.height / 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("You don't have an account yet? "),
                        GestureDetector(
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => SignUpScreen())),
                            child: const Text("Sign Up",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ))),
                      ],
                    ),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     final user = await _authService.signInWithGoogle();
                    //     if (user != null) {
                    //       // Đăng nhập thành công
                    //       print('Đăng nhập thành công: ${user.displayName}');
                    //     } else {
                    //       // Đăng nhập thất bại
                    //       print('Đăng nhập thất bại');
                    //     }
                    //   },
                    //   child: Text('Đăng nhập với Google'),
                    // ),
                  ],
                ),
              ));
  }

  Widget customButton(Size size) {
    return GestureDetector(
      onTap: () {
        if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
          setState(() {
            isLoading = true;
          });
          _auth.logIn(_email.text, _password.text).then((user) {
            if (user != null) {
              print("Login Successful");
              setState(() {
                isLoading = false;
              });
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => HomeScreen()));
            } else {
              print("Login failed");
              setState(() {
                isLoading = false;
              });
            }
          });
        } else {
          print("Please fill form correctly");
        }
      },
      child: Container(
          height: size.height / 14,
          width: size.width / 1.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.blue),
          alignment: Alignment.center,
          child: Text("Login",
              style: TextStyle(color: Colors.white, fontSize: 22))),
    );
  }

  Widget field(Size size, String hintText, IconData icon,
      TextEditingController context) {
    return Container(
        height: size.height / 15,
        width: size.width / 1.2,
        child: TextField(
          controller: context,
          decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )),
        ));
  }
}
