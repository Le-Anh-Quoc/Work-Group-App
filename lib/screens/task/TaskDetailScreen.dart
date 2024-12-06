// ignore_for_file: file_names, unused_element

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project/task_model.dart';
import 'package:ruprup/providers/project_provider.dart';
import 'package:ruprup/screens/project/DetailProjectScreen.dart';
import 'package:ruprup/screens/task/TaskListScreen.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  final String sourceScreen;
  const TaskDetailScreen(
      {super.key, required this.task, required this.sourceScreen});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final String actionUserId = FirebaseAuth.instance.currentUser!.uid;
  final List<File> _uploadedFiles = [];

  // Hàm tải lên tệp
  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _uploadedFiles
            .addAll(result.paths.whereType<String>().map((path) => File(path)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProject =
        Provider.of<ProjectProvider>(context, listen: false).currentProject;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            if (widget.sourceScreen == 'HomeScreen') {
              // Quay về HomeScreen
              Navigator.pop(context);
            } else if (widget.sourceScreen == 'ActivityScreen') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DetailProjectScreen(project: currentProject)
                ),
              );
            } else {
              // Quay về TaskListScreen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskListScreen(
                    typeTask: widget.task!.status.name,
                    project: currentProject,
                  ),
                ),
              );
            }
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Task', style: TextStyle(color: Colors.grey)),
        centerTitle: true,
        actions: _buildTaskActions(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskTitle(),
              const SizedBox(height: 16),
              // _buildCreaterRow(currentProject!.ownerId),
              const SizedBox(height: 16),
              _buildTaskDescription(),
              const SizedBox(height: 16),
              _buildDueDateRow(),
              const SizedBox(height: 16),
              _buildDifficultyIndicator(),
              const SizedBox(height: 16),
              _buildAssigneeList(),
              const SizedBox(height: 16),
              _buildAttachmentSection(),
              const SizedBox(height: 16),
              _buildAttachButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Các phương thức riêng cho các phần tử widget
  Widget _buildTaskTitle() {
    return Text(
      widget.task!.taskName,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCreaterRow(String ownerProject) {
    final name = UserService().getFullNameByUid(ownerProject);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InitialsAvatar(
              name: name,
              size: 30,
            ),
            const SizedBox(width: 5),
            const Text('Created by \'Project Leader\'',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskDescription() {
    return Text(
      widget.task!.description,
      style: const TextStyle(fontSize: 18, color: Colors.black, height: 1.4),
    );
  }

  Widget _buildDueDateRow() {
    return Row(
      children: [
        const Icon(Icons.flag, color: Colors.redAccent),
        const SizedBox(width: 8),
        Text(
          DateFormat('dd MMM yyyy').format(widget.task!.dueDate),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDifficultyIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColorForDifficulty(widget.task!.difficulty),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.task!.difficulty.name,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _getTextColorForDifficulty(widget.task!.difficulty),
        ),
      ),
    );
  }

  Widget _buildAssigneeList() {
    return Row(
      children: widget.task!.assigneeIds
          .map((uid) => InitialsAvatar(
                name: UserService().getFullNameByUid(uid),
                size: 45,
              ))
          .toList(),
    );
  }

  Widget _buildAttachmentSection() {
    if (_uploadedFiles.isEmpty) {
      return const Text('Attachment',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Column(
          children: _uploadedFiles.map((file) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(_getFileIcon(file), color: Colors.blueAccent),
                title: Text(path.basename(file.path)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAttachButton() {
    return Row(
      children: [
        TextButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.attach_file),
          label: const Text("Attach"),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  // Tách riêng hành động task ra một phương thức riêng
  List<Widget> _buildTaskActions(BuildContext context) {
    final task = widget.task!;
    if (!task.assigneeIds.contains(actionUserId)) return [];

    List<Widget> actions = [];
    if (task.status == TaskStatus.toDo) {
      actions.add(_buildActionButton(Icons.start, Colors.blueAccent,
          () => _updateTaskStatus(context, TaskStatus.inProgress)));
    } else if (task.status == TaskStatus.inProgress) {
      actions.addAll([
        _buildActionButton(Icons.replay, Colors.orange,
            () => _updateTaskStatus(context, TaskStatus.toDo)),
        _buildActionButton(Icons.visibility, Colors.redAccent,
            () => _updateTaskStatus(context, TaskStatus.inReview)),
      ]);
    } else if (task.status == TaskStatus.inReview) {
      actions.addAll([
        _buildActionButton(Icons.replay, Colors.orange,
            () => _updateTaskStatus(context, TaskStatus.inProgress)),
        _buildActionButton(Icons.done, Colors.green,
            () => _updateTaskStatus(context, TaskStatus.done)),
      ]);
    }
    return actions;
  }

  IconButton _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      iconSize: 30,
      onPressed: onPressed,
    );
  }

  Future<void> _updateTaskStatus(
      BuildContext context, TaskStatus status) async {
    await Provider.of<Task>(context, listen: false).updateTaskStatus(
      context,
      widget.task!.projectId,
      widget.task!.taskId,
      status,
      actionUserId,
    );
  }

  // Hàm để lấy màu và icon
  Color _getBackgroundColorForDifficulty(Difficulty difficulty) {
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

  Color _getTextColorForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.low:
        return Colors.greenAccent;
      case Difficulty.medium:
        return Colors.blueAccent;
      case Difficulty.hard:
        return Colors.redAccent;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getFileIcon(File file) {
    final extension = path.extension(file.path).toLowerCase();
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
      default:
        return Icons.attach_file;
    }
  }
}
