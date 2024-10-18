import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/task_model.dart';

class TaskService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Thêm một Task mới vào subcollection tasks của project
  static Future<Task> addTask(String projectId, Task task) async {
    // Lấy reference cho document mới
    final taskRef = _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc();

    // Khởi tạo taskId từ ID của document
    final taskWithId = task.copyWith(taskId: taskRef.id);

    // Lưu task vào Firestore
    await taskRef.set(taskWithId.toMap());

    // Cập nhật số lượng todo trong bảng project
    await _firestore.collection('projects').doc(projectId).update({
      'toDo': FieldValue.increment(1), // Tăng giá trị trường toDo lên 1
    });

    // Trả về Task mới đã được lưu vào Firestore
    return taskWithId;
  }

  // Lấy danh sách tất cả Task trong subcollection tasks của project
  Future<List<Task>> getTasks(String projectId) async {
    final taskSnapshot = await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .get();

    return taskSnapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
  }

  // Cập nhật một Task trong subcollection tasks của project
  Future<void> updateTask(String projectId, Task task) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(task.taskId)
        .update(task.toMap());
  }

  // Xóa một Task trong subcollection tasks của project
  Future<void> deleteTask(String projectId, String taskId) async {
    await _firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // Hàm lấy tất cả các task dựa vào projectId
  static Future<List<Task>> getTasksByProjectId(String projectId) async {
    try {
      // Truy vấn các task trong subcollection 'tasks' của project
      final taskQuerySnapshot = await _firestore
          .collection('projects')
          .doc(projectId)
          .collection('tasks')
          .get();

      // Chuyển đổi các document thành danh sách Task
      return taskQuerySnapshot.docs.map((doc) {
        return Task.fromMap(doc.data() as Map<String, dynamic>)
            .copyWith(taskId: doc.id); // Thiết lập taskId từ document ID
      }).toList();
    } catch (e) {
      print("Error getting tasks: $e");
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
  }
}
