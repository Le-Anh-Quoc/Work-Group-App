import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:ruprup/screens/task/TaskListScreen.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final String actionUserId = FirebaseAuth.instance.currentUser!.uid;

  final List<File> _uploadedFiles = []; // Danh sách các tệp đã tải lên
  //final ImagePicker _picker = ImagePicker();

  // Hàm tải lên hình ảnh
  // Future<void> _pickImage() async {
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     setState(() {
  //       _uploadedFiles.add(File(image.path));
  //     });
  //   }
  // }

  // Hàm tải lên tệp
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _uploadedFiles.add(File(result.files.single.path!));
      });
    }
  }

// Hàm để lấy màu dựa trên status của task
  Color getBackgroundColorForStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.toDo:
        return Colors.orange[100]!;
      case TaskStatus.inProgress:
        return Colors.blue[100]!;
      case TaskStatus.inReview:
        return Colors.red[100]!;
      case TaskStatus.done:
        return Colors.green[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  Color getBackgroundColorForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.low:
        return Colors.greenAccent.withOpacity(0.2);
      case Difficulty.medium:
        return Colors.blueAccent.withOpacity(0.2);
      case Difficulty.hard:
        return Colors.redAccent.withOpacity(0.2);
      default:
        return Colors.grey.shade200;
    }
  }

// Hàm để lấy màu text dựa trên status của task
  Color getTextColorForStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.toDo:
        return Colors.orangeAccent[700]!;
      case TaskStatus.inProgress:
        return Colors.blue[700]!;
      case TaskStatus.inReview:
        return Colors.red[700]!;
      case TaskStatus.done:
        return Colors.green[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Color getTextColorForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.low:
        return Colors.greenAccent;
      case Difficulty.medium:
        return Colors.blueAccent;
      case Difficulty.hard:
        return Colors.redAccent;
      default:
        return Colors
            .grey.shade600; // Màu mặc định nếu không xác định được độ khó
    }
  }

  @override
  Widget build(BuildContext context) {
    Project? currentProject =
        Provider.of<Project>(context, listen: false).currentProject;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TaskListScreen(
                          typeTask: widget.task!.status.name,
                          project: currentProject),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_back_ios)),
            title: const Row(
              children: [
                Text('Task'),
                SizedBox(width: 15),
                // Text(task.status.name,
                //     style:
                //         TextStyle(color: getTextColorForStatus(task.status))),
                // Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //     decoration: BoxDecoration(
                //       color: getBackgroundColorForStatus(widget.task.status),
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //     child: Text(
                //       widget.task.status.name,
                //       style: TextStyle(
                //           fontSize: 18,
                //           color: getTextColorForStatus(widget.task.status)),
                //     ),
                //   ),
              ],
            ),
            actions: [
              if (widget.task!.assigneeIds.contains(actionUserId)) ...[
                if (widget.task!.status == TaskStatus.toDo)
                  IconButton(
                    icon: const Icon(Icons.start), // Icon for 'To do'
                    onPressed: () async {
                      await Provider.of<Task>(context, listen: false)
                          .updateTaskStatus(
                              context,
                              widget.task!.projectId,
                              widget.task!.taskId,
                              TaskStatus.inProgress,
                              actionUserId);
                    },
                    iconSize: 30,
                    color: Colors.blueAccent,
                  ),
                if (widget.task!.status == TaskStatus.inProgress)
                  IconButton(
                    icon: const Icon(Icons.visibility), // Icon for 'To do'
                    onPressed: () async {
                      await Provider.of<Task>(context, listen: false)
                          .updateTaskStatus(
                              context,
                              widget.task!.projectId,
                              widget.task!.taskId,
                              TaskStatus.inReview,
                              actionUserId);
                    },
                    iconSize: 30,
                    color: Colors.redAccent,
                  ),
                if (widget.task!.status == TaskStatus.inReview)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay, color: Colors.orange),
                        onPressed: () async {
                          await Provider.of<Task>(context, listen: false)
                              .updateTaskStatus(
                                  context,
                                  widget.task!.projectId,
                                  widget.task!.taskId,
                                  TaskStatus.inProgress,
                                  actionUserId);
                        },
                        iconSize: 30,
                        color: Colors.blueAccent,
                      ),
                      IconButton(
                        icon: const Icon(Icons.done),
                        onPressed: () async {
                          await Provider.of<Task>(context, listen: false)
                              .updateTaskStatus(
                                  context,
                                  widget.task!.projectId,
                                  widget.task!.taskId,
                                  TaskStatus.done,
                                  actionUserId);
                        },
                        iconSize: 30,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
              ]
            ]),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Difficulty Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: getBackgroundColorForDifficulty(
                            widget.task!.difficulty),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.task!.difficulty.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: getTextColorForDifficulty(
                              widget.task!.difficulty),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Task Name
                Text(
                  widget.task!.taskName,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Assignee and Due Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InitialsAvatar(
                            name: UserService()
                                .getFullNameByUid(widget.task!.assigneeIds[0])),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Created',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            Text('Duy Tan',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Tạo hình tròn
                            color: Colors.grey[100], // Màu nền xám
                          ),
                          padding: const EdgeInsets.all(
                              12), // Khoảng cách giữa biểu tượng và đường viền
                          child: const Icon(
                            Icons.calendar_today,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Due Date',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            Text(
                                DateFormat('dd MMM yyyy')
                                    .format(widget.task!.dueDate),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ))
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description Section
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.task!.description,
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey[600], height: 1.4),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Assignee',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (String uid in widget.task!.assigneeIds)
                      InitialsAvatar(name: UserService().getFullNameByUid(uid)),
                  ],
                ),
                const SizedBox(height: 24),

                const Text('Work',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                if (_uploadedFiles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Column(
                    children: _uploadedFiles.map((file) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8), // Khoảng cách giữa các tệp
                        decoration: BoxDecoration(
                          color: Colors.grey[50], // Màu nền
                          border:
                              Border.all(color: Colors.blueAccent), // Viền màu
                          borderRadius: BorderRadius.circular(10), // Bo góc
                        ),
                        child: ListTile(
                          leading: Icon(
                            _getFileIcon(file),
                            color: Colors.blueAccent,
                          ),
                          title: Text(path.basename(file.path)),
                          //subtitle: Text('File size: ${file.lengthSync()} bytes'),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                const Divider(thickness: 2, color: Colors.grey),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text("Attach"),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            Colors.blue, // Màu văn bản và biểu tượng
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}

// Hàm để lấy biểu tượng theo loại tệp
IconData _getFileIcon(File file) {
  String extension = path.extension(file.path);
  switch (extension) {
    case '.jpg':
    case '.jpeg':
    case '.png':
      return Icons.image;
    case '.pdf':
      return Icons.picture_as_pdf;
    case '.doc':
    case '.docx':
      return Icons.description;
    case '.xls':
    case '.xlsx':
      return Icons.table_chart;
    case '.ppt':
    case '.pptx':
      return Icons.slideshow;
    default:
      return Icons.file_copy; // Biểu tượng mặc định cho tệp khác
  }
}
