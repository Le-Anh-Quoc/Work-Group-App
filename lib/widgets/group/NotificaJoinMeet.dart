// ignore_for_file: file_names

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/conference_screen.dart';
import 'package:ruprup/models/channel/meeting_model.dart';
//import 'package:ruprup/services/jitsi_meet_service.dart';
import 'package:ruprup/services/meeting_service.dart';
import 'package:ruprup/services/user_service.dart';

class JoinCallCard extends StatefulWidget {
  final String channelId;
  final Meeting meeting;
  const JoinCallCard(
      {super.key, required this.meeting, required this.channelId});

  @override
  State<JoinCallCard> createState() => _JoinCallCardState();
}

class _JoinCallCardState extends State<JoinCallCard> {
  final MeetingService _meetingService = MeetingService();
  final UserService _userService = UserService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String? _fullName = '';
  String elapsedTime = '';
  Timer? timer;

  Future<void> _fetchUserFullName() async {
    _fullName = await _userService.getCurrentUserFullName();
    setState(() {});
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final duration = now.difference(widget.meeting.startTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);
      setState(() {
        elapsedTime =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });
    });
  }

  Future<void> joinMeeting() async {
    if (await _meetingService.addParticipant(widget.channelId,
        widget.meeting.meetingId, currentUserId)) {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => VideoConferencePage(
                channelId: widget.channelId,
                meeting: widget.meeting,
                userId: currentUserId,
                userName: _fullName)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserFullName();
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.meeting.status == MeetingStatus.ongoing
          ? Colors.blue[50]
          : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: widget.meeting.status == MeetingStatus.ongoing
              ? const BorderSide(color: Colors.blue, width: 0.5)
              : BorderSide.none),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.meeting.status == MeetingStatus.ongoing
                      ? Icons.videocam
                      : widget.meeting.status == MeetingStatus.ended
                          ? Icons.videocam_off
                          : Icons.access_time,
                  color: widget.meeting.status == MeetingStatus.ongoing
                      ? Colors.blue
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.meeting.status == MeetingStatus.ongoing
                        ? widget.meeting.meetingTitle
                        : widget.meeting.status == MeetingStatus.ended
                            ? '${widget.meeting.meetingTitle} ended'
                            : '${widget.meeting.meetingTitle} (upcoming)', // Sử dụng cho trạng thái sắp diễn ra
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.meeting.status == MeetingStatus.ongoing)
                  Text(
                    elapsedTime,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.meeting.status == MeetingStatus.ongoing)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: joinMeeting,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Join',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
