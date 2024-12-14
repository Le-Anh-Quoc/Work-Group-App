// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/transcoder/v1.dart';
import 'package:ruprup/models/channel/meeting_model.dart';
import 'package:ruprup/services/user_notification.dart';

class MeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth  get _auth => FirebaseAuth.instance;
  // Tạo cuộc họp mới
  Future<void> createMeeting(String channelId, Meeting meeting) async {
    try {
      await _firestore
          .collection('channel')
          .doc(channelId)
          .collection('meetings')
          .add(meeting.toMap());
      print("Meeting created successfully!");
    } catch (e) {
      print("Error creating meeting: $e");
    }
    String name='Đã tạo một cuộc họp';
    DocumentSnapshot docSnapShot= await _firestore
    .collection('channel')
    .doc(channelId)
    .get();
    String GroupChatId;
    GroupChatId = docSnapShot['groupChatId'];
    DocumentSnapshot docPushToken= await _firestore
    .collection('chats')
    .doc(GroupChatId)
    .get();
    List<dynamic> userIds = docPushToken['userIds'];
    String currentId= _auth.currentUser!.uid;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentId).get();
    String names= userDoc['fullname'];
      for (String userId in userIds) {
         print('userid: $userId  và it hien tai $currentId');
        if(userId == _auth.currentUser!.uid){
          print('userid: $userId  và it hien tai $currentId');
          continue;
        }
        try{
          //Lấy thông tin user từ collection 'users' theo userId
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
        // if(userId == _auth.currentUser!.uid) return;
        // else{
          if (userDoc.exists) {
          // Lấy trường pushToken từ document của user
          String pushToken = userDoc['pushToken'];
          
            await FirebaseAPI().sendPushNotification(pushToken,name,names);
          // In ra pushToken của user
          print('Push Token for $userId: $pushToken');
        } 
        }catch (e)  {
          print('User not found: $userId');
        }
      }
  }

  // Lấy tất cả các cuộc họp của một kênh
  Stream<List<Meeting>> getAllMeetings(String channelId) {
    try {
      return _firestore
          .collection('channel')
          .doc(channelId)
          .collection('meetings')
          .snapshots() // Lắng nghe dữ liệu liên tục
          .map((snapshot) {
        // Chuyển dữ liệu từ Firestore sang danh sách Meeting
        final meetings =
            snapshot.docs.map((doc) => Meeting.fromMap(doc.data())).toList();

        // Sắp xếp danh sách dựa trên status và startTime
        meetings.sort((a, b) {
          const statusOrder = {
            MeetingStatus.ongoing: 0,
            MeetingStatus.upcoming: 1,
            MeetingStatus.ended: 2,
          };

          // So sánh theo status trước
          final statusComparison =
              statusOrder[a.status]!.compareTo(statusOrder[b.status]!);

          // Nếu status giống nhau, so sánh theo startTime
          if (statusComparison == 0) {
            return a.startTime.compareTo(b.startTime);
          }

          return statusComparison;
        });

        return meetings;
      });
    } catch (e) {
      print("Error fetching meetings: $e");
      return const Stream.empty(); // Trả về Stream rỗng nếu có lỗi
    }
  }

  // Sửa thông tin cuộc họp
  Future<void> updateMeeting(String channelId, Meeting meeting) async {
    try {
      // Truy vấn để tìm document có trường `meetingId` khớp
      final querySnapshot = await _firestore
          .collection('channel')
          .doc(channelId)
          .collection('meetings')
          .where('meetingId', isEqualTo: meeting.meetingId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Lấy document đầu tiên tìm thấy và cập nhật
        final doc = querySnapshot.docs.first;
        await doc.reference.update(meeting.toMap());
        print("Meeting updated successfully!");
      } else {
        print("No meeting found with meetingId: ${meeting.meetingId}");
      }
    } catch (e) {
      print("Error updating meeting: $e");
    }
    
  }

  // Xóa cuộc họp
  Future<void> deleteMeeting(String channelId, String meetingId) async {
    try {
      await _firestore
          .collection('channel')
          .doc(channelId)
          .collection('meetings')
          .doc(meetingId)
          .delete();
      print("Meeting deleted successfully!");
    } catch (e) {
      print("Error deleting meeting: $e");
    }
  }

  Future<bool> addParticipant(
      String channelId, String meetingId, String userId) async {
    try {
      // Truy vấn để tìm tài liệu có trường meetingId khớp với giá trị truyền vào
      final querySnapshot = await _firestore
          .collection('channel')
          .doc(channelId)
          .collection('meetings')
          .where('meetingId', isEqualTo: meetingId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('tài liệu không trống');
        // Lấy tài liệu đầu tiên khớp với điều kiện
        final document = querySnapshot.docs.first;
        final meetingRef = document.reference;

        // Lấy thông tin cuộc họp từ tài liệu
        final currentParticipants =
            List<String>.from(document.data()['participants'] ?? []);

        // Kiểm tra nếu người dùng chưa có trong danh sách participants
        if (!currentParticipants.contains(userId)) {
          currentParticipants.add(userId);

          // Cập nhật danh sách participants trên Firestore
          await meetingRef.update({'participants': currentParticipants});
          print('Đã thêm người dùng vào danh sách tham gia.');
          return true;
        } else {
          print('Người dùng đã có trong danh sách tham gia.');
          return false;
        }
      } else {
        print('Không tìm thấy cuộc họp với meetingId: $meetingId');
        return false;
      }
    } catch (e) {
      print('Lỗi khi thêm người dùng vào danh sách participants: $e');
      throw Exception('Không thể thêm người dùng vào danh sách tham gia.');
    }
  }

  Future<bool> updateMeetingStatus(
      String channelId, String meetingId, MeetingStatus newStatus) async {
    try {
      // Lấy tất cả các tài liệu trong collection 'meetings' thuộc 'channel'
      // với điều kiện meetingId khớp
      final querySnapshot = await FirebaseFirestore.instance
          .collection('channel')
          .doc(channelId)
          .collection('meetings')
          .where('meetingId', isEqualTo: meetingId)
          .get();

      // Nếu tìm thấy ít nhất một tài liệu
      if (querySnapshot.docs.isNotEmpty) {
        // Lấy tài liệu đầu tiên (trường hợp meetingId là duy nhất)
        final doc = querySnapshot.docs.first;

        // Cập nhật trường 'status'
        await FirebaseFirestore.instance
            .collection('channel')
            .doc(channelId)
            .collection('meetings')
            .doc(doc.id)
            .update({'status': newStatus.toString().split('.').last});

        return true;
      } else {
        // Nếu không tìm thấy tài liệu
        print('Meeting not found.');
        return false;
      }
    } catch (e) {
      print('Error updating meeting status: $e');
      return false;
    }
  }

  Future<List<Meeting>> getUpcomingMeetings(List<String> channelIds) async {
    try {
      final List<Meeting> allMeetings = [];
      final currentDateTime = DateTime.now();

      // Lấy dữ liệu từ từng kênh
      for (final channelId in channelIds) {
        final snapshots = await _firestore
            .collection('channel')
            .doc(channelId)
            .collection('meetings')
            .get();

        final meetings =
            snapshots.docs.map((doc) => Meeting.fromMap(doc.data())).toList();

        allMeetings.addAll(meetings); // Gộp tất cả các cuộc họp
      }

      // Lọc theo trạng thái upcoming
      final upcomingMeetings = allMeetings
          .where((meeting) =>
              meeting.status == MeetingStatus.upcoming &&
              meeting.startTime.isAfter(currentDateTime))
          .toList();

      // Sắp xếp theo startTime (tăng dần)
      upcomingMeetings.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Lấy 2 cuộc họp đầu tiên
      final recentUpcomingMeetings = upcomingMeetings.take(2).toList();

      return recentUpcomingMeetings; // Trả về danh sách
    } catch (e) {
      print("Error fetching upcoming meetings: $e");
      return []; // Trả về danh sách rỗng nếu lỗi
    }
  }

  Future<List<Map<String, dynamic>>> getMeetingByDayWithChannelNames(
      DateTime selectedDate, List<String> channelIds) async {
    try {
      final List<Map<String, dynamic>> meetingsWithChannelNames = [];

      for (final channelId in channelIds) {
        // Lấy thông tin của channel
        final channelSnapshot =
            await _firestore.collection('channel').doc(channelId).get();

        if (!channelSnapshot.exists) continue;

        final channelName =
            channelSnapshot.data()?['channelName'] ?? 'Unknown Channel';

        // Lấy danh sách các cuộc họp trong channel
        final snapshots = await _firestore
            .collection('channel')
            .doc(channelId)
            .collection('meetings')
            .get();

        final meetings = snapshots.docs.map((doc) {
          final meeting = Meeting.fromMap(doc.data());
          return {
            'meeting': meeting,
            'channelName': channelName, // Gắn tên channel vào mỗi meeting
          };
        }).toList();

        meetingsWithChannelNames.addAll(meetings);
      }

      // Lọc các cuộc họp theo ngày
      final filteredMeetings = meetingsWithChannelNames.where((entry) {
        final meeting = entry['meeting'] as Meeting;
        return meeting.startTime.year == selectedDate.year &&
            meeting.startTime.month == selectedDate.month &&
            meeting.startTime.day == selectedDate.day;
      }).toList();

      return filteredMeetings;
    } catch (e) {
      print("Error fetching meetings with channel names by date: $e");
      return []; // Trả về danh sách rỗng nếu lỗi
    }
  }
}
