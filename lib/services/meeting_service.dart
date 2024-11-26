import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/channel/meeting_model.dart';

class MeetingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  }

  // Lấy tất cả các cuộc họp của một kênh
  Stream<List<Meeting>> getAllMeetings(String channelId) {
    try {
      return _firestore
          .collection('channel')
          .doc(channelId)
          .collection('meetings')
          .snapshots() // Lắng nghe dữ liệu liên tục
          .map((snapshot) =>
              snapshot.docs.map((doc) => Meeting.fromMap(doc.data())).toList());
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

  Future<bool> addParticipant(String channelId, String meetingId, String userId) async {
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
}
