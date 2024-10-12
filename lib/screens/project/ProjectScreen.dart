import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/services/project_service.dart';
import 'package:ruprup/widgets/project/ProjectWidget.dart';
import 'package:ruprup/widgets/search/SearchWidget.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen>
    with AutomaticKeepAliveClientMixin<ProjectScreen> {
  ProjectService _projectService = ProjectService();
  List<Project> _userProjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProjects();
  }

  Future<void> _loadUserProjects() async {
    try {
      String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      List<Project> userGroups =
          await _projectService.getProjectsForCurrentUser(currentUserId!);
      setState(() {
        _userProjects = userGroups;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching Projects: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshProjects() async {
    setState(() {
      isLoading = true; // Hiển thị loading trong lúc đang làm mới dữ liệu
    });
    await _loadUserProjects(); // Gọi lại hàm lấy dữ liệu
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
            child: Column(children: [
              CustomSearchField(),
              const SizedBox(height: 15),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Projects',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshProjects, // Kéo từ trên xuống để làm mới
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator()) // Hiển thị loader
                      : _userProjects.isEmpty
                          ? const Center(
                              child: Text("You currently have no projects"))
                          : ListView.builder(
                              itemCount: _userProjects.length,
                              itemBuilder: (context, index) {
                                final project = _userProjects[index];
                                return ProjectWidget(
                                    project: project);
                              },
                            ),
                ),
              ),
            ]),
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
