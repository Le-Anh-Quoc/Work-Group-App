// ignore_for_file: file_names, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:ruprup/screens/group/EventCalendarScreen.dart';
import 'package:ruprup/services/auth_service.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/bottomNav/CustomAppbar.dart';
import 'package:ruprup/widgets/project/ChildProjectWidget.dart';
import 'package:ruprup/widgets/task/TaskWidget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final UserService userService = UserService();
  final AuthService authService = AuthService();
  String? _fullName = '';
  String _taskCount = '0'; // Biến để lưu trữ số lượng task

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  

  Future<void> _fetchUserFullName() async {
    _fullName = await userService.getCurrentUserFullName();
    setState(() {}); // cập nhật lại giao diện
  }

  Future<void> _loadTaskCount() async {
    // Lấy số lượng task từ Future và cập nhật trạng thái
    String taskCount = await Provider.of<Task>(context, listen: false).countTaskInProgressMe(currentUserId);
    setState(() {
      _taskCount = taskCount;
      print('taskCount $taskCount');
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserFullName();
    Provider.of<Task>(context, listen: false).fetchTasksInProgressMe(currentUserId);
    Provider.of<Project>(context, listen: false).fetchRecentProjects();
    _loadTaskCount(); // Gọi hàm tải số lượng task
  }

  @override
  Widget build(BuildContext context) {
    String greeting = getGreeting(); // lời chào

    DateTime now = DateTime.now(); // lấy ngày hiện tại
    int currentDay = now.day;
    String currentMonth = DateFormat('MMMM').format(now);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        drawer: _buildDrawer(),
        appBar: CustomAppBar(
          isHome: true,
          title: '$greeting, $_fullName',
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: const CircleAvatar(
                backgroundImage:
                    NetworkImage('https://picsum.photos/200/300?random=1'),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateCard(currentDay, currentMonth),
                const SizedBox(height: 10),
                _buildRecentProjectsSection(Provider.of<Project>(context)),
                _buildMyProgressTasksSection(),
                _buildTaskList(Provider.of<Task>(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tạo Drawer
  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Text(
              _fullName ?? 'Unknown User',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 24,
              ),
            ),
          ),
          _buildDrawerItem(Icons.person, 'Status', () {}),
          _buildDrawerItem(Icons.settings, 'Settings', () {}),
          _buildDrawerItem(Icons.logout, 'Logout', () {
            authService.logOut(context);
          }),
        ],
      ),
    );
  }

  // Tạo mục cho Drawer
  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(color: Colors.blue)),
      onTap: onTap,
    );
  }

  // Tạo Card hiển thị ngày tháng
  Widget _buildDateCard(int currentDay, String currentMonth) {
    return GestureDetector(
      onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const EventCalendarScreen()
            ),
          );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    '$currentDay',
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    currentMonth,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Up next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.event_outlined, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Meeting lunch with James Strobinsty',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.event_outlined, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Dave's birthday party",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tạo phần Recent Projects
  Widget _buildRecentProjectsSection(Project projectProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Projects',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: projectProvider.recentProjects.map((project) {
              return ChildProjectWidget(project: project);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Tạo phần My Progress tasks
  Widget _buildMyProgressTasksSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Progress tasks ($_taskCount)',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'See all',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // Tạo danh sách Task
  Widget _buildTaskList(Task taskProvider) {
    return Column(
      children: taskProvider.tasksInProgressMe.map((task) {
        return TaskWidget(task: task, isFromHome: true);
      }).toList(),
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
