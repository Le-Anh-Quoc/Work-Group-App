import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/screens/ChatScreen.dart';
import 'package:ruprup/screens/HomeScreen.dart';

import 'screens/LoginScreen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}