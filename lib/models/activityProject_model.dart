// ignore_for_file: avoid_print, file_names

import 'package:flutter/material.dart';
import 'package:ruprup/services/activity_service.dart';

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

  static final ActivityService _activityService = ActivityService();

  List<ActivityLog> _activity = [];
  List<ActivityLog> get activity => _activity;

  List<ActivityLog> _activityByDate = [];
  List<ActivityLog> get activityByDate => _activityByDate;

  // Future<void> fetchAllActivities(String projectId) async {
  //   try {
  //     _activity = await _activityService.getAllActivityLogs(projectId);
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error fetching activities: $e');
  //   }
  // }

  Future<void> fetchRecentActivities(String projectId) async {
    try {
      _activity = await _activityService.getRecentActivityLogs(projectId);
      notifyListeners();
    } catch (e) {
      print('Error fetching recent activities: $e');
    }
  }

  Future<void> fetchActivitiesbyDate(
      String projectId, DateTime selectedDate) async {
    try {
      _activityByDate = await _activityService.getActivityLogsByDate(projectId, selectedDate);
      notifyListeners();
    } catch (e) {
      print('Error fetching activities by date: $e');
    }
  }

  Future<void> addActivityLog(ActivityLog newActivity, String projectId) async {
    await _activityService.addActivityLog(newActivity, projectId);
    await fetchRecentActivities(projectId);
  }
}
