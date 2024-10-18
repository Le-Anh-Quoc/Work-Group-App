import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// enum RoomChatType {
//   group,
//   direct
// }

// extension RoomChatTypeExtension on RoomChatType {
//   String get value {
//     switch (this) {
//       case RoomChatType.group:
//         return 'group';
//       case RoomChatType.direct:
//         return 'direct';
//     }
//   }

//   static RoomChatType fromString(String value) {
//     switch (value) {
//       case 'group':
//         return RoomChatType.group;
//       case 'direct':
//         return RoomChatType.direct;
//       default:
//         throw Exception('Invalid NotificationType: $value');
//     }
//   }
// }

class RoomChat {
  final String idRoom;
  final String type;
  final String? lastMessage;
  final List<String> userIds; // Danh sách userId thay vì đối tượng UserModel
  final String nameRoom;
  final String? imageUrl;
  final int createAt;

  RoomChat({
    required this.idRoom,
    required this.type,
    this.lastMessage,
    required this.userIds,
    required this.nameRoom,
    this.imageUrl,
    required this.createAt,
  });

  // Chuyển đổi đối tượng RoomChat thành Map
  Map<String, dynamic> toMap() {
    return {
      'idRoom': idRoom,
      'type': type,
      'lastMessage': lastMessage,
      'userIds': userIds, // Lưu danh sách userId
      'nameRoom': nameRoom,
      'imageUrl': imageUrl,
      'createAt': createAt,
    };
  }

  // Chuyển đổi Map thành đối tượng RoomChat
  factory RoomChat.fromMap(Map<String, dynamic> map) {
    return RoomChat(
      idRoom: map['idRoom'],
      type: map['type'],
      lastMessage: map['lastMessage'],
      userIds: List<String>.from(map['userIds']), // Chuyển đổi danh sách userId
      nameRoom: map['nameRoom'],
      imageUrl: map['imageUrl'],
      createAt: map['createAt'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }
}
