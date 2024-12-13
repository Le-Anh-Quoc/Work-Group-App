import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/channel/channel_model.dart';
import 'package:ruprup/models/room_model.dart';
import 'package:ruprup/utils/searchKeyWord.dart';

class ChannelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'channel'; // Tên collection trong Firestore

  // 1. Tạo một nhóm mới với ID tự động sinh (Create)
  Future<void> createChannel(RoomChat roomChat, String groupChatId) async {
    // Tạo đối tượng Channel từ roomChat
    Channel newChannel = Channel(
        channelId: '', // Sẽ tự sinh ID
        groupChatId: groupChatId, // ID của group liên kết với channel
        projectId: [],
        channelName: roomChat.nameRoom, // Sử dụng tên phòng từ roomChat
        adminId: roomChat.userIds[0], // Giả định người đầu tiên là admin
        memberIds: roomChat.userIds
            .map((user) => user)
            .toList(), // Lấy danh sách ID người dùng
        createdAt: DateTime.now(), // Thời gian tạo
        searchKeywords: generateSearchKeywords(roomChat.nameRoom));

    // Thêm channel vào Firestore và lấy DocumentReference
    DocumentReference docRef =
        await _firestore.collection(collection).add(newChannel.toMap());

    // Lấy ID tự sinh từ Firebase và cập nhật channelId
    String newChannelId = docRef.id;
    await docRef.update(
        {'channelId': newChannelId}); // Cập nhật lại channelId trong tài liệu
  }

  // 2. Đọc một nhóm (Read)
  Future<Channel?> getChannel(String channelId) async {
    DocumentSnapshot doc =
        await _firestore.collection(collection).doc(channelId).get();
    if (doc.exists) {
      return Channel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // 3. Cập nhật một nhóm (Update)
  Future<void> updateGroup(Channel channel) async {
    await _firestore
        .collection(collection)
        .doc(channel.channelId)
        .update(channel.toMap());
  }

  // 4. Xóa một nhóm (Delete)
  Future<void> deleteChannel(String channelId) async {
    await _firestore.collection(collection).doc(channelId).delete();
  }

  // lấy thông tin của một group dựa vào groupChatId
  // Future<Group?> getGroupByChatId(String groupChatId) async {
  //   QuerySnapshot querySnapshot = await _firestore
  //       .collection(collection)
  //       .where('groupChatId', isEqualTo: groupChatId)
  //       .limit(1) // Giới hạn 1 kết quả
  //       .get();

  //   if (querySnapshot.docs.isNotEmpty) {
  //     return Group.fromMap(
  //         querySnapshot.docs.first.data() as Map<String, dynamic>);
  //   }
  //   return null;
  // }

  // Hàm lấy tất cả các group mà người dùng hiện tại đang tham gia
  Future<List<Channel>> getChannelsForCurrentUser(String currentUserId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(collection)
          .where('memberIds',
              arrayContains:
                  currentUserId) // Kiểm tra người dùng có trong memberIds
          .get();

      // Chuyển đổi kết quả truy vấn thành danh sách Channel
      List<Channel> channels = querySnapshot.docs.map((doc) {
        // Đảm bảo rằng doc.data() không null và đúng kiểu Map<String, dynamic>
        final data = doc.data() as Map<String, dynamic>;
        return Channel.fromMap(data);
      }).toList();

      return channels;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching channels: $e');
      return []; // Trả về danh sách rỗng trong trường hợp lỗi
    }
  }

  Future<List<Channel>> searchChannels(
      String keyword, String currentUserId) async {
    keyword = keyword.toLowerCase();

    // Truy vấn các kênh mà currentUserId là thành viên
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('channel')
        .where('memberIds', arrayContains: currentUserId)
        .get();

    // Lọc kết quả theo keyword trong 'searchKeywords'
    List<Channel> channels = query.docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;

      // Kiểm tra xem trường 'searchKeywords' có tồn tại và không phải là null
      var searchKeywords = data['searchKeywords'];
      if (searchKeywords == null || !(searchKeywords is List)) {
        return false; // Nếu 'searchKeywords' không phải là một List, bỏ qua tài liệu này
      }

      // Lọc những kênh mà 'searchKeywords' chứa keyword
      return (searchKeywords as List).contains(keyword);
    }).map((doc) {
      return Channel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();

    return channels;
  }
}
