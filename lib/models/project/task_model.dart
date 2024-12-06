// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ruprup/services/activity_service.dart';
import 'package:ruprup/services/task_service.dart';

enum TaskStatus { toDo, inProgress, inReview, done }

enum Difficulty { low, medium, hard }

class Task extends ChangeNotifier {
  late final String taskId;
  final String projectId;
  final String taskName;
  final String description;
  final List<String> assigneeIds;
  final TaskStatus status;
  final DateTime dueDate;
  final DateTime createdAt;
  final Difficulty difficulty;
  final List<File> files;

  Task({
    required this.taskId,
    required this.projectId, //
    required this.taskName,
    required this.description,
    required this.assigneeIds,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    required this.difficulty,
    this.files = const [],
  });

  Task copyWith({String? taskId, List<File>? files}) {
    return Task(
      taskId: taskId ??
          this.taskId, // Nếu không cung cấp taskId mới, sử dụng taskId hiện tại
      taskName: taskName,
      description: description,
      assigneeIds: assigneeIds,
      status: status,
      dueDate: dueDate,
      createdAt: createdAt,
      difficulty: difficulty, projectId: projectId,
      files: files ?? this.files,
    );
  }

  // Convert a Task object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'projectId': projectId,
      'taskName': taskName,
      'description': description,
      'assigneeIds': assigneeIds,
      'status': status.name,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'difficulty': difficulty.name,
      'files': files,
    };
  }

  // Create a Task object from a map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
        taskId: map['taskId'] ?? '',
        projectId: map['projectId'] ?? '',
        taskName: map['taskName'] ?? '',
        description: map['description'] ?? '',
        assigneeIds: List<String>.from(map['assigneeIds'] ?? []),
        status: TaskStatus.values.firstWhere((e) => e.name == map['status'],
            orElse: () => TaskStatus.toDo),
        dueDate:
            DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
        createdAt: DateTime.parse(
            map['createdAt'] ?? DateTime.now().toIso8601String()),
        difficulty: Difficulty.values.firstWhere(
            (e) => e.name == map['difficulty'],
            orElse: () => Difficulty.medium),
        files: List<File>.from(map['files'] ?? []));
  }

  static final TaskService _taskService = TaskService();
  static final ActivityService _activityService = ActivityService();

  // danh sách cho team và cá nhân (có theo dự án)

  List<Task> _tasksToDo = [];
  List<Task> get tasksToDo => _tasksToDo;

  List<Task> _tasksInProgess = [];
  List<Task> get tasksInProgess => _tasksInProgess;

  List<Task> _tasksInReview = [];
  List<Task> get tasksInReview => _tasksInReview;

  List<Task> _tasksDone = [];
  List<Task> get tasksDone => _tasksDone;

  // danh sách cho cá nhân (không theo dự án)

  // List<Task> _tasksToDoMe = [];
  // List<Task> get tasksToDoMe => _tasksToDoMe;

  List<Task> _tasksInProgressMe = [];
  List<Task> get tasksInProgressMe => _tasksInProgressMe;

  // List<Task> _tasksInReviewMe = [];
  // List<Task> get tasksInReviewMe => _tasksInReviewMe;

  // List<Task> _tasksDoneMe = [];
  // List<Task> get tasksDoneMe => _tasksDoneMe;

  // lấy danh sách Task
  // Future<void> fetchTasks(String idProject, TaskStatus status) async {
  //   try {
  //     _tasks = await _taskService.getTasks(idProject, status);
  //     notifyListeners();
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print('Error fetching tasks: $e');
  //     // ignore: use_rethrow_when_possible
  //     throw e;
  //   }
  // }

  // lấy danh sách Task (lọc theo project)
  Future<void> fetchTasksToDo(String idProject, {String? currentUserId}) async {
    try {
      _tasksToDo = await _taskService.getTasks(idProject, TaskStatus.toDo,
          currentUserId: currentUserId);
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<void> fetchTasksInProgess(String idProject,
      {String? currentUserId}) async {
    try {
      _tasksInProgess = await _taskService.getTasks(
          idProject, TaskStatus.inProgress,
          currentUserId: currentUserId);
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<void> fetchTasksInReview(String idProject,
      {String? currentUserId}) async {
    try {
      _tasksInReview = await _taskService.getTasks(
          idProject, TaskStatus.inReview,
          currentUserId: currentUserId);
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<void> fetchTasksDone(String idProject, {String? currentUserId}) async {
    try {
      _tasksDone = await _taskService.getTasks(idProject, TaskStatus.done,
          currentUserId: currentUserId);
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<String> countTaskInProgressMe(String currentUserId, String idProject) async {
    final equal = await _taskService.getAllTasksForCurrentUser(idProject, currentUserId, TaskStatus.inProgress);
    return equal.length.toString();
  }

  // lấy danh sách task (không loc theo project)
  Future<void> fetchTasksInProgressMe(String currentUserId, String idProject) async {
    try {
      _tasksInProgressMe = await _taskService.getAllTasksForCurrentUser(idProject, currentUserId, TaskStatus.inProgress, limit: 4);
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
      // ignore: use_rethrow_when_possible
      throw e;
    }
  }

  Future<void> addTask(BuildContext context, String idProject, Task task,
      String actionUserId) async {
    try {
      Task taskWithId = await _taskService.addTask(idProject, task);
      await fetchTasksToDo(idProject);

      // ignore: duplicate_ignore
      // ignore: use_build_context_synchronously
      await _activityService.logTaskActivity(
          context, 'add', taskWithId, actionUserId);
    } catch (e) {
      print("Error creating task: $e");
    }
  }

  Future<Task?> getTask(String idProject, String idTask) async {
    final task = await _taskService.getTask(idProject, idTask);
    return task;
  }

  Future<void> updateTask(BuildContext context, String idProject, Task task,
      String actionUserId) async {
    try {
      await _taskService.updateTask(idProject, task);
      if (task.status == TaskStatus.toDo) {
        await fetchTasksToDo(idProject);
      } else {
        await fetchTasksInProgess(idProject);
      }

      await _activityService.logTaskActivity(
          context, 'update', task, actionUserId);
    } catch (e) {
      print("Error updating task: $e");
    }
  }

  Future<void> deleteTask(BuildContext context, String idProject, String idTask,
      String actionUserId) async {
    try {
      Task? task = await _taskService.getTask(idProject, idTask);

      await _taskService.deleteTask(idProject, idTask);
      await fetchTasksToDo(idProject);

      await _activityService.logTaskActivity(
          context, 'delete', task!, actionUserId);
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  Future<void> updateTaskStatus(BuildContext context, String projectId,
      String taskId, TaskStatus status, String actionUserId) async {
    try {
      await _taskService.updateTaskStatus(projectId, taskId, status);

      Task? task = await _taskService.getTask(projectId, taskId);

      await _activityService.logTaskActivity(
          context, 'update status', task!, actionUserId);
    } catch (e) {
      print('Error update task status: $e');
    }
  }
}
