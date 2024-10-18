class UserModel {
  final String userId;
  final String fullname;
  final String email;
  final String? profilePictureUrl;
  final List<String>? friendList;
  final List<String>? groupIds;

  UserModel({  
    required this.userId,
    required this.fullname,
    required this.email,
    this.profilePictureUrl,
    this.friendList,
    this.groupIds,
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
    );
  }
}
