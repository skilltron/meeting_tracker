import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import '../services/github_issues_service.dart';
import 'package:flutter/foundation.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  final GitHubIssuesService _githubService = GitHubIssuesService();
  String? _dataDirectory;
  bool _githubIntegrationEnabled = false;
  
  // Getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get githubIntegrationEnabled => _githubIntegrationEnabled;
  
  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList()
      ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }
  
  List<Task> getMyTasks(String userId) {
    return _tasks.where((task) => task.assignedTo == userId).toList()
      ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }
  
  TaskProvider() {
    _initializeDataDirectory();
    _loadTasks();
    _loadSettings();
  }
  
  Future<void> _initializeDataDirectory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // On web, use SharedPreferences directly
      if (kIsWeb) {
        _dataDirectory = 'web';
        return;
      }
      // For desktop/mobile, would use file system (conditional import needed)
      _dataDirectory = 'data';
      await prefs.setString('data_directory', 'data');
    } catch (e) {
      debugPrint('Error initializing data directory: $e');
    }
  }
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _githubIntegrationEnabled = prefs.getBool('github_integration_enabled') ?? false;
      
      if (_githubIntegrationEnabled) {
        final token = prefs.getString('github_access_token');
        final owner = prefs.getString('github_repo_owner');
        final repo = prefs.getString('github_repo_name');
        
        if (token != null && owner != null && repo != null) {
          _githubService.configure(token, owner, repo);
        }
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }
  
  Future<void> enableGitHubIntegration(String accessToken, String owner, String repo) async {
    _githubService.configure(accessToken, owner, repo);
    _githubIntegrationEnabled = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('github_integration_enabled', true);
    await prefs.setString('github_access_token', accessToken);
    await prefs.setString('github_repo_owner', owner);
    await prefs.setString('github_repo_name', repo);
    
    notifyListeners();
  }
  
  // Create task (optionally create GitHub issue)
  Future<Task> createTask({
    required String title,
    required String description,
    required String createdBy,
    TaskPriority priority = TaskPriority.medium,
    String? assignedTo,
    String? assignedByName,
    DateTime? dueDate,
    String? meetingId,
    List<String> tags = const [],
    bool createGitHubIssue = false,
  }) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      priority: priority,
      assignedTo: assignedTo,
      assignedByName: assignedByName,
      createdBy: createdBy,
      dueDate: dueDate,
      meetingId: meetingId,
      tags: tags,
    );
    
    _tasks.add(task);
    
    // Create GitHub issue if enabled
    if (createGitHubIssue && _githubIntegrationEnabled) {
      try {
        final issue = await _githubService.createIssue(
          title: title,
          body: description,
          labels: tags,
          assignee: assignedTo,
        );
        
        final updatedTask = task.copyWith(
          gitIssueNumber: issue['number'].toString(),
          gitIssueUrl: issue['html_url'],
        );
        
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
      } catch (e) {
        debugPrint('Error creating GitHub issue: $e');
      }
    }
    
    await _saveTasks();
    notifyListeners();
    return task;
  }
  
  // Update task
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      
      // Update GitHub issue if linked
      if (_githubIntegrationEnabled && task.gitIssueNumber != null) {
        try {
          await _githubService.updateIssue(
            issueNumber: int.parse(task.gitIssueNumber!),
            title: task.title,
            body: task.description,
            state: task.status == TaskStatus.done ? 'closed' : 'open',
            labels: task.tags,
          );
        } catch (e) {
          debugPrint('Error updating GitHub issue: $e');
        }
      }
      
      await _saveTasks();
      notifyListeners();
    }
  }
  
  // Move task to different status (Trello-like)
  Future<void> moveTask(String taskId, TaskStatus newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final updatedTask = task.copyWith(
        status: newStatus,
        completedAt: newStatus == TaskStatus.done ? DateTime.now() : null,
      );
      await updateTask(updatedTask);
    }
  }
  
  // Delete task
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _saveTasks();
    notifyListeners();
  }
  
  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = _tasks.map((t) => t.toJson()).toList();
      await prefs.setString('tasks', jsonEncode(tasksJson));
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }
  
  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('tasks');
      if (tasksJson != null) {
        final json = jsonDecode(tasksJson) as List;
        _tasks.clear();
        _tasks.addAll(json.map((j) => Task.fromJson(j)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }
}
