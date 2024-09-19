import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ruprup/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // lấy tin nhắn
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
                recipientId: data['recipientId'],
                content: data['content'],
                timestamp:
                    (data['timestamp'] as Timestamp).millisecondsSinceEpoch,
              );
            }).toList());
  }

  // gửi tin nhắn
  Future<void> sendMessage(MessageModel message, String chatId) async {
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
    });

    await _db.collection('chats').doc(chatId).set({
      'userIds': [message.senderId, message.recipientId],
      'lastMessage': message.content,
      'timestamp': Timestamp.fromMillisecondsSinceEpoch(message.timestamp),
    }, SetOptions(merge: true));
  }

  // Hàm lấy tin nhắn mới nhất từ tài liệu của cuộc trò chuyện
  Stream<Map<String, dynamic>> getLastMessageStream(String chatId) {
    return _db.collection('chats').doc(chatId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        // Extracting the data from the snapshot
        String? lastMessage = snapshot.get('lastMessage') as String?;
        List<dynamic> userIds = snapshot.get('userIds') as List<dynamic>;

        // Assuming userIds always contain exactly 2 values
        String user0 = userIds.isNotEmpty ? userIds[0] as String : '';
        String user1 = userIds.length > 1 ? userIds[1] as String : '';

        return {
          'lastMessage': lastMessage,
          'user0': user0,
          'user1': user1,
        };
      }
      // Return empty map if document does not exist
      return {};
    });
  }

  // khi 2 người dùng bắt đầu đoạn chat với nhau
  Future<void> startChat(String otherUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception("User is not logged in");
    }

    final chatId = generateChatId(currentUserId, otherUserId);

    await _db.collection('chats').doc(chatId).set({
      'userIds': [currentUserId, otherUserId],
      'lastMessage': '',
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String generateChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }
}
