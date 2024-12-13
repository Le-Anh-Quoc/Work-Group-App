// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/channel/channel_model.dart';
import 'package:ruprup/providers/channel_provider.dart';
import 'package:ruprup/providers/project_provider.dart';
import 'package:ruprup/widgets/bottomNav/CustomAppbar.dart';
import 'package:ruprup/widgets/project/ProjectWidget.dart';
// import 'package:ruprup/widgets/search/SearchWidget.dart';

class ListProjectScreen extends StatefulWidget {
  const ListProjectScreen({super.key});

  @override
  State<ListProjectScreen> createState() => _ListProjectScreenState();
}

class _ListProjectScreenState extends State<ListProjectScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String? _selectedGroupId = 'All'; // Biến để lưu trữ nhóm được chọn
  //List<Map<String, String>> _groups = []; // Danh sách nhóm với id và tên
  final List<Channel> _channels = [
    Channel(
      channelId: 'All',
      groupChatId: 'someGroupChatId', // Thay bằng giá trị thích hợp
      projectId: [], // Thay bằng giá trị thích hợp
      channelName: 'All group',
      adminId: 'someAdminId', // Thay bằng giá trị thích hợp
      memberIds: [], // Thêm danh sách các thành viên
      createdAt: DateTime.now(),
      searchKeywords: []
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    try {
      List<Channel> channelList =
          Provider.of<ChannelProvider>(context, listen: false)
              .listChannelPersonal;

      setState(() {
        _channels.addAll(channelList);
      });

      if (mounted) {
        _fetchProjects(_selectedGroupId!);
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching groups: $e");
    }
  }

  void _fetchProjects(String groupId) {
    if (groupId != 'All') {
      Provider.of<ProjectProvider>(context, listen: false)
          .fetchProjects(groupId: groupId);
    } else {
      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);

    return Scaffold(
        appBar: const CustomAppBar(title: 'Projects', isHome: false),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
          child: Column(children: [
            // CustomSearchField(),
            // const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Màu nền dropdown
                    borderRadius:
                        BorderRadius.circular(16.0), // Bo tròn dropdown
                    border: Border.all(
                      color: Colors.grey.shade300, // Đường viền của dropdown
                      width: 1.0,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedGroupId,
                    hint: const Text(
                        'All group'), // Hiển thị khi không có lựa chọn nào
                    alignment: Alignment.center,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGroupId = newValue;
                        _fetchProjects(newValue!); // Cập nhật giá trị được chọn
                      });
                    },
                    borderRadius: BorderRadius.circular(16.0),
                    dropdownColor: Colors.white, // Làm nền dropdown trong suốt
                    underline: const SizedBox(), // Loại bỏ đường gạch chân
                    items: _channels.map<DropdownMenuItem<String>>((channel) {
                      return DropdownMenuItem<String>(
                        value: channel.channelId,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors
                                .transparent, // Làm nền của item trong suốt
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (channel.channelId != 'All')
                                const Icon(
                                  Icons.groups_outlined,
                                  color: Colors.blueAccent,
                                ),
                              const SizedBox(width: 8.0),
                              Text(
                                channel.channelName,
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
                  ),
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
        ));
  }
}
