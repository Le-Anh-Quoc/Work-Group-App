// ignore_for_file: unrelated_type_equality_checks, file_names

import 'dart:io';
// import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:ruprup/models/comment_model.dart';
import 'package:ruprup/models/file/file_comment.dart';
import 'package:ruprup/providers/comment_provider.dart';
import 'package:ruprup/providers/project_provider.dart';
import 'package:ruprup/providers/taskFileComment_provider.dart';
import 'package:ruprup/providers/user_provider.dart';
import 'package:ruprup/services/storage_service.dart';

class AddCommentWidget extends StatefulWidget {
  final String taskId;
  final Comment? comment;
  const AddCommentWidget({super.key, required this.taskId, this.comment});

  @override
  State<AddCommentWidget> createState() => _AddCommentWidgetState();
}

class _AddCommentWidgetState extends State<AddCommentWidget> {
  late TextEditingController _commentController = TextEditingController();
  final List<File> _uploadedFiles = [];

  final List<String> _upload = [];

  StorageService storageService = StorageService();

  @override
  void initState() {
    super.initState();

    _commentController =
        TextEditingController(text: widget.comment?.content ?? '');

  }

  // Hàm để thêm file vào danh sách
  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _uploadedFiles
            .addAll(result.paths.whereType<String>().map((path) => File(path)));

        _upload.addAll(
          result.paths
              .whereType<String>() // Lọc các path hợp lệ
              .map((path) => basename(path)), // Lấy tên file từ đường dẫn
        );
      });
    }
  }

  // Hàm để xóa file khỏi danh sách
  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
      _upload.removeAt(index);
    });
  }

  void _submitComment(
      CommentProvider cmtProvider,
      TaskFileCommentProvider fileCommentProvider,
      String projectId,
      String currentUserId) async {
    Comment newComment = Comment(
        id: '',
        content: _commentController.text,
        taskId: widget.taskId,
        createdAt: DateTime.now(),
        createdBy: currentUserId);
    final commentId = await cmtProvider.createComment(projectId, newComment);

    if (_uploadedFiles.isNotEmpty) {
      for (File file in _uploadedFiles) {
        String fileName = basename(file.path);

        String downloadUrl = await storageService
            .uploadFileCommentToFirebaseStorage(file, commentId);

        FileComment newFileComment = FileComment(
            id: '',
            name: fileName,
            downloadUrl: downloadUrl,
            createdAt: DateTime.now(),
            createdBy: currentUserId,
            commentId: commentId);

        fileCommentProvider.createFileComment(projectId, newFileComment);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    final currentProject =
        Provider.of<ProjectProvider>(context, listen: false).currentProject;
    final commentProvider =
        Provider.of<CommentProvider>(context, listen: false);
    final taskFileCommentProvider =
        Provider.of<TaskFileCommentProvider>(context, listen: false);
    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Comment Task',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_commentController.text.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Comment'),
                          content: const Text(
                            'Comment đang trống! Vui lòng thêm nội dung hoặc tệp đính kèm.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Đóng hộp thoại
                              },
                              child: const Text('Đóng'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    _submitComment(commentProvider, taskFileCommentProvider,
                        currentProject!.projectId, currentUser!.userId);

                    Provider.of<CommentProvider>(context, listen: false)
                        .fetchCommentsTask(
                            currentProject.projectId, widget.taskId);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Comment', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter comment here...',
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
          // const SizedBox(height: 10),
          // Danh sách file đã đính kèm
          ElevatedButton.icon(
            onPressed: () {
              // Thêm file mẫu (thay thế bằng logic chọn file thực tế)
              _pickFile();
            },
            icon: const Icon(
              Icons.attach_file,
              color: Colors.blue,
              size: 16,
            ),
            label: const Text(
              'Attach',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
          ),
          if (_upload.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _upload.length,
                itemBuilder: (context, index) {
                  final file = _upload[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      //border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file,
                          color: Colors.blueAccent),
                      title: Text(file),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeFile(index),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // IconData _getFileIcon(File file) {
  //   final extension = path.extension(file.path).toLowerCase();
  //   switch (extension) {
  //     case '.jpg':
  //     case '.jpeg':
  //     case '.png':
  //       return Icons.image;
  //     case '.pdf':
  //       return Icons.picture_as_pdf;
  //     case '.doc':
  //     case '.docx':
  //       return Icons.description;
  //     case '.xls':
  //     case '.xlsx':
  //       return Icons.table_chart;
  //     default:
  //       return Icons.attach_file;
  //   }
  // }
}
