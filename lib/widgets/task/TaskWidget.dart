import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:ruprup/screens/task/TaskDetailScreen.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';

class TaskWidget extends StatelessWidget {
  final Task task;
  const TaskWidget({super.key, required this.task});

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Slidable(
        key: ValueKey(task.taskId),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Marked as Done'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.check_circle_outline,
            ),
            SlidableAction(
              onPressed: (context) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Task Updated'),
                    backgroundColor: Colors.orangeAccent,
                  ),
                );
              },
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                              task.taskName,
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
                                color: getDifficultyColor(task
                                    .difficulty), // Hàm lấy màu dựa trên độ khó
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.difficulty
                                    .toString()
                                    .split('.')
                                    .last, // Hiển thị độ khó
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: getTextColor(task
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
                          for (String uid in task.assigneeIds)
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
                            DateFormat('MMM dd, yyyy').format(task.createdAt),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.comment,
                              color: Colors.grey, size: 18),
                          const SizedBox(width: 5),
                          Text(
                            '1', // Có thể thay bằng số lượng bình luận thực tế
                            style: const TextStyle(color: Colors.grey),
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
