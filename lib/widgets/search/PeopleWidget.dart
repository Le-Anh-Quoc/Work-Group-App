// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/services/notification_service.dart';
import 'package:ruprup/services/user_service.dart';

class PeopleWidget extends StatelessWidget {
  final UserModel people;
  const PeopleWidget({super.key, required this.people});

  @override
  Widget build(BuildContext context) {
    UserService user = UserService();
    NotificationService notification = NotificationService();

    return GestureDetector(
      // onTap: () {
      //   Navigator.of(context).push(
      //                   MaterialPageRoute(
      //                     builder: (_) => PersonalScreen(userId: targetUserId),
      //                   ),
      //                 );
      // },
      child: Card(
        color: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        elevation: 6, // Tăng độ cao để tạo bóng lớn hơn
        shadowColor: Colors.grey.withOpacity(0.4), // Màu bóng
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar hình tròn với hiệu ứng viền
              CircleAvatar(
                radius: 30, // Tăng kích thước avatar
                backgroundColor: Colors.grey.shade300,
                backgroundImage: const NetworkImage(
                    'https://picsum.photos/200/300?random=1'),
              ),

              const SizedBox(width: 16.0),

              // Thông tin người dùng
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      people.fullname, // Thay thế bằng tên người dùng thực tế
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0, // Tăng kích thước chữ cho tên
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      people.email, // Thay thế bằng email thực tế
                      style: TextStyle(
                        fontSize: 15.0, // Tăng kích thước chữ cho email
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Nút thêm bạn bè hiện đại hơn
              // GestureDetector(
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              //     decoration: BoxDecoration(
              //       color: Colors.blueAccent, // Đổi sang màu xanh tươi sáng hơn
              //       borderRadius: BorderRadius.circular(30.0), // Tạo nút bo tròn hơn
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.blueAccent.withOpacity(0.4),
              //           spreadRadius: 2,
              //           blurRadius: 5,
              //           offset: const Offset(0, 3), // Hiệu ứng bóng cho nút
              //         ),
              //       ],
              //     ),
              //     child: const Icon(
              //       Icons.person_add_alt_1_sharp,
              //       color: Colors.white,
              //       size: 24, // Tăng kích thước biểu tượng
              //     ),
              //   ),
              //   onTap: () async {
              //     // Lấy uid của người dùng hiện tại
              //     String currentUserId = FirebaseAuth.instance.currentUser!.uid;

              //     try {
              //       // Gửi lời mời kết bạn
              //       bool success = await user.sendFriendRequest(currentUserId, targetUserId);

              //       if (success) {
              //         // Tạo thông báo cho người dùng mục tiêu
              //         await notification.sendFriendRequestNotification(
              //           currentUserId,
              //           targetUserId,
              //         );
              //       } else {
              //         // ignore: avoid_print
              //         print('notifications not created');
              //       }
              //     } catch (e) {
              //       // ignore: avoid_print
              //       print('Error: $e');
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
