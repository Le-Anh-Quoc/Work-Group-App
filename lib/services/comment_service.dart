import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createComment(String projectId, Comment comment) async {
    final docRef = _firestore
        .collection('projects')
        .doc(projectId)
        .collection('comments')
        .doc(); // Tạo một DocumentReference với ID tự động

    // Tạo bản đồ với ID và các thuộc tính khác của comment
    final commentMap = {
      'id': docRef.id,
      'content': comment.content,
      'taskId': comment.taskId,
      'createdAt': comment.createdAt,
      'createdBy': comment.createdBy,
    };

    await docRef.set(commentMap); // Lưu dữ liệu vào Firestore
    return docRef.id; // Trả về ID của document
  }

  // Read - Lấy danh sách comments theo projectId
  Future<List<Comment>> getCommentsByTaskandProjectId(
      String projectId, String taskId) async {
    final querySnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('comments')
        .where('taskId', isEqualTo: taskId)
        .get();
    return querySnapshot.docs
        .map((doc) => Comment.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Update - Cập nhật comment
  Future<void> updateComment(String projectId, Comment updatedComment) async {
    final docRef = _firestore
        .collection('projects')
        .doc(projectId)
        .collection('comments')
        .doc(updatedComment.id);
    await docRef.update(updatedComment.toMap());
  }

  // Delete - Xóa comment
  Future<void> deleteComment(String projectId, String commentId) async {
    final docRef = _firestore
        .collection('projects')
        .doc(projectId)
        .collection('comments')
        .doc(commentId);
    await docRef.delete();
  }
}
