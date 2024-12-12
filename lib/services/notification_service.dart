import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruprup/models/notification_model.dart';
import 'package:ruprup/services/user_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserService user = UserService();
  //Gui tin notificatu nguoi dung hien tại thực hiện đến người nhận
  Future<void> createNotification(String useredId, NotificationUser notifica) async {
    try {
     DocumentReference NotiDocRef = await _firestore
          .collection('users')
          .doc(useredId)
          .collection('notification')
          .add(notifica.toMap());
      print("Send notification successfully!");
      String id = NotiDocRef.id;
      await NotiDocRef.update({'id':id});
    } catch (e) {
      print("Error send notification: $e");
    }
  }
  Stream<List<NotificationUser>> getAllNotifica(userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('notification')
          .snapshots() // Lắng nghe dữ liệu liên tục
          .map((snapshot) {
        // Chuyển dữ liệu từ Firestore sang danh sách Notifica
        final notifications =
            snapshot.docs.map((doc) => NotificationUser.fromMap(doc.data())).toList();
        print("danh sach  $notifications");
        //Sắp xếp danh sách dựa trên  startTime
        notifications.sort((a, b) {
          
            int aTime = a.timestamp.millisecondsSinceEpoch;
            int bTime = b.timestamp.millisecondsSinceEpoch;
            return (aTime).compareTo(bTime);
          ;
        });

        return notifications;
      });
    } catch (e) {
      print("Error fetching notifications: $e");
      return const Stream.empty(); // Trả về Stream rỗng nếu có lỗi
    }
  }
  // hàm này dùng để lấy tất cả các thông báo của người dùng hiện tại đang đăng nhập
  Future<List<Map<String, dynamic>>> getNotificationsOfCurrentUser() async {
    try {
      // Lấy uid của người dùng hiện tại
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

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
//   Stream<List<Notification>> getUserNotifications(String userId) {
//   return FirebaseFirestore.instance
//       .collection('notifications')
//       .where('userId', isEqualTo: userId)
//       .orderBy('timestamp', descending: true)
//       .snapshots()
//       .map((snapshot) => snapshot.docs
//           .map((doc) =>
//               Notification.fromMap(doc.id, doc.data()))
//           .toList());
// }
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
