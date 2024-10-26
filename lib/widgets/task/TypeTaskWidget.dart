import 'package:flutter/material.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/screens/task/TaskListScreen.dart';

class TypeTaskWidget extends StatefulWidget {
  final int total;
  final String typeTask;
  final Color color;
  final IconData icon;

  final Project? project;

  const TypeTaskWidget(
      {super.key,
      required this.total,
      required this.typeTask,
      required this.color,
      required this.icon,
      required this.project});

  @override
  State<TypeTaskWidget> createState() => _TypeTaskWidgetState();
}

class _TypeTaskWidgetState extends State<TypeTaskWidget> {
  String getTaskDisplayName(String typeTask) {
    switch (typeTask) {
      case 'toDo':
        return 'To do';
      case 'inProgress':
        return 'In progress';
      case 'inReview':
        return 'In review';
      case 'done':
        return 'Completed';
      default:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayTask = getTaskDisplayName(widget.typeTask);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaskListScreen(
                  typeTask: widget.typeTask, project: widget.project),
            ),
          );
        },
        child: Container(
          //height: 100,
          decoration: BoxDecoration(
            //border: Border.all(color: Colors.black.withOpacity(0.8)),
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              colors: [
                widget.color.withOpacity(0.8),
                widget.color,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black26,
            //     blurRadius: 8,
            //     offset: Offset(2, 2),
            //   ),
            // ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                      // Giúp Text và Icon chia sẻ không gian trong Row
                      child: Text(
                        widget.total.toString(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
                //const SizedBox(height: 5), // Khoảng cách giữa các phần tử
                Text(
                  displayTask,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
