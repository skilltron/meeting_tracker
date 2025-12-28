enum TodoPriority {
  critical,  // Must do - red/orange
  high,      // Should do - yellow
  medium,    // Nice to do - blue
  low,       // Optional - gray
}

class MeetingTodo {
  final String id;
  final String meetingId; // Links to calendar event ID
  final String text;
  final bool isCompleted;
  final TodoPriority priority;
  final int orderIndex; // For drag-to-reorder within same priority
  final DateTime createdAt;
  
  MeetingTodo({
    required this.id,
    required this.meetingId,
    required this.text,
    this.isCompleted = false,
    this.priority = TodoPriority.medium,
    this.orderIndex = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  MeetingTodo copyWith({
    String? id,
    String? meetingId,
    String? text,
    bool? isCompleted,
    TodoPriority? priority,
    int? orderIndex,
    DateTime? createdAt,
  }) {
    return MeetingTodo(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // Priority order: critical > high > medium > low
  int get priorityOrder {
    switch (priority) {
      case TodoPriority.critical:
        return 0;
      case TodoPriority.high:
        return 1;
      case TodoPriority.medium:
        return 2;
      case TodoPriority.low:
        return 3;
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingId': meetingId,
      'text': text,
      'isCompleted': isCompleted,
      'priority': priority.toString(),
      'orderIndex': orderIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory MeetingTodo.fromJson(Map<String, dynamic> json) {
    TodoPriority priority = TodoPriority.medium;
    try {
      final priorityStr = json['priority'] ?? 'medium';
      priority = TodoPriority.values.firstWhere(
        (p) => p.toString() == priorityStr,
        orElse: () => TodoPriority.medium,
      );
    } catch (e) {
      // Default to medium if parsing fails
    }
    
    return MeetingTodo(
      id: json['id'],
      meetingId: json['meetingId'],
      text: json['text'],
      isCompleted: json['isCompleted'] ?? false,
      priority: priority,
      orderIndex: json['orderIndex'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
