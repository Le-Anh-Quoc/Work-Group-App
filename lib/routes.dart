import 'package:flutter/material.dart';
import 'package:ruprup/screens/home/HomeScreen.dart';

class AppRoutes {
  static const String home = '/';

  static const String listProjects = '/listProjects';
  static const String projectDetail = '/projectDetail';
  static const String listTasks = '/listTasks';
  static const String taskDetail = '/taskDetail';

  static const String listGroups = '/listGroups';
  static const String group = '/group';

  static const String listChats = '/listChats';
  static const String chat = '/chat';

  static const String me = '/me';

  // Hàm để lấy route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      default:
        throw Exception('Route not found');
    }
  }
}