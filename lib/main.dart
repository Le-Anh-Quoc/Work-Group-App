import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/models/group_model.dart';
import 'package:ruprup/screens/MainScreen.dart';
import 'package:ruprup/screens/authentication/LoginScreen.dart';
import 'package:ruprup/screens/group/GroupScreen.dart';
import 'package:ruprup/widgets/animation/hero.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [CustomHeroController()],
      home: const GroupScreen(groupId: '3qF6vu37TuHpZQppFvlz',),
      //initialRoute: AppRoutes.home,
      //routes: AppRoutes.routes, // Sử dụng routes tĩnh
      // Hoặc bạn có thể sử dụng generateRoute
      //onGenerateRoute: AppRoutes.generateRoute, // Sử dụng phương thức generateRoute
      // Các thuộc tính khác
    );
  }
}