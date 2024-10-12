import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ruprup/services/chat_service.dart';
import 'package:ruprup/services/user_service.dart';
import '../../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String? titleChat;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.titleChat,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  late final types.User _currentUser;
  final List<types.Message> _messages = [];
  Set<String> _recipientIds = {};
  String _recipientName = '';

  @override
  void initState() {
    super.initState();

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _currentUser = types.User(id: currentUserId);

    print(widget.chatId);
    _fetchRecipientDetails();
    _fetchMessages();
  }

  Future<void> _fetchRecipientDetails() async {
    try {
      final chatData = await _chatService.getChatDetails(widget.chatId);
      final users = chatData['users'] as List<Map<String, dynamic>>;

      // Lấy tất cả ID người dùng trừ người dùng hiện tại
      _recipientIds = users
          .map((user) => user['id'] as String)
          .where((id) => id != _currentUser.id)
          .toSet();
      print('2');
      print(_recipientIds);
      // if (_recipientIds.length == 1) {
      //   // Nếu là chat 1vs1, lấy tên của người còn lại
      //   final fullName = await _userService.getFullNameByUid(_recipientIds.first);
      //   setState(() {
      //     _recipientName = fullName;
      //   });
      // } else {
      //   final groupName = chatData['groupName'];
      //   _recipientName = groupName;
      // }
    } catch (e) {
      print('Error fetching recipient details: $e');
    }
  }

  void _fetchMessages() {
    _chatService.getMessages(widget.chatId).listen((messages) {
      setState(() {
        _messages
          ..clear()
          ..addAll(messages.map((msg) => msg.toTypesTextMessage()).toList()
            ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!)));
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = MessageModel(
      id: _generateRandomId(),
      senderId: _currentUser.id,
      recipientId: _recipientIds.toList(),
      content: message.text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.add(textMessage.toTypesTextMessage());
    });

    _chatService.sendMessage(textMessage, widget.chatId);
  }

  String _generateRandomId() => Random().nextInt(100000).toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(widget.titleChat ?? "Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cài đặt cuộc trò chuyện')),
              );
            },
          ),
        ],
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _currentUser,
      ),
    );
  }
}
