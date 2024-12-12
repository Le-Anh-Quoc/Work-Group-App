import 'package:flutter/material.dart';
import 'package:ruprup/models/comment_model.dart';
import 'package:ruprup/services/comment_service.dart';

class CommentProvider with ChangeNotifier {
  final CommentService _commentService = CommentService();

  List<Comment>? _commentsTask = [];
  List<Comment>? get commentsTask => _commentsTask;

  Future<String> createComment(String projectId, Comment comment) async {
    final newComment = await _commentService.createComment(projectId, comment);
    return newComment;
  }

  Future<void> updateComment(String projectId, Comment updatedComment) async {
    await _commentService.updateComment(projectId, updatedComment);
  }

  Future<void> deleteComment(String projectId, String commentId) async {
    await _commentService.deleteComment(projectId, commentId);
  }

  Future<void> fetchCommentsTask(String projectId, String taskId) async {
    _commentsTask = await _commentService.getCommentsByTaskandProjectId(projectId, taskId);
    notifyListeners();
  }
}