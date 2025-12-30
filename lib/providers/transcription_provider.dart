import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/transcription_service.dart';
import '../services/action_item_parser.dart';
import '../providers/task_provider.dart';
import '../providers/obs_provider.dart';

/// Provider for managing transcription and auto-assignment of action items
class TranscriptionProvider with ChangeNotifier {
  final TranscriptionService _transcriptionService = TranscriptionService();
  final TaskProvider _taskProvider;
  final OBSProvider _obsProvider;
  
  bool _isTranscribing = false;
  String _currentTranscript = '';
  int _actionItemsDetected = 0;
  
  // Getters
  bool get isTranscribing => _isTranscribing;
  String get currentTranscript => _currentTranscript;
  int get actionItemsDetected => _actionItemsDetected;
  
  TranscriptionProvider(this._taskProvider, this._obsProvider) {
    _setupCallbacks();
    _setupOBSListener();
  }
  
  /// Setup transcription service callbacks
  void _setupCallbacks() {
    _transcriptionService.onTranscriptUpdate = (text) {
      _currentTranscript += ' $text';
      notifyListeners();
    };
    
    _transcriptionService.onActionItemsDetected = (actionItems) {
      _processActionItems(actionItems);
    };
  }
  
  /// Listen to OBS recording state and start/stop transcription
  void _setupOBSListener() {
    // This will be called when OBS recording state changes
    // We'll integrate this in the OBS provider
  }
  
  /// Start transcription (called when recording starts)
  Future<void> startTranscription() async {
    if (_isTranscribing) return;
    
    try {
      final started = await _transcriptionService.startListening();
      if (started) {
        _isTranscribing = true;
        _currentTranscript = '';
        _actionItemsDetected = 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error starting transcription: $e');
    }
  }
  
  /// Stop transcription (called when recording stops)
  void stopTranscription() {
    if (!_isTranscribing) return;
    
    _transcriptionService.stopListening();
    _isTranscribing = false;
    notifyListeners();
  }
  
  /// Process detected action items and create tasks
  Future<void> _processActionItems(List<String> actionItemTexts) async {
    for (final text in actionItemTexts) {
      final parsed = ActionItemParser.parse(text);
      if (parsed != null) {
        await _createTaskFromActionItem(parsed);
        _actionItemsDetected++;
        notifyListeners();
      }
    }
  }
  
  /// Create a task from a parsed action item
  Future<void> _createTaskFromActionItem(ParsedActionItem parsed) async {
    try {
      await _taskProvider.createTask(
        title: parsed.title,
        description: parsed.description ?? 'Auto-detected from meeting transcript',
        createdBy: 'system',
        priority: parsed.priority,
        assignedTo: parsed.assignee,
        dueDate: parsed.dueDate,
        createGitHubIssue: false, // Don't auto-create GitHub issues from voice
      );
      
      debugPrint('Created task: ${parsed.title} (assigned to: ${parsed.assignee ?? "unassigned"})');
    } catch (e) {
      debugPrint('Error creating task from action item: $e');
    }
  }
  
  /// Get full transcript
  String getFullTranscript() {
    return _transcriptionService.getFullTranscript();
  }
  
  /// Clear transcript
  void clearTranscript() {
    _transcriptionService.clearTranscript();
    _currentTranscript = '';
    _actionItemsDetected = 0;
    notifyListeners();
  }
}
