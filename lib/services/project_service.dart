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
      // ignore: avoid_print
      print('Error deleting project: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  // 5. lấy tất cả (ALL) các project của người dùng hiện tại đang tham gia
  Future<List<Project>> getAllProjectsForCurrentUser({String? groupId}) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Trường hợp người dùng chưa đăng nhập
      throw Exception("No user is currently signed in.");
    }
    String currentUserId = currentUser.uid;

    Query query = _firestore
        .collection(collection)
        .where('memberIds', arrayContains: currentUserId);

    // Nếu groupId không null, thêm điều kiện vào truy vấn
    if (groupId != null) {
      query = query.where('groupId', isEqualTo: groupId);
    }

    QuerySnapshot querySnapshot = await query.get();

    // Chuyển đổi kết quả truy vấn thành danh sách Project
    List<Project> projects = querySnapshot.docs.map((doc) {
      return Project.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return projects;
  }

  // 6.  Lấy 3 dự án được cập nhật activity gần nhất
  Future<List<Project>> getRecentProjectsForCurrentUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Trường hợp người dùng chưa đăng nhập
      throw Exception("No user is currently signed in.");
    }
    String currentUserId = currentUser.uid;

    Query query = _firestore
        .collection(collection)
        .where('memberIds', arrayContains: currentUserId);

    QuerySnapshot querySnapshot = await query.get();

    // Danh sách để chứa các dự án có hoạt động gần đây nhất
    List<Project> recentProjects = [];

    // Duyệt qua từng dự án và tìm hoạt động gần đây nhất
    for (var doc in querySnapshot.docs) {
      // Lấy ID của dự án hiện tại
      String projectId = doc.id;

      // Truy vấn subcollection 'activityLogs' của dự án để tìm hoạt động gần đây nhất
      QuerySnapshot activitySnapshot = await _firestore
          .collection(collection)
          .doc(projectId)
          .collection('activityLogs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (activitySnapshot.docs.isNotEmpty) {
        // Nếu có ít nhất một hoạt động, thêm dự án vào danh sách recentProjects
        recentProjects.add(Project.fromMap(doc.data() as Map<String, dynamic>));
      }
    }

    // Lấy ra 3 dự án đầu tiên trong danh sách recentProjects (hoặc ít hơn nếu không đủ 3 dự án)
    return recentProjects.take(3).toList();
  }
}
