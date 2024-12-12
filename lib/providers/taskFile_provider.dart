// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:ruprup/models/file/file_task.dart';
import 'package:ruprup/services/file_task_service.dart';

class TaskFileProvider with ChangeNotifier {
  final FileTaskService _fileTaskService = FileTaskService();

  List<FileTask>? _fileTask = [];
  List<FileTask>? get fileTask => _fileTask;

  Future<void> createFileTask(
    String projectId,
    FileTask newFileTask,
  ) async {
    try {
      // Gọi hàm tạo từ service
      await _fileTaskService.createFileTask(projectId, newFileTask);

      // Làm mới danh sách file sau khi thêm
      await fetchFileTask(projectId, newFileTask.taskId);
      notifyListeners();
    } catch (e) {
      print("Error creating FileTask: $e");
    }
  }

  Future<void> fetchFileTask(String projectId, String taskId) async {
    _fileTask = await _fileTaskService.getFileTasksByTaskId(projectId, taskId);
    notifyListeners();
  }

  void clearFileTask() {
    _fileTask = [];
    notifyListeners();
  }

  void deleteFileTask(String projectId, String fileId) async {
    // Xóa tệp từ danh sách (List)
    fileTask!.removeWhere((file) => file.id == fileId);
    await _fileTaskService.deleteFileTask(projectId, fileId);
    notifyListeners();
  }
}
