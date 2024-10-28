// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruprup/models/room_model.dart';
import 'package:ruprup/screens/search/SearchScreen.dart';
import 'package:ruprup/services/auth_service.dart';
import 'package:ruprup/services/roomchat_service.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/bottomNav/CustomAppbar.dart';
import 'package:ruprup/widgets/chat/ChattingUsers.dart';

class ListChatScreen extends StatefulWidget {
  const ListChatScreen({super.key});

  @override
  State<ListChatScreen> createState() => _ListChatScreenState();
}

class _ListChatScreenState extends State<ListChatScreen>
    with AutomaticKeepAliveClientMixin<ListChatScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  //final ChatService chatService = ChatService();
  final RoomChatService roomChatService = RoomChatService();
  final UserService userService = UserService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Cần thiết cho AutomaticKeepAliveClientMixin hoạt động
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Chats',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[50],
            ),
            child: IconButton(
              icon: const Icon(Icons.search_rounded,
                  color: Colors.black, size: 30),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  ),
                );
              },
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<List<RoomChat>>(
        stream: roomChatService.getChatsOfCurrentUser(currentUserId),
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
            int aTime = a.createAt;
            int bTime = b.createAt;
            return (bTime).compareTo(aTime);
          });

          return chatResults.isEmpty
              ? const Center(child: Text("Không có cuộc trò chuyện nào"))
              : ListView.builder(
                  itemCount: chatResults.length,
                  itemBuilder: (context, index) {
                    RoomChat roomChat = chatResults[index];
                    return ChattingUsersWidget(roomChat: roomChat);
                  },
                );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
