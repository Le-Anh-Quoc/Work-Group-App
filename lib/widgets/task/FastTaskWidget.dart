// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ruprup/models/project/task_model.dart';
import 'package:ruprup/screens/task/TaskDetailScreen.dart';

class FastTaskWidget extends StatefulWidget {
  final Task task;
  final bool isFromHome;
  const FastTaskWidget(
      {super.key, required this.task, required this.isFromHome});

  @override
  State<FastTaskWidget> createState() => _FastTaskWidgetState();
}

class _FastTaskWidgetState extends State<FastTaskWidget> {
  final String actionUserId = FirebaseAuth.instance.currentUser!.uid;

  Color getDifficultyColor(Difficulty difficulty) {
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

  Color getTextColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.low:
        return Colors.green;
      case Difficulty.medium:
        return Colors.blue;
      case Difficulty.hard:
        return Colors.red;
      default:
        return Colors.grey.shade600;
    }
  }

  Color getIconColorByTerm(DateTime dueDate) {
    final currentDate = DateTime.now();
    final differenceInMinutes = dueDate.difference(currentDate).inMinutes;

    if (differenceInMinutes > 2 * 24 * 60) {
      return Colors.blue;
    } else if (differenceInMinutes >= 0) {
      return Colors.orangeAccent;
    } else {
      return Colors.red;
    }
  }

  IconData _getStatusIcon(DateTime dueDate) {
    final currentDate = DateTime.now();
    final differenceInMinutes = dueDate.difference(currentDate).inMinutes;

    if (differenceInMinutes > 2 * 24 * 60) {
      return Icons.timeline;
    } else if (differenceInMinutes >= 0) {
      return Icons.timelapse;
    } else {
      return Icons.error;
    }
  }

  void _showTaskStatusMessage(DateTime dueDate) {
    final currentDate = DateTime.now();
    final differenceInMinutes = dueDate.difference(currentDate).inMinutes;

    String message;
    if (differenceInMinutes > 2 * 24 * 60) {
      message = "Task is still valid.";
    } else if (differenceInMinutes >= 0) {
      message = "Task is about to expire!";
    } else {
      message = "Task is overdue!";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(
                task: widget.task,
                sourceScreen:
                    widget.isFromHome ? 'HomeScreen' : 'ListTaskScreen',
              ),
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
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task name and difficulty
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.task.taskName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getDifficultyColor(widget.task.difficulty),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.task.difficulty.toString().split('.').last,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: getTextColor(widget.task.difficulty),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.task.status != TaskStatus.done)
                      GestureDetector(
                        onTap: () {
                          _showTaskStatusMessage(widget.task.dueDate);
                        },
                        child: Icon(
                          _getStatusIcon(widget.task.dueDate),
                          color: getIconColorByTerm(widget.task.dueDate),
                          size: 30,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Due date and attachments
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.flag_outlined,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMM dd, yyyy')
                              .format(widget.task.dueDate),
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        Icon(Icons.attach_file, color: Colors.grey, size: 18),
                        SizedBox(width: 5),
                        Text(
                          '1', // Placeholder for attachment count
                          style: TextStyle(color: Colors.grey, fontSize: 14),
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
    );
  }
}
