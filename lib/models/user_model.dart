import 'package:flutter/material.dart';
import 'package:ruprup/services/user_service.dart';

class UserModel extends ChangeNotifier{
  late String userId;
  late String fullname;
  late String email;
  late String? profilePictureUrl;
  late List<String>? friendList;
  late List<String>? groupIds;
  late String pushToken;

  UserModel({
    required this.userId,
    required this.fullname,
    required this.email,
    this.profilePictureUrl,
    this.friendList,
    this.groupIds,
    required this.pushToken,
  });

  // Convert a User object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullname': fullname,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'friendList': friendList,
      'groupIds': groupIds,
      'pushToken':pushToken,
    };
  }

  // Create a User object from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      fullname: map['fullname'] ?? 'Unknown User',
      email: map['email'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      friendList: List<String>.from(map['friendList'] ?? []),
      groupIds: List<String>.from(map['groupIds'] ?? []),
      pushToken: map['pushToken'] ??'',
    );
  }

  static final UserService _userService = UserService();

  Future<String> getFullNameByUid(String userId) async {
    String fullname = await _userService.getFullNameByUid(userId);
    return fullname;
  }

  Future<UserModel?> getUser(String id) async {
    final user = await _userService.readUser(id);
    return user;
  }
  
  Future<List<Map<String, String>>> getListGroupForCurrentUser(
      String id) async {
    List<Map<String, String>> listGroup =
        await _userService.getListGroupForCurrentUser(id);
    return listGroup;
  }
}
