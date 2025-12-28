import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/meeting_todo.dart';

class TodoProvider with ChangeNotifier {
  List<MeetingTodo> _todos = [];
  
  List<MeetingTodo> get todos => _todos;
  
  TodoProvider() {
    _loadTodos();
  }
  
  Future<void> _loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString('meeting_todos');
      if (todosJson != null) {
        final List<dynamic> decoded = json.decode(todosJson);
        _todos = decoded.map((json) => MeetingTodo.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading todos: $e');
    }
  }
  
  Future<void> _saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = json.encode(
        _todos.map((todo) => todo.toJson()).toList(),
      );
      await prefs.setString('meeting_todos', todosJson);
    } catch (e) {
      debugPrint('Error saving todos: $e');
    }
  }
  
  List<MeetingTodo> getTodosForMeeting(String meetingId) {
    final meetingTodos = _todos
        .where((todo) => todo.meetingId == meetingId)
        .toList();
    
    // Sort by priority first (critical > high > medium > low), then by orderIndex
    meetingTodos.sort((a, b) {
      final priorityCompare = a.priorityOrder.compareTo(b.priorityOrder);
      if (priorityCompare != 0) return priorityCompare;
      return a.orderIndex.compareTo(b.orderIndex);
    });
    
    return meetingTodos;
  }
  
  Future<void> addTodo(String meetingId, String text, {TodoPriority priority = TodoPriority.medium}) async {
    if (text.trim().isEmpty) return;
    
    // Get max orderIndex for this priority in this meeting
    final existingTodos = getTodosForMeeting(meetingId);
    final samePriorityTodos = existingTodos.where((t) => t.priority == priority).toList();
    final maxOrderIndex = samePriorityTodos.isEmpty 
        ? 0 
        : samePriorityTodos.map((t) => t.orderIndex).reduce((a, b) => a > b ? a : b);
    
    final todo = MeetingTodo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      meetingId: meetingId,
      text: text.trim(),
      priority: priority,
      orderIndex: maxOrderIndex + 1,
    );
    
    _todos.add(todo);
    await _saveTodos();
    notifyListeners();
  }
  
  Future<void> updateTodoPriority(String todoId, TodoPriority newPriority) async {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index != -1) {
      // Get new orderIndex for this priority
      final meetingId = _todos[index].meetingId;
      final existingTodos = getTodosForMeeting(meetingId);
      final samePriorityTodos = existingTodos.where((t) => t.priority == newPriority).toList();
      final maxOrderIndex = samePriorityTodos.isEmpty 
          ? 0 
          : samePriorityTodos.map((t) => t.orderIndex).reduce((a, b) => a > b ? a : b);
      
      _todos[index] = _todos[index].copyWith(
        priority: newPriority,
        orderIndex: maxOrderIndex + 1,
      );
      await _saveTodos();
      notifyListeners();
    }
  }
  
  Future<void> reorderTodo(String todoId, int newOrderIndex) async {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(orderIndex: newOrderIndex);
      await _saveTodos();
      notifyListeners();
    }
  }
  
  Future<void> toggleTodo(String todoId) async {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
      await _saveTodos();
      notifyListeners();
    }
  }
  
  Future<void> deleteTodo(String todoId) async {
    _todos.removeWhere((todo) => todo.id == todoId);
    await _saveTodos();
    notifyListeners();
  }
  
  Future<void> updateTodo(String todoId, String newText) async {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index != -1 && newText.trim().isNotEmpty) {
      _todos[index] = _todos[index].copyWith(text: newText.trim());
      await _saveTodos();
      notifyListeners();
    }
  }
  
  int getCompletedCountForMeeting(String meetingId) {
    return _todos
        .where((todo) =>
            todo.meetingId == meetingId && todo.isCompleted)
        .length;
  }
  
  int getTotalCountForMeeting(String meetingId) {
    return _todos.where((todo) => todo.meetingId == meetingId).length;
  }
}
