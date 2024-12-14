class Channel {
  late final String channelId;
  final String groupChatId;
  final List<String> projectId;
  final String channelName;
  final String adminId;
  final List<String> memberIds;
  final DateTime createdAt;
  final List<String> searchKeywords;

  Channel({
    required this.channelId,
    required this.groupChatId,
    required this.projectId,
    required this.channelName,
    required this.adminId,
    required this.memberIds,
    required this.createdAt,
    required this.searchKeywords
  });

  // Convert a Group object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'groupChatId': groupChatId,
      'projectIds': projectId,
      'channelName': channelName,
      'adminId': adminId,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'searchKeywords': searchKeywords
      //'tasks': tasks,
    };
  }

  // Create a Group object from a map
  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      channelId: map['channelId'] ?? '',
      groupChatId: map['groupChatId'] ?? '',
      projectId: List<String>.from(map['projectId'] ?? []),
      channelName: map['channelName'] ?? '',
      adminId: map['adminId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      searchKeywords: List<String>.from(map['searchKeywords'] ?? []),
    );
  }

  @override
  String toString() {
    return 'Channel(channelId: $channelId, channelName: $channelName, createdAt: $createdAt)';
  }
}