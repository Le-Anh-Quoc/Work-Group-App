// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/screens/chat/ListChatScreen.dart';
import 'package:ruprup/screens/group/ListGroupScreen.dart';
import 'package:ruprup/screens/home/HomeScreen.dart';
import 'package:ruprup/screens/project/ListProjectScreen.dart';
import 'package:ruprup/screens/individual/MeScreen.dart';
import 'package:ruprup/widgets/bottomNav/BottomNav.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  const MainScreen({super.key, required this.selectedIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // Khởi tạo _selectedIndex bằng giá trị truyền vào
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const ListChatScreen();
      case 1:
        return const ListGroupScreen();
      case 2:
        return const HomeScreen();
      case 3:
        return const ListProjectScreen();
      case 4:
        return PersonalScreen(userId: currentUserId);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBody(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BottomNavItem(
                    icon: Icons.chat_outlined,
                    label: 'Chat',
                    isSelected: _selectedIndex == 0,
                    onTap: () {
                      _onItemTapped(0);
                    },
                  ),
                  BottomNavItem(
                    icon: Icons.groups_outlined,
                    label: 'Group',
                    isSelected: _selectedIndex == 1,
                    onTap: () {
                      _onItemTapped(1);
                    },
                  ),
                  BottomNavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isSelected: _selectedIndex == 2,
                    onTap: () {
                      _onItemTapped(2);
                    },
                  ),
                  BottomNavItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Project',
                    isSelected: _selectedIndex == 3,
                    onTap: () {
                      _onItemTapped(3);
                    },
                  ),
                  BottomNavItem(
                    icon: Icons.person_outline,
                    label: 'Me',
                    isSelected: _selectedIndex == 4,
                    onTap: () {
                      _onItemTapped(4);
                    },
                  ),
                ],
              ),
            ),
          ),

          //Centering the floating button with adequate spacing
          // Positioned(
          //   bottom: 30, // Distance from the bottom
          //   left: MediaQuery.of(context).size.width / 2 - 30,
          //   child: Container(
          //     width: 60,
          //     height: 60,
          //     decoration: const BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Colors.blue,
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black26,
          //           blurRadius: 8.0,
          //           offset: Offset(0, 4),
          //         ),
          //       ],
          //     ),
          //     child: ClipOval(
          //       child: Material(
          //         color: Colors.blue,
          //         child: InkWell(
          //           onTap: () {
          //             Navigator.of(context).push(
          //               MaterialPageRoute(
          //                 builder: (_) => const AddGroupScreen(),
          //               ),
          //             );
          //           },
          //           child: const SizedBox(
          //             width: 60,
          //             height: 60,
          //             child: Icon(Icons.add, size: 30, color: Colors.white),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
