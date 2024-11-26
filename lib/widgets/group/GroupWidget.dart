// ignore_for_file: file_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/channel/channel_model.dart';
import 'package:ruprup/providers/channel_provider.dart';
import 'package:ruprup/screens/group/GroupScreen.dart';

class GroupWidget extends StatelessWidget {
  final Channel channel;

  const GroupWidget({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
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
        context.read<ChannelProvider>().setChannel(channel);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupScreen(channelId: channel.channelId, channelName: channel.channelName),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(
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
              offset: const Offset(0, 3), // Vị trí của bóng (x,y)
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
                  radius: 22,
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundImage: NetworkImage(displayedImages[1]),
                  radius: 22,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
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
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              channel.channelName, // Sử dụng channelName từ đối tượng channel
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
