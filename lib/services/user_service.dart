// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/services/chat_service.dart';
import 'package:ruprup/services/friend_service.dart';
import 'package:ruprup/services/notification_service.dart';

class UserService {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Create: Tạo một người dùng mới
  Future<void> createUser(UserModel user) async {
    try {
      // Sử dụng userId (UID) từ Firebase Authentication làm ID cho người dùng
      await userCollection.doc(user.userId).set(user.toMap());
      print("Người dùng đã được tạo với ID: ${user.userId}");
    } catch (e) {
      print("Lỗi khi tạo người dùng: $e");
    }
  }

  // 2. Read: Lấy thông tin người dùng theo ID
  Future<UserModel?> readUser(String id) async {
    try {
      DocumentSnapshot docSnapshot = await userCollection.doc(id).get();
      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data() as Map<String, dynamic>);
      } else {
        print("Người dùng không tồn tại với ID: $id");
        return null;
      }
    } catch (e) {
      print("Lỗi khi đọc người dùng: $e");
      return null;
    }
  }

  // 3. Update: Cập nhật thông tin người dùng theo ID
  Future<void> updateUser(String id, Map<String, dynamic> updatedData) async {
    try {
      await userCollection.doc(id).update(updatedData);
      print("Người dùng đã được cập nhật với ID: $id");
    } catch (e) {
      print("Lỗi khi cập nhật người dùng: $e");
    }
  }

  // 4. Delete: Xóa người dùng theo ID
  Future<void> deleteUser(String id) async {
    try {
      await userCollection.doc(id).delete();
      print("Người dùng đã được xóa với ID: $id");
    } catch (e) {
      print("Lỗi khi xóa người dùng: $e");
    }
  }

  // 5. tìm kiếm người dùng khác bằng email
  Future<List<Map<String, dynamic>>> searchUserByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      List<Map<String, dynamic>> results = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id; // Thêm uid của tài liệu vào dữ liệu
        return data;
      }).toList();

      print(results);
      return results;
    } catch (e) {
      print('Error searching user: $e');
      return [];
    }
  }

  // 6. lấy fullName của người dùng hiện tại
  Future<String?> getCurrentUserFullName() async {
    try {
      // Lấy uid của người dùng hiện tại
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

      // Tham chiếu đến tài liệu của người dùng dựa vào uid
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users') // Collection 'users'
          .doc(currentUserId) // Tài liệu của người dùng hiện tại
          .get();

      if (userDoc.exists) {
        // Ép kiểu dữ liệu sang Map<String, dynamic>
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        // Nếu tồn tại, trả về fullname
        return userData?['fullname'] as String?;
      } else {
        // Nếu tài liệu không tồn tại, trả về giá trị mặc định
        return 'Unknown User';
      }
    } catch (e) {
      print('Error getting current user fullname: $e');
      return 'Error';
    }
  }

  // 7. Lấy fullName của một người dùng nào đó bằng id
  Future<String> getFullNameByUid(String uid) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['fullname'] as String? ??
            'User'; // Trả về 'Người dùng' nếu fullname là null
      }
    } catch (e) {
      print('Error getting full name: $e');
    }
    return 'User'; // Trả về giá trị mặc định nếu có lỗi
  }

  // 8. Người dùng hiện tại gửi yêu cầu kết bạn tới người dùng khác
  Future<bool> sendFriendRequest(
      String currentUserId, String targetUserId) async {
    final requestId = '${currentUserId}_$targetUserId';
    final requestDoc =
        FirebaseFirestore.instance.collection('friends').doc(requestId);

    try {
      final requestSnapshot = await requestDoc.get();
      if (!requestSnapshot.exists) {
        await requestDoc.set({
          'sendUserId': currentUserId,
          'targetUserId': targetUserId,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Friend request sent.');
        return true; // Thành công
        

      } else {
        print("Friend request already exists.");
        return false; // Đã tồn tại
      }
    } catch (e) {
      print('Error sending friend request: $e');
      return false; // Thất bại
    }
  }

  // 9. người dùng chấp nhận lời mời kết bạn
  Future<void> acceptFriendRequest(
      String currentUserId, String friendUserId) async {
    try {
      FriendService friend = FriendService();
      NotificationService notification = NotificationService();
      ChatService chatService = ChatService();

      // 1. Cập nhật trạng thái chấp nhận kết bạn
      await friend.updateAcceptFriendRequestStatus(currentUserId, friendUserId);

      // 2. Cập nhật danh sách bạn bè
      await friend.updateFriendLists(currentUserId, friendUserId);

      // 3. Tạo đoạn chat 1vs1
      List<String> userIds = [currentUserId, friendUserId];
      await chatService.createChat(userIds);

      // 4. Gửi thông báo tới tài khoản đã gửi lời mời
      await notification.sendNotificationToRequester(
          friendUserId, currentUserId);

      print("Friend request accepted and notification sent.");
    } catch (e) {
      print("Error accepting friend request: $e");
    }
  }

  // 10. Hàm dùng để từ chối lời mời kết bạn
  Future<void> rejectFriendRequest(
      String currentUserId, String friendUserId) async {
    try {
      FriendService friend = FriendService();

      // 1. Cập nhật trạng thái từ chối kết bạn
      await friend.updateRejectFriendRequestStatus(currentUserId, friendUserId);

      print("Friend request accepted and notification sent.");
    } catch (e) {
      print("Error accepting friend request: $e");
    }
  }

  // 11. tìm kiếm người dùng khác
  // Future<List<UserModel>> searchUsers(String keyword) async {
  //   //keyword = keyword.toLowerCase();

  //   Map<String, Map<String, dynamic>> userMap = {};

  //   // Tham chiếu tới collection "User"
  //   CollectionReference users = FirebaseFirestore.instance.collection('users');

  //   // Tìm kiếm các người dùng có 'email' hoặc 'fullname' chứa từ khóa
  //   QuerySnapshot emailQuery = await users
  //       .where('email', isGreaterThanOrEqualTo: keyword)
  //       .where('email', isLessThan: '$keyword\uf8ff')
  //       .where('email', isEqualTo: keyword)
  //       .get();

  //   for (var doc in emailQuery.docs) {
  //     userMap[doc.id] = doc.data() as Map<String, dynamic>;
  //   }

  //   QuerySnapshot nameQuery = await users
  //       .where('fullname', isGreaterThanOrEqualTo: keyword)
  //       .where('fullname', isLessThan: '$keyword\uf8ff')
  //       .where('fullname', isEqualTo: keyword)
  //       .get();

  //   for (var doc in nameQuery.docs) {
  //     userMap[doc.id] = doc.data() as Map<String, dynamic>;
  //   }

  //   // Chuyển đổi map thành danh sách UserModel sử dụng hàm fromMap
  //   List<UserModel> userList = userMap.values.map((userData) {
  //     return UserModel.fromMap(userData);
  //   }).toList();

  //   return userList;
  // }

  Future<List<UserModel>> searchUsers(String keyword) async {
    keyword = keyword.toLowerCase();

    // Tham chiếu tới collection "users"
    QuerySnapshot query;

    // Kiểm tra nếu keyword là email (có dấu "@")
    if (keyword.contains('@')) {
      // Tìm kiếm theo email
      query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: keyword)
          .get();
    } else {
      // Tìm kiếm theo các từ khóa liên quan
      query = await FirebaseFirestore.instance
          .collection('users')
          .where('searchKeywords', arrayContains: keyword)
          .get();
    }

    // Chuyển đổi dữ liệu từ Firebase thành danh sách UserModel
    List<UserModel> users = query.docs.map((doc) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return users;
  }

  // Hợp nhất kết quả từ email và fullname
  // Set<Map<String, dynamic>> resultsSet = {};
  // Set<String> uniqueEmails = {}; // Set để theo dõi email đã được thêm vào

  // // Thêm kết quả từ emailQuery
  // for (var doc in emailQuery.docs) {
  //   var data = doc.data() as Map<String, dynamic>;
  //   String email = data['email']; // Lấy email
  //   // Chỉ thêm nếu email chưa có trong danh sách uniqueEmails
  //   if (!uniqueEmails.contains(email)) {
  //     resultsSet.add(data);
  //     uniqueEmails.add(email); // Thêm email vào danh sách đã thấy
  //   }
  // }

  // // Thêm kết quả từ nameQuery
  // for (var doc in nameQuery.docs) {
  //   var data = doc.data() as Map<String, dynamic>;
  //   String email = data['email']; // Lấy email
  //   // Chỉ thêm nếu email chưa có trong danh sách uniqueEmails
  //   if (!uniqueEmails.contains(email)) {
  //     resultsSet.add(data);
  //     uniqueEmails.add(email); // Thêm email vào danh sách đã thấy
  //   }
  // }

  // return resultsSet.toList();

  // Hàm tìm kiếm người dùng dựa vào fullName hoặc email và trả về list ModelUser
  // Future<List<UserModel>> searchUsers(String keyword) async {
  //   if (keyword.isEmpty) {
  //     return [];
  //   }

  //   try {
  //     QuerySnapshot querySnapshot = await _firestore
  //         .collection('users')
  //         .orderBy('fullName')
  //         .startAt([keyword])
  //         .endAt([keyword + '\uf8ff'])
  //         .get();

  //     Chuyển đổi từ DocumentSnapshot thành ModelUser
  //     List<UserModel> users = querySnapshot.docs.map((doc) {
  //       return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  //     }).toList();

  //     return users;
  //   } catch (error) {
  //     print("Lỗi tìm kiếm: $error");
  //     return [];
  //   }
  // }

  Future<List<Map<String, String>>> getListGroupForCurrentUser(
      String currentUserId) async {
    // Lấy danh sách các nhóm (channels) mà người dùng hiện tại là thành viên
    QuerySnapshot querySnapshot = await _firestore
        .collection('channel') // Tên collection là 'channel'
        .where('memberIds', arrayContains: currentUserId)
        .get();

    // Chuyển đổi kết quả thành danh sách Map với 'id' và 'name' của nhóm
    List<Map<String, String>> groups = querySnapshot.docs.map((doc) {
      return {
        'id': doc.id, // ID của tài liệu (nhóm)
        'name': doc['channelName']
            as String // Lấy tên của nhóm từ trường 'channelName'
      };
    }).toList();

    return groups;
  }
}
