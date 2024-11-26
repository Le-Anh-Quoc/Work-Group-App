// ignore_for_file: file_names, use_build_context_synchronously, sort_child_properties_last, avoid_print, unnecessary_to_list_in_spreads

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/conference_screen.dart';
import 'package:ruprup/models/channel/channel_model.dart';
import 'package:ruprup/models/channel/meeting_model.dart';
import 'package:ruprup/models/project/project_model.dart';
import 'package:ruprup/screens/project/DetailProjectScreen.dart';
import 'package:ruprup/services/channel_service.dart';
import 'package:ruprup/services/jitsi_meet_service.dart';
import 'package:ruprup/services/meeting_service.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/group/NotificaJoinMeet.dart';

class GroupScreen extends StatefulWidget {
  final String channelId;
  final String channelName;
  const GroupScreen(
      {super.key, required this.channelName, required this.channelId});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final ChannelService _channelService = ChannelService();
  final UserService _userService = UserService();
  final MeetingService _meetingService = MeetingService();

  String? _fullName = '';

  final TextEditingController _nameProjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final JitsiMeetService jitsiMeetService = JitsiMeetService();
  List<Map<String, dynamic>> meetings = [];

  late String idProject;

  @override
  void initState() {
    super.initState();
    _fetchUserFullName();
  }

  Future<void> _fetchUserFullName() async {
    _fullName = await _userService.getCurrentUserFullName();
    setState(() {}); // cập nhật lại giao diện
  }

  void _createProject(List<String> groupMemberIds) async {
    Project newProject = Project(
        projectId: '',
        groupId: widget.channelId,
        projectName: _nameProjectController.text,
        description: _descriptionController.text,
        startDate: DateTime.now(),
        ownerId: currentUserId,
        memberIds: groupMemberIds,
        tasks: []);

    await Provider.of<Project>(context, listen: false)
        .createProject(newProject);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailProjectScreen(project: newProject),
      ),
    );
  }

  void _showCreateProjectBottomSheet(BuildContext context) async {
    Channel? groupData = await _channelService.getChannel(widget.channelId);

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
            height: 400, // Chiều cao tùy chỉnh cho BottomModalSheet
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(15)),
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

  void scheduleMeeting(
      {required String meetingName, required DateTime startTime}) {
    Meeting meetingNow = Meeting(
        meetingId: startTime.microsecondsSinceEpoch.toString(),
        meetingTitle: meetingName,
        startTime: startTime,
        status: MeetingStatus.upcoming,
        participants: []);

    _meetingService.createMeeting(widget.channelId, meetingNow);
  }

  void createInstantMeeting() {
    Meeting meetingNow = Meeting(
        meetingId: DateTime.now().microsecondsSinceEpoch.toString(),
        meetingTitle: 'Meeting\'s $_fullName',
        startTime: DateTime.now(),
        status: MeetingStatus.ongoing,
        participants: [currentUserId]);

    _meetingService.createMeeting(widget.channelId, meetingNow);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VideoConferencePage(
              channelId: widget.channelId,
              meeting: meetingNow,
              userId: currentUserId,
              userName: _fullName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Số lượng tab
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.blue,
          ),
          title: Text(widget.channelName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue)),
          actions: [
            PopupMenuButton<String>(
              color: Colors.white,
              icon: const Icon(Icons.videocam_outlined, color: Colors.blue),
              onSelected: (value) {
                if (value == 'instant') {
                  createInstantMeeting(); // Gọi hàm tạo cuộc họp tức thì
                } else if (value == 'schedule') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      TextEditingController meetingNameController =
                          TextEditingController();
                      DateTime selectedDateTime = DateTime.now();

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text('Lên lịch cuộc họp'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Trường nhập tên cuộc họp
                                TextField(
                                  controller: meetingNameController,
                                  decoration: const InputDecoration(
                                      labelText: 'Tên cuộc họp'),
                                ),
                                const SizedBox(height: 16),
                                // Trường chọn ngày giờ bắt đầu
                                TextFormField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'Ngày giờ bắt đầu',
                                    hintText: DateFormat('yyyy-MM-dd HH:mm')
                                        .format(selectedDateTime),
                                  ),
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDateTime,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2100),
                                    );

                                    if (pickedDate != null) {
                                      TimeOfDay? pickedTime =
                                          await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.fromDateTime(
                                            selectedDateTime),
                                      );

                                      if (pickedTime != null) {
                                        setState(() {
                                          selectedDateTime = DateTime(
                                            pickedDate.year,
                                            pickedDate.month,
                                            pickedDate.day,
                                            pickedTime.hour,
                                            pickedTime.minute,
                                          );
                                        });
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (meetingNameController.text.isEmpty) {
                                    // Kiểm tra nếu chưa nhập tên cuộc họp
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Vui lòng nhập tên cuộc họp')),
                                    );
                                  } else if (selectedDateTime
                                      .isBefore(DateTime.now())) {
                                    // Kiểm tra nếu ngày giờ bắt đầu là quá khứ
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Ngày giờ phải là sau thời gian hiện tại')),
                                    );
                                  } else {
                                    // Tiến hành tạo cuộc họp
                                    Navigator.pop(context);
                                    scheduleMeeting(
                                      meetingName: meetingNameController.text,
                                      startTime: selectedDateTime,
                                    );
                                  }
                                },
                                child: const Text('Tạo'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'instant',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.video_call_outlined),
                      SizedBox(width: 10),
                      Text('Create an instant meeting'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'schedule',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.schedule),
                      SizedBox(width: 10),
                      Text('Schedule a meeting'),
                    ],
                  ),
                ),
              ],
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
              Tab(text: "Meets"), // Tab cho các bài đăng
              Tab(text: "Files"), // Tab cho lưu tài liệu
            ],
            indicatorColor: Colors.blue, // Màu của thanh trượt
            labelColor: Colors.blue, // Màu của văn bản đã chọn
            unselectedLabelColor: Colors.black, // Màu văn bản chưa chọn
            dividerColor: Colors.transparent,
          ),
        ),
        body: TabBarView(
          children: [
            // Nội dung của tab Bài Đăng
            PostsTab(channelId: widget.channelId),
            // Nội dung của tab Tài Liệu
            const FilesTab(),
          ],
        ),
      ),
    );
  }
}

