import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String content;
  final String postedBy;
  final DateTime postedAt;
  final Map<String, int> reactions;
  final List<Map<String, dynamic>> comments;

  Post({
    required this.postId,
    required this.content,
    required this.postedBy,
    required this.postedAt,
    this.reactions = const {},
    this.comments = const [],
  });

  // Convert Firestore document to Post
  factory Post.fromMap(Map<String, dynamic> map, String id) {
    return Post(
      postId: id,
      content: map['content'] ?? '',
      postedBy: map['postedBy'] ?? '',
      postedAt: (map['postedAt'] as Timestamp).toDate(),
      reactions: Map<String, int>.from(map['reactions'] ?? {}),
      comments: List<Map<String, dynamic>>.from(map['comments'] ?? []),
    );
  }

  // Convert Post to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'postedBy': postedBy,
      'postedAt': postedAt,
      'reactions': reactions,
      'comments': comments,
    };
  }
}
