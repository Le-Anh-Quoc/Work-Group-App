import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:intl/intl.dart';
import 'package:ruprup/screens/task/TaskDetailScreen.dart';

class TaskWidget extends StatelessWidget {
  final Task task;
  const TaskWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Slidable(
        key: ValueKey(task.taskId), 
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                // Hành động xóa hoặc tùy chỉnh khác
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Done'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.done,
            ),

            SlidableAction(
              onPressed: (context) {
                // Hành động xóa hoặc tùy chỉnh khác
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Update'),
                    backgroundColor: Colors.orangeAccent,
                  ),
                );
              },
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white,
              icon: Icons.settings
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(task: task)),
            );
          },
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        task.taskName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      //IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month),
                          const SizedBox(width: 5),
                          Text(DateFormat('MMM/dd/yyyy').format(task.createdAt)),
                        ],
                      ),
                      // Row(
                      //   children: [
                      //     Icon(Icons.comment),
                      //     SizedBox(width: 5),
                      //     Text('1'),
                      //   ],
                      // ),
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
