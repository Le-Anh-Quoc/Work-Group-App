import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/screens/group/AddGroupScreen.dart';
import 'package:ruprup/screens/home/HomeScreen.dart';
import 'package:ruprup/screens/search/SearchScreen.dart';
import 'package:ruprup/screens/project/ProjectScreen.dart';
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
        return const HomeScreen();
      case 1:
        return const SearchScreen();
      case 3:
        return const ProjectScreen();
      case 4:
        return PersonalScreen(userId: currentUserId);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: _screens[_selectedIndex],
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.grey[100],
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.house_outlined),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.search_sharp),
      //       label: 'Search',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.task_alt_outlined),
      //       label: 'Task',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person_2_outlined),
      //       label: 'You',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Colors.blue,
      //   unselectedItemColor: Colors.grey,
      //   selectedIconTheme: const IconThemeData(size: 24),
      //   unselectedIconTheme: const IconThemeData(size: 24),
      //   onTap: _onItemTapped,
      //   //type: BottomNavigationBarType.fixed,
      // ),
      body: Stack(
        children: [
          _buildBody(),
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   child: BottomNavigationBar(
          //     backgroundColor: Colors.grey[50],
          //     items: const <BottomNavigationBarItem>[
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.house_outlined),
          //         label: 'Home',
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.search_sharp),
          //         label: 'Search',
          //       ),
          //       BottomNavigationBarItem(label: '', icon: Icon(null)),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.task_alt_outlined),
          //         label: 'Task',
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.person_2_outlined),
          //         label: 'You',
          //       ),
          //     ],
          //     currentIndex: _selectedIndex,
          //     selectedItemColor: Colors.blue,
          //     unselectedItemColor: Colors.grey,
          //     selectedIconTheme: const IconThemeData(size: 24),
          //     unselectedIconTheme: const IconThemeData(size: 24),
          //     onTap: _onItemTapped,
          //     type: BottomNavigationBarType.fixed,
          //   ),
          // ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.grey[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BottomNavItem(
                    icon: Icons.house_outlined,
                    //label: 'Home',
                    isSelected: _selectedIndex == 0,
                    onTap: () {
                      _onItemTapped(0);
                    },
                  ),
                  BottomNavItem(
                    icon: Icons.search_sharp,
                    //label: 'Search',
                    isSelected: _selectedIndex == 1,
                    onTap: () {
                      _onItemTapped(1);
                    },
                  ),
                  // Mục vô hiệu hóa (không có hành động)
                  Container(
                    width: 30, // Đặt chiều rộng cho mục vô hiệu hóa
                    child: const Icon(
                      null,
                      size: 24,
                      color: Colors.transparent, // Không hiển thị màu sắc
                    ),
                  ),
                  BottomNavItem(
                    icon: Icons.task_alt_outlined,
                    //label: 'Task',
                    isSelected: _selectedIndex == 3,
                    onTap: () {
                      _onItemTapped(3);
                    },
                  ),
                  BottomNavItem(
                    icon: Icons.person_2_outlined,
                    //label: 'You',
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
          Positioned(
            bottom: 30, // Distance from the bottom
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Material(
                  color: Colors.blue,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddGroupScreen(),
                        ),
                      );
                    },
                    child: const SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(Icons.add, size: 30, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
