import 'package:flutter/foundation.dart';
import '../models/task.dart';

/// Parses action items from transcript text and extracts structured data
class ActionItemParser {
  /// Parse a single action item string into structured data
  /// Format: "assignee|task" or just "task"
  static ParsedActionItem? parse(String actionItemText) {
    try {
      // Split by pipe if present (assignee|task format)
      final parts = actionItemText.split('|');
      
      String? assignee;
      String task;
      
      if (parts.length >= 2) {
        assignee = parts[0].trim();
        task = parts.sublist(1).join('|').trim();
      } else {
        task = actionItemText.trim();
      }
      
      if (task.isEmpty) return null;
      
      // Extract priority keywords
      final priority = _extractPriority(task);
      
      // Extract due date keywords
      final dueDate = _extractDueDate(task);
      
      // Clean up task text (remove priority/date keywords)
      task = _cleanTaskText(task);
      
      // Extract task title (first sentence or first 50 chars)
      final title = _extractTitle(task);
      final description = task.length > title.length ? task : null;
      
      return ParsedActionItem(
        title: title,
        description: description,
        assignee: assignee,
        priority: priority,
        dueDate: dueDate,
      );
    } catch (e) {
      debugPrint('Error parsing action item: $e');
      return null;
    }
  }
  
  /// Extract priority from task text
  static TaskPriority _extractPriority(String text) {
    final lowerText = text.toLowerCase();
    
    if (lowerText.contains(RegExp(r'\b(urgent|critical|asap|immediately)\b'))) {
      return TaskPriority.critical;
    } else if (lowerText.contains(RegExp(r'\b(high|important|priority)\b'))) {
      return TaskPriority.high;
    } else if (lowerText.contains(RegExp(r'\b(low|minor|nice\s+to\s+have)\b'))) {
      return TaskPriority.low;
    }
    
    return TaskPriority.medium;
  }
  
  /// Extract due date from task text
  static DateTime? _extractDueDate(String text) {
    final now = DateTime.now();
    final lowerText = text.toLowerCase();
    
    // Today
    if (lowerText.contains(RegExp(r'\b(today|by\s+end\s+of\s+day)\b'))) {
      return DateTime(now.year, now.month, now.day, 23, 59);
    }
    
    // Tomorrow
    if (lowerText.contains(RegExp(r'\b(tomorrow)\b'))) {
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 17, 0);
    }
    
    // This week
    if (lowerText.contains(RegExp(r'\b(this\s+week|by\s+end\s+of\s+week|friday)\b'))) {
      final daysUntilFriday = (DateTime.friday - now.weekday) % 7;
      final friday = now.add(Duration(days: daysUntilFriday == 0 ? 7 : daysUntilFriday));
      return DateTime(friday.year, friday.month, friday.day, 17, 0);
    }
    
    // Next week
    if (lowerText.contains(RegExp(r'\b(next\s+week)\b'))) {
      final daysUntilNextMonday = (DateTime.monday - now.weekday) % 7;
      final nextMonday = now.add(Duration(days: daysUntilNextMonday == 0 ? 7 : daysUntilNextMonday));
      return DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 17, 0);
    }
    
    // Days (e.g., "in 3 days")
    final daysMatch = RegExp(r'\b(?:in\s+)?(\d+)\s+days?\b').firstMatch(lowerText);
    if (daysMatch != null) {
      final days = int.tryParse(daysMatch.group(1) ?? '');
      if (days != null) {
        final dueDate = now.add(Duration(days: days));
        return DateTime(dueDate.year, dueDate.month, dueDate.day, 17, 0);
      }
    }
    
    return null;
  }
  
  /// Clean task text by removing priority/date keywords
  static String _cleanTaskText(String text) {
    String cleaned = text;
    
    // Remove priority keywords
    cleaned = cleaned.replaceAll(RegExp(r'\b(urgent|critical|asap|immediately|high|important|priority|low|minor|nice\s+to\s+have)\b', caseSensitive: false), '');
    
    // Remove date keywords
    cleaned = cleaned.replaceAll(RegExp(r'\b(today|tomorrow|this\s+week|next\s+week|by\s+end\s+of\s+(?:day|week)|friday|in\s+\d+\s+days?)\b', caseSensitive: false), '');
    
    // Clean up extra spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }
  
  /// Extract title from task (first sentence or first 50 chars)
  static String _extractTitle(String task) {
    // Try to find first sentence
    final sentenceMatch = RegExp(r'^([^.!?]+[.!?])').firstMatch(task);
    if (sentenceMatch != null) {
      return sentenceMatch.group(1)!.trim();
    }
    
    // Otherwise, take first 50 chars
    if (task.length <= 50) {
      return task;
    }
    
    // Find last word boundary before 50 chars
    final truncated = task.substring(0, 50);
    final lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > 20) {
      return '${truncated.substring(0, lastSpace)}...';
    }
    
    return '$truncated...';
  }
}

/// Parsed action item data structure
class ParsedActionItem {
  final String title;
  final String? description;
  final String? assignee;
  final TaskPriority priority;
  final DateTime? dueDate;
  
  ParsedActionItem({
    required this.title,
    this.description,
    this.assignee,
    required this.priority,
    this.dueDate,
  });
}
