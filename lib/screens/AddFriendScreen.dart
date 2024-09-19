import 'package:flutter/material.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/person_tile.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService =
      UserService(); // Tạo instance của UserService
  List<Map<String, dynamic>> _searchResults = [];

  void _searchUser(String email) async {
    if (email.isEmpty) return;

    List<Map<String, dynamic>> results =
        await _userService.searchUserByEmail(email);

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tìm kiếm người dùng'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Nhập email để tìm kiếm',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchUser(_searchController.text.trim()),
                ),
              ),
            ),
            GestureDetector(
              child: Container(
                child: Text("Tạo nhóm")
              ),
              onTap: () {
                
              }
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  return PersonTile(
                      name: _searchResults[index]['fullname'],
                      targetUserId: _searchResults[index]['uid']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
