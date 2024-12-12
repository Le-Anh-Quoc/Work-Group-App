import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  late final String id;
  final String content;
  final String taskId;
  final DateTime createdAt;
  final String createdBy;

  Comment({
    required this.id,
    required this.content,
    required this.taskId,
    required this.createdAt,
    required this.createdBy,
  });

  // Chuyển từ Map sang File object
  factory Comment.fromMap(Map<String, dynamic> map, String documentId) {
    return Comment(
      id: documentId,
      content: map['content'] as String,
      taskId: map['taskId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] as String,
    );
  }

  // Chuyển từ File object sang Map
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'taskId': taskId,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }
}
