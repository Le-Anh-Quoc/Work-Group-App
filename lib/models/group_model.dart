class Group {
  late final String groupId;
  final String groupChatId;
  final String projectId;
  final String groupName;
  final String adminId;
  final List<String> memberIds;
  final DateTime createdAt;

  Group({
    required this.groupId,
    required this.groupChatId,
    required this.projectId,
    required this.groupName,
    required this.adminId,
    required this.memberIds,
    required this.createdAt,
    //required this.tasks,
  });

  // Convert a Group object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupChatId': groupChatId,
      'projectId': projectId,
      'groupName': groupName,
      'adminId': adminId,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      //'tasks': tasks,
    };
  }

  // Create a Group object from a map
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      groupId: map['groupId'] ?? '',
      groupChatId: map['groupChatId'] ?? '',
      projectId: map['projectId'] ?? '',
      groupName: map['groupName'] ?? '',
      adminId: map['adminId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      //tasks: List<String>.from(map['tasks'] ?? []),
    );
  }
}