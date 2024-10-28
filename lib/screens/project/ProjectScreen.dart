import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/widgets/project/ProjectWidget.dart';
// import 'package:ruprup/widgets/search/SearchWidget.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String? _selectedGroupId; // Biến để lưu trữ nhóm được chọn
  List<Map<String, String>> _groups = []; // Danh sách nhóm với id và tên
  // final List<String> _groups = [
  //   'All',
  //   'Project A',
  //   'Project B',
  //   'Project C',
  //   'Project D',
  // ];

  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    print("Screen List Project");
    // Future.microtask(
    //     // ignore: use_build_context_synchronously
    //     () => Provider.of<Project>(context, listen: false).fetchProjects(groupId: _selectedGroup));
    // // final List<String> listGroup = Provider.of<UserModel>(context, listen: false).getListGroupForCurrentUser(currentUserId);
    // print(listGroup);
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    try {
      // Lấy danh sách groupId và tên của nhóm
      List<Map<String, String>> groupList =
          await Provider.of<UserModel>(context, listen: false)
              .getListGroupForCurrentUser(currentUserId);

      groupList.insert(0, {'id': 'All', 'name': 'All'});

      setState(() {
        _groups = groupList;
      });

      _fetchProjects(_selectedGroupId);
    } catch (e) {
      print("Error fetching groups: $e");
    }
  }

  void _fetchProjects(String? groupId) {
    if (groupId != 'All') {
      Provider.of<Project>(context, listen: false)
          .fetchProjects(groupId: groupId);
    } else {
      Provider.of<Project>(context, listen: false).fetchProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<Project>(context);

    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
            child: Column(children: [
              // CustomSearchField(),
              // const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Projects',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  DropdownButton<String>(
                    value: _selectedGroupId,
                    hint:
                        const Text('All'), // Hiển thị khi không có lựa chọn nào
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGroupId = newValue;
                        _fetchProjects(newValue); // Cập nhật giá trị được chọn
                      });
                    },
                    dropdownColor: Colors.white, // Làm nền dropdown trong suốt
                    underline: SizedBox(), // Loại bỏ đường gạch chân
                    items: _groups.map<DropdownMenuItem<String>>((group) {
                      return DropdownMenuItem<String>(
                        value: group['id'],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors
                                .transparent, // Làm nền của item trong suốt
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            children: [
                              if (group['name'] != 'All')
                                const Icon(
                                  Icons.group,
                                  color: Colors.blueAccent,
                                ),
                              const SizedBox(width: 8.0),
                              Text(
                                group['name']!,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
              const SizedBox(height: 15),
              projectProvider.projects.isEmpty
                  ? const Center(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Currently, you don\'t have any projects.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: projectProvider.projects.length,
                        itemBuilder: (context, index) {
                          final project = projectProvider.projects[index];
                          return ProjectWidget(project: project);
                        },
                      ),
                    ),
            ]),
          )),
    );
  }
}
