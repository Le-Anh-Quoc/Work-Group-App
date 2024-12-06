// ignore_for_file: prefer_const_constructors, avoid_print, file_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ruprup/models/channel/channel_model.dart';

class InformationGroup extends StatefulWidget {
  final Channel channel;
  const InformationGroup({super.key, required this.channel});

  @override
  State<InformationGroup> createState() => _InformationGroupState();
}

class _InformationGroupState extends State<InformationGroup> {
  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.group, size: 40, color: Colors.white),
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
                                              onPressed: () => print(
                                                  'Đã thay đổi tên thành $newNameController'),
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
              _buildListInfoTile(
                icon: Icons.dashboard_outlined,
                title: 'Projects',
                lists: widget.channel.projectId,
                isProject: true,
              ),
              // Created At Information
              _buildInfoTile(
                  icon: Icons.timeline_outlined,
                  title: 'Created at',
                  content:
                      DateFormat('dd/M/yyyy').format(widget.channel.createdAt)),
              const SizedBox(height: 30),
              // Delete Group Button
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm leaving"),
                              content: Text(
                                  "If you delete this group, the chat and related projects will also be deleted ?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Đóng dialog
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Đóng dialog
                                    // Thêm logic xóa group ở đây
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Group deleted!")),
                                    );
                                  },
                                  child: Text("Agree"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Leave Group',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm deletion"),
                              content: Text(
                                  "If you delete this group, the chat and related projects will also be deleted ?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Đóng dialog
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Đóng dialog
                                    // Thêm logic xóa group ở đây
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Group deleted!")),
                                    );
                                  },
                                  child: Text("Agree"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Delete Group',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
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
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                title: Text(
                  member,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view') {
                      // Thực hiện hành động khi chọn "Xem"
                      print('Xem $title');
                    } else if (value == 'delete') {
                      // Thực hiện hành động khi chọn "Xóa"
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm deletion'),
                            content: Text(
                                'Are you sure you want to delete this $title?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  // Logic xóa ở đây
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '$title deleted successfully!')),
                                  );
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('View $titleOption'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete $titleOption'),
                        ],
                      ),
                    ),
                  ],
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
