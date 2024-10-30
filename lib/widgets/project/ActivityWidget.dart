// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/activityProject_model.dart';
import 'package:ruprup/models/project_model.dart';
import 'package:ruprup/models/task_model.dart';
import 'package:ruprup/screens/task/TaskDetailScreen.dart';
import 'package:ruprup/services/user_service.dart';

class ActivityWidget extends StatefulWidget {
  final ActivityLog actLog;
  const ActivityWidget({super.key, required this.actLog});

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  late Color themeColor = Colors.grey;
  late String contentActivity = 'Loading....';
  late String actionUser = 'User';

  Color getColor(String action) {
    switch (action) {
      case 'add':
        return Colors.green; // Màu cho hành động thêm
      case 'update':
        return Colors.orange; // Màu cho hành động cập nhật
      case 'delete':
        return Colors.red; // Màu cho hành động xóa
      case 'update status':
        return Colors.blue; // Màu cho hành động cập nhật tình trạng
      default:
        return Colors.grey; // Màu mặc định nếu không khớp hành động nào
    }
  }

  String getContent(String action, String userName, String nameTask) {
    switch (action) {
      case 'add':
        return '$userName added $nameTask'; // Nội dung cho hành động thêm
      case 'update':
        return '$userName updated $nameTask'; // Nội dung cho hành động cập nhật
      case 'delete':
        return '$userName deleted $nameTask'; // Nội dung cho hành động xóa
      case 'update status':
        return '$userName update status of $nameTask'; // Nội dung cho hành động cập nhật tình trạng
      default:
        return 'Error when create content'; // Nội dung mặc định nếu không khớp hành động nào
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserNameandTask();
  }

  // hàm này hỗ trợ việc tự động cập nhật widget khi nội dung thay đổi
  // tránh tình trạng dữ liệu cũ đè lên dữ liệu mới
  @override
  void didUpdateWidget(covariant ActivityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi widget được cập nhật, fetch lại dữ liệu
    if (widget.actLog != oldWidget.actLog) {
      fetchUserNameandTask();
    }
  }

  Future<void> fetchUserNameandTask() async {
    // Lấy tên người dùng từ UserModel
    final userName = await UserService()
        .getFullNameByUid(widget.actLog.userActionId); // lấy name user action

    // Cập nhật trạng thái để gán nội dung activity
    if (mounted) {
      setState(() {
        actionUser = userName;
        contentActivity = getContent(
            widget.actLog.action, actionUser, widget.actLog.taskName);
        themeColor = getColor(widget.actLog.action); // Đặt màu sau khi fetch
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Project? currentProject =
        Provider.of<Project>(context, listen: false).currentProject;
    return GestureDetector(
      onTap: () async {
        final Task? task = await Provider.of<Task>(context, listen: false)
            .getTask(currentProject!.projectId,
                widget.actLog.taskId); // lấy thông tin task

        if (task == null) {
          // Task không còn tồn tại nữa
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task does not exist.'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaskDetailScreen(task: task, sourceScreen: 'ActivityScreen'),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dấu chấm tròn và thanh dọc
            Column(
              children: [
                // Dấu chấm tròn màu xanh dương
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.7), // Màu của dấu chấm
                    shape: BoxShape.circle,
                  ),
                ),
                // Thanh dọc màu xanh dương
                Container(
                  width: 2, // Độ rộng của thanh dọc
                  height: 90, // Chiều cao của thanh dọc
                  color: themeColor.withOpacity(0.3), // Màu của thanh dọc
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Nội dung chính
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loại hành động (Added, Updated, etc.)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(widget.actLog.action,
                        style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                  const SizedBox(height: 6),
                  // Mô tả chi tiết
                  Text(
                    contentActivity,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  // Thời gian
                  Text(
                    DateFormat('HH:mm, dd MMM yyyy')
                        .format(widget.actLog.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
