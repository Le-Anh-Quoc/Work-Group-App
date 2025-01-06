// ignore_for_file: avoid_print, use_rethrow_when_possible

import 'package:flutter/material.dart';
import 'package:ruprup/models/project/project_model.dart';
import 'package:ruprup/services/project_service.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  Project? _currentProject;

  Project? get currentProject => _currentProject;

  void setCurrentProject(Project project) {
    _currentProject = project;
    notifyListeners(); // Thông báo cho UI khi project thay đổi
  }

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  List<Project> _recentProject = [];
  List<Project> get recentProjects => _recentProject;

  // Lấy danh sách Projects
  Future<void> fetchProjects({String? groupId}) async {
    try {
      _projects =
          await _projectService.getAllProjectsForCurrentUser(groupId: groupId);
      notifyListeners(); // Cập nhật trạng thái để render lại Screen
    } catch (e) {
      print('Error fetching projects: $e');
      throw e; // Ném lỗi để xử lý bên ngoài nếu cần
    }
  }

  Future<void> fetchRecentProjects() async {
    try {
      _recentProject = await _projectService.getRecentProjectsForCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Error fetching recent projects: $e');
      throw e;
    }
  }

  // Thêm project
  Future<void> createProject(Project project, String channelId) async {
    try {
      await _projectService.createProject(project, channelId);
      await fetchProjects(); // Sau khi tạo, load lại danh sách
    } catch (e) {
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
}