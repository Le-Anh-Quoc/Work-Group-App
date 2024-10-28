// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/models/room_model.dart';
import 'package:ruprup/screens/chat/ChatScreen.dart';
import 'package:ruprup/services/chat_service.dart';

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

  @override
  Widget build(BuildContext context) {
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

        int createAtTimestamp = snapshot.data!['createAt'];
        DateTime createAt =
            DateTime.fromMillisecondsSinceEpoch(createAtTimestamp);

        // Định dạng thời gian
        String formattedTime = DateFormat('hh:mm a').format(createAt);

        return GestureDetector(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage('${widget.roomChat.imageUrl}'),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameRoom,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width *
                                    0.5), // Giới hạn chiều rộng
                            child: Text(
                              (lastMessage
                                      .startsWith('https://firebasestorage'))
                                  ? 'You sent an image'
                                  : (lastMessage == '')
                                      ? 'Bạn vừa tạo nhóm thành công'
                                      : messagePrefix + lastMessage,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[600]),
                              maxLines: 1, // Giới hạn số dòng hiển thị
                              overflow: TextOverflow
                                  .ellipsis, // Hiển thị "..." khi vượt quá độ dài
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formattedTime,
                        style: TextStyle(fontSize: 15, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 4),
                      if (4 > 0)
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Text(
                            '4',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
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
