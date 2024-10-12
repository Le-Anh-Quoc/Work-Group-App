import 'package:flutter/material.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/widgets/task/TypeTaskWidget.dart';

class BoardTypeTaskWidget extends StatelessWidget {
  final Project project;
  const BoardTypeTaskWidget({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final taskTypes = [
      {
        'total': project.toDo,
        'typeTask': 'To do',
        'color': Colors.orangeAccent,
        'icon': Icons.task,
      },
      {
        'total': project.inProgress,
        'typeTask': 'In progress',
        'color': Colors.blueAccent,
        'icon': Icons.timeline,
      },
      {
        'total': project.inReview,
        'typeTask': 'In review',
        'color': Colors.redAccent,
        'icon': Icons.visibility,
      },
      {
        'total': project.done,
        'typeTask': 'Completed',
        'color': Colors.greenAccent,
        'icon': Icons.check_box_rounded,
      },
    ];
    return Expanded(
        child: GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      children: taskTypes.map((task) {
        return TypeTaskWidget(
          total: task['total'] as int,
          typeTask: task['typeTask'].toString(),
          color: task['color'] as Color,
          icon: task['icon'] as IconData,
          project: project,
        );
      }).toList(),
    ));
  }
}
