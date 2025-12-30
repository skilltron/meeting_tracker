import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/meeting_action.dart';
import 'package:flutter/foundation.dart';

class MeetingActionsProvider with ChangeNotifier {
  // Current user info (would come from GitHub auth)
  String? _currentUserId;
  String? _currentUserName;
  bool _isModerator = false;
  
  // Active meeting state
  String? _activeMeetingId;
  final Map<String, List<MeetingAction>> _meetingActions = {};
  final Map<String, List<ActionItem>> _actionItems = {};
  final Map<String, List<TabledTopic>> _tabledTopics = {};
  final Set<String> _raisedHands = {}; // User IDs with raised hands
  
  // Data directory path
  String? _dataDirectory;
  
  // Getters
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  bool get isModerator => _isModerator;
  String? get activeMeetingId => _activeMeetingId;
  Set<String> get raisedHands => Set.unmodifiable(_raisedHands);
  
  List<MeetingAction> getActionsForMeeting(String meetingId) {
    return _meetingActions[meetingId] ?? [];
  }
  
  List<ActionItem> getActionItemsForMeeting(String meetingId) {
    return _actionItems[meetingId] ?? [];
  }
  
  List<TabledTopic> getTabledTopicsForMeeting(String meetingId) {
    return _tabledTopics[meetingId] ?? [];
  }
  
  List<ActionItem> getMyActionItems() {
    if (_currentUserId == null) return [];
    final allItems = <ActionItem>[];
    _actionItems.values.forEach((items) {
      allItems.addAll(items.where((item) => item.assignedTo == _currentUserId));
    });
    return allItems;
  }
  
  MeetingActionsProvider() {
    _initializeDataDirectory();
    _loadData();
  }
  
