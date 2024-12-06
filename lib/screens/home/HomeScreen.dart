// ignore_for_file: file_names, avoid_print, prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/channel/channel_model.dart';
import 'package:ruprup/models/project/task_model.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/providers/channel_provider.dart';
import 'package:ruprup/providers/meeting_provider.dart';
import 'package:ruprup/providers/project_provider.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/screens/group/EventCalendarScreen.dart';
import 'package:ruprup/services/auth_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';
import 'package:ruprup/widgets/bottomNav/CustomAppbar.dart';
import 'package:ruprup/widgets/project/ChildProjectWidget.dart';
import 'package:ruprup/widgets/task/FastTaskWidget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final AuthService authService = AuthService();
  String _taskCount = '0'; // Biến để lưu trữ số lượng task

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> channelsCurrentUser = [];

  String _selectedProjectId = "All";

  Future<void> _loadTaskCount() async {
    // Lấy số lượng task từ Future và cập nhật trạng thái
    String taskCount = await Provider.of<Task>(context, listen: false)
        .countTaskInProgressMe(currentUserId, _selectedProjectId);
    setState(() {
      _taskCount = taskCount;
      print('taskCount $taskCount');
    });
  }

  Future<void> _loadChannelCurrentUser() async {
    // List<Map<String, String>> groupList =
    //     await Provider.of<UserModel>(context, listen: false)
    //         .getListGroupForCurrentUser(currentUserId);

    List<Channel> channelList =
        Provider.of<ChannelProvider>(context, listen: false)
            .listChannelPersonal;

    // Tạo danh sách channels chứa các giá trị id từ groupList
    channelsCurrentUser =
        channelList.map((channel) => channel.channelId).toList();

    // Nếu cần lọc bỏ các giá trị rỗng
    channelsCurrentUser.removeWhere((id) => id.isEmpty);

    Provider.of<MeetingProvider>(context, listen: false)
        .fetchUpcomingMeetings(channelsCurrentUser);
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

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (mounted) {
      await Future.wait([
        Provider.of<ProjectProvider>(context, listen: false).fetchRecentProjects(),
        Provider.of<ProjectProvider>(context, listen: false).fetchProjects(),
        Provider.of<Task>(context, listen: false)
            .fetchTasksInProgressMe(currentUserId, _selectedProjectId),
        Provider.of<ChannelProvider>(context, listen: false)
            .fetchChannelsPersonal(currentUserId)
      ]);
      _loadTaskCount();
      _loadChannelCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    String greeting = getGreeting(); // lời chào
    final currentUser = Provider.of<UserProvider>(context).currentUser;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        drawer: _buildDrawer(currentUser!),
        appBar: CustomAppBar(
          isHome: true,
          title: '$greeting, ${currentUser.fullname}',
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: PersonalInitialsAvatar(
                    name: currentUser.fullname, size: 40)),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateCard(),
                const SizedBox(height: 15),
                _buildRecentProjectsSection(),
                const SizedBox(height: 10),
                _buildMyProgressTasksSection(),
                _buildTaskList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tạo Drawer
  Drawer _buildDrawer(UserModel currentUser) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Text(
              currentUser.fullname,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 24,
              ),
            ),
          ),
          //_buildDrawerItem(Icons.person, 'Status', () {}),
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
  Widget _buildDateCard() {
    final meetingProvider = Provider.of<MeetingProvider>(context);

    DateTime now = DateTime.now(); // lấy ngày hiện tại
    int currentDay = now.day;
    String currentMonth = DateFormat('MMMM').format(now);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventCalendarScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
          //border: Border.all(width: 0.5, color: Colors.blue)
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Up next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: meetingProvider.upcomingMeetings.isNotEmpty
                          ? meetingProvider.upcomingMeetings.map((meeting) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_outlined,
                                        color: Colors.black, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        meeting.meetingTitle,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList()
                          : [
                              const SizedBox(
                                  height: 10), // Khoảng cách bên trên
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Center(
                                    child: Icon(Icons.event_busy,
                                        color: Colors.grey, size: 35),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No upcoming meetings',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                    )
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
  Widget _buildRecentProjectsSection() {
    final projectProvider = Provider.of<ProjectProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent projects',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        projectProvider.recentProjects.isEmpty
            ? Text("You don't have any project")
            : SingleChildScrollView(
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
    final projectProvider = Provider.of<ProjectProvider>(context);

    // Danh sách dự án kèm tùy chọn mặc định "All"
    final projectList = [
      {'projectId': 'All', 'projectName': 'All projects'}, // Giá trị mặc định
      ...projectProvider.projects.map((project) => {
            'projectId': project.projectId,
            'projectName': project.projectName,
          }),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Tasks ($_taskCount)', // Hiển thị số lượng nhiệm vụ
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // Màu nền dropdown
            borderRadius: BorderRadius.circular(16.0), // Bo tròn dropdown
            // border: Border.all(
            //   color: Colors.grey.shade300, // Đường viền của dropdown
            //   //width: 1.0,
            // ),
          ),
          child: DropdownButton<String>(
            value: _selectedProjectId, // Giá trị đã chọn
            alignment: Alignment.centerRight,
            onChanged: (String? newValue) {
              setState(() {
                _selectedProjectId = newValue!;
                Provider.of<Task>(context, listen: false)
                    .fetchTasksInProgressMe(currentUserId, _selectedProjectId);
                _loadTaskCount();
              });
            },
            dropdownColor: Colors.white, // Nền của dropdown
            underline: const SizedBox(), // Loại bỏ đường gạch chân
            borderRadius: BorderRadius.circular(16.0),
            items: projectList.map<DropdownMenuItem<String>>((project) {
              return DropdownMenuItem<String>(
                value: project['projectId'], // Giá trị của mỗi tùy chọn
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Nền trong suốt
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (project['projectName'] != 'All projects')
                        const Icon(
                          Icons.dashboard_outlined,
                          color: Colors.blueAccent,
                        ),
                      const SizedBox(width: 8.0),
                      Text(
                        project['projectName']!,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  // Tạo danh sách Task
  Widget _buildTaskList() {
    final taskProvider = Provider.of<Task>(context);
    if (taskProvider.tasksInProgressMe.isEmpty) {
      return const Center(
        child: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            Text('Currently you don\'t have any work in this project'),
          ],
        ),
      );
    } else {
      return Column(
        children: taskProvider.tasksInProgressMe.map((task) {
          return FastTaskWidget(task: task, isFromHome: true);
        }).toList(),
      );
    }
  }
}
