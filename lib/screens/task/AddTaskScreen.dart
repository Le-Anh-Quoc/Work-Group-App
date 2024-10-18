import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:ruprup/screens/task/TaskDetailScreen.dart';
import 'package:ruprup/services/task_service.dart';
import 'package:ruprup/widgets/task/AssignPersonWidget.dart';
import 'package:ruprup/widgets/task/DifficultyWidget.dart';

class AddTaskScreen extends StatefulWidget {
  final Project project;
  const AddTaskScreen({super.key, required this.project});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TaskService taskService = TaskService();

  late DateTime startDateTime = DateTime.now();
  late DateTime endDateTime = DateTime.now();
  final DateFormat dateTimeFormat = DateFormat('HH:mm dd/MM/yyyy');

  // Thay đổi trạng thái chọn
  String selectedDifficulty = '';

  // Các controller để nhập dữ liệu
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Danh sách lưu ID người được giao việc
  List<String> assigneeIds = [];

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStart) {
            startDateTime = selectedDateTime;
          } else {
            endDateTime = selectedDateTime;
          }
        });
      }
    }
  }

  void _onDifficultySelected(String difficulty) {
    setState(() {
      selectedDifficulty = difficulty; // Cập nhật trạng thái
    });
  }

  Difficulty _getDifficultyFromSelected() {
    switch (selectedDifficulty.toLowerCase()) {
      case 'low':
        return Difficulty.low;
      case 'medium':
        return Difficulty.medium;
      case 'hard':
        return Difficulty.hard;
      default:
        return Difficulty.low; // Mặc định là Low nếu không chọn gì
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onAssignPersonSelected(String memberId) {
    setState(() {
      if (assigneeIds.contains(memberId)) {
        assigneeIds.remove(memberId); // Bỏ người được giao nếu đã chọn
      } else {
        assigneeIds.add(memberId); // Thêm người được giao
      }
    });
  }

  void _createTask() async {
    Task newTask = Task(
        taskId: '',
        projectId: widget.project.projectId,
        taskName: _taskNameController.text,
        description: _descriptionController.text,
        assigneeIds: assigneeIds,
        status: TaskStatus.toDo,
        dueDate: endDateTime,
        createdAt: startDateTime,
        difficulty: _getDifficultyFromSelected());

    Task task = await TaskService.addTask(widget.project.projectId, newTask);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('add Task success'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      // Điều chỉnh để tự động cuộn khi bàn phím xuất hiện
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Task',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.blue)),
              SizedBox(height: 16),
              TextField(
                controller: _taskNameController,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  hintText: 'Your Task Name',
                  hintStyle: const TextStyle(color: Colors.grey),
                  suffixIcon:
                      const Icon(Icons.task_alt, color: Colors.blueAccent),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 20.0),
                ),
              ),
              SizedBox(height: 20),
              const Text('ASSIGN',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              SizedBox(height: 10),
              Container(
                height: 65,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.project.memberIds.length,
                  itemBuilder: (context, index) {
                    final memberId = widget.project.memberIds[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: AssignPersonWidget(
                          memberId: memberId,
                          onSelect: () => _onAssignPersonSelected(memberId)),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('START TIME',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDateTime(context, true),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            startDateTime != null
                                ? dateTimeFormat.format(startDateTime!)
                                : dateTimeFormat.format(DateTime.now()
                                    .copyWith(hour: 0, minute: 0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('END TIME',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDateTime(context, false),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            endDateTime != null
                                ? dateTimeFormat.format(endDateTime!)
                                : dateTimeFormat.format(DateTime.now()
                                    .copyWith(hour: 0, minute: 0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              const Text('DESCRIPTION',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              SizedBox(height: 15),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter description here...',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('DIFFICULTY',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DifficultyTag(
                      label: 'LOW',
                      color: Colors.greenAccent,
                      isSelected: selectedDifficulty == 'LOW',
                      onSelect: () => _onDifficultySelected('LOW'),
                    ),
                    DifficultyTag(
                      label: 'MEDIUM',
                      color: Colors.blueAccent,
                      isSelected: selectedDifficulty == 'MEDIUM',
                      onSelect: () => _onDifficultySelected('MEDIUM'),
                    ),
                    DifficultyTag(
                      label: 'HARD',
                      color: Colors.redAccent,
                      isSelected: selectedDifficulty == 'HARD',
                      onSelect: () => _onDifficultySelected('HARD'),
                    ),
                  ],
                ),
              ),
              Container(
                height: 100,
                decoration: BoxDecoration(color: Colors.white),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _createTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade500,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Create New Task',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
