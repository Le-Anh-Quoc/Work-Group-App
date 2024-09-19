import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/screens/ChatScreen.dart';
import 'package:ruprup/services/chat_service.dart';

class ChatTile extends StatelessWidget {
  final String uid;
  final String name;
  final String mostRecentMessage;
  final bool isNewMessage;

  const ChatTile(
      {super.key,
      required this.name,
      required this.mostRecentMessage,
      required this.uid, required this.isNewMessage});

  @override
  Widget build(BuildContext context) {
    ChatService chatService = ChatService();
    return ListTile(
        leading: const CircleAvatar(
          backgroundImage:
              NetworkImage('https://picsum.photos/200/300?random=${1}'),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isNewMessage
                ? FontWeight.bold
                : FontWeight.normal, // Bold if new message
          ),
        ),
        subtitle: Text(
          mostRecentMessage,
          style: TextStyle(
            fontWeight: isNewMessage
                ? FontWeight.bold
                : FontWeight.normal, // Bold if new message
          ),
        ),
        //trailing: GestureDetector(child: const Icon(Icons.people_rounded))
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatScreen(
                    chatId: chatService.generateChatId(
                        FirebaseAuth.instance.currentUser!.uid, uid),
                    uid: uid,
                    userName: name,
                  )));
        });
  }
}
