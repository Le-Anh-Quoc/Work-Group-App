import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruprup/models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'projects'; // Tên collection trong Firestore

  // 1. Tạo một dự án mới với ID tự động sinh (Create)
  Future<void> createProject(Project project) async {
    try {
      DocumentReference docRef =
          await _firestore.collection(collection).add(project.toMap());
      String newProjectId = docRef.id;
      await docRef.update({'projectId': newProjectId});
      //return newProjectId;
    } catch (e) {
      throw Exception("Failed to create project: $e");
    }
  }

  // 2. Đọc dự án (Read)
  Future<Project> getProject(String idProject) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collection).doc(idProject).get();

      if (doc.exists) {
        return Project.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        // Nếu document không tồn tại, bạn có thể ném ra ngoại lệ
        throw Exception("Project not found");
      }
    } catch (e) {
      // Bắt và ném lại lỗi nếu có sự cố khi lấy dữ liệu
      throw Exception("Error fetching project: $e");
    }
  }

  // 3. Cập nhật một dự án (Update)
  Future<void> updateProject(Project project) async {
    if (project.projectId.isEmpty) {
      throw Exception("Invalid project ID.");
    }
    await _firestore
        .collection(collection)
        .doc(project.projectId)
        .update(project.toMap());
  }

  // 4. Xóa một dự án (Delete)
  Future<void> deleteProject(String idProject) async {
    try {
      await _firestore.collection(collection).doc(idProject).delete();
    } catch (e) {
      print('Error deleting project: $e');
      throw e;
    }
  }

  // 5. lấy tất cả (ALL) các project của người dùng hiện tại đang tham gia
  Future<List<Project>> getAllProjectsForCurrentUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Trường hợp người dùng chưa đăng nhập
      throw Exception("No user is currently signed in.");
    }
    String currentUserId = currentUser.uid;
    QuerySnapshot querySnapshot = await _firestore
        .collection(collection)
        .where('memberIds',
            arrayContains:
                currentUserId) // Kiểm tra người dùng có trong memberIds
        .get();

    // Chuyển đổi kết quả truy vấn thành danh sách Project
    List<Project> projects = querySnapshot.docs.map((doc) {
      return Project.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return projects;
  }
}
