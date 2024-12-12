import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  friend, // Giá trị cho bạn bè
  friendInvite, // Giá trị cho lời mời kết bạn
  group, // Giá trị cho thông báo nhóm
  //groupMeeting, // Giá trị cho thông báo cuộc họp nhóm
  task, // Giá trị cho công việc
  project, // Giá trị cho liên quan đến dự án
}
class NotificationUser {
  final String id; // ID của thông báo
  final String useredId; // ID người nhận thông báo
  final String body; // Nội dung thông báo
  final NotificationType type; // Loại thông báo (friendInvite, group, task, project)
  final bool isRead; // Trạng thái đã đọc hay chưa
  final DateTime timestamp; // Thời gian tạo thông báo

  NotificationUser({
    required this.id,
    required this.useredId,
    required this.body,
    required this.type,
    required this.isRead,
    required this.timestamp,
  });
  // Tạo từ Firestore DocumentSnapshot
  factory NotificationUser.fromMap(
      Map<String, dynamic> map) {
    return NotificationUser(
      id: map['id'],
      useredId: map['useredId'] ?? '',
      body: map['body'] ?? '',
      type:NotificationTypeExtension.fromString(map['type'] ?? ''),
      isRead: map['isRead'] ?? false,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  // Chuyển sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': useredId,
      'body': body,
      'type':  type.toString().split('.').last,// chuyển trành string
      'isRead': isRead,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
  
}
extension NotificationTypeExtension on NotificationType {
    String get value {
      switch (this) {
        case NotificationType.friend:
          return 'friend';
        case NotificationType.friendInvite:
          return 'friendInvite';
        case NotificationType.group:
          return 'group';
        case NotificationType.task:
          return 'task';
        case NotificationType.project:
          return 'project';
      }
    }


  static NotificationType fromString(String value) {
    switch (value) {
      case 'friend':
        return NotificationType.friend;
      case 'friendInvite':
        return NotificationType.friendInvite;
      case 'group':
        return NotificationType.group;
      // case 'groupMeeting':
      //   return NotificationType.groupMeeting;
      case 'task':
        return NotificationType.task;
      case 'project':
        return NotificationType.project;
      default:
        throw Exception('Invalid NotificationType: $value');
    }
  }
}
