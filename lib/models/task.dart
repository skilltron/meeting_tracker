enum TaskStatus {
  todo,
  inProgress,
  review,
  done,
  blocked,
}

enum TaskPriority {
  critical,
  high,
  medium,
  low,
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assignedTo; // User ID
  final String? assignedByName;
  final String createdBy; // User ID
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? meetingId; // Linked meeting
  final String? gitIssueNumber; // GitHub issue number
  final String? gitIssueUrl; // GitHub issue URL
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  
  Task({
    required this.id,
    required this.title,
    required this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.assignedTo,
    this.assignedByName,
    required this.createdBy,
    DateTime? createdAt,
    this.dueDate,
    this.completedAt,
    this.meetingId,
    this.gitIssueNumber,
    this.gitIssueUrl,
    this.tags = const [],
    this.metadata,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedTo,
    String? assignedByName,
    String? createdBy,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
    String? meetingId,
    String? gitIssueNumber,
    String? gitIssueUrl,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedByName: assignedByName ?? this.assignedByName,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      meetingId: meetingId ?? this.meetingId,
      gitIssueNumber: gitIssueNumber ?? this.gitIssueNumber,
      gitIssueUrl: gitIssueUrl ?? this.gitIssueUrl,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toString(),
      'priority': priority.toString(),
      'assignedTo': assignedTo,
      'assignedByName': assignedByName,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'meetingId': meetingId,
      'gitIssueNumber': gitIssueNumber,
      'gitIssueUrl': gitIssueUrl,
      'tags': tags,
      'metadata': metadata,
    };
  }
  
  factory Task.fromJson(Map<String, dynamic> json) {
    TaskStatus status = TaskStatus.todo;
    TaskPriority priority = TaskPriority.medium;
    
    try {
      final statusStr = json['status'] ?? 'todo';
      status = TaskStatus.values.firstWhere(
        (s) => s.toString() == statusStr,
        orElse: () => TaskStatus.todo,
      );
    } catch (e) {}
    
    try {
      final priorityStr = json['priority'] ?? 'medium';
      priority = TaskPriority.values.firstWhere(
        (p) => p.toString() == priorityStr,
        orElse: () => TaskPriority.medium,
      );
    } catch (e) {}
    
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      status: status,
      priority: priority,
      assignedTo: json['assignedTo'],
      assignedByName: json['assignedByName'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      meetingId: json['meetingId'],
      gitIssueNumber: json['gitIssueNumber'],
      gitIssueUrl: json['gitIssueUrl'],
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      metadata: json['metadata'],
    );
  }
}
