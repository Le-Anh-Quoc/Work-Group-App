enum NotificationType {
  friend, // Giá trị cho bạn bè
  friendInvite, // Giá trị cho lời mời kết bạn
  group, // Giá trị cho thông báo nhóm
  groupMeeting, // Giá trị cho thông báo cuộc họp nhóm
  task, // Giá trị cho công việc
  project, // Giá trị cho liên quan đến dự án
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
      case NotificationType.groupMeeting:
        return 'groupMeeting';
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
      case 'groupMeeting':
        return NotificationType.groupMeeting;
      case 'task':
        return NotificationType.task;
      case 'project':
        return NotificationType.project;
      default:
        throw Exception('Invalid NotificationType: $value');
    }
  }
}
