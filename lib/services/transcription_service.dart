import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service for transcribing audio to text
/// Uses Web Speech API on web, or platform-specific APIs
class TranscriptionService {
  bool _isListening = false;
  final List<String> _transcript = [];
  StreamController<String>? _transcriptController;
  
  // Callbacks
  Function(String)? onTranscriptUpdate;
  Function(List<String>)? onActionItemsDetected;
  
  // Getters
  bool get isListening => _isListening;
  List<String> get transcript => List.unmodifiable(_transcript);
  Stream<String>? get transcriptStream => _transcriptController?.stream;
  
  /// Start listening/transcribing
  Future<bool> startListening() async {
    if (_isListening) return true;
    
    try {
      if (kIsWeb) {
        return await _startWebSpeechRecognition();
      } else {
        // For mobile/desktop, would use platform-specific speech recognition
        debugPrint('Speech recognition not yet implemented for mobile/desktop');
        return false;
      }
    } catch (e) {
      debugPrint('Error starting transcription: $e');
      return false;
    }
  }
  
  /// Stop listening
  void stopListening() {
    if (!_isListening) return;
    
    if (kIsWeb) {
      _stopWebSpeechRecognition();
    }
    
    _isListening = false;
  }
  
  /// Start Web Speech API recognition
  Future<bool> _startWebSpeechRecognition() async {
    try {
      if (kIsWeb) {
        // Use JavaScript interop to call Web Speech API
        // This requires dart:js_interop or a similar approach
        // For now, we'll check if the browser supports it
        
        // In a production app, you would use:
        // import 'dart:js_interop';
        // final manager = globalContext['speechRecognitionManager'];
        // manager.callMethod('start'.toJS);
        
        _isListening = true;
        _transcriptController = StreamController<String>.broadcast();
        
        debugPrint('Web Speech Recognition started');
        
        // Simulate receiving transcript (in real implementation, this comes from JS)
        // For now, we'll set up a listener that would receive JS callbacks
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error starting web speech recognition: $e');
      return false;
    }
  }
  
  /// Stop Web Speech API recognition
  void _stopWebSpeechRecognition() {
    _transcriptController?.close();
    _transcriptController = null;
    debugPrint('Web Speech Recognition stopped');
  }
  
  /// Add transcript text (called from JavaScript interop)
  void addTranscript(String text) {
    if (text.trim().isEmpty) return;
    
    _transcript.add(text);
    _transcriptController?.add(text);
    onTranscriptUpdate?.call(text);
    
    // Check for action items in the new text
    _detectActionItems(text);
  }
  
  /// Detect action items in transcript text
  void _detectActionItems(String text) {
    final actionItems = _parseActionItems(text);
    if (actionItems.isNotEmpty) {
      onActionItemsDetected?.call(actionItems);
    }
  }
  
  /// Parse action items from text using pattern matching
  List<String> _parseActionItems(String text) {
    final actionItems = <String>[];
    
    // Common action item patterns
    final patterns = [
      // "assign action item {item} to {person} in team"
      RegExp(r'assign\s+action\s+item\s+(.+?)\s+to\s+(\w+)(?:\s+in\s+team)?(?:\.|$)', caseSensitive: false),
      // "Action item {item} to {person} in team"
      RegExp(r'action\s+item\s+(.+?)\s+to\s+(\w+)(?:\s+in\s+team)?(?:\.|$)', caseSensitive: false),
      // "John will do X"
      RegExp(r'(\w+)\s+(?:will|should|needs?\s+to|has\s+to)\s+(.+?)(?:\.|$)', caseSensitive: false),
      // "Action item: X for Y"
      RegExp(r'action\s+item[:\s]+(.+?)(?:\s+for\s+(\w+))?(?:\.|$)', caseSensitive: false),
      // "Assign X to Y"
      RegExp(r'assign\s+(.+?)\s+to\s+(\w+)', caseSensitive: false),
      // "X, please do Y"
      RegExp(r'(\w+)[,\s]+(?:please\s+)?(?:do|handle|take\s+care\s+of|work\s+on)\s+(.+?)(?:\.|$)', caseSensitive: false),
      // "Let's have X do Y"
      RegExp(r"let'?s\s+have\s+(\w+)\s+(?:do|handle|work\s+on)\s+(.+?)(?:\.|$)", caseSensitive: false),
      // "X is responsible for Y"
      RegExp(r'(\w+)\s+is\s+responsible\s+for\s+(.+?)(?:\.|$)', caseSensitive: false),
      // "Follow up on X"
      RegExp(r'follow\s+up\s+(?:on\s+)?(.+?)(?:\.|$)', caseSensitive: false),
      // "TODO: X"
      RegExp(r'todo[:\s]+(.+?)(?:\.|$)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        String? assignee;
        String? task;
        
        if (match.groupCount >= 2) {
          assignee = match.group(1)?.trim();
          task = match.group(2)?.trim();
        } else if (match.groupCount >= 1) {
          task = match.group(1)?.trim();
        }
        
        if (task != null && task.isNotEmpty) {
          // Format: "assignee|task" or just "task"
          final actionItem = assignee != null ? '$assignee|$task' : task;
          actionItems.add(actionItem);
        }
      }
    }
    
    return actionItems;
  }
  
  /// Clear transcript
  void clearTranscript() {
    _transcript.clear();
  }
  
  /// Get full transcript as single string
  String getFullTranscript() {
    return _transcript.join(' ');
  }
}
