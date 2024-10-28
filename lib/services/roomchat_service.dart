import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/room_model.dart';
import 'package:ruprup/services/channel_service.dart';

class RoomChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ChannelService channelService = ChannelService();

  Future<RoomChat> createRoomChat(RoomChat roomChat) async {
    // Tạo tài liệu mới với ID tự sinh cho group
    DocumentReference groupDocRef =
        await _firestore.collection('chats').add(roomChat.toMap());

    // Lấy ID tự sinh và thêm nó vào ID của RoomChat
    String newRoomId = groupDocRef.id;

    // Cập nhật lại ID cho tài liệu đã tạo
    await groupDocRef.update({'idRoom': newRoomId});

    // Nếu loại là group, tạo một kênh tương ứng
    if (roomChat.type == 'group') {
      await channelService.createChannel(roomChat, newRoomId);
    }

    // Tạo đối tượng RoomChat mới với ID đã cập nhật
    RoomChat updatedRoomChat = RoomChat(
      idRoom: newRoomId,
      type: roomChat.type,
      lastMessage: roomChat.lastMessage,
      userIds: roomChat.userIds,
      nameRoom: roomChat.nameRoom,
      imageUrl: roomChat.imageUrl,
      createAt: roomChat.createAt,
    );

    // Trả về đối tượng RoomChat vừa tạo
    return updatedRoomChat;
  }

  Future<RoomChat?> getRoomChat(String idRoom) async {
    final doc = await _firestore.collection('rooms').doc(idRoom).get();
    if (doc.exists) {
      final data = doc.data()!;
      return RoomChat(
        idRoom: data['idRoom'],
        type: data['type'],
        lastMessage: data['lastMessage'],
        userIds: List<String>.from(data['users']),
        nameRoom: data['nameRoom'],
        imageUrl: data['imageUrl'],
        createAt: data['createAt'],
      );
    }
    return null;
  }

  Future<void> updateRoomChat(RoomChat roomChat) async {
    await _firestore.collection('rooms').doc(roomChat.idRoom).update({
      'lastMessage': roomChat.lastMessage,
      'userIds': roomChat.userIds,
      'nameRoom': roomChat.nameRoom,
      'imageUrl': roomChat.imageUrl,
      'createAt': roomChat.createAt,
    });
  }

  Future<void> deleteRoomChat(String idRoom) async {
    await _firestore.collection('rooms').doc(idRoom).delete();
  }

  Stream<List<RoomChat>> getChatsOfCurrentUser(String userId) {
    return _firestore
        .collection('chats')
        .where('userIds',
            arrayContains:
                userId) // Lấy các chat mà userId là một phần của mảng userIds
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RoomChat.fromMap(doc.data());
      }).toList();
    });
  }
}
