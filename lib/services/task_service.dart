import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/task_model.dart';

class TaskService {
  final CollectionReference _taskCollection =
      FirebaseFirestore.instance.collection('tasks');

  // Create a new task
  Future<void> createTask(Task task) async {
    await _taskCollection.doc(task.taskId).set(task.toMap());
  }

  // Read a task by taskId
  Future<Task?> readTask(String taskId) async {
    DocumentSnapshot snapshot = await _taskCollection.doc(taskId).get();
    if (snapshot.exists) {
      return Task.fromMap(snapshot.data() as Map<String, dynamic>);
    }
    return null; // Task not found
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    await _taskCollection.doc(task.taskId).update(task.toMap());
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _taskCollection.doc(taskId).delete();
  }
}
