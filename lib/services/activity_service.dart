import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/models/project/activityProject_model.dart';
import 'package:ruprup/models/project/task_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String parentCollection = 'projects';
  final String collection = 'activityLogs';

  // Hàm thêm log vào Firestore
  Future<void> addActivityLog(ActivityLog log, String projectId) async {
    await _firestore
        .collection(parentCollection)
        .doc(projectId)
        .collection(collection)
        .add(log.toMap());
  }

  // Hàm lấy một log cụ thể dựa trên projectId và logId
  Future<ActivityLog?> getActivityLog(String projectId, String logId) async {
    try {
      final docSnapshot = await _firestore
          .collection(parentCollection)
          .doc(projectId)
          .collection(collection)
          .doc(logId)
          .get();

      if (docSnapshot.exists) {
        return ActivityLog.fromMap(docSnapshot.data()!);
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error getting activity log: $e");
    }
    return null;
  }

  // Hàm lấy tất cả các log trong một project
  Future<List<ActivityLog>> getAllActivityLogs(String projectId) async {
    List<ActivityLog> logs = [];
    try {
      final querySnapshot = await _firestore
          .collection(parentCollection)
          .doc(projectId)
          .collection(collection)
          .orderBy('timestamp', descending: true) // Sắp xếp theo thời gian
          .get();

      logs = querySnapshot.docs
          .map((doc) => ActivityLog.fromMap(doc.data()))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print("Error getting all activity logs: $e");
    }
    return logs;
  }

  // hàm lấy 5 cái mới nhất
  Future<List<ActivityLog>> getRecentActivityLogs(String projectId,
      {int limit = 5}) async {
    List<ActivityLog> logs = [];
    try {
      final querySnapshot = await _firestore
          .collection(parentCollection)
          .doc(projectId)
          .collection(collection)
          .orderBy('timestamp',
              descending: true) // Sắp xếp theo thời gian giảm dần
          .limit(limit) // Giới hạn số lượng kết quả trả về
          .get();

      logs = querySnapshot.docs
          .map((doc) => ActivityLog.fromMap(doc.data()))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print("Error getting recent activity logs: $e");
    }
    return logs;
  }

  // hàm lấy activity theo ngày cụ thể
  Future<List<ActivityLog>> getActivityLogsByDate(
      String projectId, DateTime selectedDate) async {
    List<ActivityLog> logs = [];
    try {
      // Lấy thời điểm bắt đầu và kết thúc của ngày được chọn
      DateTime startOfDay =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      DateTime endOfDay = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, 23, 59, 59, 999);

      // Chuyển đổi thành chuỗi ISO 8601
      String startOfDayString = startOfDay.toIso8601String();
      String endOfDayString = endOfDay.toIso8601String();

      final querySnapshot = await _firestore
          .collection(parentCollection)
          .doc(projectId)
          .collection(collection)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDayString)
          .where('timestamp', isLessThanOrEqualTo: endOfDayString)
          .orderBy('timestamp', descending: true) // Sắp xếp theo thời gian
          .get();

      logs = querySnapshot.docs
          .map((doc) => ActivityLog.fromMap(doc.data()))
          .toList();
      // ignore: avoid_print
      print('logs: $logs');
    } catch (e) {
      // ignore: avoid_print
      print("Error getting activity logs by date: $e");
    }
    return logs;
  }

  // hàm sử dụng chung
  Future<void> logTaskActivity(BuildContext context, String action, Task task,
      String actionUserId) async {
    try {
      ActivityLog newActivity = ActivityLog(
        taskId: task.taskId,
        taskName: task.taskName,
        action: action,
        userActionId: actionUserId,
        timestamp: DateTime.now(),
      );

      await addActivityLog(newActivity, task.projectId);
    } catch (e) {
      // ignore: avoid_print
      print("Error logging activity: $e");
    }
  }
}
