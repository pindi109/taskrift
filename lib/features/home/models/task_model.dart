class TaskModel {
  final String id;
  final String title;
  final String? note;
  final String projectId;
  final DateTime? dueDate;
  final String priority;
  final String status;
  final bool isCompleted;
  final List<String> labels;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const TaskModel({
    required this.id,
    required this.title,
    this.note,
    required this.projectId,
    this.dueDate,
    this.priority = 'medium',
    this.status = 'todo',
    this.isCompleted = false,
    this.labels = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      note: map['note'],
      projectId: map['projectId'] ?? 'inbox',
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as dynamic).toDate()
          : null,
      priority: map['priority'] ?? 'medium',
      status: map['status'] ?? 'todo',
      isCompleted: map['isCompleted'] ?? false,
      labels: List<String>.from(map['labels'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate()
          : DateTime.now(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'note': note,
      'projectId': projectId,
      'dueDate': dueDate,
      'priority': priority,
      'status': status,
      'isCompleted': isCompleted,
      'labels': labels,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? note,
    String? projectId,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? priority,
    String? status,
    bool? isCompleted,
    List<String>? labels,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      projectId: projectId ?? this.projectId,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      labels: labels ?? this.labels,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}
