import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project/task_model.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/providers/activity_provider.dart';
import 'package:ruprup/providers/channel_provider.dart';
import 'package:ruprup/providers/comment_provider.dart';
import 'package:ruprup/providers/meeting_provider.dart';
import 'package:ruprup/providers/project_provider.dart';
import 'package:ruprup/providers/taskFileComment_provider.dart';
import 'package:ruprup/providers/taskFile_provider.dart';
import 'package:ruprup/providers/task_provider.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/routes.dart';
import 'package:ruprup/screens/authentication/LoginScreen.dart';
import 'package:ruprup/services/user_notification.dart';
import 'package:ruprup/widgets/animation/hero.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  await FirebaseAPI().initNotifications();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => UserProvider()),
      ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ChangeNotifierProvider(
        create: (context) => Task(
            taskId: 'taskId', // Thay thế bằng ID thực tế
            projectId: 'projectId', // Thay thế bằng ID thực tế
            taskName: 'Task Name',
            description: 'Task Description',
            assigneeId: '', // Danh sách ID thực tế
            status: TaskStatus.toDo, // Trạng thái ban đầu
            dueDate: DateTime.now(),
            createdAt: DateTime.now(),
            priority: TaskPriority.medium // Độ khó ban đầu
            ),
      ),
      ChangeNotifierProvider(create: (_) => TaskProvider()),
      ChangeNotifierProvider(create: (_) => TaskFileProvider()),
      ChangeNotifierProvider(create: (_) => CommentProvider()),
      ChangeNotifierProvider(create: (_) => TaskFileCommentProvider()),
      ChangeNotifierProvider(
          create: (context) => UserModel(
              userId: '12',
              fullname: '22',
              email: 'leanhquocit@gmail.com',
              pushToken: '')),
      ChangeNotifierProvider(create: (_) => ChannelProvider()),
      ChangeNotifierProvider(create: (_) => MeetingProvider()),
      ChangeNotifierProvider(create: (_) => ActivityProvider())
      // Các Provider khác nếu có
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [CustomHeroController()],
      //home: const GroupScreen(groupId: '3qF6vu37TuHpZQppFvlz',),
      home: const LoginScreen(),
      initialRoute: AppRoutes.home,
      //routes: AppRoutes.routes, // Sử dụng routes tĩnh
      // Hoặc bạn có thể sử dụng generateRoute
      onGenerateRoute:
          AppRoutes.generateRoute, // Sử dụng phương thức generateRoute
      // Các thuộc tính khác
    );
  }
}
