import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/screens/chat/ChatScreen.dart';
import 'package:ruprup/services/chat_service.dart';
import 'package:ruprup/services/group_service.dart';
import 'package:ruprup/services/user_service.dart';

class ChattingUsersWidget extends StatefulWidget {
  final String chatId;

  const ChattingUsersWidget({
    super.key,
    required this.chatId,
  });

  @override
  _ChattingUsersWidgetState createState() => _ChattingUsersWidgetState();
}

class _ChattingUsersWidgetState extends State<ChattingUsersWidget> {
  final ChatService _chatService = ChatService();
  final GroupService _groupService = GroupService();
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  String? titleNameChat;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _chatService.getLastMessageStream(widget.chatId),
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
       
        final time = snapshot.data!['time'] ?? '??:??'; 


        if (titleNameChat == null) {
          _getChatTitle(userIds).then((title) {
            setState(() {
              titleNameChat = title;
            });
          });
        }

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
                      const CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://picsum.photos/200/300?random=2'),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleNameChat ?? 'Loading....',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 19),
                          ),
                          Text(
                            messagePrefix + lastMessage,
                            style:
                                TextStyle(fontSize: 15, color: Colors.grey[00]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: TextStyle(fontSize: 15, color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 4),
                      // if (4 > 0)
                      //   const CircleAvatar(
                      //     radius: 12,
                      //     backgroundColor: Colors.red,
                      //     child: Text(
                      //       '4',
                      //       style: TextStyle(color: Colors.white, fontSize: 12),
                      //     ),
                      //   ),
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
                builder: (context) =>
                    ChatScreen(chatId: widget.chatId, titleChat: titleNameChat),
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _getChatTitle(List<dynamic> userIds) async {
    if (userIds.length == 2) {
      String otherUserId = userIds.firstWhere((id) => id != currentUserId);
      return await UserService().getFullNameByUid(otherUserId);
    } else {
      final groupData = await _groupService.getGroupByChatId(widget.chatId);
      return groupData?.groupName;
    }
  }
}
