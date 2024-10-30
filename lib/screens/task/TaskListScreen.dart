// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:ruprup/screens/project/DetailProjectScreen.dart';
import 'package:ruprup/widgets/task/ModalBottomTask.dart';
import 'package:ruprup/widgets/task/TaskWidget.dart';

class TaskListScreen extends StatefulWidget {
  final String typeTask;
  final Project? project;
  const TaskListScreen(
      {super.key, required this.typeTask, required this.project});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isMe = false;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();

    int initialIndex = getInitialIndex(widget.typeTask);
    //TaskStatus taskStatus = getStatus(widget.typeTask);

    _tabController =
        TabController(length: 4, vsync: this, initialIndex: initialIndex);

    // Listen for tab changes to update the state
    _tabController.addListener(() {
      setState(() {});
    });

    fetchTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void fetchTasks() {
    final taskProvider = Provider.of<Task>(context, listen: false);
    if (isMe) {
      taskProvider.fetchTasksToDo(widget.project!.projectId,
          currentUserId: currentUserId);
      taskProvider.fetchTasksInProgess(widget.project!.projectId,
          currentUserId: currentUserId);
      taskProvider.fetchTasksInReview(widget.project!.projectId,
          currentUserId: currentUserId);
      taskProvider.fetchTasksDone(widget.project!.projectId,
          currentUserId: currentUserId);
    } else {
      taskProvider.fetchTasksToDo(widget.project!.projectId);
      taskProvider.fetchTasksInProgess(widget.project!.projectId);
      taskProvider.fetchTasksInReview(widget.project!.projectId);
      taskProvider.fetchTasksDone(widget.project!.projectId);
    }
  }

// Phương thức để xác định chỉ số dựa trên typeTask
  int getInitialIndex(String typeTask) {
    switch (typeTask) {
      case 'toDo':
        return 0; // Chỉ số cho 'To do'
      case 'inProgress':
        return 1; // Chỉ số cho 'In progress'
      case 'inReview':
        return 2; // Chỉ số cho 'In review'
      case 'done':
        return 3; // Chỉ số cho 'Complete'
      default:
        return 1; // Mặc định là 'In progress'
    }
  }

  // Define colors for each tab
  Color getTabColor(int index) {
    switch (index) {
      case 0:
        return Colors.orangeAccent.withOpacity(0.8); // Color for 'To do'
      case 1:
        return Colors.blueAccent.withOpacity(0.8); // Color for 'In progress'
      case 2:
        return Colors.redAccent.withOpacity(0.8); // Color for 'In review'
      case 3:
        return Colors.greenAccent.withOpacity(0.8); // Color for 'Complete'
      default:
        return Colors.white;
    }
  }

  TaskStatus getStatus(String typeTask) {
    switch (typeTask) {
      case 'To do':
        return TaskStatus.toDo;
      case 'In progress':
        return TaskStatus.inProgress;
      case 'In review':
        return TaskStatus.inReview;
      case 'Completed':
        return TaskStatus.done;
      default:
        return TaskStatus.toDo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<Task>(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor:
            Colors.white, // Change background color based on tab index
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DetailProjectScreen(project: widget.project),
                ),
              );
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
          ),
          title: const Text(
            'Task',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blue),
          ),
          actions: [
            GestureDetector(
                onTap: () {
                  setState(() {
                    isMe = !isMe;
                    fetchTasks();
                  });
                },
                child: isMe
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 30, color: Colors.blue),
                            SizedBox(width: 5),
                            Text('Me', style: TextStyle(color: Colors.blue))
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.group_outlined,
                                size: 30, color: Colors.blue),
                            SizedBox(width: 5),
                            Text('Team', style: TextStyle(color: Colors.blue))
                          ],
                        ),
                      )),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.blue,
                )),
          ],
          bottom: TabBar(
            controller: _tabController, // Link the controller
            tabs: const [
              Tab(text: 'To do'),
              Tab(text: 'In progress'),
              Tab(text: 'In review'),
              Tab(text: 'Done'),
            ],
            dividerColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            indicatorWeight: 4.0,
            labelColor: Colors.white,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: getTabColor(_tabController
                  .index), // Tab indicator color based on selected tab
            ),
            indicatorPadding:
                const EdgeInsets.symmetric(horizontal: -25, vertical: 5),
            unselectedLabelColor: Colors.grey,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          ),
        ),
        body: TabBarView(
          controller: _tabController, // Link the controller
          children: [
            TaskListWidget(
              tasks: taskProvider.tasksToDo,
              backgroundColor: Colors.yellowAccent.withOpacity(0.1),
            ),
            TaskListWidget(
              tasks: taskProvider.tasksInProgess,
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
            ),
            TaskListWidget(
              tasks: taskProvider
                  .tasksInReview, // Add actual list for 'In review' tasks
              backgroundColor: Colors.redAccent.withOpacity(0.1),
            ),
            TaskListWidget(
              tasks: taskProvider
                  .tasksDone, // Add actual list for 'Completed' tasks
              backgroundColor: Colors.greenAccent.withOpacity(0.1),
            ),
          ],
        ),
        floatingActionButton: (currentUserId == widget.project!.ownerId)
            ? FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true, // Để cho phép cuộn khi nội dung dài
                    builder: (BuildContext context) {
                      return ModalBottomTask(
                          isAdd: true); // Gọi ModalBottomTask ở đây
                    },
                  );
                }, // Add icon
                backgroundColor: Colors.white, // Button background color
                tooltip: 'Add Task',
                child: const Icon(
                  Icons.add,
                  color: Colors.blue,
                  size: 30,
                ), // Tooltip for the button
              )
            : null,
      ),
    );
  }
}

class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;
  final Color backgroundColor;

  const TaskListWidget({super.key, required this.tasks, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Container(
        decoration: BoxDecoration(color: backgroundColor),
        child: const Center(
          child: Text(
            'Currently, project don\'t have any tasks.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskWidget(task: task, isFromHome: false);
              },
            ),
          ),
        ],
      );
    }
  }
}
