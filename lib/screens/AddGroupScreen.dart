import 'package:flutter/material.dart';
import 'package:ruprup/services/friend_service.dart';
import 'package:ruprup/widgets/person_tile.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  int countMember = 0;

  final FriendService _friendService = FriendService();
  List<Map<String, dynamic>> _friendResults = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendsOfCurrentUser();
  }

  void _fetchFriendsOfCurrentUser() async {
    List<Map<String, dynamic>> results =
        await _friendService.getFriendsOfCurrentUser();
    setState(() {
      _friendResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Create Group"),
          actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
        ),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("Số lượng thành viên: "),
                    Text("$countMember"),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black,
                    ),
                    SizedBox(
                        width:
                            10), // Khoảng cách giữa CircleAvatar và TextField
                    Expanded(
                      // Sử dụng Expanded để TextField chiếm phần không gian còn lại
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Đặt tên nhóm'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  //controller:,
                  decoration: InputDecoration(
                    labelText: 'Nhập email để tìm kiếm',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => {},
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: _friendResults.length,
                        itemBuilder: (context, index) {
                          String nameUserChat =
                              _friendResults[index]['fullname'];
                          return ChooseMemberGroupTile(
                            name: nameUserChat,
                          );
                        }))
              ],
            )));
  }
}
