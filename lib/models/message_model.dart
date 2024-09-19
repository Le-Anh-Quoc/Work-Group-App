import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class MessageModel {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final int timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.timestamp,
  });

  types.TextMessage toTypesTextMessage() => types.TextMessage(
        author: types.User(id: senderId),
        createdAt: timestamp,
        id: id,
        text: content,
      );
}
