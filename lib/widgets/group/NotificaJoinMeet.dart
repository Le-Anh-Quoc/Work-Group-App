// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:ruprup/services/jitsi_meet_service.dart';

class JoinCallCard extends StatelessWidget {
  final String roomName;
  const JoinCallCard({super.key,required this.roomName});
  
  JitsiMeetService get jitsiMeetService => JitsiMeetService();
  
  joinMeeting(){
  jitsiMeetService.CreateMeeting(roomName:roomName , isAudioMuted: true, isVideoMuted: true);
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Có cuộc gọi nhóm",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Phòng : $roomName',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
          
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: joinMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Tham gia cuộc gọi',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}