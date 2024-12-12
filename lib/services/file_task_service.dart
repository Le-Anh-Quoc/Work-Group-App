import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/file/file_task.dart';

class FileTaskService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createFileTask(String projectId, FileTask fileTask) async {
    try {
      // Firebase tự sinh ID cho document
      final docRef = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('fileTasks')
          .add(fileTask.toMap());

      print("FileTask created successfully with ID: ${docRef.id}");
    } catch (e) {
      print("Error creating FileTask: $e");
    }
  }

  Future<void> deleteFileTask(String projectId, String fileTaskId) async {
    try {
      await firestore
          .collection('projects')
          .doc(projectId)
          .collection('fileTasks')
          .doc(fileTaskId)
          .delete();
      print("FileTask deleted successfully.");
    } catch (e) {
      print("Error deleting FileTask: $e");
    }
  }

  Future<List<FileTask>> getFileTasksByTaskId(
      String projectId, String taskId) async {
    try {
      final querySnapshot = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('fileTasks')
          .where('taskId', isEqualTo: taskId)
          .get();

      // Kiểm tra nếu không có tài liệu
      if (querySnapshot.docs.isEmpty) {
        print("No FileTasks found for taskId: $taskId");
        return []; // Trả về danh sách rỗng
      }

      // Chuyển đổi tài liệu thành danh sách FileTask
      return querySnapshot.docs.map((doc) {
        return FileTask.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching FileTasks by taskId: $e");
      return []; // Trả về danh sách rỗng khi có lỗi
    }
  }
}
