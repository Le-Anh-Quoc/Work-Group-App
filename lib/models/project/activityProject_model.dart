// ignore_for_file: avoid_print, file_names

import 'package:flutter/material.dart';

class ActivityLog extends ChangeNotifier {
  final String taskId;
  final String taskName;
  final String action; // "added", "updated", "deleted"
  final String userActionId;
  final DateTime timestamp;
  final String details; // Có thể là JSON string mô tả các thay đổi

  ActivityLog({
    required this.taskId,
    required this.taskName,
    required this.action,
    required this.userActionId,
    required this.timestamp,
    this.details = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'taskName': taskName,
      'action': action,
      'userActionId': userActionId,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      taskId: map['taskId'] ?? '',
      taskName: map['taskName'] ?? '',
      action: map['action'] ?? '',
      userActionId: map['userActionId'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      details: map['details'] ?? '',
    );
  }
}
