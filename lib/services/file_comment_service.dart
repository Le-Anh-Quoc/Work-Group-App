// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/file/file_comment.dart';

class FileCommentService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createFileComment(
      String projectId, FileComment fileComment) async {
    try {
      // Firebase tự sinh ID cho document
      final docRef = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('fileComments')
          .add(fileComment.toMap());

      print("FileComment created successfully with ID: ${docRef.id}");
    } catch (e) {
      print("Error creating FileComment: $e");
    }
  }

  Future<void> deleteFileComment(String projectId, String fileCommentId) async {
    try {
      await firestore
          .collection('projects')
          .doc(projectId)
          .collection('fileComments')
          .doc(fileCommentId)
          .delete();
      print("FileComment deleted successfully.");
    } catch (e) {
      print("Error deleting FileComment: $e");
    }
  }

  Future<List<FileComment>> getFileCommentsByCommentId(
      String projectId, String commentId) async {
    try {
      final querySnapshot = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('fileComments')
          .where('commentId', isEqualTo: commentId)
          .get();

      return querySnapshot.docs.map((doc) {
        return FileComment.fromMap(
            doc.data(), doc.id); // Dùng doc.id (ID tự sinh)
      }).toList();
    } catch (e) {
      print("Error fetching FileComments by commentId: $e");
      return [];
    }
  }
}
