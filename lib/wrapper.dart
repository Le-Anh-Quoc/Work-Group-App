import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/screens/HomeScreen.dart';
import 'package:ruprup/screens/LoginScreen.dart';
import 'package:ruprup/screens/VerificationScreen.dart';

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
                    return HomeScreen();
                  }
                  return const VerificationScreen();
                }
              }
            }));
  }
}
