import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/file/file_model.dart';

class FileFolder extends FileModel {
  final String folderId; // ID của folder chứa file

  FileFolder({
    required super.id,
    required super.name,
    required super.downloadUrl,
    required super.createdAt,
    required super.createdBy,
    required this.folderId,
  });

  factory FileFolder.fromMap(Map<String, dynamic> map, String documentId) {
    return FileFolder(
      id: documentId,
      name: map['name'] as String,
      downloadUrl: map['downloadUrl'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] as String,
      folderId: map['folderId'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['folderId'] = folderId;
    return map;
  }
}
