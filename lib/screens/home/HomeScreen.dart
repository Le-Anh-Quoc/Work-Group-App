// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/services/auth_service.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/bottomNav/CustomAppbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService userService = UserService();
  final AuthService authService = AuthService();
  String? _fullName = '';

  Future<void> _fetchUserFullName() async {
    _fullName = await userService.getCurrentUserFullName();
    setState(() {});   // cập nhật lại giao diện
  }

  @override
  void initState() {
    super.initState();
    _fetchUserFullName();
  }

  @override
  Widget build(BuildContext context) {
    String greeting = getGreeting();
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Text(
                _fullName ?? 'Unknown User',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text(
                'Status',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.blue),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                authService.logOut(context);
              },
            ),
          ],
        ),
      ),
      appBar: CustomAppBar(
        title: '$greeting, $_fullName',
      ),
      body: const Center(child: Text('Content'),),
    );
  }

  // Hàm để xác định lời chào
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
