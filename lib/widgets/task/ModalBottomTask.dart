// ignore_for_file: use_build_context_synchronously, unused_element, file_names, unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:ruprup/screens/task/TaskDetailScreen.dart';
import 'package:ruprup/widgets/task/AssignPersonWidget.dart';
import 'package:ruprup/widgets/task/DifficultyWidget.dart';

// ignore: must_be_immutable
class ModalBottomTask extends StatefulWidget {
  Task? task;
  bool isAdd;
  ModalBottomTask({required this.isAdd, this.task, super.key});

  @override
  State<ModalBottomTask> createState() => _ModalBottomTaskState();
}

class _ModalBottomTaskState extends State<ModalBottomTask> {
  final String actionUserId = FirebaseAuth.instance.currentUser!.uid;

  late DateTime startDateTime;
  late DateTime endDateTime;
  final DateFormat dateTimeFormat = DateFormat('HH:mm dd/MM/yyyy');

  // Thay đổi trạng thái chọn
  late String selectedDifficulty = '';

  // Các controller để nhập dữ liệu
  late final TextEditingController _taskNameController;
  late final TextEditingController _descriptionController;

  // Danh sách lưu ID người được giao việc
  late List<String> assigneeIds = [];
  late List<String> tempAssigneeIds = [];

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

  String _stringDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.low:
        return 'LOW';
      case Difficulty.medium:
        return 'MEDIUM';
      case Difficulty.hard:
        return 'HARD';
      default:
        return 'LOW'; // Mặc định là Low nếu không chọn gì
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
      if (tempAssigneeIds.contains(memberId)) {
        tempAssigneeIds.remove(memberId); // Bỏ người được giao nếu đã chọn
      } else {
        tempAssigneeIds.add(memberId); // Thêm người được giao
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo TextEditingController với tên task hiện tại
    _taskNameController =
        TextEditingController(text: widget.task?.taskName ?? '');
    assigneeIds = widget.task?.assigneeIds ?? [];
    startDateTime = widget.task?.createdAt ?? DateTime.now();
    endDateTime = widget.task?.dueDate ?? DateTime.now();
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    selectedDifficulty =
        _stringDifficulty(widget.task?.difficulty ?? Difficulty.low);

    tempAssigneeIds = List<String>.from(
        assigneeIds); // tạo danh sách tạm theo danh sách đã có
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createOrUpdateTask() async {
    Project? currentProject =
        Provider.of<Project>(context, listen: false).currentProject;
    
    if (currentProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Project không tồn tại'), backgroundColor: Colors.red));
      return; // Kết thúc hàm nếu project là null
    }

    assigneeIds = List<String>.from(tempAssigneeIds);
    // nếu tạo task thì cập nhật lại danh sách theo danh sách tạm

    if (widget.isAdd) {
      Task newTask = Task(
          taskId: '',
          projectId: currentProject.projectId,
          taskName: _taskNameController.text,
          description: _descriptionController.text,
          assigneeIds: assigneeIds,
          status: widget.task?.status ?? TaskStatus.toDo,
          dueDate: endDateTime,
          createdAt: startDateTime,
          difficulty: _getDifficultyFromSelected());
      await Provider.of<Task>(context, listen: false)
          .addTask(context, currentProject.projectId, newTask, actionUserId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Add Task success'), backgroundColor: Colors.green));
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TaskDetailScreen(task: newTask, sourceScreen: 'AddScreen',)));
    } else {
      Task task = Task(
          taskId: widget.task!.taskId,
          projectId: currentProject.projectId,
          taskName: _taskNameController.text,
          description: _descriptionController.text,
          assigneeIds: assigneeIds,
          status: widget.task!.status,
          dueDate: endDateTime,
          createdAt: startDateTime,
          difficulty: _getDifficultyFromSelected());
      await Provider.of<Task>(context, listen: false)
          .updateTask(context, currentProject.projectId, task, actionUserId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Update task success'), backgroundColor: Colors.green));
    }
  }


  @override
  Widget build(BuildContext context) {
    Project? currentProject =
        Provider.of<Project>(context, listen: false).currentProject;
    return Container(
      height: 700, // Chiều cao tùy chỉnh cho BottomModalSheet
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isAdd ? 'New Task' : 'Update Task',
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 15),
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
                hintText: 'Name Task',
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon:
                    const Icon(Icons.task_alt, color: Colors.blueAccent),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 20.0),
              ),
            ),
            const SizedBox(height: 20),
            const Text('ASSIGN',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            SizedBox(
              height: 65,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: currentProject!.memberIds.length,
                itemBuilder: (context, index) {
                  final memberId = currentProject.memberIds[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: AssignPersonWidget(
                        memberId: memberId,
                        isSelected: tempAssigneeIds.contains(memberId),
                        onSelect: () => _onAssignPersonSelected(memberId)),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('START TIME',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDateTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          startDateTime != null
                              ? dateTimeFormat.format(startDateTime)
                              : dateTimeFormat.format(
                                  DateTime.now().copyWith(hour: 0, minute: 0)),
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
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDateTime(context, false),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          endDateTime != null
                              ? dateTimeFormat.format(endDateTime)
                              : dateTimeFormat.format(
                                  DateTime.now().copyWith(hour: 0, minute: 0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('DESCRIPTION',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 15),
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
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  if (_taskNameController.text.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Thông báo'),
                          content: const Text('Tên dự án không được để trống.'),
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
                  } else {
                    _createOrUpdateTask();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Màu chữ
                ),
                child: Text(widget.isAdd ? 'Add' : 'Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
