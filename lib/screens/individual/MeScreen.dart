// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/room_model.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/screens/chat/ChatScreen.dart';
import 'package:ruprup/screens/individual/EditMeScreen.dart';
import 'package:ruprup/services/channel_service.dart';
import 'package:ruprup/services/project_service.dart';
import 'package:ruprup/services/roomchat_service.dart';
import 'package:ruprup/services/task_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';
import 'package:ruprup/widgets/me/TaskWidget.dart';

class PersonalScreen extends StatefulWidget {
  final UserModel? profileUser;
  const PersonalScreen({super.key, this.profileUser});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  final RoomChatService _roomChatService = RoomChatService();

  List<String> selectedUsers = [];

  void startChat(UserModel currentUser) async {
    selectedUsers.add(currentUser.userId);
    selectedUsers.add(widget.profileUser!.userId);
    RoomChat newRoomChat = RoomChat(
        idRoom: '',
        type: 'direct',
        userIds: selectedUsers,
        nameRoom: '${currentUser.fullname}_${widget.profileUser!.fullname}',
        createAt: DateTime.now().millisecondsSinceEpoch,
        timestamp: DateTime.now());
    RoomChat roomChat = await _roomChatService.createRoomChat(newRoomChat);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(roomChat: roomChat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    bool isCurrentUser = currentUser!.userId ==
        widget.profileUser
            ?.userId; // kiểm tra xem userId truyền vào có phải người dùng hiện tại không
    final user;
    if (isCurrentUser) {
      user = currentUser.userId;
    } else {
      user = widget.profileUser?.userId;
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context); // Quay lại khi nhấn nút
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
              fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isCurrentUser
                        ? PersonalInitialsAvatar(
                            name: currentUser.fullname, size: 70)
                        : PersonalInitialsAvatar(
                            name: widget.profileUser!.fullname, size: 70),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCurrentUser
                              ? currentUser.fullname
                              : widget.profileUser!.fullname,
                          style: const TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                            isCurrentUser
                                ? currentUser.email
                                : widget.profileUser!.email,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            )),
                      ],
                    ),
                    !isCurrentUser
                        ? IconButton(
                            onPressed: () {
                              startChat(currentUser);
                            },
                            icon: const Icon(Icons.message_outlined,
                                color: Colors.grey, size: 25))
                        : IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => EditMeScreen(
                                          profileUser: currentUser,
                                        )),
                              );
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.grey,
                              size: 25,
                            ))
                  ],
                ),
              ),
              // if (!isCurrentUser)
              //   Column(
              //     children: [
              //       ElevatedButton(
              //         onPressed: () {
              //           // Xử lý logic gửi yêu cầu kết bạn
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.blueAccent,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(40),
              //           ),
              //           padding: const EdgeInsets.symmetric(
              //               horizontal: 24, vertical: 12),
              //         ),
              //         child: const Text('Add Friend',
              //             style: TextStyle(color: Colors.white)),
              //       ),
              //       const SizedBox(height: 15),
              //     ],
              //   ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      FutureBuilder<int>(
                        future: ProjectService()
                            .countProjectsByUserId(user), // Hàm trả về Future
                        builder: (BuildContext context,
                            AsyncSnapshot<int> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Hiển thị loading khi dữ liệu đang được tải
                          } else if (snapshot.hasError) {
                            return Text('Có lỗi: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data}', // Hiển thị số lượng dự án
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            );
                          } else {
                            return const Text('Không có dữ liệu');
                          }
                        },
                      ),
                      const Text(
                        'Projects',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: const Color.fromARGB(255, 219, 203, 203),
                  ),
                  Column(
                    children: [
                      FutureBuilder<int>(
                        future: TaskService()
                            .countTasksByUser(user), // Hàm trả về Future
                        builder: (BuildContext context,
                            AsyncSnapshot<int> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Hiển thị loading khi dữ liệu đang được tải
                          } else if (snapshot.hasError) {
                            return Text('Có lỗi: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data}', // Hiển thị số lượng task
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            );
                          } else {
                            return const Text('Không có dữ liệu');
                          }
                        },
                      ),
                      const Text(
                        'Tasks',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: const Color.fromARGB(255, 219, 203, 203),
                  ),
                  Column(
                    children: [
                      FutureBuilder<int>(
                        future: ChannelService()
                            .countChannelsByUserId(user), // Hàm trả về Future
                        builder: (BuildContext context,
                            AsyncSnapshot<int> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Hiển thị loading khi dữ liệu đang được tải
                          } else if (snapshot.hasError) {
                            return Text('Có lỗi: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data}', // Hiển thị số lượng channel
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            );
                          } else {
                            return const Text('Không có dữ liệu');
                          }
                        },
                      ),
                      const Text(
                        'Channels',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<Map<String, int>>(
                future: _countTasksByStatus(
                    user), // Gọi hàm đếm task theo trạng thái
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Hiển thị loading khi dữ liệu chưa có
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData) {
                    return Text("No tasks available");
                  } else {
                    var taskCounts = snapshot.data ?? {};

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TaskIndivi(
                              typeTask: 'Todo task',
                              numberTask:
                                  '${taskCounts['toDo'] ?? 0}', // Số lượng task Todo
                              color: Colors.orange,
                            ),
                            TaskIndivi(
                              typeTask: 'Progress task',
                              numberTask:
                                  '${taskCounts['inProgress'] ?? 0}', // Số lượng task Progress
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TaskIndivi(
                              typeTask: 'InReview task',
                              numberTask:
                                  '${taskCounts['inReview'] ?? 0}', // Số lượng task InReview
                              color: Colors.red,
                            ),
                            TaskIndivi(
                              typeTask: 'Complete task',
                              numberTask:
                                  '${taskCounts['done'] ?? 0}', // Số lượng task Complete
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, int>> _countTasksByStatus(String userId) async {
    Map<String, int> taskCounts = {
      'toDo': 0,
      'inProgress': 0,
      'inReview': 0,
      'done': 0,
    };

    List<String> statuses = taskCounts.keys.toList();

    for (var status in statuses) {
      int count = await TaskService().countTasksByUserAndStatus(userId, status);
      taskCounts[status] = count;
    }

    return taskCounts;
  }
}
