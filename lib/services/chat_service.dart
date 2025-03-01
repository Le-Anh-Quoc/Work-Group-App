// ignore_for_file: avoid_print, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:path/path.dart';
// import 'package:provider/provider.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruprup/models/message_model.dart';
import 'package:ruprup/models/user_model.dart';
// import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/services/user_notification.dart';
// import 'package:ruprup/services/user_service.dart';
//import 'package:ruprup/services/user_notification.dart';
//import 'package:ruprup/services/user_notification.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return MessageModel(
                id: doc.id,
                senderId: data['senderId'],
                recipientId: List<String>.from(data['recipientId'] ?? []),
                content: data['content'],
                timestamp:
                    (data['timestamp'] as Timestamp).millisecondsSinceEpoch,
                type: data['type'],
              );
            }).toList());
  }

  // gửi tin nhắn
  Future<void> sendMessage(MessageModel message, String chatId,
      Map<String, UserModel> userModels) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .set({
      'senderId': message.senderId,
      'recipientId': message.recipientId,
      'content': message.content,
      'timestamp': Timestamp.fromMillisecondsSinceEpoch(message.timestamp),
      'type': message.type
    });

    //  await FirebaseAPI().sendPushNotification(, message.content);
    await _db.collection('chats').doc(chatId).set({
      //'userIds': [message.senderId, message.recipientId],
      'lastMessage': message.content,
      'timestamp': Timestamp.fromMillisecondsSinceEpoch(message.timestamp),
    }, SetOptions(merge: true));

    DocumentSnapshot userDoc =
        await _db.collection('users').doc(_auth.currentUser!.uid).get();
    String name = userDoc['fullname'];
    print('ten nguoi dung hien tai $name');
    List<String> pushTokens = userModels.values
        .map((user) => user.pushToken)
        .where((token) => token.isNotEmpty)
        .toList();
    print(pushTokens);
    if (pushTokens.isNotEmpty) {
      for (String pushToken in pushTokens) {
        await FirebaseAPI()
            .sendPushNotification(pushToken, message.content, name);
      }
    }
  }

  // Hàm lấy tin nhắn mới nhất từ tài liệu của cuộc trò chuyện
  Stream<Map<String, dynamic>> getLastMessageStream(String chatId) {
    return _db.collection('chats').doc(chatId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        String? lastMessage = snapshot.get('lastMessage') as String?;
        List<dynamic> userIds = snapshot.get('userIds') as List<dynamic>;
        String nameRoom = snapshot.get('nameRoom');
        int createAt = snapshot.get('createAt');
        Timestamp lassTimeMessage = snapshot.get('timestamp');
        return {
          'lastMessage': lastMessage,
          'userIds': userIds,
          'createAt': createAt,
          'nameRoom': nameRoom,
          'timestamp': lassTimeMessage,
        };
      }
      return {};
    });
  }

  Stream<Map<String, dynamic>> getLastTimeChat(String chatId) {
    return _db.collection('chats').doc(chatId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        String? lastMessage = snapshot.get('lastMessage') as String?;
        List<dynamic> userIds = snapshot.get('userIds') as List<dynamic>;
        String nameRoom = snapshot.get('nameRoom');
        int createAt = snapshot.get('createAt');

        return {
          'lastMessage': lastMessage,
          'userIds': userIds,
          'createAt': createAt,
          'nameRoom': nameRoom,
        };
      }
      return {};
    });
  }

  // Tạo nhóm hoặc chat 1vs1
  Future<String> createChat(List<String> userIds) async {
    // Xử lý trường hợp nhóm hoặc 1vs1
    String chatId = userIds.length == 2
        ? generateChatId(userIds[0], userIds[1])
        : _db.collection('chats').doc().id; // Chat nhóm có ID mới

    await _db.collection('chats').doc(chatId).set({
      'userIds': userIds,
      //if (groupName != null) 'groupName': groupName,
      'lastMessage': '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    return chatId;
  }

  // // Khởi tạo chat 1vs1 hoặc nhóm
  // Future<void> startChat(List<String> userIds, {String? groupName}) async {
  //   if (userIds.isEmpty) return;

  //   // Tạo ID chat dựa trên loại chat
  //   String chatId = await createChat(userIds, groupName: groupName);
  //   // Điều hướng sang màn hình chat
  //   // Navigator.push(...); // Điều hướng đến màn hình chat với chatId
  // }

  // Tạo ID cho chat 1vs1
  String generateChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Đảm bảo thứ tự không đổi
    return '${ids[0]}_${ids[1]}';
  }

  // Hàm lấy danh sách các cuộc trò chuyện mà người dùng hiện tại tham gia
  Stream<List<Map<String, dynamic>>> getChatsOfCurrentUser(String userId) {
    return _db
        .collection('chats')
        .where('userIds',
            arrayContains:
                userId) // Lấy các chat mà userId là một phần của mảng userIds
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'chatId': doc.id,
          'lastMessage': doc['lastMessage'],
          'createAt': doc['createAt'],
          // Thêm các trường khác nếu cần
        };
      }).toList();
    });
  }

  // lấy thông tin chi tiết của đoạn
  Future<Map<String, dynamic>> getChatDetails(String chatId) async {
    Map<String, dynamic> chatDetails = {};

    // Lấy thông tin chat
    DocumentSnapshot chatSnapshot =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

    if (!chatSnapshot.exists) {
      throw Exception('Chat not found');
    }

    //chatDetails['groupName'] = chatSnapshot['groupName'];
    chatDetails['chatInfo'] = chatSnapshot.data();

    List<dynamic> userIds = chatSnapshot['userIds'];

    // Lấy thông tin người dùng tham gia vào chat
    List<Map<String, dynamic>> users = [];
    for (var userId in userIds) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        // Lấy dữ liệu người dùng và thêm `id`
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        userData['id'] = userSnapshot.id; // Thêm `id` vào dữ liệu người dùng
        users.add(userData);
      }
    }
    chatDetails['users'] = users;

    // ignore: avoid_print
    print('1');
    // ignore: avoid_print
    print(chatDetails['users']);

    // Lấy tin nhắn trong chat
    QuerySnapshot messagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> messages = messagesSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    chatDetails['messages'] = messages;

    return chatDetails;
  }

  Stream<List<Map<String, dynamic>>> getChatUpdatesForUser(String userId) {
    return _db
        .collection('chats')
        .where('userIds',
            arrayContains:
                userId) // Assuming `userIds` contains the current user's ID
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'chatId': doc.id,
          'lastMessage': doc['lastMessage'],
          'timestamp': doc['timestamp'], // Ensure the timestamp is present
          // Add other fields as necessary
        };
      }).toList();
    });
  }

  Future<void> deleteRoomChat(String roomId) async {
    // Xóa RoomChat
    await _db.collection('chats').doc(roomId).delete();
  }

  Future<bool> checkIfRoomHasMessages(String roomId) async {
    final roomDoc = await _db.collection('chats').doc(roomId).get();

    // Kiểm tra nếu document tồn tại và lastMessage không phải là null hoặc rỗng
    if (roomDoc.exists && roomDoc.data() != null) {
      final data = roomDoc.data() as Map<String, dynamic>;
      return data['lastMessage'] != null &&
          data['lastMessage'].toString().trim().isNotEmpty;
    }

    return false; // Trả về false nếu không tồn tại hoặc lastMessage là null
  }
}
