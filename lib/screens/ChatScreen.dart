import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ruprup/services/chat_service.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String uid;
  final String userName;
  final String chatId;

  const ChatScreen({super.key, required this.userName, required this.chatId, required this.uid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService chatService = ChatService();
  late final types.User _currentUser;
  final List<types.Message> _messages = [];

  @override
  void initState() {
    super.initState();

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    _currentUser = types.User(id: currentUserId);
    chatService.getMessages(widget.chatId).listen((messages) {
      setState(() {
        _messages.clear();
        // Sắp xếp tin nhắn theo thứ tự thời gian tăng dần (tin nhắn cũ hơn ở đầu)
        _messages.addAll(messages
            .map((msg) => msg.toTypesTextMessage())
            .toList()
            ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!)));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.userName),
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

  void _handleSendPressed(types.PartialText message) {
    final textMessage = MessageModel(
      id: _generateRandomId(),
      senderId: _currentUser.id,
      recipientId: widget.uid,
      content: message.text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.add(textMessage.toTypesTextMessage()); // Thêm tin nhắn mới vào cuối danh sách
    });

    chatService.sendMessage(textMessage, widget.chatId);
  }

  String _generateRandomId() {
    final random = Random();
    return random.nextInt(100000).toString();
  }
}
