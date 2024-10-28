// ignore_for_file: use_rethrow_when_possible

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:ruprup/services/project_service.dart';

class Project with ChangeNotifier {
  final String projectId; // ID của dự án
  final String groupId;
  final String projectName; // Tên dự án
  final String description; // Mô tả dự án
  final DateTime startDate; // Ngày bắt đầu
  final DateTime? endDate; // Ngày kết thúc
  final String ownerId; // ID của người sở hữu dự án
  final List<String> memberIds; // Danh sách ID của các thành viên trong dự án
  int toDo; // Công việc cần làm
  int inProgress; // Công việc đang tiến hành
  int inReview; // Công việc đang được đánh giá
  int done; // Công việc đã hoàn thành
  final List<Task>? tasks; // danh sách các công việc trong dự án

  Project? _currentProject;

  Project? get currentProject => _currentProject;

  void setCurrentProject(Project project) {
    _currentProject = project;
    notifyListeners(); // Thông báo cho UI khi project thay đổi
  }

  Project(
      {required this.projectId,
      required this.groupId,
      required this.projectName,
      required this.description,
      required this.startDate,
      this.endDate, // có thể null
      required this.ownerId,
      required this.memberIds,
      this.toDo = 0, // Giá trị mặc định là 0
      this.inProgress = 0, // Giá trị mặc định là 0
      this.inReview = 0, // Giá trị mặc định là 0
      this.done = 0, // Giá trị mặc định là 0
      this.tasks});

  // Phương thức để chuyển đổi đối tượng thành Map (có thể sử dụng để lưu vào Firestore)
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'groupId': groupId,
      'projectName': projectName,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'ownerId': ownerId,
      'memberIds': memberIds,
      'toDo': toDo,
      'inProgress': inProgress,
      'inReview': inReview,
      'done': done,
      'tasks': tasks?.map((task) => task.toMap()).toList()
    };
  }

  // Phương thức để khởi tạo đối tượng từ Map (có thể sử dụng khi lấy dữ liệu từ Firestore)
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
        projectId: map['projectId'],
        groupId: map['groupId'],
        projectName: map['projectName'],
        description: map['description'],
        startDate: map['startDate'] is Timestamp
            ? (map['startDate'] as Timestamp).toDate()
            : DateTime.parse(map['startDate']),
        endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
        ownerId: map['ownerId'],
        memberIds: List<String>.from(map['memberIds']),
        toDo: map['toDo'] ?? 0,
        inProgress: map['inProgress'] ?? 0,
        inReview: map['inReview'] ?? 0,
        done: map['done'] ?? 0,
        tasks: map['tasks'] != null
            ? List<Task>.from(map['tasks'].map((task) => Task.fromMap(task)))
            : null);
  }

  static final ProjectService _projectService = ProjectService();

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  // Lấy danh sách Projects
  Future<void> fetchProjects({String? groupId}) async {
    try {
      _projects = await _projectService.getAllProjectsForCurrentUser(groupId: groupId);
      notifyListeners(); // Cập nhật trạng thái để render lại Screen
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching projects: $e');
      throw e; // Ném lỗi để xử lý bên ngoài nếu cần
    }
  }

  // Thêm project
  Future<void> createProject(Project project) async {
    try {
      await _projectService.createProject(project);
      await fetchProjects(); // Sau khi tạo, load lại danh sách
    } catch (e) {
      // ignore: avoid_print
      print("Error creating project: $e");
    }
  }

  // Đọc project
  Future<Project?> getProject(String idProject) async {
    try {
      Project? project = await _projectService.getProject(idProject);
      setCurrentProject(project);
      return project; // Trả về project
    } catch (e) {
      // ignore: avoid_print
      print("Error getting project: $e");
      return null;
    }
  }

  // Cập nhật project
  Future<void> updateProject(Project project) async {
    await _projectService.updateProject(project);
    await fetchProjects();
  }

  // Xóa project
  Future<void> deleteProject(String idProject) async {
    await _projectService.deleteProject(idProject);
    await fetchProjects();
  }

  int getTotalTask() {
    return toDo + inProgress + inReview + done;
  }
}
