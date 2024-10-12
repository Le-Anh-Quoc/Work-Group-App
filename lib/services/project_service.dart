import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'projects'; // Tên collection trong Firestore

  // 1. Tạo một dự án mới với ID tự động sinh (Create)
  Future<String> createProject(Project project) async {
    // Sử dụng add() để tự động sinh ID
    DocumentReference docRef =
        await _firestore.collection(collection).add(project.toMap());

    // Lấy projectId mới được tạo
    String newProjectId = docRef.id;

    // Cập nhật projectId của dự án với ID mới sinh ra
    await docRef.update({'projectId': newProjectId});

    // Trả về projectId mới
    return newProjectId;
  }

  // 2. Đọc dự án (Read)
  Future<Project?> getProject(String projectId) async {
    DocumentSnapshot doc =
        await _firestore.collection(collection).doc(projectId).get();
    if (doc.exists) {
      return Project.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // 3. Cập nhật một dự án (Update)
  Future<void> updateProject(Project project) async {
    await _firestore
        .collection(collection)
        .doc(project.projectId)
        .update(project.toMap());
  }

  // 4. Xóa một dự án (Delete)
  Future<void> deleteProject(String projectId) async {
    await _firestore.collection(collection).doc(projectId).delete();
  }

  // 5. lấy tất cả các project của người dùng hiện tại đang tham gia
  Future<List<Project>> getProjectsForCurrentUser(String currentUserId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(collection)
        .where('memberIds',
            arrayContains:
                currentUserId) // Kiểm tra người dùng có trong memberIds
        .get();

    // Chuyển đổi kết quả truy vấn thành danh sách Group
    List<Project> groups = querySnapshot.docs.map((doc) {
      return Project.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return groups;
  }
}
