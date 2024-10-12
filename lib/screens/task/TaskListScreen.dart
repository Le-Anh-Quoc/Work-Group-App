import 'package:flutter/material.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/screens/task/AddTaskScreen.dart';
import 'package:ruprup/widgets/task/TaskWidget.dart';

class TaskListScreen extends StatefulWidget {
  final String typeTask;
  final Project project;
  const TaskListScreen({super.key, required this.typeTask, required this.project});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    int initialIndex = getInitialIndex(widget.typeTask);
    _tabController =
        TabController(length: 4, vsync: this, initialIndex: initialIndex);

    // Listen for tab changes to update the state
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

// Phương thức để xác định chỉ số dựa trên typeTask
  int getInitialIndex(String typeTask) {
    switch (typeTask) {
      case 'To do':
        return 0; // Chỉ số cho 'To do'
      case 'In progress':
        return 1; // Chỉ số cho 'In progress'
      case 'In review':
        return 2; // Chỉ số cho 'In review'
      case 'Completed':
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor:
            Colors.white, // Change background color based on tab index
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          title: const Center(
            child: Text(
              'Task',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
          ],
          bottom: TabBar(
            controller: _tabController, // Link the controller
            tabs: const [
              Tab(text: 'To do'),
              Tab(text: 'In progress'),
              Tab(text: 'In review'),
              Tab(text: 'Complete'),
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
            Container(
              decoration:
                  BoxDecoration(color: Colors.yellowAccent.withOpacity(0.1)),
              child: Expanded(
                child: Column(
                  children: [
                    TaskWidget(),
                    TaskWidget(),
                  ],
                ),
              ),
            ),
            Container(
                decoration:
                    BoxDecoration(color: Colors.blueAccent.withOpacity(0.1)),
                child: const Center(child: Text('Task in Progess'))),
            Container(
                decoration:
                    BoxDecoration(color: Colors.redAccent.withOpacity(0.1)),
                child: const Center(child: Text('Task in Review'))),
            Container(
                decoration:
                    BoxDecoration(color: Colors.greenAccent.withOpacity(0.1)),
                child: const Center(child: Text('Task Completed'))),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddTaskScreen(project: widget.project)));
          }, // Add icon
          backgroundColor: Colors.white, // Button background color
          tooltip: 'Add Task',
          child: const Icon(
            Icons.add,
            color: Colors.blue,
            size: 30,
          ), // Tooltip for the button
        ),
      ),
    );
  }
}
