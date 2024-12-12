import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/file/file_model.dart';

class FileComment extends FileModel {
  final String commentId; // ID của comment chứa file

  FileComment({
    required super.id,
    required super.name,
    required super.downloadUrl,
    required super.createdAt,
    required super.createdBy,
    required this.commentId,
  });

  factory FileComment.fromMap(Map<String, dynamic> map, String documentId) {
    return FileComment(
      id: documentId,
      name: map['name'] as String,
      downloadUrl: map['downloadUrl'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] as String,
      commentId: map['commentId'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['commentId'] = commentId;
    return map;
  }
}
