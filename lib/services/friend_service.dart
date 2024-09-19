import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  Future<List<Map<String, dynamic>>> getFriendsOfCurrentUser() async {
    try {
      // Lấy uid của người dùng hiện tại
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception("User is not logged in");
      }

      // Tham chiếu đến tài liệu người dùng hiện tại
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        // Lấy danh sách bạn bè từ tài liệu người dùng
        List<String> friendIds =
            List<String>.from(userDoc.get('friends') ?? []);

        // Nếu không có bạn bè, trả về danh sách trống
        if (friendIds.isEmpty) {
          return [];
        }

        // Truy vấn thông tin chi tiết của bạn bè từ Firestore
        QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: friendIds)
            .get();

        // Chuyển đổi danh sách tài liệu thành danh sách các Map, bao gồm cả ID tài liệu
        List<Map<String, dynamic>> friendsList =
            friendsSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['uid'] = doc.id; // Thêm ID tài liệu vào Map
          return data;
        }).toList();

        print('Friends List: $friendsList');
        return friendsList;
      } else {
        print('No user document found for current user.');
        return [];
      }
    } catch (e) {
      print('Error getting friends list: $e');
      return [];
    }
  }

  // cập nhật trạng thái đã chấp nhận lời mời kết bạn
  Future<void> updateAcceptFriendRequestStatus(
      String currentUserId, String friendUserId) async {
    try {
      final friendRequestRef = FirebaseFirestore.instance
          .collection('friends')
          .doc('${friendUserId}_$currentUserId');

      await friendRequestRef.update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("có lỗi khi chấp nhận lời mời kết bạn: $e");
    }
  }

  // cập nhật trạng thái đã từ chối lời mời kết bạn
  Future<void> updateRejectFriendRequestStatus(
      String currentUserId, String friendUserId) async {
    try {
      final friendRequestRef = FirebaseFirestore.instance
          .collection('friends')
          .doc('${currentUserId}_$friendUserId');

      await friendRequestRef.update({
        'status': 'rejected',
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("có lỗi khi từ chối lời mời kết bạn: $e");
    }
  }

  // cập nhật lại danh sách bạn bè của 2 người đã kết bạn với nhau
  Future<void> updateFriendLists(
      String currentUserId, String friendUserId) async {
    try {
      final currentUserRef =
          FirebaseFirestore.instance.collection('users').doc(currentUserId);
      final friendUserRef =
          FirebaseFirestore.instance.collection('users').doc(friendUserId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Thêm friendUserId vào danh sách bạn bè của currentUserId
        transaction.update(currentUserRef, {
          'friends': FieldValue.arrayUnion([friendUserId]),
        });

        // Thêm currentUserId vào danh sách bạn bè của friendUserId
        transaction.update(friendUserRef, {
          'friends': FieldValue.arrayUnion([currentUserId]),
        });
      });

      print("Đã cập nhật danh sách bạn bè của 2 người thành công");
    } catch (e) {
      print("đã có lỗi khi cập nhật danh sách bạn bè: $e");
    }
  }
}
