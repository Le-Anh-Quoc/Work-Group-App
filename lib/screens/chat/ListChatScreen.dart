import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruprup/services/auth_service.dart';
import 'package:ruprup/services/chat_service.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/chat/ChattingUsers.dart';

class ListChatScreen extends StatefulWidget {
  const ListChatScreen({super.key});

  @override
  State<ListChatScreen> createState() => _ListChatScreenState();
}

class _ListChatScreenState extends State<ListChatScreen>
    with AutomaticKeepAliveClientMixin<ListChatScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final ChatService chatService = ChatService();
  final UserService userService = UserService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    super.build(context); // Cần thiết cho AutomaticKeepAliveClientMixin hoạt động
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getChatsOfCurrentUser(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final chatResults = snapshot.data ?? [];

          // Sắp xếp các chat theo thời gian tin nhắn
          chatResults.sort((a, b) {
            Timestamp? aTime = a['timestamp'] as Timestamp?;
            Timestamp? bTime = b['timestamp'] as Timestamp?;
            return bTime?.compareTo(aTime ?? Timestamp(0, 0)) ?? 0;
          });

          return chatResults.isEmpty
              ? const Center(child: Text("Không có cuộc trò chuyện nào"))
              : ListView.builder(
                  itemCount: chatResults.length,
                  itemBuilder: (context, index) {
                    String chatId = chatResults[index]['chatId'];
                    return ChattingUsersWidget(chatId: chatId);
                  },
                );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
