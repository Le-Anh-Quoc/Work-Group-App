import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruprup/models/project/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'projects'; // Tên collection trong Firestore

  // 1. Tạo một dự án mới với ID tự động sinh (Create)
  Future<void> createProject(Project project, String channelId) async {
    try {
      // Tạo một project mới và lấy docRef
      DocumentReference docRef =
          await _firestore.collection('projects').add(project.toMap());

      // Lấy projectId vừa tạo
      String newProjectId = docRef.id;

      // Cập nhật projectId vào project vừa tạo
      await docRef.update({'projectId': newProjectId});

      // Cập nhật projectId vào collection channel
      DocumentReference channelDoc =
          _firestore.collection('channel').doc(channelId);
      await channelDoc.update({
        'projectIds': FieldValue.arrayUnion([newProjectId]),
      });

      print('Project created and updated in channel successfully.');
    } catch (e) {
      throw Exception("Failed to create project and update channel: $e");
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

    // Truy vấn để lấy các dự án mà người dùng là thành viên
    Query query = _firestore
        .collection(collection)
        .where('memberIds', arrayContains: currentUserId);

    QuerySnapshot querySnapshot = await query.get();

    List<Map<String, dynamic>> projectsWithRecentActivity = [];

    for (var doc in querySnapshot.docs) {
      String projectId = doc.id;

      // Truy vấn hoạt động gần đây nhất của dự án
      QuerySnapshot activitySnapshot = await _firestore
          .collection(collection)
          .doc(projectId)
          .collection('activityLogs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (activitySnapshot.docs.isNotEmpty) {
        var recentActivity = activitySnapshot.docs.first;

        // Kiểm tra xem timestamp có phải là Timestamp không, nếu không thì chuyển đổi
        DateTime recentTimestamp;
        if (recentActivity['timestamp'] is Timestamp) {
          recentTimestamp = (recentActivity['timestamp'] as Timestamp).toDate();
        } else {
          // Nếu timestamp là một chuỗi, có thể chuyển đổi nếu cần
          recentTimestamp = DateTime.parse(recentActivity['timestamp']);
        }

        // Lưu thông tin dự án và thời gian hoạt động gần đây nhất
        projectsWithRecentActivity.add({
          'project': Project.fromMap(doc.data() as Map<String, dynamic>),
          'recentTimestamp': recentTimestamp,
        });
      }
    }

    // Sắp xếp dự án theo thời gian hoạt động gần đây nhất
    projectsWithRecentActivity.sort((a, b) => (b['recentTimestamp'] as DateTime)
        .compareTo(a['recentTimestamp'] as DateTime));

    // Lấy 3 dự án đầu tiên có hoạt động mới nhất
    return projectsWithRecentActivity
        .take(3)
        .map((e) => e['project'] as Project)
        .toList();
  }

  Future<List<Project>> searchProjects(String keyword) async {
    keyword = keyword.toLowerCase();

    // Tham chiếu tới collection "users"
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('projects')
        .where('searchKeywords', arrayContains: keyword)
        .get();

    // Chuyển đổi dữ liệu từ Firebase thành danh sách UserModel
    List<Project> users = query.docs.map((doc) {
      return Project.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return users;
  }

  Future<void> updateMultipleProjectsMembers(List<String> projectIds,
      List<String> membersToAdd, List<String> membersToRemove) async {
    if (projectIds.isEmpty) {
      throw Exception("Danh sách projectIds trống.");
    }

    print("Bắt đầu cập nhật members cho projects: $projectIds");

    final batch = FirebaseFirestore.instance.batch();

    try {
      // Lấy thông tin của tất cả projects trước
      final projectSnapshots = await Future.wait(projectIds.map((projectId) =>
          FirebaseFirestore.instance
              .collection('projects')
              .doc(projectId)
              .get()));

      for (var snapshot in projectSnapshots) {
        if (!snapshot.exists) {
          print("Project ID: ${snapshot.id} không tồn tại.");
          continue; // Bỏ qua nếu project không tồn tại.
        }

        final projectRef = snapshot.reference;
        List<String> currentMembers = [];
        if (snapshot.data()?.containsKey('memberIds') == true) {
          currentMembers = List<String>.from(snapshot['memberIds'] ?? []);
        }
        print(
            "Project ID: ${snapshot.id} - Thành viên hiện tại: $currentMembers");

        // Cập nhật danh sách thành viên
        currentMembers.addAll(membersToAdd);
        currentMembers
            .removeWhere((member) => membersToRemove.contains(member));
        print(
            "Project ID: ${snapshot.id} - Thành viên sau cập nhật: $currentMembers");

        // Thêm thao tác vào batch
        batch.update(projectRef, {'memberIds': currentMembers});
      }

      // Commit batch
      await batch.commit();
      print("Cập nhật thành công.");
    } catch (e) {
      print("Lỗi khi cập nhật: $e");
      rethrow;
    }
  }

  Future<int> countProjectsByUserId(String userId) async {
    try {
      // Lấy danh sách các project từ Firestore
      QuerySnapshot snapshot = await _firestore.collection('projects')
          .where('memberIds', arrayContains: userId)  // Kiểm tra userId có trong memberIds không
          .get();

      // Trả về số lượng project
      return snapshot.docs.length;
    } catch (e) {
      print('Error counting projects: $e');
      return 0; // Trả về 0 nếu có lỗi
    }
  }
}
