enum MessageStatus {
  draft,
  scheduled,
  sent,
  failed,
}

enum MessagePriority {
  normal,
  priority,
  urgent,
}

class Message {
  final String id;
  final String fromUserId;
  final String? fromUserName;
  final String toUserId;
  final String? toUserName;
  final String subject;
  final String content;
  final MessagePriority priority;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final DateTime? sentAt;
  final String? error;
  final List<String> relatedMessageIds; // For batching related messages
  final bool isBatched; // If this message was combined with others
  
  Message({
    required this.id,
    required this.fromUserId,
    this.fromUserName,
    required this.toUserId,
    this.toUserName,
    required this.subject,
    required this.content,
    this.priority = MessagePriority.normal,
    this.status = MessageStatus.draft,
    DateTime? createdAt,
    this.scheduledFor,
    this.sentAt,
    this.error,
    this.relatedMessageIds = const [],
    this.isBatched = false,
  }) : createdAt = createdAt ?? DateTime.now();
  
  Message copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? toUserId,
    String? toUserName,
    String? subject,
    String? content,
    MessagePriority? priority,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? scheduledFor,
    DateTime? sentAt,
    String? error,
    List<String>? relatedMessageIds,
    bool? isBatched,
  }) {
    return Message(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      sentAt: sentAt ?? this.sentAt,
      error: error ?? this.error,
      relatedMessageIds: relatedMessageIds ?? this.relatedMessageIds,
      isBatched: isBatched ?? this.isBatched,
    );
  }
  
  // Check if message should be delayed (after hours, default to next day)
  static DateTime? calculateScheduledTime(MessagePriority priority) {
    final now = DateTime.now();
    final hour = now.hour;
    
    // Priority override: send immediately regardless of time
    if (priority == MessagePriority.urgent || priority == MessagePriority.priority) {
      return null; // Send immediately
    }
    
    // After hours (after 6 PM or before 8 AM): schedule for next business day at 9 AM
    if (hour >= 18 || hour < 8) {
      final nextDay = now.add(const Duration(days: 1));
      // If weekend, move to Monday
      final weekday = nextDay.weekday;
      final daysToAdd = weekday == 6 ? 2 : (weekday == 7 ? 1 : 0);
      final scheduledDate = nextDay.add(Duration(days: daysToAdd));
      return DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day, 9, 0);
    }
    
    return null; // Send immediately during business hours
  }
  
  // Check if two messages are related (for batching)
  static bool areRelated(Message msg1, Message msg2) {
    // Same sender and recipient
    if (msg1.fromUserId != msg2.fromUserId || msg1.toUserId != msg2.toUserId) {
      return false;
    }
    
    // Similar subject or content
    final subjectSimilarity = _calculateSimilarity(msg1.subject, msg2.subject);
    final contentSimilarity = _calculateSimilarity(msg1.content, msg2.content);
    
    return subjectSimilarity > 0.5 || contentSimilarity > 0.3;
  }
  
  static double _calculateSimilarity(String str1, String str2) {
    if (str1.isEmpty || str2.isEmpty) return 0.0;
    
    final words1 = str1.toLowerCase().split(RegExp(r'\s+'));
    final words2 = str2.toLowerCase().split(RegExp(r'\s+'));
    
    final intersection = words1.where((w) => words2.contains(w)).length;
    final union = (words1.toSet()..addAll(words2)).length;
    
    return union > 0 ? intersection / union : 0.0;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'subject': subject,
      'content': content,
      'priority': priority.toString(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'error': error,
      'relatedMessageIds': relatedMessageIds,
      'isBatched': isBatched,
    };
  }
  
  factory Message.fromJson(Map<String, dynamic> json) {
    MessagePriority priority = MessagePriority.normal;
    MessageStatus status = MessageStatus.draft;
    
    try {
      final priorityStr = json['priority'] ?? 'normal';
      priority = MessagePriority.values.firstWhere(
        (p) => p.toString() == priorityStr,
        orElse: () => MessagePriority.normal,
      );
    } catch (e) {}
    
    try {
      final statusStr = json['status'] ?? 'draft';
      status = MessageStatus.values.firstWhere(
        (s) => s.toString() == statusStr,
        orElse: () => MessageStatus.draft,
      );
    } catch (e) {}
    
    return Message(
      id: json['id'],
      fromUserId: json['fromUserId'],
      fromUserName: json['fromUserName'],
      toUserId: json['toUserId'],
      toUserName: json['toUserName'],
      subject: json['subject'],
      content: json['content'],
      priority: priority,
      status: status,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'])
          : null,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'])
          : null,
      error: json['error'],
      relatedMessageIds: (json['relatedMessageIds'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isBatched: json['isBatched'] ?? false,
    );
  }
}

class BatchedMessage {
  final String id;
  final List<Message> messages;
  final DateTime scheduledFor;
  final String fromUserId;
  final String toUserId;
  
  BatchedMessage({
    required this.id,
    required this.messages,
    required this.scheduledFor,
    required this.fromUserId,
    required this.toUserId,
  });
  
  String get combinedSubject {
    if (messages.length == 1) return messages.first.subject;
    
    // Find common words or create summary
    final subjects = messages.map((m) => m.subject).toList();
    return '${messages.length} Related Messages';
  }
  
  String get combinedContent {
    final buffer = StringBuffer();
    for (var i = 0; i < messages.length; i++) {
      final msg = messages[i];
      buffer.writeln('--- Message ${i + 1}: ${msg.subject} ---');
      buffer.writeln(msg.content);
      if (i < messages.length - 1) buffer.writeln();
    }
    return buffer.toString();
  }
}
