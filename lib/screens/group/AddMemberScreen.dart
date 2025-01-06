import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/providers/channel_provider.dart';
import 'package:ruprup/services/channel_service.dart';
import 'package:ruprup/services/friend_service.dart';
import 'package:ruprup/services/project_service.dart';
import 'package:ruprup/services/roomchat_service.dart';
import 'package:ruprup/widgets/group/NewMemberWidget.dart';

class AddMemberScreen extends StatefulWidget {
  final List<String> members;
  const AddMemberScreen({super.key, required this.members});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  List<String> selectedUsers = []; // Danh sách người dùng được chọn hiện tại
  List<String> initialSelectedUsers =
      []; // Danh sách người dùng được chọn ban đầu
  final FriendService _friendService = FriendService();
  List<Map<String, dynamic>> _friendResults = [];

  void _fetchFriendsOfCurrentUser() async {
    List<Map<String, dynamic>> results =
        await _friendService.getFriendsOfCurrentUser();
    setState(() {
      _friendResults = results;
    });
  }

  void _toggleSelection(String userId) {
    setState(() {
      if (selectedUsers.contains(userId)) {
        selectedUsers.remove(userId); // Bỏ chọn người dùng
      } else {
        selectedUsers.add(userId); // Chọn người dùng
      }
    });
    print(selectedUsers);
  }

  @override
  void initState() {
    super.initState();
    _fetchFriendsOfCurrentUser();
    selectedUsers = List.from(widget.members); // Sao chép danh sách ban đầu
    initialSelectedUsers = List.from(widget.members); // Lưu trạng thái ban đầu
  }

  void _resetSelections() {
    setState(() {
      selectedUsers =
          List.from(initialSelectedUsers); // Khôi phục trạng thái ban đầu
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentChannel = Provider.of<ChannelProvider>(context, listen: false).selectedChannel;
    print('1${currentChannel!.projectIds}');
    print('2${currentChannel.adminId}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            _resetSelections(); // Khôi phục trạng thái
            Navigator.pop(context); // Quay lại màn hình trước đó
          },
          icon: const Icon(Icons.arrow_back_ios, size: 25, color: Colors.blue),
        ),
        title: Column(
          children: [
            const Center(
              child: Text(
                "Update member",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            Text(
              "Numbers of member: ${selectedUsers.length - 1}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
  onPressed: () async {
    // Tìm sự khác biệt giữa hai danh sách
    final membersToAdd = selectedUsers.where((user) => !initialSelectedUsers.contains(user)).toList();
    final membersToRemove = initialSelectedUsers.where((user) => !selectedUsers.contains(user)).toList();

    if (membersToAdd.isNotEmpty || membersToRemove.isNotEmpty) {
      // Hiển thị hộp thoại xác nhận
      final shouldUpdate = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Danh sách thành viên đã thay đổi"),
            content: const Text("Bạn có muốn cập nhật danh sách không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Không cập nhật
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Cập nhật
                child: const Text("Cập nhật"),
              ),
            ],
          );
        },
      );

      if (shouldUpdate == true) {
        try {
          // Cập nhật Firestore cho Channel
          await ChannelService().updateChannelMembers(currentChannel!.channelId, membersToAdd, membersToRemove);

          // Cập nhật Firestore cho Project
          await ProjectService().updateMultipleProjectsMembers(currentChannel.projectIds, membersToAdd, membersToRemove);

          // Cập nhật Firestore cho Chat
          await RoomChatService().updateChatMembers(currentChannel.groupChatId, membersToAdd, membersToRemove);

          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Danh sách thành viên đã được cập nhật thành công.")),
          );

          // Quay lại màn hình trước
          Navigator.of(context).pop(selectedUsers);
        } catch (e) {
          // Hiển thị thông báo lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: ${e.toString()}")),
          );
        }
      }
    } else {
      // Không có thay đổi, quay lại bình thường
      Navigator.of(context).pop();
    }
  },
  icon: const Icon(Icons.check, size: 25, color: Colors.blue),
),

        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Expanded(
            child: ListView.builder(
              itemCount: _friendResults.length,
              itemBuilder: (context, index) {
                String nameUserChat = _friendResults[index]['fullname'];
                String idUserChat = _friendResults[index]['uid'];
                bool isSelected = selectedUsers.contains(idUserChat);
                return NewMemberWidget(
                  name: nameUserChat,
                  isSelected: isSelected,
                  onSelected: () {
                    _toggleSelection(idUserChat);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
