// ignore_for_file: file_names, use_build_context_synchronously, sort_child_properties_last, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/channel_model.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/screens/project/DetailProjectScreen.dart';
import 'package:ruprup/services/channel_service.dart';
import 'package:ruprup/services/jitsi_meet_service.dart';
import 'package:ruprup/widgets/group/NotificaJoinMeet.dart';
import 'package:ruprup/widgets/group/PostWidget.dart';

class GroupScreen extends StatefulWidget {
  final String groupId;
  const GroupScreen({super.key, required this.groupId});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final ChannelService _channelService = ChannelService();

  final TextEditingController _nameProjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final JitsiMeetService jitsiMeetService= JitsiMeetService();
  List<Map<String, dynamic>> meetings = [];


  late String idProject;
  createNewMeeting() async{
    String roomName= "Room_${DateTime.now().millisecondsSinceEpoch}";
    print("thanhcong");
    jitsiMeetService.CreateMeeting(roomName: roomName, isAudioMuted: true, isVideoMuted: true);
    setState(() {
      meetings.add({'roomName': roomName}); // Thêm thông tin phòng vào danh sách
    });
  }
  
  void _createProject(List<String> groupMemberIds) async {
    Project newProject = Project(
        projectId: '',
        groupId: widget.groupId,
        projectName: _nameProjectController.text,
        description: _descriptionController.text,
        startDate: DateTime.now(),
        ownerId: currentUserId,
        memberIds: groupMemberIds, tasks: []);

    await Provider.of<Project>(context, listen: false).createProject(newProject);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailProjectScreen(project: newProject),
      ),
    );
  }

  void _showCreateProjectBottomSheet(BuildContext context) async {
    Channel? groupData = await _channelService.getChannel(widget.groupId);

    if (groupData != null && groupData.adminId == currentUserId) {
      List<String> groupMemberIds = List<String>.from(groupData.memberIds);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          return Container(
            height: 500, // Chiều cao tùy chỉnh cho BottomModalSheet
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15)
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Project',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _nameProjectController,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                      hintText: 'Name Project',
                      hintStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: const Icon(Icons.star_outline,
                          color: Colors.blueAccent),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
                      ),
                      hintText: 'Description',
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_nameProjectController.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Thông báo'),
                              content:
                                  const Text('Tên dự án không được để trống.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Đóng dialog
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        _createProject(groupMemberIds);
                      }
                    },
                    child: const Text('Create New Project'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue, // Màu chữ
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Nếu không phải admin, bạn có thể hiển thị thông báo hoặc không cho phép tạo dự án
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bạn không có quyền tạo dự án trong nhóm này.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Số lượng tab
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(onPressed: () {Navigator.pop(context);}, icon: const Icon(Icons.arrow_back_ios)),
          title: const Text("Group ABC", style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              color: Colors.blue,
              icon: const Icon(Icons.videocam_outlined),
              onPressed: () {
                createNewMeeting();
              },
            ),
            IconButton(
                onPressed: () {
                  _showCreateProjectBottomSheet(context);
                },
                icon: const Icon(
                  Icons.star_outline,
                  color: Colors.blue,
                )),
            IconButton(
              color: Colors.blue,
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Xử lý nút thêm
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Posts"), // Tab cho các bài đăng
              Tab(text: "Files"), // Tab cho lưu tài liệu
            ],
            indicatorColor: Colors.blue, // Màu của thanh trượt
            labelColor: Colors.blue, // Màu của văn bản đã chọn
            unselectedLabelColor: Colors.black, // Màu văn bản chưa chọn
          ),
        ),
        body: TabBarView(
          children: [
            // Nội dung của tab Bài Đăng
            PostsTab(meetings: meetings,),
            // Nội dung của tab Tài Liệu
            const FilesTab(),
          ],
        ),
      ),
    );
  }
}

class PostsTab extends StatelessWidget {
  const PostsTab({super.key, required this.meetings});
  final List<Map<String,dynamic>> meetings;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Danh sách bài đăng
        ListView(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Để tạo khoảng trống cho nút
          children: [
             const PostWidget(),
             ...meetings.map((meeting) => JoinCallCard(roomName: meeting['roomName'])).toList(),
          ],
        ),
        // Nút thêm bài đăng
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              // Xử lý khi nhấn nút
              print("Nút thêm bài đăng được nhấn");
            },
            child: const Icon(Icons.add_card, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

class FilesTab extends StatelessWidget {
  const FilesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              // Xử lý khi nhấn nút
              print("Nút thêm tài liệu được nhấn");
            },
            child: const Icon(Icons.add, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}
