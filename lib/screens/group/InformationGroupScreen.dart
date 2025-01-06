// ignore_for_file: prefer_const_constructors, avoid_print, file_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/channel/channel_model.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/screens/group/AddMemberScreen.dart';
import 'package:ruprup/services/channel_service.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';

class InformationGroup extends StatefulWidget {
  final Channel channel;
  const InformationGroup({super.key, required this.channel});

  @override
  State<InformationGroup> createState() => _InformationGroupState();
}

class _InformationGroupState extends State<InformationGroup> {
  Color getColorFromCreatedAt(DateTime createdAt) {
    // Danh sách 7 màu sắc cầu vồng
    final List<Color> rainbowColors = [
      Colors.red.shade300,
      Colors.orange.shade300,
      Colors.yellow.shade700,
      Colors.green.shade300,
      Colors.blue.shade300,
      Colors.indigo.shade300,
      Colors.purple.shade300,
    ];

    // Chuyển `createdAt` thành chỉ số trong khoảng từ 0 đến 6
    final index = createdAt.millisecondsSinceEpoch % rainbowColors.length;
    return rainbowColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
        ),
        title: const Text(
          'Information',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (currentUser!.userId == widget.channel.adminId)
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddMemberScreen(members: widget.channel.memberIds)),
                  );
                },
                icon: Icon(Icons.person_add_alt, color: Colors.blue))
        ],
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar and Group Name
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: getColorFromCreatedAt(
                          DateTime.fromMillisecondsSinceEpoch(
                              widget.channel.createdAt)),
                      child: Icon(Icons.groups, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.channel.channelName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        // ignore: unrelated_type_equality_checks
                        if (currentUser.userId == widget.channel.adminId)
                          IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      TextEditingController newNameController =
                                          TextEditingController();
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: const Text('Change name'),
                                          content: TextField(
                                            controller: newNameController,
                                            decoration: const InputDecoration(
                                                labelText: 'New name'),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                                onPressed: () => {
                                                  ChannelService().renameChannel(widget.channel.channelId, newNameController.text),
                                                  Navigator.pop(context)
                                                },
                                                child: const Text('Apply'))
                                          ],
                                        );
                                      });
                                    });
                              },
                              icon: const Icon(Icons.edit, size: 20))
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Admin Information
              // _buildInfoTile(
              //   icon: Icons.admin_panel_settings_outlined,
              //   title: 'Admin',
              //   content: widget.channel.adminId,
              // ),
              // Member Information
              _buildListInfoTile(
                icon: Icons.groups_outlined,
                title: 'Members',
                lists: widget.channel.memberIds,
                isProject: false,
              ),
              // Project Information
              // _buildListInfoTile(
              //   icon: Icons.dashboard_outlined,
              //   title: 'Projects',
              //   lists: widget.channel.projectIds,
              //   isProject: true,
              // ),
              // Created At Information
              _buildInfoTile(
                  icon: Icons.timeline_outlined,
                  title: 'Created at',
                  content: DateFormat('dd/M/yyyy').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          widget.channel.createdAt))),
              const SizedBox(height: 30),
              // Delete Group Button
              // Center(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.stretch,
              //     children: [
              //       ElevatedButton(
              //         onPressed: () {
              //           showDialog(
              //             context: context,
              //             builder: (BuildContext context) {
              //               return AlertDialog(
              //                 title: Text("Confirm leaving"),
              //                 content: Text(
              //                     "Do you want to definitely leave the group ?"),
              //                 actions: [
              //                   TextButton(
              //                     onPressed: () {
              //                       Navigator.of(context).pop(); // Đóng dialog
              //                     },
              //                     child: Text("Cancel"),
              //                   ),
              //                   TextButton(
              //                     onPressed: () {
              //                       Navigator.of(context).pop(); // Đóng dialog
              //                       // Thêm logic xóa group ở đây
              //                       ScaffoldMessenger.of(context).showSnackBar(
              //                         SnackBar(content: Text("Group deleted!")),
              //                       );
              //                     },
              //                     child: Text("Agree"),
              //                   ),
              //                 ],
              //               );
              //             },
              //           );
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.blue,
              //           padding: const EdgeInsets.symmetric(
              //               horizontal: 24, vertical: 12),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(30),
              //           ),
              //         ),
              //         child: const Text(
              //           'Leave Group',
              //           style: TextStyle(fontSize: 16, color: Colors.white),
              //         ),
              //       ),
              //       const SizedBox(height: 10),
              //       if (currentUser.userId == widget.channel.adminId)
              //         ElevatedButton(
              //           onPressed: () {
              //             showDialog(
              //               context: context,
              //               builder: (BuildContext context) {
              //                 return AlertDialog(
              //                   title: Text("Confirm deletion"),
              //                   content: Text(
              //                       "If you delete this group, the chat and related projects will also be deleted ?"),
              //                   actions: [
              //                     TextButton(
              //                       onPressed: () {
              //                         Navigator.of(context)
              //                             .pop(); // Đóng dialog
              //                       },
              //                       child: Text("Cancel"),
              //                     ),
              //                     TextButton(
              //                       onPressed: () {
              //                         Navigator.of(context)
              //                             .pop(); // Đóng dialog
              //                         // Thêm logic xóa group ở đây
              //                         ScaffoldMessenger.of(context)
              //                             .showSnackBar(
              //                           SnackBar(
              //                               content: Text("Group deleted!")),
              //                         );
              //                       },
              //                       child: Text("Agree"),
              //                     ),
              //                   ],
              //                 );
              //               },
              //             );
              //           },
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: Colors.red,
              //             padding: const EdgeInsets.symmetric(
              //                 horizontal: 24, vertical: 12),
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(30),
              //             ),
              //           ),
              //           child: const Text(
              //             'Delete Group',
              //             style: TextStyle(fontSize: 16, color: Colors.white),
              //           ),
              //         ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Thành phần hiển thị thông tin về danh sách thành viên với khả năng mở rộng
  Widget _buildListInfoTile({
    required IconData icon,
    required String title,
    required List<String> lists,
    required bool isProject,
  }) {
    final String titleOption = isProject ? 'project' : 'member';
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          '$title (${lists.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: lists
            .map(
              (member) => ListTile(
                leading: InitialsAvatar(
                    name: UserService().getFullNameByUid(member), size: 40),
                title: FutureBuilder<String>(
                  future: UserService().getFullNameByUid(
                      member), // Gọi hàm trả về Future<String>
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        'Đang tải...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Text(
                        'Lỗi khi tải tên',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      );
                    }
                    return Text(
                      snapshot.data ??
                          'Không rõ tên', // Hiển thị tên hoặc giá trị mặc định
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    );
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // Helper Widget to Create a Modern Information Tile
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          content,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}
