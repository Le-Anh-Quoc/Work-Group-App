enum TaskStatus { toDo, inProgress, inReview, done }
enum Difficulty { low, medium, hard}

class Task {
  late final String taskId;
  final String projectId;
  final String taskName;
  final String description;
  final List<String> assigneeIds;
  final TaskStatus status;
  final DateTime dueDate;
  final DateTime createdAt;
  final Difficulty difficulty; 

  Task({
    required this.taskId,
    required this.projectId,    //
    required this.taskName,
    required this.description,
    required this.assigneeIds,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    required this.difficulty,
  });

  Task copyWith({String? taskId}) {
    return Task(
      taskId: taskId ?? this.taskId, // Nếu không cung cấp taskId mới, sử dụng taskId hiện tại
      taskName: taskName,
      description: description,
      assigneeIds: assigneeIds,
      status: status,
      dueDate: dueDate,
      createdAt: createdAt,
      difficulty: difficulty, projectId: projectId,
    );
  }

  // Convert a Task object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'projectId': projectId,
      'taskName': taskName,
      'description': description,
      'assigneeIds': assigneeIds,
      'status': status.name,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'difficulty': difficulty.name
    };
  }

  // Create a Task object from a map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      taskId: map['taskId'] ?? '',
      projectId: map['projectId'] ?? '',
      taskName: map['taskName'] ?? '',
      description: map['description'] ?? '',
      assigneeIds: List<String>.from(map['assigneeIds'] ?? []),
      status: TaskStatus.values.firstWhere(
          (e) => e.name == map['status'], orElse: () => TaskStatus.toDo),
      dueDate: DateTime.parse(map['dueDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      difficulty: Difficulty.values.firstWhere(
          (e) => e.name == map['difficulty'], orElse: () => Difficulty.medium),
    );
  }
}