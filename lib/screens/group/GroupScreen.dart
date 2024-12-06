// ignore_for_file: file_names, use_build_context_synchronously, sort_child_properties_last, avoid_print, unnecessary_to_list_in_spreads

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/channel/file_model.dart';
import 'package:ruprup/models/channel/folder_model.dart';
import 'package:ruprup/providers/channel_provider.dart';
import 'package:ruprup/providers/project_provider.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/screens/group/InformationGroupScreen.dart';
import 'package:ruprup/screens/group/conference_screen.dart';
import 'package:ruprup/models/channel/channel_model.dart';
import 'package:ruprup/models/channel/meeting_model.dart';
import 'package:ruprup/models/project/project_model.dart';
import 'package:ruprup/screens/project/DetailProjectScreen.dart';
import 'package:ruprup/services/file_service.dart';
import 'package:ruprup/services/folder_service.dart';
import 'package:ruprup/services/meeting_service.dart';
import 'package:ruprup/services/storage_service.dart';
import 'package:ruprup/widgets/group/NotificaJoinMeet.dart';
import 'package:open_file/open_file.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final MeetingService _meetingService = MeetingService();

  final TextEditingController _nameProjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _createProject(Channel channel) async {
    Project newProject = Project(
        projectId: '',
        groupId: channel.channelId,
        projectName: _nameProjectController.text,
        description: _descriptionController.text,
        startDate: DateTime.now(),
        ownerId: channel.adminId,
        memberIds: channel.memberIds,
        tasks: []);

    await Provider.of<ProjectProvider>(context, listen: false)
        .createProject(newProject);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailProjectScreen(project: newProject),
      ),
    );
  }

  void _showCreateProjectBottomSheet(
      BuildContext context, String currentUserId, Channel channel) async {
    if (channel.adminId == currentUserId) {
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
                        _createProject(channel);
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
      String currentChannelId, String meetingName, DateTime startTime) {
    Meeting meetingNow = Meeting(
        meetingId: startTime.microsecondsSinceEpoch.toString(),
        meetingTitle: meetingName,
        startTime: startTime,
        status: MeetingStatus.upcoming,
        participants: []);

    _meetingService.createMeeting(currentChannelId, meetingNow);
  }

  void createInstantMeeting(
      String currentUserId, String currentUserName, String currentChannelId) {
    Meeting meetingNow = Meeting(
        meetingId: DateTime.now().microsecondsSinceEpoch.toString(),
        meetingTitle: 'Meeting\'s $currentUserName',
        startTime: DateTime.now(),
        status: MeetingStatus.ongoing,
        participants: [currentUserId]);

    _meetingService.createMeeting(currentChannelId, meetingNow);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VideoConferencePage(
              channelId: currentChannelId,
              meeting: meetingNow,
              userId: currentUserId,
              userName: currentUserName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentChannel =
        Provider.of<ChannelProvider>(context, listen: false).selectedChannel;
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    return DefaultTabController(
      length: 2, // Số lượng tab
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ChannelProvider>(context, listen: false)
                  .clearChannel();
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.blue,
          ),
          title: Text(currentChannel!.channelName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue)),
          actions: [
            PopupMenuButton<String>(
              color: Colors.white,
              icon: const Icon(Icons.videocam_outlined, color: Colors.blue),
              onSelected: (value) {
                if (value == 'instant') {
                  createInstantMeeting(
                      currentUser!.userId,
                      currentUser.fullname,
                      currentChannel.channelId); // Gọi hàm tạo cuộc họp tức thì
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
                                      currentChannel.channelId,
                                      meetingNameController.text,
                                      selectedDateTime,
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
                  _showCreateProjectBottomSheet(
                      context, currentUser!.userId, currentChannel);
                },
                icon: const Icon(
                  Icons.star_outline,
                  color: Colors.blue,
                )),
            IconButton(
              color: Colors.blue,
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) =>
                          InformationGroup(channel: currentChannel)),
                );
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
            MeetingsTab(channel: currentChannel),
            // Nội dung của tab Tài Liệu
            FilesTab(channel: currentChannel),
          ],
        ),
      ),
    );
  }
}

class MeetingsTab extends StatefulWidget {
  final Channel channel;
  const MeetingsTab({super.key, required this.channel});

  @override
  State<MeetingsTab> createState() => _MeetingsTabState();
}

