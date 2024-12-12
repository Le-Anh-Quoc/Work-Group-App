// // ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, depend_on_referenced_packages
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

// class JitsiMeetService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final _jitsiMeetPlugin = JitsiMeet();
//   List<String> participants = [];

//   // Hàm lấy token từ server
//   // Future<String> getJitsiToken({
//   //   required String room,
//   //   required String userId,
//   //   required String userName,
//   // }) async {
//   //   final url = Uri.parse('http://192.168.56.1:3000/api/get-jitsi-token');  // Đảm bảo URL chính xác
//   //   final response = await http.post(
//   //     url,
//   //     headers: {'Content-Type': 'application/json'},
//   //     body: json.encode({
//   //       'room': room,
//   //       'userId': userId,
//   //       'userName': userName,
//   //     }),
//   //   );

//   //   if (response.statusCode == 200) {
//   //     // Parse token từ response
//   //     final responseData = json.decode(response.body);
//   //     return responseData['token'];
//   //   } else {
//   //     throw Exception('Không thể lấy token');
//   //   }
//   // }

//   // ignore: non_constant_identifier_names
//   void CreateMeeting({
//     required String roomName,
//     required bool isAudioMuted,
//     required bool isVideoMuted,
//     required String? username,
//   }) async {
//     try {
//       // String? name =
//       //     username.isEmpty ? _auth.currentUser?.displayName : username;

//       //print("name: $name");

//       // var options = JitsiMeetConferenceOptions(
//       //     room: roomName,
//       //     configOverrides: {
//       //       "startWithAudioMuted": isAudioMuted,
//       //       "startWithVideoMuted": isVideoMuted,
//       //     },
//       //     featureFlags: {
//       //       "unsaferoomwarning.enabled": false
//       //     },
//       //     userInfo: JitsiMeetUserInfo(
//       //         displayName: name,
//       //         email: _auth.currentUser?.email,
//       //     ),
//       //   );
//       //     await _jitsiMeetPlugin.join(options);

//       // String token = await getJitsiToken(
//       //   room: roomName,
//       //   userId: _auth.currentUser?.uid ?? '',
//       //   userName: username ?? _auth.currentUser?.displayName ?? 'User',
//       // );
//       // print(token);

//       var options = JitsiMeetConferenceOptions (
//         //serverURL: 'https://ruprup.xyz/',
//         serverURL: 'https://meet.jit.si',
//         //token: token,
//         room: roomName,
//         configOverrides: {
//           "startWithAudioMuted": isAudioMuted,
//           "startWithVideoMuted": isVideoMuted,
//           //"enableLobby": false, // Tắt chế độ chờ
//         },
//         featureFlags: {
//           FeatureFlags.resolution: FeatureFlagVideoResolutions.resolution720p,
//           FeatureFlags.welcomePageEnabled: true, // Tắt trang chào mừng
//           FeatureFlags.lobbyModeEnabled: false // Tắt chế độ chờ
//         },
//         userInfo: JitsiMeetUserInfo(
//           displayName: username,
//           email: _auth.currentUser?.email,
//           avatar:
//               "https://avatars.githubusercontent.com/u/57035818?s=400&u=02572f10fe61bca6fc20426548f3920d53f79693&v=4",
//         ),
//       );

//       var listener = JitsiMeetEventListener(
//         //   conferenceJoined: (url) {
//         //     debugPrint("conferenceJoined: url: $url");
//         //   },
//         //   conferenceTerminated: (url, error) {
//         //     debugPrint("conferenceTerminated: url: $url, error: $error");
//         //   },
//         //   conferenceWillJoin: (url) {
//         //     debugPrint("conferenceWillJoin: url: $url");
//         //   },
//         participantJoined: (email, name, role, participantId) {
//           debugPrint(
//             "participantJoined: email: $email, name: $name, role: $role, "
//             "participantId: $participantId",
//           );
//           var participants;
//           participants.add(participantId!);
//           print(participants.length);
//         },
//         //   participantLeft: (participantId) {
//         //     debugPrint("participantLeft: participantId: $participantId");
//         //   },
//         //   audioMutedChanged: (muted) {
//         //     debugPrint("audioMutedChanged: isMuted: $muted");
//         //   },
//         //   videoMutedChanged: (muted) {
//         //     debugPrint("videoMutedChanged: isMuted: $muted");
//         //   },
//         //   endpointTextMessageReceived: (senderId, message) {
//         //     debugPrint(
//         //         "endpointTextMessageReceived: senderId: $senderId, message: $message");
//         //   },
//         //   screenShareToggled: (participantId, sharing) {
//         //     debugPrint(
//         //       "screenShareToggled: participantId: $participantId, "
//         //       "isSharing: $sharing",
//         //     );
//         //   },
//         //   chatMessageReceived: (senderId, message, isPrivate, timestamp) {
//         //     debugPrint(
//         //       "chatMessageReceived: senderId: $senderId, message: $message, "
//         //       "isPrivate: $isPrivate, timestamp: $timestamp",
//         //     );
//         //   },
//         //   chatToggled: (isOpen) => debugPrint("chatToggled: isOpen: $isOpen"),
//         //   participantsInfoRetrieved: (participantsInfo) {
//         //     debugPrint(
//         //         "participantsInfoRetrieved: participantsInfo: $participantsInfo, ");
//         //   },
//         //   readyToClose: () {
//         //     debugPrint("readyToClose");
//         //   },
//       );
//       await _jitsiMeetPlugin.join(options, listener);
//     } catch (error) {
//       print("error: $error");
//     }
//   }
// }
