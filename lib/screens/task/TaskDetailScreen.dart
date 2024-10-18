import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:ruprup/main.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:ruprup/screens/MainScreen.dart';
import 'package:ruprup/screens/task/TaskListScreen.dart';
import 'package:ruprup/services/project_service.dart';
import 'package:ruprup/utils/validators.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:slideable/Slideable.dart';
import 'package:ruprup/widgets/task/Todo.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  TaskDetailScreen({Key? key, required this.task}) : super(key: key);
  @override
  ProjectService _projectService = ProjectService();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text(task.taskName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Name
            Text(
              task.taskName,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Description
            Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              task.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Assignee
            Text(
              'Assignee',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Row(
            //   children: [
            //     InitialsAvatar(name: task.assignedTo),
            //     SizedBox(width: 15),
            //     Text(
            //       task.assignedTo,
            //       style: TextStyle(fontSize: 16,),
            //     ),
            //   ],
            // ),
            SizedBox(height: 16),

            // Due Date
            Text(
              'Due Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              DateFormat('MMM/dd/yyyy').format(task.dueDate),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Status
            Text(
              'Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                task.status.toString().split('.').last,
                style: TextStyle(fontSize: 16, color: Colors.green[700]),
              ),
            ),
            SizedBox(height: 16),
            // Comments
            Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text('JD'),
                    ),
                    title: Text('John Doe'),
                    subtitle: Text('Great job on the task so far!'),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text('ES'),
                    ),
                    title: Text('Emily Smith'),
                    subtitle: Text('Please make sure to add tests.'),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text('ES'),
                    ),
                    title: Text('Emily Smith'),
                    subtitle: Text('Please make sure to add tests.'),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text('ES'),
                    ),
                    title: Text('Emily Smith'),
                    subtitle: Text('Please make sure to add tests.'),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text('ES'),
                    ),
                    title: Text('Emily Smith'),
                    subtitle: Text('Please make sure to add tests.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
