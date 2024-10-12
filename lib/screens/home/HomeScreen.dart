import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/screens/chat/ListChatScreen.dart';
import 'package:ruprup/screens/group/ListGroupScreen.dart';
import 'package:ruprup/screens/notification/NotificationScreen.dart';
import 'package:ruprup/services/auth_service.dart';
import 'package:ruprup/services/chat_service.dart';
import 'package:ruprup/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final ChatService chatService = ChatService();
  final UserService userService = UserService();
  final AuthService authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> chatResults = [];
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //final AuthService authService = AuthService();
  //final UserService userService = UserService();

  String? _fullName;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    //_fetchChats();
    _fetchUserFullName();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    //_searchController.removeListener(_onSearchChanged);
    //_searchController.dispose();
    _tabController.dispose(); // Dispose the TabController
    super.dispose();
  }

  Future<void> _fetchUserFullName() async {
    _fullName = await userService.getCurrentUserFullName();
    setState(() {});
  }

  //List Chat
  // void _fetchChats() async {
  //   try {
  //     List<Map<String, dynamic>> results =
  //         await chatService.getChatsOfCurrentUser(currentUserId);
  //     setState(() {
  //       chatResults = results;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print('Error fetching chats: $e');
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  // void _onSearchChanged() async {
  //   try {
  //     String keyword = _searchController.text.toLowerCase();
  //     List<Map<String, dynamic>> results =
  //         await userService.searchUsers(keyword);
  //     setState(() {
  //       chatResults = results;
  //     });
  //   } catch (e) {
  //     print("Error search: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: const CircleAvatar(
                  backgroundImage:
                      NetworkImage('https://picsum.photos/200/300?random=1')),
            ),
          ),
          title: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Chat'),
              Tab(text: 'Group'),
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            labelStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            dividerColor: Colors.transparent,
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[50],
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: Colors.black, size: 30),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 64.0),
          child: TabBarView(
            controller: _tabController,
            children: const [
              ListChatScreen(),
              ListGroupScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
