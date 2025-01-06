class Channel {
  late final String channelId;
  final String groupChatId;
  final List<String> projectIds;
  final String channelName;
  final String adminId;
  final List<String> memberIds;
  final int createdAt;
  final List<String> searchKeywords;

  Channel({
    required this.channelId,
    required this.groupChatId,
    required this.projectIds,
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
      'projectIds': projectIds,
      'channelName': channelName,
      'adminId': adminId,
      'memberIds': memberIds,
      'createdAt': createdAt,
      'searchKeywords': searchKeywords
      //'tasks': tasks,
    };
  }

  // Create a Group object from a map
  factory Channel.fromMap(Map<String, dynamic> map) {
    return Channel(
      channelId: map['channelId'] ?? '',
      groupChatId: map['groupChatId'] ?? '',
      projectIds: List<String>.from(map['projectIds'] ?? []),
      channelName: map['channelName'] ?? '',
      adminId: map['adminId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: map['createdAt'] ?? DateTime.now().microsecondsSinceEpoch,
      searchKeywords: List<String>.from(map['searchKeywords'] ?? []),
    );
  }
}