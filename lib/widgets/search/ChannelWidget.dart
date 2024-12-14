// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/channel/channel_model.dart';
import 'package:ruprup/providers/channel_provider.dart';
import 'package:ruprup/screens/group/GroupScreen.dart';

class ChannelWidget extends StatelessWidget {
  final Channel channel;

  const ChannelWidget({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Provider.of<ChannelProvider>(context, listen: false).setChannel(channel);
          Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GroupScreen(),
          ),
        );
        },
        child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            elevation: 6, // Tăng độ cao để tạo bóng lớn hơn
            shadowColor: Colors.grey.withOpacity(0.4), // Màu bóng
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(children: [
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
                    child: Text(
                      channel.channelName, // Thay thế bằng tên người dùng thực tế
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0, // Tăng kích thước chữ cho tên
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ]))));
  }
}
