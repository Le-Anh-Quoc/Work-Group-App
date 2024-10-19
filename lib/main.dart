import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/screens/MainScreen.dart';
import 'package:ruprup/screens/authentication/LoginScreen.dart';
import 'package:ruprup/screens/group/GroupScreen.dart';
import 'package:ruprup/screens/task/TaskListScreen.dart';
import 'package:ruprup/widgets/animation/hero.dart';
import 'package:ruprup/widgets/task/Todo.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [CustomHeroController()],
      //home: const GroupScreen(groupId: '3qF6vu37TuHpZQppFvlz',),
      home: LoginScreen()
      //initialRoute: AppRoutes.home,
      //routes: AppRoutes.routes, // Sử dụng routes tĩnh
      // Hoặc bạn có thể sử dụng generateRoute
      //onGenerateRoute: AppRoutes.generateRoute, // Sử dụng phương thức generateRoute
      // Các thuộc tính khác
    );
  }
}