class PostsTab extends StatefulWidget {
  final String channelId;
  const PostsTab({super.key, required this.channelId});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  @override
  Widget build(BuildContext context) {
    final MeetingService meetingService = MeetingService();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Danh sách bài đăng
          StreamBuilder<List<Meeting>>(
            stream: meetingService.getAllMeetings(widget.channelId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Lỗi: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text("Không có cuộc họp nào đang diễn ra"));
              }

              final allMeetings = snapshot.data!;

              return ListView(
                children: allMeetings
                    .map((meeting) => JoinCallCard(
                          channelId: widget.channelId,
                          meeting: meeting,
                        ))
                    .toList(),
              );
            },
          ),
          // Nút thêm bài đăng
          // Positioned(
          //   bottom: 16.0,
          //   right: 16.0,
          //   child: FloatingActionButton(
          //     backgroundColor: Colors.white,
          //     onPressed: () {
          //       // Xử lý khi nhấn nút
          //       print("Nút thêm bài đăng được nhấn");
          //     },
          //     child: const Icon(Icons.add_card, color: Colors.blue),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class FilesTab extends StatefulWidget {
  const FilesTab({super.key});

  @override
  State<FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends State<FilesTab> {
  bool _showOptionsAdd = false;

  void _toggleOptions() {
    setState(() {
      _showOptionsAdd = !_showOptionsAdd;
    });
  }

  void _showCreateFolderDialog() {
    String folderName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create folder"),
          content: TextField(
            onChanged: (value) {
              folderName = value;
            },
            decoration: const InputDecoration(
              labelText: "Name folder",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (folderName.isNotEmpty) {
                  print("Folder created: $folderName");
                  // Thực hiện logic tạo thư mục ở đây
                }
                Navigator.pop(context); // Đóng dialog
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? filePath = result.files.single.path;
      print("Đã chọn tệp: $filePath");
      // Thực hiện logic tải lên tệp ở đây
    } else {
      print("Người dùng hủy chọn tệp.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_showOptionsAdd)
          Positioned(
            bottom: 80.0,
            right: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  backgroundColor: Colors.white,
                  onPressed: _showCreateFolderDialog,
                  label: const Text(
                    "Create folder",
                    style: TextStyle(color: Colors.blue),
                  ),
                  icon: const Icon(Icons.create_new_folder, color: Colors.blue),
                ),
                const SizedBox(height: 8.0),
                FloatingActionButton.extended(
                  backgroundColor: Colors.white,
                  onPressed: _uploadFile,
                  label: const Text("Upload file",
                      style: TextStyle(color: Colors.blue)),
                  icon: const Icon(Icons.upload_file, color: Colors.blue),
                ),
              ],
            ),
          ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _toggleOptions,
            child: Icon(
              _showOptionsAdd ? Icons.close : Icons.add,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
