class HabitRecord {
  final String id;
  final String meetingId;
  final DateTime date;
  final bool attended;
  final bool prepared;
  final int preparationTasksCompleted;
  final int totalPreparationTasks;
  final String? notes;
  
  HabitRecord({
    required this.id,
    required this.meetingId,
    required this.date,
    this.attended = false,
    this.prepared = false,
    this.preparationTasksCompleted = 0,
    this.totalPreparationTasks = 0,
    this.notes,
  });
  
  HabitRecord copyWith({
    String? id,
    String? meetingId,
    DateTime? date,
    bool? attended,
    bool? prepared,
    int? preparationTasksCompleted,
    int? totalPreparationTasks,
    String? notes,
  }) {
    return HabitRecord(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      date: date ?? this.date,
      attended: attended ?? this.attended,
      prepared: prepared ?? this.prepared,
      preparationTasksCompleted:
          preparationTasksCompleted ?? this.preparationTasksCompleted,
      totalPreparationTasks:
          totalPreparationTasks ?? this.totalPreparationTasks,
      notes: notes ?? this.notes,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meetingId': meetingId,
      'date': date.toIso8601String(),
      'attended': attended,
      'prepared': prepared,
      'preparationTasksCompleted': preparationTasksCompleted,
      'totalPreparationTasks': totalPreparationTasks,
      'notes': notes,
    };
  }
  
  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    return HabitRecord(
      id: json['id'],
      meetingId: json['meetingId'],
      date: DateTime.parse(json['date']),
      attended: json['attended'] ?? false,
      prepared: json['prepared'] ?? false,
      preparationTasksCompleted: json['preparationTasksCompleted'] ?? 0,
      totalPreparationTasks: json['totalPreparationTasks'] ?? 0,
      notes: json['notes'],
    );
  }
}
