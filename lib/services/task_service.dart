import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String parentCollection = 'projects';
  final String collection = 'tasks';

  // 1. Thêm một Task mới vào subcollection tasks của project
  Future<Task> addTask(String idProject, Task task) async {
    // Lấy reference cho document mới
    final taskRef = _firestore
        .collection(parentCollection)
        .doc(idProject)
        .collection(collection)
        .doc();

    // Khởi tạo taskId từ ID của document
    final taskWithId = task.copyWith(taskId: taskRef.id);

    // Lưu task vào Firestore
    await taskRef.set(taskWithId.toMap());

    // Cập nhật số lượng todo trong bảng project
    await _firestore.collection(parentCollection).doc(idProject).update({
      'toDo': FieldValue.increment(1), // Tăng giá trị trường toDo lên 1
    });

    // Trả về Task mới đã được lưu vào Firestore
    return taskWithId;
  }

  // 2. lấy thông tin của một task
  Future<Task?> getTask(String idProject, String idTask) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(parentCollection)
          .doc(idProject)
          .collection(collection)
          .doc(idTask)
          .get();

      if (doc.exists) {
        return Task.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        // Nếu document không tồn tại, bạn có thể ném ra ngoại lệ
        return null;
      }
    } catch (e) {
      // Bắt và ném lại lỗi nếu có sự cố khi lấy dữ liệu
      throw Exception("Error fetching task: $e");
    }
  }

  // 3. Cập nhật một Task trong subcollection tasks của project
  Future<void> updateTask(String projectId, Task task) async {
    await _firestore
        .collection(parentCollection)
        .doc(projectId)
        .collection(collection)
        .doc(task.taskId)
        .update(task.toMap());
  }

  // 4. Xóa một Task trong subcollection tasks của project
  Future<void> deleteTask(String projectId, String taskId) async {
    await _firestore
        .collection(parentCollection)
        .doc(projectId)
        .collection(collection)
        .doc(taskId)
        .delete();
    await _firestore.collection(parentCollection).doc(projectId).update({
      'toDo': FieldValue.increment(-1), // Tăng giá trị trường toDo lên 1
    });
  }

  // 5. Lấy danh sách các Task trong subcollection tasks của project
  Future<List<Task>> getTasks(String idProject, TaskStatus status, {String? currentUserId}) async {
    final String sStatus =
        status.name; //chuyển thành kiểu String để truyền vào so sánh

    // Bắt đầu xây dựng truy vấn
    var query = _firestore
        .collection(parentCollection)
        .doc(idProject)
        .collection(collection)
        .where('status', isEqualTo: sStatus);

    // Kiểm tra xem currentUserId có được cung cấp hay không
    if (currentUserId != null) {
        query = query.where('assigneeIds', arrayContains: currentUserId); // Giả sử trường userId lưu ID người dùng
    }

    final taskSnapshot = await query.get();

    return taskSnapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
  }

  // 6. Hàm update tình trạng công việc
  Future<void> updateTaskStatus(
      String projectId, String taskId, TaskStatus newStatus) async {
    // Lấy document project
    DocumentReference projectRef =
        FirebaseFirestore.instance.collection(parentCollection).doc(projectId);

    final String sStatus = newStatus.name;

    // Cập nhật trạng thái task
    await FirebaseFirestore.instance
        .collection(parentCollection)
        .doc(projectId)
        .collection(collection)
        .doc(taskId)
        .update({'status': sStatus});

    // Lấy tất cả tasks để cập nhật số lượng
    QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance
        .collection(parentCollection)
        .doc(projectId)
        .collection(collection)
        .get();

    // Tính số lượng công việc theo trạng thái
    int toDoCount = 0;
    int inProgressCount = 0;
    int inReviewCount = 0;
    int doneCount = 0;

    for (var doc in tasksSnapshot.docs) {
      String status = doc['status'];
      if (status == 'toDo') {
        toDoCount++;
      } else if (status == 'inProgress') {
        inProgressCount++;
      } else if (status == 'inReview') {
        inReviewCount++;
      } else if (status == 'done') {
        doneCount++;
      }
    }

    // Cập nhật lại số lượng công việc trong project
    await projectRef.update({
      'toDo': toDoCount,
      'inProgress': inProgressCount,
      'inReview': inReviewCount,
      'done': doneCount,
    });
  }
}
