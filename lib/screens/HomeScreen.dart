import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/screens/AddFriendScreen.dart';
import 'package:ruprup/screens/AddGroupScreen.dart';
import 'package:ruprup/screens/NotificationScreen.dart';
import 'package:ruprup/services/chat_service.dart';
import 'package:ruprup/services/friend_service.dart';
import 'package:ruprup/widgets/chat_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FriendService _friendService = FriendService();
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _friendResults = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendsOfCurrentUser();
  }

  void _fetchFriendsOfCurrentUser() async {
    List<Map<String, dynamic>> results =
        await _friendService.getFriendsOfCurrentUser();
    setState(() {
      _friendResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RupRup'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This is show notification')),
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.add),
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       MaterialPageRoute(builder: (_) => const AddFriendcreen()),
          //     );

          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //           content: Text('This is add friend and create group')),
          //     );
          //   },
          // ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.add), // Icon của nút
            onSelected: (String value) {
              if (value == 'Add Friend') {
                // Điều hướng tới màn hình AddFriendScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AddFriendScreen()),
                );
              } else if (value == 'Create Group') {
                // Điều hướng tới màn hình CreateGroupScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AddGroupScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Add Friend',
                  child: Row(
                    children: [Icon(Icons.add), Text("Add Friend")],
                  ),

                  // )Text('Add Friend'),
                ),
                const PopupMenuItem<String>(
                  value: 'Create Group',
                  child: Row(
                    children: [Icon(Icons.add), Text("Create Group")],
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _friendResults.length,
              itemBuilder: (context, index) {
                String friendUid = _friendResults[index]['uid'];
                String chatId = _chatService.generateChatId(
                  FirebaseAuth.instance.currentUser!.uid,
                  friendUid,
                );

                // Use StreamBuilder to listen for real-time updates
                return StreamBuilder<Map<String, dynamic>>(
                  stream: _chatService.getLastMessageStream(chatId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Error loading message');
                    } else if (!snapshot.hasData) {
                      return const Text('No data');
                    } else {
                      // Lấy dữ liệu từ snapshot
                      String mostRecentMessage =
                          snapshot.data?['lastMessage'] ?? 'No messages yet';
                      String user0 = snapshot.data?['user0'] ?? '';
                      String nameUserChat = _friendResults[index]['fullname'];

                      // Xác định người dùng hiện tại
                      String currentUserId =
                          FirebaseAuth.instance.currentUser!.uid;
                      String displayMessage;

                      if (user0 == currentUserId) {
                        // Nếu user0 là người dùng hiện tại, thêm "You:" vào tin nhắn
                        displayMessage = 'You: $mostRecentMessage';
                      } else {
                        // Nếu user0 không phải người dùng hiện tại, thêm tên của user1 vào tin nhắn
                        displayMessage = mostRecentMessage;
                      }

                      bool isNewMessage = user0 != currentUserId;

                      return ChatTile(
                        uid: friendUid,
                        name: nameUserChat,
                        mostRecentMessage: displayMessage,
                        isNewMessage: isNewMessage,
                        //isNewMessage: isNewMessage,
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
