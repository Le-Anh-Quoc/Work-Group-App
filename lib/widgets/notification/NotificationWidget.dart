// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:ruprup/models/notification_model.dart';
import 'package:ruprup/widgets/notification/ButtonInvite.dart';

class NotificationWidget extends StatelessWidget {
  final String body; // dùng để hiển thị nội dung thông báo
  final String notificationTypeString; // Biến này là để nhận giá trị từ Firebase
  late final NotificationType notificationType;
  NotificationWidget({super.key,required this.body, required this.notificationTypeString}) {
    notificationType = NotificationTypeExtension.fromString(notificationTypeString);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Thực hiện hành động khi chạm vào thông báo
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(notificationType),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nội dung thông báo
                    Text(
                      body,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ignore: unrelated_type_equality_checks
                    if (notificationType == NotificationType.friendInvite)
                      const Row(
                        children: [
                          ButtonInvite(typeButton: true), // Nút Chấp nhận
                          SizedBox(width: 10),
                          ButtonInvite(typeButton: false), // Nút Từ chối
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Thời gian thông báo
                    const Text(
                      '16 minutes ago',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildIcon(NotificationType type) {
  switch (type) {
    case NotificationType.friendInvite:
      return const SizedBox(
        width: 50,
        height: 50,
        child: CircleAvatar(
          backgroundImage:
              NetworkImage('https://picsum.photos/200/300?random=2'),
          //radius: 25,
        ),
      );
      case NotificationType.friend:
      return const SizedBox(
        width: 50,
        height: 50,
        child: CircleAvatar(
          backgroundImage:
              NetworkImage('https://picsum.photos/200/300?random=2'),
          //radius: 25,
        ),
      );
    case NotificationType.group:
      return SizedBox(
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.lightBlue.shade100, // Nền xanh nhạt
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.group_outlined, // Icon cho nhóm
            color: Colors.blue,
            size: 25,
          ),
        ),
      );
    case NotificationType.task:
      return SizedBox(
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.lightGreen.shade100, // Nền xanh nhạt
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.task_outlined, // Icon cho nhóm
            color: Colors.green,
            size: 25,
          ),
        ),
      );
    case NotificationType.project:
      return SizedBox(
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange.shade100, // Nền xanh nhạt
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.check_circle_outline, // Icon cho project
            color: Colors.orange,
            size: 25,
          ),
        ),
      );
    default:
      return Container(); // Trường hợp không xác định
  }
}
