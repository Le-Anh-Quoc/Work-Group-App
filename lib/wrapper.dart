import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/screens/MainScreen.dart';
import 'package:ruprup/screens/authentication/LoginScreen.dart';
import 'package:ruprup/screens/authentication/VerificationScreen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text("Error"),
                );
              } else {
                if (snapshot.data == null) {
                  return const LoginScreen();
                } else {
                  if (snapshot.data?.emailVerified == true) {
                    return MainScreen(selectedIndex: 0);
                  }
                  return const VerificationScreen();
                }
              }
            }));
  }
}
