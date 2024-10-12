class Chat {
  final String chatId;
  // final bool isGroup;
  // final String? name;
  final List<String> participants;
  final DateTime createdAt;
  final String lastMessage;
  final DateTime lastMessageTime;

  Chat({
    required this.chatId,
    // required this.isGroup,
    // this.name,
    required this.participants,
    required this.createdAt,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  // Convert a Chat object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      // 'isGroup': isGroup,
      // 'name': name,
      'participants': participants,
      'createdAt': createdAt.toIso8601String(),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
    };
  }

  // Create a Chat object from a map
  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      chatId: map['chatId'] ?? '',
      // isGroup: map['isGroup'] ?? false,
      // name: map['name'],
      participants: List<String>.from(map['participants'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: DateTime.parse(map['lastMessageTime'] ?? DateTime.now().toIso8601String()),
    );
  }
}
