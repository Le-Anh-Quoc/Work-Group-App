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

class ChooseMemberGroupTile extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onSelected;

  const ChooseMemberGroupTile({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(8),
      leading: const CircleAvatar(
        radius: 22,
        backgroundImage:
            NetworkImage('https://picsum.photos/200/300?random=${1}'),
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected
              ? FontWeight.bold
              : FontWeight.normal, // In đậm khi được chọn
        ),
      ),
      trailing: GestureDetector(
        child: isSelected
            ? const Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 28,
              )
            : const Icon(
                Icons.circle_outlined,
                color: Colors.blue,
                size: 28,
              ),
      ),
      tileColor: isSelected
          ? Colors.grey.withOpacity(0.1)
          : Colors.transparent, // Nền hơi ngả màu khi được chọn
      onTap: onSelected, // Kích hoạt khi nhấn vào toàn bộ ListTile
    );
  }
}
