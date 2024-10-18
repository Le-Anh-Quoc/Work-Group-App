class Channel {
  late final String channelId;
  final String groupChatId;
  final String projectId;
  final String channelName;
  final String adminId;
  final List<String> memberIds;
  final DateTime createdAt;

  Channel({
    required this.channelId,
    required this.groupChatId,
    required this.projectId,
    required this.channelName,
    required this.adminId,
    required this.memberIds,
    required this.createdAt,
  });

  // Convert a Group object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'groupChatId': groupChatId,
      'projectId': projectId,
      'channelName': channelName,
      'adminId': adminId,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      //'tasks': tasks,
    };
  }

  // Create a Group object from a map
  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      channelId: map['channelId'] ?? '',
      groupChatId: map['groupChatId'] ?? '',
      projectId: map['projectId'] ?? '',
      channelName: map['channelName'] ?? '',
      adminId: map['adminId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'Channel(channelId: $channelId, channelName: $channelName, createdAt: $createdAt)';
  }
}