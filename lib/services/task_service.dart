import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/project/task_model.dart';

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

  // 5. Lấy danh sách các Task trong subcollection tasks của project (theo Project)
  Future<List<Task>> getTasks(String idProject, TaskStatus status,
      {String? currentUserId}) async {
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
      query = query.where('assigneeIds',
          arrayContains:
              currentUserId); // Giả sử trường userId lưu ID người dùng
    }

    final taskSnapshot = await query.get();

    return taskSnapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();
  }

  // 6. Lấy tất cả các Task của người dùng hiện tại không theo projectId
  Future<List<Task>> getAllTasksForCurrentUser(
      String idProject, String currentUserId, TaskStatus status,
      {int? limit}) async {
    final String sStatus =
        status.name; // Chuyển thành kiểu String để truyền vào so sánh
    List<Task> allTasks = []; // Danh sách để lưu tất cả các nhiệm vụ

    if (idProject == 'All') {
      final projectSnapshot =
          await _firestore.collection(parentCollection).get();

      // Duyệt qua từng project để lấy nhiệm vụ
      for (var projectDoc in projectSnapshot.docs) {
        // Truy vấn các nhiệm vụ trong subcollection của từng project
        var query = projectDoc.reference
            .collection(collection)
            .where('status', isEqualTo: sStatus)
            .where('assigneeIds', arrayContains: currentUserId);

        final taskSnapshot = await query.get();

        // Thêm các nhiệm vụ vào danh sách
        allTasks
            .addAll(taskSnapshot.docs.map((doc) => Task.fromMap(doc.data())));
      }
    } else {
      final projectSnapshot = await _firestore
          .collection(parentCollection)
          .doc(idProject)
          .collection(collection)
          .where('status', isEqualTo: sStatus)
          .where('assigneeIds', arrayContains: currentUserId)
          .get();

      // Thêm các nhiệm vụ vào danh sách
      allTasks
          .addAll(projectSnapshot.docs.map((doc) => Task.fromMap(doc.data())));
    }

    // Sắp xếp các nhiệm vụ theo dueDate (giả sử dueDate là thuộc tính kiểu DateTime của Task)
    allTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    // Nếu truyền vào giá trị `limit`, lấy `limit` nhiệm vụ gần nhất, nếu không thì lấy tất cả
    if (limit != null) {
      return allTasks.take(limit).toList();
    } else {
      return allTasks;
    }
  }

  // 7. Hàm update tình trạng công việc
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
