import 'package:cloud_firestore/cloud_firestore.dart';

// Enum cho trạng thái cuộc họp
enum MeetingStatus { upcoming, ongoing, ended }

class Meeting {
  final String meetingId;
  final String meetingTitle;
  final DateTime startTime;
  final DateTime? endTime;
  final MeetingStatus status; // Thay isOngoing bằng MeetingStatus
  final List<String> participants;

  Meeting({
    required this.meetingId,
    required this.meetingTitle,
    required this.startTime,
    this.endTime,
    required this.status,
    this.participants = const [],
  });

  // Chuyển đổi trạng thái từ Firestore document sang MeetingStatus
  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      meetingId: map['meetingId'],
      meetingTitle: map['meetingTitle'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: map['endTime'] != null ? (map['endTime'] as Timestamp).toDate() : null,
      status: _statusFromString(map['status'] ?? 'upcoming'),
      participants: List<String>.from(map['participants'] ?? []),
    );
  }

  // Chuyển đổi MeetingStatus sang dạng String để lưu trữ vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'meetingId': meetingId,
      'meetingTitle': meetingTitle,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'status': status.toString().split('.').last, // Lưu dưới dạng chuỗi
      'participants': participants,
    };
  }

  // Phương thức helper để chuyển đổi chuỗi từ Firestore thành MeetingStatus
  static MeetingStatus _statusFromString(String status) {
    switch (status) {
      case 'ongoing':
        return MeetingStatus.ongoing;
      case 'ended':
        return MeetingStatus.ended;
      case 'upcoming':
      default:
        return MeetingStatus.upcoming;
    }
  }
}
