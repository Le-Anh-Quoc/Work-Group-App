import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/activityProject_model.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/routes.dart';
import 'package:ruprup/screens/authentication/LoginScreen.dart';
import 'package:ruprup/widgets/animation/hero.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => Project(
          projectId: '1', // Thay thế bằng giá trị thực tế nếu cần
          groupId: 'group1',
          projectName: 'Project 1',
          description: 'Description of Project 1',
          startDate: DateTime.now(),
          ownerId: 'ownerId', // Thay thế bằng ID thực tế
          memberIds: [
            'memberId1',
            'memberId2'
          ], // Thay thế bằng danh sách ID thực tế
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => Task(
            taskId: 'taskId', // Thay thế bằng ID thực tế
            projectId: 'projectId', // Thay thế bằng ID thực tế
            taskName: 'Task Name',
            description: 'Task Description',
            assigneeIds: ['assigneeId1', 'assigneeId2'], // Danh sách ID thực tế
            status: TaskStatus.toDo, // Trạng thái ban đầu
            dueDate: DateTime.now(),
            createdAt: DateTime.now(),
            difficulty: Difficulty.medium // Độ khó ban đầu
            ),
      ),
      ChangeNotifierProvider(
          create: (context) => ActivityLog(
              taskId: 'taskId',
              taskName: 'taskName',
              action: 'action',
              userActionId: 'userActionId',
              timestamp: DateTime.now())),
      ChangeNotifierProvider(
          create: (context) =>
              UserModel(userId: '12', fullname: '22', email: 'leanhquocit@gmail.com')),
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
        onGenerateRoute: AppRoutes.generateRoute, // Sử dụng phương thức generateRoute
        // Các thuộc tính khác
        );
  }
}
