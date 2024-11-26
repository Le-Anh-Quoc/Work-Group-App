import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final String uploadedBy;
  final DateTime uploadedAt;

  FileModel({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  // Convert Firestore document to FileModel
  factory FileModel.fromMap(Map<String, dynamic> map, String id) {
    return FileModel(
      fileId: id,
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
    );
  }

  // Convert FileModel to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
    };
  }
}
