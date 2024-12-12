import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/file/file_model.dart';

class FileTask extends FileModel {
  final String taskId; // ID của task chứa file

  FileTask({
    required super.id,
    required super.name,
    required super.downloadUrl,
    required super.createdAt,
    required super.createdBy,
    required this.taskId,
  });

  factory FileTask.fromMap(Map<String, dynamic> map, String documentId) {
    return FileTask(
      id: documentId,
      name: map['name'] as String,
      downloadUrl: map['downloadUrl'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] as String,
      taskId: map['taskId'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['taskId'] = taskId;
    return map;
  }
}
