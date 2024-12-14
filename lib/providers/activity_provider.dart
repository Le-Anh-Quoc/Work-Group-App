// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:ruprup/models/project/activityProject_model.dart';
import 'package:ruprup/services/activity_service.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityService _activityService = ActivityService();

  List<ActivityLog> _activity = [];
  List<ActivityLog> get activity => _activity;

  List<ActivityLog> _activityByDate = [];
  List<ActivityLog> get activityByDate => _activityByDate;

  List<ActivityLog> _activityByTaskandDate = [];
  List<ActivityLog> get activityByTaskandDate => _activityByTaskandDate;

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
      _activityByDate =
          await _activityService.getActivityLogsByDate(projectId, selectedDate);
      notifyListeners();
    } catch (e) {
      print('Error fetching activities by date: $e');
    }
  }

  Future<void> clearActivitiesbyDate() async {
    try {
      _activityByDate = [];
      notifyListeners();
    } catch (e) {
      print('Error clearing activities by date: $e');
    }
  }

  Future<void> fetchActivitiesbyTaskandDate(
      String projectId, String taskId, DateTime selectedDate) async {
    try {
      _activityByTaskandDate =
          await _activityService.getActivityLogsByTaskandDate(projectId, taskId, selectedDate);
      notifyListeners();
    } catch (e) {
      print('Error fetching activities by date: $e');
    }
  }

  Future<void> clearActivitiesbyTaskandDate() async {
    try {
      _activityByTaskandDate = [];
      notifyListeners();
    } catch (e) {
      print('Error clearing activities by task and date: $e');
    }
  }

  Future<void> addActivityLog(ActivityLog newActivity, String projectId) async {
    await _activityService.addActivityLog(newActivity, projectId);
    await fetchRecentActivities(projectId);
  }
}
