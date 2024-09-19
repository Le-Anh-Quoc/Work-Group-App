import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruprup/services/friend_service.dart';
import 'package:ruprup/services/notification_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // tìm kiếm người dùng khác bằng email
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

  // lấy fullName của người dùng hiện tại
  Future<String?> getCurrentUserFullName() async {
    try {
      // Lấy uid của người dùng hiện tại
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        return null; // Người dùng không đăng nhập
      }

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

  // người dùng hiện tại gửi yêu cầu kết bạn tới người dùng khác
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

  // người dùng chấp nhận lời mời kết bạn
  Future<void> acceptFriendRequest(
      String currentUserId, String friendUserId) async {
    try {
      FriendService friend = FriendService();
      NotificationService notification = NotificationService();

      // 1. Cập nhật trạng thái chấp nhận kết bạn
      await friend.updateAcceptFriendRequestStatus(currentUserId, friendUserId);

      // 2. Cập nhật danh sách bạn bè
      await friend.updateFriendLists(currentUserId, friendUserId);

      // 3. Gửi thông báo tới tài khoản đã gửi lời mời
      await notification.sendNotificationToRequester(
          friendUserId, currentUserId);

      print("Friend request accepted and notification sent.");
    } catch (e) {
      print("Error accepting friend request: $e");
    }
  }

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
}
