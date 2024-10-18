import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class MessageModel {
  final String id;
  final String senderId;
  final List<String> recipientId;
  final String content;
  final int timestamp;
  final String type;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  types.TextMessage toTypesTextMessage() => types.TextMessage(
        author: types.User(id: senderId),
        createdAt: timestamp,
        id: id,
        text: content,
      );
  types.ImageMessage toTypesImageMessage() => types.ImageMessage(
        author: types.User(id: senderId),
        createdAt: timestamp,
        id: id,
        uri: content, // Giả sử content là đường dẫn hình ảnh
        name: 'Image', size: 15,
      );
}

// class Message {
//   final String messageId;
//   final String chatId;
//   final String senderId;
//   final String content;
//   final String messageType;
//   final DateTime createdAt;

//   Message({
//     required this.messageId,
//     required this.chatId,
//     required this.senderId,
//     required this.content,
//     required this.messageType,
//     required this.createdAt,
//   });

//   // Convert a Message object to a map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'messageId': messageId,
//       'chatId': chatId,
//       'senderId': senderId,
//       'content': content,
//       'messageType': messageType,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }

//   // Create a Message object from a map
//   factory Message.fromMap(Map<String, dynamic> map) {
//     return Message(
//       messageId: map['messageId'] ?? '',
//       chatId: map['chatId'] ?? '',
//       senderId: map['senderId'] ?? '',
//       content: map['content'] ?? '',
//       messageType: map['messageType'] ?? 'text',
//       createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
//     );
//   }
// }
