import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/habit_record.dart';

class HabitProvider with ChangeNotifier {
  List<HabitRecord> _records = [];
  
  List<HabitRecord> get records => _records;
  
  HabitProvider() {
    _loadRecords();
  }
  
  Future<void> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = prefs.getString('habit_records');
      if (recordsJson != null) {
        final List<dynamic> decoded = json.decode(recordsJson);
        _records = decoded.map((json) => HabitRecord.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading habit records: $e');
    }
  }
  
  Future<void> _saveRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recordsJson = json.encode(
        _records.map((record) => record.toJson()).toList(),
      );
      await prefs.setString('habit_records', recordsJson);
    } catch (e) {
      debugPrint('Error saving habit records: $e');
    }
  }
  
  HabitRecord? getRecordForMeeting(String meetingId, DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    try {
      return _records.firstWhere(
        (record) =>
            record.meetingId == meetingId &&
            DateTime(record.date.year, record.date.month, record.date.day)
                    .isAtSameMomentAs(dateOnly),
      );
    } catch (e) {
      return null;
    }
  }
  
  Future<void> recordMeetingAttendance(
    String meetingId,
    DateTime date, {
    bool? attended,
    bool? prepared,
    int? preparationTasksCompleted,
    int? totalPreparationTasks,
    String? notes,
  }) async {
    final existing = getRecordForMeeting(meetingId, date);
    
    if (existing != null) {
      final index = _records.indexWhere((r) => r.id == existing.id);
      _records[index] = existing.copyWith(
        attended: attended ?? existing.attended,
        prepared: prepared ?? existing.prepared,
        preparationTasksCompleted:
            preparationTasksCompleted ?? existing.preparationTasksCompleted,
        totalPreparationTasks:
            totalPreparationTasks ?? existing.totalPreparationTasks,
        notes: notes ?? existing.notes,
      );
    } else {
      final record = HabitRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        meetingId: meetingId,
        date: date,
        attended: attended ?? false,
        prepared: prepared ?? false,
        preparationTasksCompleted: preparationTasksCompleted ?? 0,
        totalPreparationTasks: totalPreparationTasks ?? 0,
        notes: notes,
      );
      _records.add(record);
    }
    
    await _saveRecords();
    notifyListeners();
  }
  
  Map<String, dynamic> getHabitStats() {
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));
    
    final recentRecords = _records.where((r) => r.date.isAfter(last30Days)).toList();
    
    if (recentRecords.isEmpty) {
      return {
        'attendanceRate': 0.0,
        'preparationRate': 0.0,
        'totalMeetings': 0,
        'attendedCount': 0,
        'preparedCount': 0,
      };
    }
    
    final attendedCount = recentRecords.where((r) => r.attended).length;
    final preparedCount = recentRecords.where((r) => r.prepared).length;
    
    return {
      'attendanceRate': attendedCount / recentRecords.length,
      'preparationRate': preparedCount / recentRecords.length,
      'totalMeetings': recentRecords.length,
      'attendedCount': attendedCount,
      'preparedCount': preparedCount,
    };
  }
}
