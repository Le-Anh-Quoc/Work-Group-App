// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:ruprup/models/file/file_comment.dart';
import 'package:ruprup/services/file_comment_service.dart';

class TaskFileCommentProvider with ChangeNotifier {
  final FileCommentService _fileCommentService = FileCommentService();

  List<FileComment>? _filesComment = [];
  List<FileComment>? get filesComment => _filesComment;

  Future<void> createFileComment(String projectId, FileComment fileComment) async {
    await _fileCommentService.createFileComment(projectId, fileComment);
  }

  Future<List<FileComment>> fetchFileCommentsByCommentId(String projectId, String commentId) async {
    final listFileComment = await _fileCommentService.getFileCommentsByCommentId(projectId, commentId);
    return listFileComment;
  }

  ////////////////
  Future<void> getFileCommentsByCommentId(String projectId, String commentId) async {
    _filesComment = await _fileCommentService.getFileCommentsByCommentId(projectId, commentId);
    notifyListeners();
  }

  void clearFilesComment() {
    _filesComment = [];
    notifyListeners();
  }

}