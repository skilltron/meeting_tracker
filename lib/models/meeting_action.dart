enum MeetingActionType {
  raiseHand,
  lowerHand,
  tableTopic,
  actionItem,
}

enum ActionItemStatus {
  pending,
  inProgress,
  completed,
  blocked,
}

class MeetingAction {
  final String id;
  final String meetingId;
  final MeetingActionType type;
  final String userId; // GitHub username or user identifier
  final String? userName;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // Additional data based on action type
  
  MeetingAction({
    required this.id,
    required this.meetingId,
    required this.type,
    required this.userId,
    this.userName,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingId': meetingId,
      'type': type.toString(),
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
  
  factory MeetingAction.fromJson(Map<String, dynamic> json) {
    MeetingActionType type = MeetingActionType.raiseHand;
    try {
      final typeStr = json['type'] ?? 'raiseHand';
      type = MeetingActionType.values.firstWhere(
        (t) => t.toString() == typeStr,
        orElse: () => MeetingActionType.raiseHand,
      );
    } catch (e) {
      // Default to raiseHand
    }
    
    return MeetingAction(
      id: json['id'],
      meetingId: json['meetingId'],
      type: type,
      userId: json['userId'],
      userName: json['userName'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      metadata: json['metadata'],
    );
  }
}

class ActionItem {
  final String id;
  final String meetingId;
  final String title;
  final String description;
  final String assignedTo; // User ID
  final String? assignedByName;
  final String assignedBy; // Moderator/assigner user ID
  final ActionItemStatus status;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;
  
  ActionItem({
    required this.id,
    required this.meetingId,
    required this.title,
    required this.description,
    required this.assignedTo,
    this.assignedByName,
    required this.assignedBy,
    this.status = ActionItemStatus.pending,
    required this.dueDate,
    DateTime? createdAt,
    this.completedAt,
    this.notes,
  }) : createdAt = createdAt ?? DateTime.now();
  
  ActionItem copyWith({
    String? id,
    String? meetingId,
    String? title,
    String? description,
    String? assignedTo,
    String? assignedByName,
    String? assignedBy,
    ActionItemStatus? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
    String? notes,
  }) {
    return ActionItem(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedByName: assignedByName ?? this.assignedByName,
      assignedBy: assignedBy ?? this.assignedBy,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingId': meetingId,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedByName': assignedByName,
      'assignedBy': assignedBy,
      'status': status.toString(),
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }
  
  factory ActionItem.fromJson(Map<String, dynamic> json) {
    ActionItemStatus status = ActionItemStatus.pending;
    try {
      final statusStr = json['status'] ?? 'pending';
      status = ActionItemStatus.values.firstWhere(
        (s) => s.toString() == statusStr,
        orElse: () => ActionItemStatus.pending,
      );
    } catch (e) {
      // Default to pending
    }
    
    return ActionItem(
      id: json['id'],
      meetingId: json['meetingId'],
      title: json['title'],
      description: json['description'],
      assignedTo: json['assignedTo'],
      assignedByName: json['assignedByName'],
      assignedBy: json['assignedBy'],
      status: status,
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      notes: json['notes'],
    );
  }
}

class TabledTopic {
  final String id;
  final String meetingId;
  final String topic;
  final String requestedBy; // User ID
  final String? requestedByName;
  final DateTime requestedAt;
  final String? reason;
  final String? scheduledForMeetingId; // If rescheduled to another meeting
  final DateTime? scheduledForDate;
  
  TabledTopic({
    required this.id,
    required this.meetingId,
    required this.topic,
    required this.requestedBy,
    this.requestedByName,
    DateTime? requestedAt,
    this.reason,
    this.scheduledForMeetingId,
    this.scheduledForDate,
  }) : requestedAt = requestedAt ?? DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingId': meetingId,
      'topic': topic,
      'requestedBy': requestedBy,
      'requestedByName': requestedByName,
      'requestedAt': requestedAt.toIso8601String(),
      'reason': reason,
      'scheduledForMeetingId': scheduledForMeetingId,
      'scheduledForDate': scheduledForDate?.toIso8601String(),
    };
  }
  
  factory TabledTopic.fromJson(Map<String, dynamic> json) {
    return TabledTopic(
      id: json['id'],
      meetingId: json['meetingId'],
      topic: json['topic'],
      requestedBy: json['requestedBy'],
      requestedByName: json['requestedByName'],
      requestedAt: json['requestedAt'] != null
          ? DateTime.parse(json['requestedAt'])
          : DateTime.now(),
      reason: json['reason'],
      scheduledForMeetingId: json['scheduledForMeetingId'],
      scheduledForDate: json['scheduledForDate'] != null
          ? DateTime.parse(json['scheduledForDate'])
          : null,
    );
  }
}
