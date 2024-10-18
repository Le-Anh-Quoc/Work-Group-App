import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:ruprup/main.dart';
import 'package:ruprup/utils/validators.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:slideable/Slideable.dart';
import 'package:ruprup/widgets/task/Todo.dart';
class TaskDetailScreen extends StatelessWidget {
  final Task task;
  TaskDetailScreen({Key? key,required this.task}):super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.id),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Name
            Text(
              task.name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // Description
            Text(
              'Description',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            Row(
              children: [
                InitialsAvatar(name: task.assignedTo),
                SizedBox(width: 15),
                Text(
                  task.assignedTo,
                  style: TextStyle(fontSize: 16,),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Due Date
            Text(
              'Due Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              task.dueDate,
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
                task.status,
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