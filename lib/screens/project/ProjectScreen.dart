import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/widgets/project/ProjectWidget.dart';
import 'package:ruprup/widgets/search/SearchWidget.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  String? _selectedGroup; // Biến để lưu trữ nhóm được chọn
  final List<String> _groups = [
    'All',
    'Project A',
    'Project B',
    'Project C',
    'Project D',
  ];

  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    print("Screen List Project");
    Future.microtask(
        // ignore: use_build_context_synchronously
        () => Provider.of<Project>(context, listen: false).fetchProjects());
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
              CustomSearchField(),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Projects',
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  DropdownButton<String>(
                    value: _selectedGroup,
                    hint: const Text(
                        'All'), // Hiển thị khi không có lựa chọn nào
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGroup =
                            newValue; // Cập nhật giá trị được chọn
                      });
                    },
                    items:
                        _groups.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(color: Colors.grey),),
                      );
                    }).toList(),
                    underline: SizedBox(), 
                  ),
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
