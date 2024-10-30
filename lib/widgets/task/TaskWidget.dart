// ignore_for_file: file_names, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:ruprup/screens/task/TaskDetailScreen.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';
import 'package:ruprup/widgets/task/ModalBottomTask.dart';

class TaskWidget extends StatefulWidget {
  final Task task;
  final bool isFromHome;
  const TaskWidget({super.key, required this.task, required this.isFromHome});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  final String actionUserId = FirebaseAuth.instance.currentUser!.uid;
  late Task
      _taskProvider; // Thay TaskProvider bằng tên provider thực tế của bạn

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _taskProvider = Provider.of<Task>(context); // Lưu tham chiếu đến provider
  }

  Color getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.low:
        return Colors.greenAccent.withOpacity(0.2);
      case Difficulty.medium:
        return Colors.blueAccent.withOpacity(0.2);
      case Difficulty.hard:
        return Colors.redAccent.withOpacity(0.2);
      default:
        return Colors
            .grey.shade200; // Màu mặc định nếu không xác định được độ khó
    }
  }

  Color getTextColor(Difficulty difficulty) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Slidable(
        key: ValueKey(widget.task.taskId),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (actionUserId == currentProject!.ownerId) ...[
              if (widget.task.status == TaskStatus.toDo ||
                  widget.task.status == TaskStatus.inProgress)
                SlidableAction(
                  onPressed: (context) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25.0)),
                      ),
                      builder: (BuildContext context) {
                        return ModalBottomTask(task: widget.task, isAdd: false);
                      },
                    );
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  icon: Icons.edit_outlined,
                  padding: const EdgeInsets.all(5),
                ),
              if (widget.task.status == TaskStatus.toDo)
                SlidableAction(
                  onPressed: (context) async {
                    final confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text('Confirm deletion'),
                          content: Text(
                              'Are you sure you want to delete ${widget.task.taskName}?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(false), // Không xóa
                              child: const Text('No',
                                  style: TextStyle(color: Colors.blue)),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(true), // Xóa
                              child: const Text('Yes',
                                  style: TextStyle(color: Colors.blue)),
                            ),
                          ],
                        );
                      },
                    );

                    // Nếu người dùng xác nhận xóa
                    if (confirmDelete == true) {
                      await _taskProvider.deleteTask(
                          context,
                          widget.task.projectId,
                          widget.task.taskId,
                          actionUserId);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Delete task success'),
                        backgroundColor: Colors.redAccent,
                      ));
                    }
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  icon: Icons.delete,
                  padding: const EdgeInsets.all(5),
                ),
            ]
          ],
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: widget.task, sourceScreen: widget.isFromHome ? 'HomeScreen' : 'ListTaskScreen'),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              // border: Border.all(
              //   width: 1,
              //   color: Colors.blue
              // ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // Shadow position
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.task.taskName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                                height:
                                    6), // Tạo khoảng cách giữa tên và độ khó
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: getDifficultyColor(widget.task
                                    .difficulty), // Hàm lấy màu dựa trên độ khó
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.task.difficulty
                                    .toString()
                                    .split('.')
                                    .last, // Hiển thị độ khó
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: getTextColor(widget.task
                                      .difficulty), // Hàm lấy màu chữ dựa trên độ khó
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Danh sách avatar của người tham gia
                      Row(
                        children: [
                          for (String uid in widget.task.assigneeIds)
                            Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: InitialsAvatar(
                                name: UserService().getFullNameByUid(uid),
                                size: 45,
                              ),
                            )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 12), // Tạo khoảng cách giữa nội dung
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: Colors.grey, size: 18),
                          const SizedBox(width: 5),
                          Text(
                            DateFormat('MMM dd, yyyy')
                                .format(widget.task.createdAt),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Icon(Icons.attach_file, color: Colors.grey, size: 18),
                          SizedBox(width: 5),
                          Text(
                            '1', // Có thể thay bằng số lượng bình luận thực tế
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
