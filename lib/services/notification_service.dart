import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruprup/services/user_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserService user = UserService();

  // hàm này dùng để lấy tất cả các thông báo của người dùng hiện tại đang đăng nhập
  Future<List<Map<String, dynamic>>> getNotificationsOfCurrentUser() async {
    try {
      // Lấy uid của người dùng hiện tại
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception("User is not logged in");
      }

      // ignore: avoid_print
      print(currentUserId);
      // Truy vấn tất cả thông báo của người dùng hiện tại từ Firestore
      QuerySnapshot notificationsSnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('recipientId',
              isEqualTo: currentUserId) // Lọc theo recipientId
          // .orderBy('timestamp',
          //     descending: true) // Sắp xếp theo thời gian giảm dần
          .get();

      // ignore: avoid_print
      print(
          'Notifications Snapshot: ${notificationsSnapshot.docs.length} documents found');

      // Chuyển đổi các tài liệu trong snapshot thành danh sách các Map
      List<Map<String, dynamic>> notifications = notificationsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      // ignore: avoid_print
      print('Notifications: $notifications');
      return notifications;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting user notifications: $e');
      return [];
    }
  }

  // hàm này dùng để tạo thông báo về lời mời kết bạn đến TargetUser
  Future<void> sendFriendRequestNotification(
      String currentUserId, String targetUserId) async {
    try {
      final notificationDoc = _firestore.collection('notifications').doc();

      String? currentUserFullName = await user.getCurrentUserFullName();

      await notificationDoc.set({
        'recipientId': targetUserId, // Người dùng nhận thông báo
        'senderId': currentUserId, // Người gửi lời mời kết bạn
        'type': 'friend_request', // Loại thông báo
        'message':
            'You just received a friend request from $currentUserFullName.',
        'isRead': false, // Trạng thái đọc thông báo
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ignore: avoid_print
      print('Thông báo đã được gửi đi cho người dùng mục tiêu');
    } catch (e) {
      // ignore: avoid_print
      print('Lỗi khi tạo thông báo: $e');
    }
  }

  // hàm này dùng để gửi thông báo tới userRequester đã chấp nhận lời mời kết bạn
  Future<void> sendNotificationToRequester(
      String friendUserId, String currentUserId) async {
    try {
      final notificationRef =
          FirebaseFirestore.instance.collection('notifications').doc();

      String? currentUserFullName = await user.getCurrentUserFullName();

      await notificationRef.set({
        'recipientId': friendUserId, // Người nhận thông báo
        'senderId': currentUserId, //Người chấp nhấn lời mời kết bạn
        'type': 'friend_accepted',
        'message': '$currentUserFullName accepted your friend request.',
        'isRead': false,
        'timeStamp': FieldValue.serverTimestamp(),
      });

      // ignore: avoid_print
      print("Thông báo tới người dùng lời mời kết bạn đã được chấp nhận");

    } catch (e) {
      // ignore: avoid_print
      print('Lỗi khi tạo thông báo: $e');
    }
  }
}
