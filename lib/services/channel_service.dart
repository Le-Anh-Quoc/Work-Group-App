// ignore_for_file: prefer_is_not_operator, unnecessary_cast

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
        projectIds: [],
        channelName: roomChat.nameRoom, // Sử dụng tên phòng từ roomChat
        adminId: roomChat.userIds[0], // Giả định người đầu tiên là admin
        memberIds: roomChat.userIds
            .map((user) => user)
            .toList(), // Lấy danh sách ID người dùng
        createdAt: roomChat.createAt, // Thời gian tạo
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

  Future<void> updateChannelMembers(String channelId, List<String> membersToAdd,
      List<String> membersToRemove) async {
    final channelRef =
        FirebaseFirestore.instance.collection('channel').doc(channelId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(channelRef);
      if (!snapshot.exists) {
        throw Exception("Channel không tồn tại.");
      }

      List<String> currentMembers =
          List<String>.from(snapshot['memberIds'] ?? []);
      currentMembers.addAll(membersToAdd);
      currentMembers.removeWhere((member) => membersToRemove.contains(member));

      transaction.update(channelRef, {'memberIds': currentMembers});
    });
  }

  Future<void> renameChannel(String channelId, String newName) async {
    try {
      final channelRef =
          FirebaseFirestore.instance.collection('channel').doc(channelId);

      // Kiểm tra xem channel có tồn tại không
      final snapshot = await channelRef.get();
      if (!snapshot.exists) {
        throw Exception("Channel với ID $channelId không tồn tại.");
      }

      // Cập nhật tên mới
      await channelRef.update({'channelName': newName});
      print("Đã đổi tên channel thành công.");
    } catch (e) {
      print("Lỗi khi đổi tên channel: $e");
    }
  }

  Future<int> countChannelsByUserId(String userId) async {
    // Truy vấn các channel mà userId có trong memberIds
    QuerySnapshot snapshot = await _firestore
        .collection('channel')
        .where('memberIds',
            arrayContains: userId) // Kiểm tra nếu userId có trong memberIds
        .get();

    return snapshot.size; // Trả về số lượng channel
  }
}
