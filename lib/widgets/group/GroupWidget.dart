import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ruprup/models/channel_model.dart';
import 'package:ruprup/screens/group/GroupScreen.dart';
import 'package:ruprup/services/channel_service.dart'; // Import dịch vụ nhóm

class GroupWidget extends StatelessWidget {
  final String channelId;

  const GroupWidget({
    Key? key,
    required this.channelId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Channel?>(
      future: ChannelService().getChannel(channelId), // Gọi hàm getGroup đã định nghĩa
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading group'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Group not found'));
        }

        // Lấy thông tin nhóm từ dữ liệu trả về
        final channel = snapshot.data!;

        // Danh sách mẫu các hình ảnh
        final List<String> allMemberImages = [
          'https://randomuser.me/api/portraits/men/1.jpg',
          'https://randomuser.me/api/portraits/men/2.jpg',
          'https://randomuser.me/api/portraits/men/3.jpg',
          'https://randomuser.me/api/portraits/women/1.jpg',
          'https://randomuser.me/api/portraits/women/2.jpg',
          'https://randomuser.me/api/portraits/women/3.jpg',
        ];

        final random = Random();
        final shuffledImages = List<String>.from(allMemberImages)..shuffle(random);
        final displayedImages = shuffledImages.take(4).toList(); // Lấy tối đa 4 ảnh ngẫu nhiên

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GroupScreen(groupId: channel.channelId)),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: BoxConstraints(
              minHeight: 150, // Đặt chiều cao tối thiểu
            ),
            decoration: BoxDecoration(
              color: Colors.white, // Đặt màu nền là trắng
              borderRadius: BorderRadius.circular(12.0), // Bo tròn các góc
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // Màu sắc bóng
                  spreadRadius: 1, // Độ lan tỏa của bóng
                  blurRadius: 5, // Độ mờ của bóng
                  offset: Offset(0, 3), // Vị trí của bóng (x,y)
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                        backgroundImage: NetworkImage(displayedImages[0]),
                        radius: 22),
                    const SizedBox(width: 8), // Khoảng cách giữa hai hình
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(displayedImages[1]), // Hình thứ hai
                      radius: 22,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2)),
                      child: Center(
                        child: Text(
                          '+${displayedImages.length - 3}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16), // Khoảng cách giữa hình đại diện và tiêu đề
                Text(
                  channel.channelName, // Sử dụng groupName từ dữ liệu nhóm
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