class _MeetingsTabState extends State<MeetingsTab> {
  @override
  Widget build(BuildContext context) {
    final MeetingService meetingService = MeetingService();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Danh sách bài đăng
          StreamBuilder<List<Meeting>>(
            stream: meetingService.getAllMeetings(widget.channel.channelId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No meetings"));
              }

              final allMeetings = snapshot.data!;

              return ListView(
                children: allMeetings
                    .map((meeting) => JoinCallCard(
                          channelId: widget.channel.channelId,
                          adminChannel: widget.channel.adminId,
                          meeting: meeting,
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FilesTab extends StatefulWidget {
  final Channel channel;
  const FilesTab({super.key, required this.channel});

  @override
  State<FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends State<FilesTab> {

  String currentFolderId = "Home";
  List<Folder> listFolderNavi = [];

  FolderService folderService = FolderService();
  FileService fileService = FileService();
  StorageService storageService = StorageService();

// Lấy danh sách folder theo currentFolderId
  Future<List<Folder>> _fetchFolders() async {
    return await folderService.getFoldersByParentId(
        widget.channel.channelId, currentFolderId);
  }

// Lấy danh sách file theo currentFolderId
  Future<List<FileModel>> _fetchFiles() async {
    return await fileService.getFilesByFolderId(
        widget.channel.channelId, currentFolderId);
  }

  // Tạo folder
  Future<void> _createFolder(String folderName) async {
    await folderService.createFolder(
        widget.channel.channelId,
        Folder(
          id: "", // Firebase sẽ tự động tạo ID
          name: folderName,
          parentFolderId: currentFolderId,
          createdAt: DateTime.now(),
          createdBy: FirebaseAuth.instance.currentUser!.uid,
        ));
  }

// Tải file lên
  Future<void> uploadFile() async {
    // Chọn file từ thiết bị
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String? filePath = result.files.single.path;
      String fileName = result.files.single.name;

      if (filePath != null) {
        // Đọc file từ đường dẫn
        final file = File(filePath);

        // Tải file lên Firebase Storage
        String downloadUrl = await storageService.uploadFileToFirebaseStorage(
            file,
            currentFolderId); // Thay thế 'your_folder_name' bằng tên thư mục mong muốn

        // Lưu thông tin file vào Firestore (sử dụng fileService.createFile)
        await fileService.createFile(
            widget.channel.channelId,
            FileModel(
              id: "", // Firebase sẽ tự động tạo ID
              name: fileName,
              downloadUrl: downloadUrl,
              folderId: currentFolderId,
              createdAt: DateTime.now(),
              createdBy: FirebaseAuth.instance.currentUser!.uid,
            ));

        // Làm mới UI
        setState(() {});
      }
    } else {
      print("User canceled file selection.");
    }
  }

  void _showCreateFolderDialog() {
    String folderName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (folderName.isNotEmpty) {
                  await _createFolder(folderName);
                  setState(() {}); // Làm mới UI
                }
                Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _uploadFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();
  //   if (result != null) {
  //     String? filePath = result.files.single.path;
  //     print("Đã chọn tệp: $filePath");
  //     // Thực hiện logic tải lên tệp ở đây
  //   } else {
  //     print("Người dùng hủy chọn tệp.");
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Thanh điều hướng folder (Breadcrumb)
          Row(
            children: [
              TextButton(
                child: const Text('Home',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                onPressed: () {
                  setState(() {
                    listFolderNavi = [];
                    currentFolderId = 'Home';
                    print('current: $currentFolderId');
                  });
                },
              ),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              if (listFolderNavi.isNotEmpty)
                for (int i = 0; i < listFolderNavi.length; i++) ...[
                  TextButton(
                    child: Text(
                      listFolderNavi[i].name,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    onPressed: () {
                      // Logic để chuyển đến folder tương ứng
                      setState(() {
                        currentFolderId =
                            listFolderNavi[i].id; // Cập nhật folderId
                        listFolderNavi = listFolderNavi.sublist(
                            0, i + 1); // Điều chỉnh breadcrumb
                      });
                      print('Navigate to ${listFolderNavi[i]}');
                    },
                  ),
                  //if (i < listFolder.length - 1)
                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                ],
            ],
          ),

          // Danh sách file và folder
          Expanded(
            child: _buildFolderAndFileList(),
          ),

          // Nút thêm (Create Folder, Upload File)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.extended(
                        backgroundColor: Colors.white,
                        onPressed: _showCreateFolderDialog,
                        label: const Text(
                          "Create folder",
                          style: TextStyle(color: Colors.blue),
                        ),
                        icon: const Icon(Icons.create_new_folder,
                            color: Colors.blue),
                      ),
                      const SizedBox(height: 8.0),
                      FloatingActionButton.extended(
                        backgroundColor: Colors.white,
                        onPressed: uploadFile,
                        label: const Text("Upload file",
                            style: TextStyle(color: Colors.blue)),
                        icon: const Icon(Icons.upload_file, color: Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       FloatingActionButton(
          //         backgroundColor: Colors.white,
          //         onPressed: _toggleOptions,
          //         child: Icon(
          //           _showOptionsAdd ? Icons.close : Icons.add,
          //           color: Colors.blue,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildFolderAndFileList() {
    return FutureBuilder(
      future: Future.wait([_fetchFolders(), _fetchFiles()]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.hasData) {
          final folders = snapshot.data![0] as List<Folder>;
          final files = snapshot.data![1] as List<FileModel>;

          return ListView(
            //padding: const EdgeInsets.all(16.0),
            children: [
              ...folders.map((folder) => Container(
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.blue, width: 0.5)), // Bo viền dưới
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.folder, color: Colors.blue),
                      title: Text(folder.name),
                      onTap: () {
                        setState(() {
                          currentFolderId = folder.id;
                          print(currentFolderId);
                          listFolderNavi.add(folder);
                          print(listFolderNavi);
                        });
                      },
                    ),
                  )),
              ...files.map((file) => Container(
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.blue, width: 0.5)), // Bo viền dưới
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file,
                          color: Colors.grey),
                      title: Text(file.name),
                      onTap: () async {
                        String filePath = file.downloadUrl;
                        try {
                          await OpenFile.open(filePath);
                        } catch (e) {
                          print('Error opening file: $e');
                        }
                      },
                    ),
                  )),
            ],
          );
        }

        return const Center(child: Text("No files or folders found."));
      },
    );
  }
}
