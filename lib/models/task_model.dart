enum TaskStatus { toDo, inProgress, inReview, done }
enum Difficulty { low, medium, hard}

class Task {
  final String taskId;
  //final String groupId;
  final String taskName;
  final String description;
  final List<String> assigneeIds;
  final TaskStatus status;
  final DateTime dueDate;
  final DateTime createdAt;
  final Difficulty difficulty; 

  Task({
    required this.taskId,
    //required this.groupId,
    required this.taskName,
    required this.description,
    required this.assigneeIds,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    required this.difficulty,
  });

  // Convert a Task object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      //'groupId': groupId,
      'taskName': taskName,
      'description': description,
      'assigneeIds': assigneeIds,
      'status': status.name,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'difficulty': difficulty.name
    };
  }

  // Create a Task object from a map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      taskId: map['taskId'] ?? '',
      //groupId: map['groupId'] ?? '',
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