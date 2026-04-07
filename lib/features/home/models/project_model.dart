class ProjectModel {
  final String id;
  final String name;
  final String color;
  final String icon;
  final bool isDefault;
  final int taskCount;
  final int completedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectModel({
    required this.id,
    required this.name,
    this.color = '#7C3AED',
    this.icon = 'folder',
    this.isDefault = false,
    this.taskCount = 0,
    this.completedCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    return ProjectModel(
      id: id,
      name: map['name'] ?? '',
      color: map['color'] ?? '#7C3AED',
      icon: map['icon'] ?? 'folder',
      isDefault: map['isDefault'] ?? false,
      taskCount: map['taskCount'] ?? 0,
      completedCount: map['completedCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'icon': icon,
      'isDefault': isDefault,
      'taskCount': taskCount,
      'completedCount': completedCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    bool? isDefault,
    int? taskCount,
    int? completedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      taskCount: taskCount ?? this.taskCount,
      completedCount: completedCount ?? this.completedCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
