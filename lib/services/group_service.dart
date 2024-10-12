import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/group_model.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'groups'; // Tên collection trong Firestore

  // 1. Tạo một nhóm mới với ID tự động sinh (Create)
  Future<void> createGroup(Group group) async {
    // Sử dụng add() để tự động sinh ID
    DocumentReference docRef =
        await _firestore.collection(collection).add(group.toMap());
    // Cập nhật groupId của nhóm với ID vừa sinh ra
    String newGroupId = docRef.id;
    await docRef
        .update({'groupId': newGroupId}); // Cập nhật lại groupId trong tài liệu
  }

  // 2. Đọc một nhóm (Read)
  Future<Group?> getGroup(String groupId) async {
    DocumentSnapshot doc =
        await _firestore.collection(collection).doc(groupId).get();
    if (doc.exists) {
      return Group.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // 3. Cập nhật một nhóm (Update)
  Future<void> updateGroup(Group group) async {
    await _firestore
        .collection(collection)
        .doc(group.groupId)
        .update(group.toMap());
  }

  // 4. Xóa một nhóm (Delete)
  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection(collection).doc(groupId).delete();
  }

  // lấy thông tin của một group dựa vào groupChatId
  Future<Group?> getGroupByChatId(String groupChatId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(collection)
        .where('groupChatId', isEqualTo: groupChatId)
        .limit(1) // Giới hạn 1 kết quả
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Group.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Hàm lấy tất cả các group mà người dùng hiện tại đang tham gia
  Future<List<Group>> getGroupsForCurrentUser(String currentUserId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(collection)
        .where('memberIds',
            arrayContains:
                currentUserId) // Kiểm tra người dùng có trong memberIds
        .get();

    // Chuyển đổi kết quả truy vấn thành danh sách Group
    List<Group> groups = querySnapshot.docs.map((doc) {
      return Group.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return groups;
  }
}
