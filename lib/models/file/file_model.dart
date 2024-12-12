import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  late final String id; // ID của file
  final String name; // Tên file
  late final String downloadUrl; // URL để tải file
  final DateTime createdAt; // Thời gian tạo
  final String createdBy; // ID người tạo

  FileModel({
    required this.id,
    required this.name,
    required this.downloadUrl,
    required this.createdAt,
    required this.createdBy,
  });

  // Chuyển từ Map sang File object
  factory FileModel.fromMap(Map<String, dynamic> map, String documentId) {
    return FileModel(
      id: documentId,
      name: map['name'] as String,
      downloadUrl: map['downloadUrl'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] as String,
    );
  }

  // Chuyển từ File object sang Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'downloadUrl': downloadUrl,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }
}
