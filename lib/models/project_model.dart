import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruprup/models/task_model.dart';

class Project {
  final String projectId; // ID của dự án
  final String projectName; // Tên dự án
  final String description; // Mô tả dự án
  final DateTime startDate; // Ngày bắt đầu
  final DateTime? endDate; // Ngày kết thúc
  final String ownerId; // ID của người sở hữu dự án
  final List<String> memberIds; // Danh sách ID của các thành viên trong dự án
  final int toDo; // Công việc cần làm
  final int inProgress; // Công việc đang tiến hành
  final int inReview; // Công việc đang được đánh giá
  final int done; // Công việc đã hoàn thành
  final List<Task> tasks;

  Project({
    required this.projectId,
    required this.projectName,
    required this.description,
    required this.startDate,
    this.endDate, // có thể null
    required this.ownerId,
    required this.memberIds,
    this.toDo = 0, // Giá trị mặc định là 0
    this.inProgress = 0, // Giá trị mặc định là 0
    this.inReview = 0, // Giá trị mặc định là 0
    this.done = 0, // Giá trị mặc định là 0
    required this.tasks
  });

  // Phương thức để chuyển đổi đối tượng thành Map (có thể sử dụng để lưu vào Firestore)
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'ownerId': ownerId,
      'memberIds': memberIds,
      'toDo': toDo,
      'inProgress': inProgress,
      'inReview': inReview,
      'done': done,
      'tasks': tasks
    };
  }

  // Phương thức để khởi tạo đối tượng từ Map (có thể sử dụng khi lấy dữ liệu từ Firestore)
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      projectId: map['projectId'],
      projectName: map['projectName'],
      description: map['description'],
      startDate:  map['startDate'] is Timestamp
        ? (map['startDate'] as Timestamp).toDate()
        : DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      ownerId: map['ownerId'],
      memberIds: List<String>.from(map['memberIds']),
      toDo: map['toDo'] ?? 0,
      inProgress: map['inProgress'] ?? 0,
      inReview: map['inReview'] ?? 0,
      done: map['done'] ?? 0,
      tasks: List<Task>.from(map['tasks'])
    );
  }

  int getTotalTask() {
    return toDo + inProgress + inReview + done;
  }
}
