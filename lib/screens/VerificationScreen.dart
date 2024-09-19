import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/services/auth_service.dart';
import 'package:ruprup/wrapper.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _auth = AuthService();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified == true) {
        timer.cancel();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Wrapper()));
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("We have sent an email for verification.", textAlign: TextAlign.center,),
            const SizedBox(height: 20),
            customButton(size)
          ],
        ),)
      )
    );
  }

  Widget customButton(Size size) {
    return GestureDetector(
      onTap: () {
        _auth.sendEmailVerificationLink();
      },
      child: Container(
          height: size.height / 14,
          width: size.width / 1.2,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.blue),
          alignment: Alignment.center,
          child: Text("Resend",
              style: TextStyle(color: Colors.white, fontSize: 22))),
    );
  }
}