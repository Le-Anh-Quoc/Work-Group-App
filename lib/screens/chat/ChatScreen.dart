import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:ruprup/services/chat_service.dart';
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
  late final types.User _currentUser;
  final List<types.Message> _messages = [];
  Set<String> _recipientIds = {};

  @override
  void initState() {
    super.initState();

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _currentUser = types.User(id: currentUserId);

    _fetchRecipientDetails();
    _fetchMessages();
  }

  Future<void> _fetchRecipientDetails() async {
    try {
      final chatData = await _chatService.getChatDetails(widget.chatId);
      final users = chatData['users'] as List<Map<String, dynamic>>;

      _recipientIds = users
          .map((user) => user['id'] as String)
          .where((id) => id != _currentUser.id)
          .toSet();
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
      _messages.add(textMessage.toTypesTextMessage()); // Đảm bảo phương thức toTypesTextMessage có xử lý cho imageUrl
    });

    _chatService.sendMessage(textMessage, widget.chatId);
  }

  String _generateRandomId() => Random().nextInt(100000).toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage:
                  NetworkImage('https://picsum.photos/200/300?random=2'),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Text(
              widget.titleChat ?? "Chat",
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white70, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Setting')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: _messages,
              onSendPressed: (types.PartialText message) {
                _handleSendPressed;
              },
              user: _currentUser,
              showUserAvatars: true,
              showUserNames: true,
              // avatarBuilder: (userId) {
              //   final messageUser = _messages
              //       .firstWhere((message) => message.author.id == userId);
              //   return CircleAvatar(
              //     backgroundImage: NetworkImage(messageUser.author.avatarUrl ??
              //         'https://example.com/default-avatar.png'),
              //   );
              // },
              nameBuilder: (user) => Text(
                user.firstName ?? 'Unknown',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              theme: DefaultChatTheme(
                inputBackgroundColor: Colors.blue.shade100,
                inputTextColor: Colors.black,
                sendButtonIcon: const Icon(Icons.send, color: Colors.blue),
                primaryColor: Colors.blue,
                messageInsetsHorizontal: 15,
                messageInsetsVertical: 15,
              ),
              customBottomWidget: CustomMessageInput(
                onSendPressed: (message) => _handleSendPressed(types.PartialText(text: message))
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CustomMessageInput extends StatefulWidget {
  final Function(String) onSendPressed;

  const CustomMessageInput({Key? key, required this.onSendPressed})
      : super(key: key);

  @override
  _CustomMessageInputState createState() => _CustomMessageInputState();
}

class _CustomMessageInputState extends State<CustomMessageInput> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      widget.onSendPressed(_controller.text);
      _controller.clear();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    // if (pickedFile != null) {
    //   widget.onSendPressed(); // Gửi đường dẫn hình ảnh
    // }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = result.files.single;
        print('File picked: ${file.name}');
        // Gửi file hoặc làm gì đó với file đã chọn
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 9,
              spreadRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.blue),
              onPressed: _pickFile,
            ),
            IconButton(
              icon: const Icon(Icons.image, color: Colors.blue),
              onPressed: _pickImage,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                style: const TextStyle(fontSize: 16),
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _sendMessage,
              padding: const EdgeInsets.all(8.0),
            ),
          ],
        ),
      ),
    );
  }
}
