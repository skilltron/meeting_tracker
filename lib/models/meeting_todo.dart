class MeetingTodo {
  final String id;
  final String meetingId; // Links to calendar event ID
  final String text;
  final bool isCompleted;
  final DateTime createdAt;
  
  MeetingTodo({
    required this.id,
    required this.meetingId,
    required this.text,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  MeetingTodo copyWith({
    String? id,
    String? meetingId,
    String? text,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return MeetingTodo(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingId': meetingId,
      'text': text,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory MeetingTodo.fromJson(Map<String, dynamic> json) {
    return MeetingTodo(
      id: json['id'],
      meetingId: json['meetingId'],
      text: json['text'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
