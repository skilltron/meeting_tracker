class TimeEntry {
  final String id;
  final String activityName;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final String? notes;
  
  TimeEntry({
    required this.id,
    required this.activityName,
    required this.startTime,
    this.endTime,
    this.duration,
    this.notes,
  });
  
  Duration get totalDuration {
    if (duration != null) return duration!;
    if (endTime != null) return endTime!.difference(startTime);
    return DateTime.now().difference(startTime);
  }
  
  bool get isActive => endTime == null;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityName': activityName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': duration?.inSeconds,
      'notes': notes,
    };
  }
  
  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'] ?? '',
      activityName: json['activityName'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: json['durationSeconds'] != null 
          ? Duration(seconds: json['durationSeconds'])
          : null,
      notes: json['notes'],
    );
  }
  
  String toCsvLine() {
    final duration = totalDuration;
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    final seconds = (duration.inSeconds % 60);
    final durationStr = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    return '${startTime.toIso8601String()},${endTime?.toIso8601String() ?? "Active"},$activityName,$durationStr,${notes ?? ""}';
  }
  
  static String getCsvHeader() {
    return 'Start Time,End Time,Activity,Duration,Notes';
  }
}
