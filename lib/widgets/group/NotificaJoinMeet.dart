// ignore_for_file: file_names, curly_braces_in_flow_control_structures, prefer_const_constructors

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ruprup/screens/group/conference_screen.dart';
import 'package:ruprup/models/channel/meeting_model.dart';
//import 'package:ruprup/services/jitsi_meet_service.dart';
import 'package:ruprup/services/meeting_service.dart';
import 'package:ruprup/services/user_service.dart';

class JoinCallCard extends StatefulWidget {
  final String channelId;
  final String adminChannel;
  final Meeting meeting;
  const JoinCallCard(
      {super.key,
      required this.meeting,
      required this.channelId,
      required this.adminChannel});

  @override
  State<JoinCallCard> createState() => _JoinCallCardState();
}

class _JoinCallCardState extends State<JoinCallCard> {
  final MeetingService _meetingService = MeetingService();
  final UserService _userService = UserService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String? _fullName = '';
  // String elapsedTime = '';
  // Timer? timer;

  Future<void> _fetchUserFullName() async {
    _fullName = await _userService.getCurrentUserFullName();
    setState(() {});
  }

  // void _startTimer() {
  //   timer = Timer.periodic(const Duration(seconds: 1), (_) {
  //     final now = DateTime.now();
  //     final duration = now.difference(widget.meeting.startTime);
  //     final hours = duration.inHours;
  //     final minutes = duration.inMinutes.remainder(60);
  //     final seconds = duration.inSeconds.remainder(60);
  //     setState(() {
  //       elapsedTime =
  //           '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  //     });
  //   });
  // }

  Future<void> joinMeeting() async {
    if (await _meetingService.addParticipant(
        widget.channelId, widget.meeting.meetingId, currentUserId)) {
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

  Future<void> startMeeting() async {
    if (await _meetingService.addParticipant(
        widget.channelId, widget.meeting.meetingId, currentUserId)) {
      if (await _meetingService.updateMeetingStatus(
          widget.channelId, widget.meeting.meetingId, MeetingStatus.ongoing))
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
    // _startTimer();
  }

  @override
  void dispose() {
    // timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOngoing = widget.meeting.status == MeetingStatus.ongoing;
    final isUpcoming = widget.meeting.status == MeetingStatus.upcoming;
    final isEnded = widget.meeting.status == MeetingStatus.ended;
    final isAdmin = widget.adminChannel == currentUserId;
    return Card(
      color: widget.meeting.status == MeetingStatus.ongoing
          ? Colors.blue[50]
          : widget.meeting.status == MeetingStatus.upcoming
              ? Colors.yellow[50]
              : Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thời gian cuộc họp
            if (widget.meeting.status == MeetingStatus.upcoming)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('HH:mm dd/MM/yyyy')
                          .format(widget.meeting.startTime),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            // Tiêu đề cuộc họp
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  widget.meeting.status == MeetingStatus.ongoing
                      ? Icons.videocam
                      : widget.meeting.status == MeetingStatus.ended
                          ? Icons.videocam_off
                          : null,
                  color: widget.meeting.status == MeetingStatus.ongoing
                      ? Colors.blue
                      : widget.meeting.status == MeetingStatus.ended
                          ? Colors.grey
                          : Colors.yellow[800],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEnded
                        ? '${widget.meeting.meetingTitle} ended'
                        : isUpcoming
                            ? '${widget.meeting.meetingTitle} (Upcoming)'
                            : '${widget.meeting.meetingTitle} (Ongoing)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.meeting.status == MeetingStatus.ongoing
                          ? Colors.blue[800]
                          : Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Thời gian đã trôi qua (chỉ hiển thị khi ongoing)
            // if (widget.meeting.status == MeetingStatus.ongoing)
            //   Padding(
            //     padding: const EdgeInsets.only(bottom: 8),
            //     child: Text(
            //       'Elapsed Time: $elapsedTime',
            //       style: const TextStyle(
            //         fontSize: 14,
            //         color: Colors.blue,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ),
            // Nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.meeting.status == MeetingStatus.ongoing)
                  ElevatedButton.icon(
                    onPressed: joinMeeting,
                    icon: const Icon(Icons.meeting_room, size: 18),
                    label: const Text('Join'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                if (widget.meeting.status == MeetingStatus.upcoming && isAdmin)
                  ElevatedButton.icon(
                    onPressed: startMeeting,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
