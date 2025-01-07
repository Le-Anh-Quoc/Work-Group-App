// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/room_model.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/screens/chat/ChatScreen.dart';
import 'package:ruprup/services/chat_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';

class ChattingUsersWidget extends StatefulWidget {
  final RoomChat roomChat;

  const ChattingUsersWidget({
    super.key,
    required this.roomChat,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ChattingUsersWidgetState createState() => _ChattingUsersWidgetState();
}

class _ChattingUsersWidgetState extends State<ChattingUsersWidget> {
  final ChatService _chatService = ChatService();
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Color getColorFromCreatedAt(DateTime createdAt) {
    // Danh sách 7 màu sắc cầu vồng
    final List<Color> rainbowColors = [
      Colors.red.shade300,
      Colors.orange.shade300,
      Colors.yellow.shade700,
      Colors.green.shade300,
      Colors.blue.shade300,
      Colors.indigo.shade300,
      Colors.purple.shade300,
    ];

    // Chuyển `createdAt` thành chỉ số trong khoảng từ 0 đến 6
    final index = createdAt.millisecondsSinceEpoch % rainbowColors.length;
    return rainbowColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    return StreamBuilder<Map<String, dynamic>>(
      stream: _chatService.getLastMessageStream(widget.roomChat.idRoom),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const ListTile(
            title: Text("No recent messages"),
          );
        }

        String lastMessage = snapshot.data!['lastMessage'] ?? '';
        List<dynamic> userIds = snapshot.data!['userIds'] ?? [];
        String senderId = userIds.isNotEmpty ? userIds[0] : '';
        String messagePrefix = (senderId == currentUserId) ? "You: " : "";

        
        String nameRoom = snapshot.data!['nameRoom'] ?? '';
        String nameRoomDirect = nameRoom;
        List<String> names = nameRoom.split('_');
        if (names.length == 2) {
          String firstName = names[0];
          String secondName = names[1];

          if (firstName == currentUser!.fullname) {
            nameRoomDirect = secondName;
          } else {
            nameRoomDirect  = firstName;
          }
        } else {
          print('Invalid nameRoom format.');
        }

        Timestamp lassTimeMessage = snapshot.data!['timestamp'];

        DateTime createAt = lassTimeMessage.toDate();
        //lay time hien tai
        DateTime now = DateTime.now();
        // định dạng là hh:mm nếu tin nhắn trong ngày nếu ngày trước thì định dạng dd:mm

        String formattedTime;
        if (createAt.year == now.year &&
            createAt.month == now.month &&
            createAt.day == now.day) {
          // Nếu cùng ngày, định dạng hh:mm
          formattedTime = DateFormat('hh:mm a').format(createAt);
        } else {
          // Nếu khác ngày, định dạng MM/dd
          formattedTime = DateFormat('dd/MM').format(createAt);
        }

        //hien dang hien thi thoi gian tao phong
        // int createAtTimestamp = snapshot.data!['createAt'];
        //  DateTime createAt =
        //      DateTime.fromMillisecondsSinceEpoch(createAtTimestamp);

        //  String formattedTime = DateFormat('hh:mm a').format(createAt);
        return GestureDetector(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey.withOpacity(0.2),
              //     spreadRadius: 5,
              //     blurRadius: 5,
              //     offset: const Offset(0, 3),
              //   ),
              // ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Avatar hoặc biểu tượng nhóm
                  widget.roomChat.type == 'group' ?
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: widget.roomChat.imageUrl == null
                        ? Colors.blue
                        : Colors.transparent,
                    backgroundImage: widget.roomChat.imageUrl != null
                        ? NetworkImage(widget.roomChat.imageUrl!)
                        : null,
                    child: widget.roomChat.imageUrl == null
                        ? const Icon(Icons.groups,
                            color: Colors.white, size: 30)
                        : null,
                  ) : PersonalInitialsAvatar(name: nameRoomDirect, size: 50),
                  const SizedBox(width: 16),
                  // Thông tin chính
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                nameRoomDirect,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (lastMessage.startsWith('https://firebasestorage'))
                              ? 'Sent an image'
                              : (lastMessage == '')
                                  ? 'Let\'s chat'
                                  : lastMessage,
                          style:
                              const TextStyle(fontSize: 15, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(roomChat: widget.roomChat),
              ),
            );
          },
        );
      },
    );
  }
}
