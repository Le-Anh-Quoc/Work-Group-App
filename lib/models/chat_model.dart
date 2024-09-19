class ChatModel {
  final String chatId;
  final List<String> userIds;
  final String lastMessage;
  final int timestamp;

  ChatModel({
    required this.chatId,
    required this.userIds,
    required this.lastMessage,
    required this.timestamp,
  });
}
