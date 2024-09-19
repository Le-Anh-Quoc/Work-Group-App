import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/services/notification_service.dart';
import 'package:ruprup/services/user_service.dart';

class PersonTile extends StatelessWidget {
  final String targetUserId;
  final String name;
  const PersonTile({super.key, required this.name, required this.targetUserId});

  @override
  Widget build(BuildContext context) {
    UserService user = UserService();
    NotificationService notification = NotificationService();
    return ListTile(
      leading: const CircleAvatar(
        backgroundImage:
            NetworkImage('https://picsum.photos/200/300?random=${1}'),
      ),
      title: Text(name),
      trailing: GestureDetector(
        child: const Icon(Icons.person_add_alt_1_sharp),
        onTap: () async {
          // Lấy uid của người dùng hiện tại
          String currentUserId = FirebaseAuth.instance.currentUser!.uid;

          try {
            // Gửi lời mời kết bạn
            bool success =
                await user.sendFriendRequest(currentUserId, targetUserId);

            if (success) {
              // Tạo thông báo cho người dùng mục tiêu
              await notification.sendFriendRequestNotification(
                currentUserId,
                targetUserId,
              );
            } else {
              print('notifications not create');
            }
          } catch (e) {
            print('Error: $e');
          }
          // // Gửi lời mời kết bạn
          // await user.sendFriendRequest(currentUserId, targetUserId);
        },
      ),
    );
  }
}

class ChooseMemberGroupTile extends StatefulWidget {
  final String name;

  const ChooseMemberGroupTile({super.key, required this.name});

  @override
  _ChooseMemberGroupTileState createState() => _ChooseMemberGroupTileState();
}

class _ChooseMemberGroupTileState extends State<ChooseMemberGroupTile> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundImage:
            NetworkImage('https://picsum.photos/200/300?random=${1}'),
      ),
      title: Text(widget.name),
      trailing: GestureDetector(
        child: isActive ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank),
      ),
      onTap: () {
        setState(() {
            isActive = !isActive; // Thay đổi trạng thái của isActive
          });
      },
    );
  }
}

