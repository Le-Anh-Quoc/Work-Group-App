// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:ruprup/const_meeting.dart';
import 'package:ruprup/models/channel/meeting_model.dart';
import 'package:ruprup/services/meeting_service.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class VideoConferencePage extends StatefulWidget {
  final String channelId;
  final Meeting meeting;
  final String userId;
  final String? userName;

  const VideoConferencePage({
    super.key,
    required this.meeting,
    required this.userId,
    required this.userName,
    required this.channelId,
  });

  @override
  State<VideoConferencePage> createState() => _VideoConferencePageState();
}

class _VideoConferencePageState extends State<VideoConferencePage> {
  @override
  void dispose() {
    // Kiểm tra danh sách người dùng khi rời khỏi widget
    ZegoUIKit().getUserListStream().listen((userList) {
      // Nếu người dùng cuối cùng đang rời khỏi
      print(userList.length);
    });
    // Dọn dẹp khi widget không còn sử dụng
    super.dispose();
  }

  void dismissMeeting() {
    Meeting meetingUpdate = Meeting(
        meetingId: widget.meeting.meetingId,
        meetingTitle: widget.meeting.meetingTitle,
        startTime: widget.meeting.startTime,
        endTime: DateTime.now(),
        status: MeetingStatus.ended);
    MeetingService().updateMeeting(widget.channelId, meetingUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: appId, // Điền vào appID từ ZEGOCLOUD Admin Console.
        appSign: appSign, // Điền vào appSign từ ZEGOCLOUD Admin Console.
        userID: widget.userId,
        userName: widget.userName!,
        conferenceID: widget.meeting.meetingId,
        config: ZegoUIKitPrebuiltVideoConferenceConfig(
          turnOnCameraWhenJoining: false,
          turnOnMicrophoneWhenJoining: false,
          onLeaveConfirmation: (BuildContext context) async {
            return await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.blue,
                  title: const Text("Leave the meeting room",
                      style: TextStyle(color: Colors.white70)),
                  content: const Text("Are you sure want to leave the meeting?",
                      style: TextStyle(color: Colors.white70)),
                  actions: [
                    ElevatedButton(
                      child: const Text("No",
                          style: TextStyle(color: Colors.blue)),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                    ElevatedButton(
                      child: const Text("Yes",
                          style: TextStyle(color: Colors.blue)),
                      onPressed: () async {
                        if (widget.meeting.participants.length == 1) {
                          dismissMeeting(); // Hàm giải tán cuộc họp
                          Navigator.of(context).pop(true); // Đóng dialog
                        } else {
                          Navigator.of(context).pop(true);
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