  Future<void> _initializeDataDirectory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (kIsWeb) {
        _dataDirectory = 'web';
        return;
      }
      // For desktop/mobile, use file system (would need conditional import)
      _dataDirectory = 'data';
      await prefs.setString('data_directory', 'data');
    } catch (e) {
      debugPrint('Error initializing data directory: $e');
    }
  }
  
  void setCurrentUser(String userId, String? userName, {bool isModerator = false}) {
    _currentUserId = userId;
    _currentUserName = userName;
    _isModerator = isModerator;
    notifyListeners();
  }
  
  void setActiveMeeting(String meetingId) {
    _activeMeetingId = meetingId;
    _loadMeetingData(meetingId);
    notifyListeners();
  }
  
  // Raise hand
  Future<void> raiseHand(String meetingId) async {
    if (_currentUserId == null) return;
    
    if (!_raisedHands.contains(_currentUserId)) {
      _raisedHands.add(_currentUserId!);
      
      final action = MeetingAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        meetingId: meetingId,
        type: MeetingActionType.raiseHand,
        userId: _currentUserId!,
        userName: _currentUserName,
      );
      
      _addAction(meetingId, action);
      await _saveMeetingData(meetingId);
      notifyListeners();
    }
  }
  
  // Lower hand
  Future<void> lowerHand(String meetingId) async {
    if (_currentUserId == null) return;
    
    if (_raisedHands.contains(_currentUserId)) {
      _raisedHands.remove(_currentUserId!);
      
      final action = MeetingAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        meetingId: meetingId,
        type: MeetingActionType.lowerHand,
        userId: _currentUserId!,
        userName: _currentUserName,
      );
      
      _addAction(meetingId, action);
      await _saveMeetingData(meetingId);
      notifyListeners();
    }
  }
  
  // Table topic
  Future<void> tableTopic(String meetingId, String topic, {String? reason}) async {
    if (_currentUserId == null) return;
    
    final tabledTopic = TabledTopic(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      meetingId: meetingId,
      topic: topic,
      requestedBy: _currentUserId!,
      requestedByName: _currentUserName,
      reason: reason,
    );
    
    if (_tabledTopics[meetingId] == null) {
      _tabledTopics[meetingId] = [];
    }
    _tabledTopics[meetingId]!.add(tabledTopic);
    
    final action = MeetingAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      meetingId: meetingId,
      type: MeetingActionType.tableTopic,
      userId: _currentUserId!,
      userName: _currentUserName,
      metadata: {
        'topic': topic,
        'reason': reason,
        'tabledTopicId': tabledTopic.id,
      },
    );
    
    _addAction(meetingId, action);
    await _saveMeetingData(meetingId);
    notifyListeners();
  }
  
  // Assign action item (moderator only)
  Future<void> assignActionItem(
    String meetingId,
    String title,
    String description,
    String assignedTo,
    String? assignedByName,
    DateTime dueDate, {
    String? notes,
  }) async {
    if (!_isModerator) {
      throw Exception('Only moderators can assign action items');
    }
    if (_currentUserId == null) return;
    
    final actionItem = ActionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      meetingId: meetingId,
      title: title,
      description: description,
      assignedTo: assignedTo,
      assignedByName: assignedByName,
      assignedBy: _currentUserId!,
      dueDate: dueDate,
      notes: notes,
    );
    
    if (_actionItems[meetingId] == null) {
      _actionItems[meetingId] = [];
    }
    _actionItems[meetingId]!.add(actionItem);
    
    final action = MeetingAction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      meetingId: meetingId,
      type: MeetingActionType.actionItem,
      userId: _currentUserId!,
      userName: _currentUserName,
      metadata: {
        'actionItemId': actionItem.id,
        'title': title,
        'assignedTo': assignedTo,
        'assignedByName': assignedByName,
      },
    );
    
    _addAction(meetingId, action);
    await _saveMeetingData(meetingId);
    notifyListeners();
  }
  
  // Update action item status
  Future<void> updateActionItemStatus(String meetingId, String actionItemId, ActionItemStatus status) async {
    final items = _actionItems[meetingId];
    if (items == null) return;
    
    final index = items.indexWhere((item) => item.id == actionItemId);
    if (index != -1) {
      final item = items[index];
      items[index] = item.copyWith(
        status: status,
        completedAt: status == ActionItemStatus.completed ? DateTime.now() : null,
      );
      await _saveMeetingData(meetingId);
      notifyListeners();
    }
  }
  
  // Schedule tabled topic for another meeting
  Future<void> scheduleTabledTopic(String meetingId, String tabledTopicId, String newMeetingId, DateTime? scheduledDate) async {
    if (!_isModerator) {
      throw Exception('Only moderators can schedule tabled topics');
    }
    
    final topics = _tabledTopics[meetingId];
    if (topics == null) return;
    
    final index = topics.indexWhere((topic) => topic.id == tabledTopicId);
    if (index != -1) {
      final topic = topics[index];
      topics[index] = TabledTopic(
        id: topic.id,
        meetingId: topic.meetingId,
        topic: topic.topic,
        requestedBy: topic.requestedBy,
        requestedByName: topic.requestedByName,
        requestedAt: topic.requestedAt,
        reason: topic.reason,
        scheduledForMeetingId: newMeetingId,
        scheduledForDate: scheduledDate,
      );
      await _saveMeetingData(meetingId);
      notifyListeners();
    }
  }
  
  void _addAction(String meetingId, MeetingAction action) {
    if (_meetingActions[meetingId] == null) {
      _meetingActions[meetingId] = [];
    }
    _meetingActions[meetingId]!.add(action);
  }
  
  Future<void> _saveMeetingData(String meetingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefix = 'meeting_${meetingId}_';
      
      // Save actions
      final actionsJson = _meetingActions[meetingId]?.map((a) => a.toJson()).toList() ?? [];
      await prefs.setString('${prefix}actions', jsonEncode(actionsJson));
      
      // Save action items
      final actionItemsJson = _actionItems[meetingId]?.map((a) => a.toJson()).toList() ?? [];
      await prefs.setString('${prefix}action_items', jsonEncode(actionItemsJson));
      
      // Save tabled topics
      final tabledTopicsJson = _tabledTopics[meetingId]?.map((t) => t.toJson()).toList() ?? [];
      await prefs.setString('${prefix}tabled_topics', jsonEncode(tabledTopicsJson));
    } catch (e) {
      debugPrint('Error saving meeting data: $e');
    }
  }
  
  Future<void> _loadMeetingData(String meetingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefix = 'meeting_${meetingId}_';
      
      // Load actions
      final actionsJson = prefs.getString('${prefix}actions');
      if (actionsJson != null) {
        final json = jsonDecode(actionsJson) as List;
        _meetingActions[meetingId] = json.map((j) => MeetingAction.fromJson(j)).toList();
        
        // Restore raised hands state
        _raisedHands.clear();
        for (final action in _meetingActions[meetingId]!) {
          if (action.type == MeetingActionType.raiseHand) {
            _raisedHands.add(action.userId);
          } else if (action.type == MeetingActionType.lowerHand) {
            _raisedHands.remove(action.userId);
          }
        }
      }
      
      // Load action items
      final actionItemsJson = prefs.getString('${prefix}action_items');
      if (actionItemsJson != null) {
        final json = jsonDecode(actionItemsJson) as List;
        _actionItems[meetingId] = json.map((j) => ActionItem.fromJson(j)).toList();
      }
      
      // Load tabled topics
      final tabledTopicsJson = prefs.getString('${prefix}tabled_topics');
      if (tabledTopicsJson != null) {
        final json = jsonDecode(tabledTopicsJson) as List;
        _tabledTopics[meetingId] = json.map((j) => TabledTopic.fromJson(j)).toList();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading meeting data: $e');
    }
  }
  
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Load all meeting IDs from SharedPreferences keys
      final keys = prefs.getKeys();
      final meetingIds = <String>{};
      
      for (final key in keys) {
        if (key.startsWith('meeting_') && key.endsWith('_actions')) {
          final meetingId = key.replaceFirst('meeting_', '').replaceFirst('_actions', '');
          meetingIds.add(meetingId);
        }
      }
      
      // Load data for each meeting
      for (final meetingId in meetingIds) {
        await _loadMeetingData(meetingId);
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }
}
