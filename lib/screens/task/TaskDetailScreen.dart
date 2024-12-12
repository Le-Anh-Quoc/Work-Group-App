// ignore_for_file: file_names, unused_element, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/comment_model.dart';
import 'package:ruprup/models/file/file_comment.dart';
import 'package:ruprup/models/file/file_task.dart';
import 'package:ruprup/models/project/task_model.dart';
import 'package:ruprup/models/user_model.dart';
import 'package:ruprup/providers/comment_provider.dart';
import 'package:ruprup/providers/project_provider.dart';
import 'package:ruprup/providers/taskFileComment_provider.dart';
import 'package:ruprup/providers/taskFile_provider.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/screens/project/DetailProjectScreen.dart';
import 'package:ruprup/screens/task/TaskListScreen.dart';
import 'package:ruprup/services/storage_service.dart';
import 'package:ruprup/services/user_service.dart';
import 'package:ruprup/widgets/avatar/InitialsAvatar.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:ruprup/widgets/task/AddCommentWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  final String sourceScreen;
  const TaskDetailScreen(
      {super.key, required this.task, required this.sourceScreen});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final String actionUserId = FirebaseAuth.instance.currentUser!.uid;
  StorageService storageService = StorageService();

  // Hàm tải lên tệp
  Future<void> _pickFile() async {
    final taskfileProvider =
        Provider.of<TaskFileProvider>(context, listen: false);
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      String? filePath = result.files.single.path;
      String fileName = result.files.single.name;

      if (filePath != null) {
        // Đọc file từ đường dẫn
        final file = File(filePath);

        // Tải file lên Firebase Storage
        String downloadUrl = await storageService
            .uploadFileTaskToFirebaseStorage(file, widget.task!.taskId);

        taskfileProvider.createFileTask(
            projectProvider.currentProject!.projectId,
            FileTask(
              id: "", // Firebase sẽ tự động tạo ID
              name: fileName,
              downloadUrl: downloadUrl,
              taskId: widget.task!.taskId,
              createdAt: DateTime.now(),
              createdBy: actionUserId,
            ));

        // Làm mới UI
        setState(() {});
      }
    } else {
      print("Tai file len task khong thanh cong");
    }
  }

  void _deleteFile(String fileId, String downloadUrl) async {
    final currentProject =
        Provider.of<ProjectProvider>(context, listen: false).currentProject;
    // Xóa tệp từ Firebase Storage và Firestore
    await StorageService().deleteFileFromFirebaseStorage(downloadUrl);

    // Cập nhật lại danh sách tệp trong provider
    Provider.of<TaskFileProvider>(context, listen: false)
        .deleteFileTask(currentProject!.projectId, fileId);

    // Cập nhật UI
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final currentProject =
        Provider.of<ProjectProvider>(context, listen: false).currentProject;
    // Gọi phương thức fetchFileTask trong addPostFrameCallback để đảm bảo sau khi giao diện đã xây dựng xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskFileProvider>(context, listen: false)
          .fetchFileTask(currentProject!.projectId, widget.task!.taskId)
          .then((_) {
        // Sau khi fetchFileTask hoàn tất, lấy dữ liệu fileTask
        final fileTask =
            Provider.of<TaskFileProvider>(context, listen: false).fileTask;
        print(fileTask); // In dữ liệu fileTask sau khi hoàn tất
      });
      Provider.of<CommentProvider>(context, listen: false)
          .fetchCommentsTask(currentProject.projectId, widget.task!.taskId)
          .then((_) {
        // Sau khi fetchFileTask hoàn tất, lấy dữ liệu fileTask
        final commentTask =
            Provider.of<CommentProvider>(context, listen: false).commentsTask;
        print(commentTask); // In dữ liệu fileTask sau khi hoàn tất
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentProject =
        Provider.of<ProjectProvider>(context, listen: false).currentProject;
    final taskfileProvider =
        Provider.of<TaskFileProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            if (widget.sourceScreen == 'HomeScreen') {
              // Quay về HomeScreen
              Navigator.pop(context);
              taskfileProvider.clearFileTask();
            } else if (widget.sourceScreen == 'ActivityScreen') {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) =>
                        DetailProjectScreen(project: currentProject)),
              );
              taskfileProvider.clearFileTask();
            } else {
              // Quay về TaskListScreen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TaskListScreen(
                    typeTask: widget.task!.status.name,
                    project: currentProject,
                  ),
                ),
              );
              taskfileProvider.clearFileTask();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
        ),
        // title: const Text('Task', style: TextStyle(color: Colors.grey)),
        // centerTitle: true,
        actions: _buildTaskActions(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTaskTitle(),
              const SizedBox(height: 16),
              // _buildCreaterRow(currentProject!.ownerId),
              //const SizedBox(height: 16),
              _buildTaskDescription(),
              const SizedBox(height: 16),
              _buildDueDateRow(),
              const SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildDifficultyIndicator(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildAssigneeList(),
                    ),
                  ],
                ),
              ),
              _buildAttachmentSection(),
              _buildCommentSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Các phương thức riêng cho các phần tử widget
  Widget _buildTaskTitle() {
    return Text(
      widget.task!.taskName,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildCreaterRow(String ownerProject) {
    final name = UserService().getFullNameByUid(ownerProject);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InitialsAvatar(
              name: name,
              size: 30,
            ),
            const SizedBox(width: 5),
            const Text('Created by \'Project Leader\'',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskDescription() {
    return Text(
      widget.task!.description,
      style: const TextStyle(fontSize: 18, color: Colors.black, height: 1.4),
    );
  }

  Widget _buildDueDateRow() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.rocket_launch_outlined, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(
              '${DateFormat('hh:mm a').format(widget.task!.createdAt)} on ${DateFormat('EEE, dd MMM yyyy').format(widget.task!.createdAt)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.flag, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(
              '${DateFormat('hh:mm a').format(widget.task!.dueDate)} on ${DateFormat('EEE, dd MMM yyyy').format(widget.task!.dueDate)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDifficultyIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getBackgroundColorForDifficulty(widget.task!.priority),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.task!.priority.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getTextColorForDifficulty(widget.task!.priority),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssigneeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assigned to',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.grey,
            )),
        InitialsAvatar(
          name: UserService().getFullNameByUid(widget.task!.assigneeId),
          size: 45,
        ),
      ],
    );
  }

  Widget _buildAttachmentSection() {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;

    return Consumer<TaskFileProvider>(
      builder: (context, taskfileProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Attachment (${taskfileProvider.fileTask?.length ?? 0})',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.grey,
                    )),
                if (widget.task!.assigneeId == currentUser!.userId)
                  IconButton(
                      onPressed: _pickFile,
                      icon:
                          Icon(Icons.attach_file, color: Colors.blue, size: 18))
              ],
            ),
            if (taskfileProvider.fileTask != null &&
                taskfileProvider.fileTask!.isNotEmpty)
              SizedBox(
                height: 180,
                child: ListView.builder(
                    itemCount: taskfileProvider.fileTask!.length,
                    itemBuilder: (context, index) {
                      final file = taskfileProvider.fileTask![index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade100,
                          border: Border.all(
                              color: Colors.grey.shade300, width: 0.8),
                        ),
                        child: ListTile(
                          onTap: () {
                            launchUrl(Uri.parse(file.downloadUrl));
                          },
                          leading: Icon(Icons.insert_drive_file,
                              color: Colors.blue, size: 30),
                          title: Text(file.name),
                          trailing: widget.task!.assigneeId ==
                                  currentUser.userId
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteFile(file.id, file.downloadUrl),
                                )
                              : null,
                        ),
                      );
                    }),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCommentSection() {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    return Consumer<CommentProvider>(
        builder: (context, commentProvider, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề section Comment
          commentHeader(commentProvider.commentsTask!.length),
          const SizedBox(height: 10),

          if (commentProvider.commentsTask != null &&
              commentProvider.commentsTask!.isNotEmpty)
            // Danh sách các comment
            commentList(commentProvider.commentsTask)
        ],
      );
    });
  }

  Widget commentHeader(int commentCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Comment ($commentCount)',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(25.0)),
                ),
                builder: (BuildContext context) {
                  return AddCommentWidget(taskId: widget.task!.taskId);
                },
              );
            },
            icon: Icon(
              Icons.comment_outlined,
              color: Colors.blue,
              size: 18,
            ))
      ],
    );
  }

  Widget commentList(List<Comment>? commentsTask) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: commentsTask!.length,
      itemBuilder: (context, index) {
        final comment = commentsTask[index];

        return FutureBuilder<UserModel?>(
          future: UserService()
              .readUser(comment.createdBy), // Lấy thông tin người dùng
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Hiển thị trạng thái đang tải
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              // Hiển thị thông báo lỗi
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Lỗi khi tải thông tin người dùng: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              // Không tìm thấy người dùng
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Người dùng không tồn tại',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            } else {
              final userComment = snapshot.data!;
              return commentCard(userComment, comment);
            }
          },
        );
      },
    );
  }

  Widget commentCard(UserModel userComment, Comment comment) {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;

    final taskFileCommentProvider =
        Provider.of<TaskFileCommentProvider>(context, listen: false);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Avatar của người comment
                    PersonalInitialsAvatar(
                      name: userComment.fullname, // Tên đầy đủ người dùng
                      size: 40,
                    ),
                    const SizedBox(width: 15),
                    // Tên người comment và ngày giờ của comment
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userComment.fullname, // Hiển thị tên người dùng
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${DateFormat('hh:mm a').format(comment.createdAt)} ${DateFormat(', dd MMM yyyy').format(comment.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (currentUser!.userId == comment.createdBy)
                  PopupMenuButton<String>(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'update_cmt') {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(25.0)),
                          ),
                          builder: (BuildContext context) {
                            return AddCommentWidget(
                                taskId: widget.task!.taskId,
                                comment: comment);
                          },
                        );
                      } else if (value == 'delete_cmt') {
                        // Thực hiện hành động khi chọn "Xóa"
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirm deletion'),
                              content: Text(
                                  'Are you sure you want to delete this comment?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // Logic xóa ở đây
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Comment deleted successfully!')),
                                    );
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    icon: const Icon(Icons.more_vert, size: 18),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'update_cmt',
                        child: Row(
                          children: [
                            Icon(Icons.update, color: Colors.orangeAccent),
                            SizedBox(width: 8),
                            Text('Update'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete_cmt',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            // Nội dung comment
            Text(
              comment.content, // Nội dung comment
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            // Danh sách file đính kèm
            fileCommentList(comment)
          ],
        ),
      ),
    );
  }

  Widget fileCommentList(Comment comment) {
    final currentProject = Provider.of<ProjectProvider>(context, listen: false).currentProject;
    return Consumer<TaskFileCommentProvider>(
      builder: (context, provider, child) {
        return FutureBuilder<List<FileComment>>(
          future: provider.fetchFileCommentsByCommentId(currentProject!.projectId, comment.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Lỗi: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox();
            }

            final fileComments = snapshot.data!;

            return Container(
              margin: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fileComments.length,
                itemBuilder: (context, index) {
                  final fileComment = fileComments[index];
                  return fileCard(fileComment);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget fileCard(FileComment fileComment) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
      ),
      child: ListTile(
        onTap: () {
          launchUrl(Uri.parse(fileComment.downloadUrl));
        },
        leading: Icon(Icons.insert_drive_file, color: Colors.blue, size: 30),
        title: Text(
          fileComment.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // Tách riêng hành động task ra một phương thức riêng
  List<Widget> _buildTaskActions(BuildContext context) {
    final task = widget.task!;
    if (!task.assigneeId.contains(actionUserId)) return [];

    List<Widget> actions = [];
    if (task.status == TaskStatus.toDo) {
      actions.add(_buildActionButton(Icons.launch, Colors.blueAccent,
          () => _updateTaskStatus(context, TaskStatus.inProgress)));
    } else if (task.status == TaskStatus.inProgress) {
      actions.addAll([
        _buildActionButton(Icons.replay, Colors.orange,
            () => _updateTaskStatus(context, TaskStatus.toDo)),
        _buildActionButton(Icons.visibility, Colors.redAccent,
            () => _updateTaskStatus(context, TaskStatus.inReview)),
      ]);
    } else if (task.status == TaskStatus.inReview) {
      actions.addAll([
        _buildActionButton(Icons.replay, Colors.orange,
            () => _updateTaskStatus(context, TaskStatus.inProgress)),
        _buildActionButton(Icons.done, Colors.green,
            () => _updateTaskStatus(context, TaskStatus.done)),
      ]);
    }
    return actions;
  }

  IconButton _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      iconSize: 30,
      onPressed: onPressed,
    );
  }

  Future<void> _updateTaskStatus(
      BuildContext context, TaskStatus status) async {
    await Provider.of<Task>(context, listen: false).updateTaskStatus(
      context,
      widget.task!.projectId,
      widget.task!.taskId,
      status,
      actionUserId,
    );
  }

  // Hàm để lấy màu và icon
  Color _getBackgroundColorForDifficulty(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.none:
        return Colors.blueAccent.withOpacity(0.2);
      case TaskPriority.low:
        return Colors.greenAccent.withOpacity(0.2);
      case TaskPriority.medium:
        return Colors.orangeAccent.withOpacity(0.2);
      case TaskPriority.high:
        return Colors.redAccent.withOpacity(0.2);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColorForDifficulty(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.none:
        return Colors.blueAccent;
      case TaskPriority.low:
        return Colors.greenAccent;
      case TaskPriority.medium:
        return Colors.orangeAccent;
      case TaskPriority.high:
        return Colors.redAccent;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getFileIcon(File file) {
    final extension = path.extension(file.path).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Icons.image;
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      default:
        return Icons.attach_file;
    }
  }
}
