
// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiMeetService {
  final FirebaseAuth _auth= FirebaseAuth.instance;
  final _jitsiMeetPlugin=JitsiMeet();
  List<String> participants = [];
  
  // ignore: non_constant_identifier_names
  void CreateMeeting({
      required String roomName,
      required bool isAudioMuted,
      required bool isVideoMuted,
      String username='',
    }) async{
      try {
        String? name;
        if(username.isEmpty){
          name=_auth.currentUser?.displayName;
        }
        else {
          name =username;
        }

      
  // var options = JitsiMeetConferenceOptions(
  //     room: roomName,
  //     configOverrides: {
  //       "startWithAudioMuted": isAudioMuted,
  //       "startWithVideoMuted": isVideoMuted,
  //     },
  //     featureFlags: {
  //       "unsaferoomwarning.enabled": false
  //     },
  //     userInfo: JitsiMeetUserInfo(
  //         displayName: name,
  //         email: _auth.currentUser?.email,
  //     ),
  //   );
  //     await _jitsiMeetPlugin.join(options);
    var options = JitsiMeetConferenceOptions(
      room: roomName,
      configOverrides: {
        "startWithAudioMuted": isAudioMuted,
        "startWithVideoMuted": isVideoMuted,
      },
      featureFlags: {
        FeatureFlags.resolution: FeatureFlagVideoResolutions.resolution720p,
        FeatureFlags.welcomePageEnabled: true,
      },
      userInfo: JitsiMeetUserInfo(
          displayName: name,
          email: _auth.currentUser?.email,
          avatar:
              "https://avatars.githubusercontent.com/u/57035818?s=400&u=02572f10fe61bca6fc20426548f3920d53f79693&v=4"),
    );

     var listener = JitsiMeetEventListener(
    //   conferenceJoined: (url) {
    //     debugPrint("conferenceJoined: url: $url");
    //   },
    //   conferenceTerminated: (url, error) {
    //     debugPrint("conferenceTerminated: url: $url, error: $error");
    //   },
    //   conferenceWillJoin: (url) {
    //     debugPrint("conferenceWillJoin: url: $url");
    //   },
      participantJoined: (email, name, role, participantId) {
        debugPrint(
          "participantJoined: email: $email, name: $name, role: $role, "
          "participantId: $participantId",
        );
        var participants;
        participants.add(participantId!);
        print(participants.length);
      },
    //   participantLeft: (participantId) {
    //     debugPrint("participantLeft: participantId: $participantId");
    //   },
    //   audioMutedChanged: (muted) {
    //     debugPrint("audioMutedChanged: isMuted: $muted");
    //   },
    //   videoMutedChanged: (muted) {
    //     debugPrint("videoMutedChanged: isMuted: $muted");
    //   },
    //   endpointTextMessageReceived: (senderId, message) {
    //     debugPrint(
    //         "endpointTextMessageReceived: senderId: $senderId, message: $message");
    //   },
    //   screenShareToggled: (participantId, sharing) {
    //     debugPrint(
    //       "screenShareToggled: participantId: $participantId, "
    //       "isSharing: $sharing",
    //     );
    //   },
    //   chatMessageReceived: (senderId, message, isPrivate, timestamp) {
    //     debugPrint(
    //       "chatMessageReceived: senderId: $senderId, message: $message, "
    //       "isPrivate: $isPrivate, timestamp: $timestamp",
    //     );
    //   },
    //   chatToggled: (isOpen) => debugPrint("chatToggled: isOpen: $isOpen"),
    //   participantsInfoRetrieved: (participantsInfo) {
    //     debugPrint(
    //         "participantsInfoRetrieved: participantsInfo: $participantsInfo, ");
    //   },
    //   readyToClose: () {
    //     debugPrint("readyToClose");
    //   },
     );
    await _jitsiMeetPlugin.join(options,listener);
      } catch (error) {
        print("error: $error");
      }
    }
}
