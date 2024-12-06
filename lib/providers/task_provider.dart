import 'package:flutter/material.dart';
import 'package:ruprup/models/project/task_model.dart';

class TaskProvider with ChangeNotifier {
  Task? _selectedTask;
  int? _totalTasksInProgess;

  Task? get selectedTask => _selectedTask;
  int? get totalTasksInProgess => _totalTasksInProgess;

  void setTask(Task task) {
    _selectedTask = selectedTask;
    notifyListeners();
  }

  void clearTask() {
    _selectedTask = null;
    notifyListeners();
  }
}