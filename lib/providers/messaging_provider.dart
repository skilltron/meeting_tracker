import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../models/message.dart';
import 'package:flutter/foundation.dart';

class MessagingProvider with ChangeNotifier {
  final List<Message> _messages = [];
  final List<BatchedMessage> _batchedMessages = [];
  Timer? _schedulerTimer;
  String? _dataDirectory;
  
  // ADHD-friendly settings
  static const Duration messageBatchingWindow = Duration(minutes: 5);
  
  // Getters
  List<Message> get messages => List.unmodifiable(_messages);
  List<Message> get scheduledMessages => _messages.where((m) => m.status == MessageStatus.scheduled).toList();
  List<Message> get sentMessages => _messages.where((m) => m.status == MessageStatus.sent).toList();
  List<BatchedMessage> get batchedMessages => List.unmodifiable(_batchedMessages);
  
  MessagingProvider() {
    _initializeDataDirectory();
    _loadMessages();
    _startScheduler();
  }
  
  Future<void> _initializeDataDirectory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // On web, use SharedPreferences directly instead of file system
      if (kIsWeb) {
        _dataDirectory = 'web'; // Placeholder for web
        return;
      }
      
      // For desktop/mobile, use a default location
      _dataDirectory = 'data';
      await prefs.setString('data_directory', 'data');
    } catch (e) {
      debugPrint('Error initializing data directory: $e');
    }
  }
  
  // Send message (with ADHD-friendly batching)
  Future<Message> sendMessage({
    required String fromUserId,
    String? fromUserName,
    required String toUserId,
    String? toUserName,
    required String subject,
    required String content,
    MessagePriority priority = MessagePriority.normal,
    bool forceImmediate = false, // Priority override
  }) async {
    final scheduledFor = forceImmediate || priority != MessagePriority.normal
        ? null
        : Message.calculateScheduledTime(priority);
    
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      toUserId: toUserId,
      toUserName: toUserName,
      subject: subject,
      content: content,
      priority: priority,
      status: scheduledFor != null ? MessageStatus.scheduled : MessageStatus.sent,
      scheduledFor: scheduledFor,
      sentAt: scheduledFor == null ? DateTime.now() : null,
    );
    
    _messages.add(message);
    
    // ADHD-friendly: Check for related messages in batching window
    if (scheduledFor != null && !forceImmediate) {
      await _checkAndBatchRelatedMessages(message);
    } else {
      // Send immediately
      await _sendMessage(message);
    }
    
    await _saveMessages();
    notifyListeners();
    return message;
  }
  
  // Check if message should be batched with recent related messages
  Future<void> _checkAndBatchRelatedMessages(Message newMessage) async {
    final now = DateTime.now();
    final windowStart = now.subtract(messageBatchingWindow);
    
    // Find recent scheduled messages from same sender to same recipient
    final recentMessages = _messages.where((m) {
      return m.status == MessageStatus.scheduled &&
          m.fromUserId == newMessage.fromUserId &&
          m.toUserId == newMessage.toUserId &&
          m.createdAt.isAfter(windowStart) &&
          m.id != newMessage.id;
    }).toList();
    
    // Check if any are related
    final relatedMessages = recentMessages.where((m) {
      return Message.areRelated(newMessage, m);
    }).toList();
    
    if (relatedMessages.isNotEmpty) {
      // Batch with related messages
      final allRelated = [newMessage, ...relatedMessages];
      final batched = BatchedMessage(
        id: 'batch_${DateTime.now().millisecondsSinceEpoch}',
        messages: allRelated,
        scheduledFor: newMessage.scheduledFor!,
        fromUserId: newMessage.fromUserId,
        toUserId: newMessage.toUserId,
      );
      
      _batchedMessages.add(batched);
      
      // Mark messages as batched
      for (final msg in allRelated) {
        final index = _messages.indexWhere((m) => m.id == msg.id);
        if (index != -1) {
          _messages[index] = msg.copyWith(
            relatedMessageIds: allRelated.map((m) => m.id).toList(),
            isBatched: true,
          );
        }
      }
      
      await _saveMessages();
      notifyListeners();
    }
  }
  
  // Send message (actual delivery)
  Future<void> _sendMessage(Message message) async {
    // TODO: Implement actual message delivery (email, Slack, etc.)
    // For now, just mark as sent
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _messages[index] = message.copyWith(
        status: MessageStatus.sent,
        sentAt: DateTime.now(),
      );
      await _saveMessages();
      notifyListeners();
    }
  }
  
  // Send batched message
  Future<void> sendBatchedMessage(String batchId) async {
    final batch = _batchedMessages.firstWhere((b) => b.id == batchId);
    
    // Send combined message
    final combinedMessage = Message(
      id: 'batched_${DateTime.now().millisecondsSinceEpoch}',
      fromUserId: batch.fromUserId,
      toUserId: batch.toUserId,
      subject: batch.combinedSubject,
      content: batch.combinedContent,
      priority: MessagePriority.normal,
      status: MessageStatus.sent,
      sentAt: DateTime.now(),
      isBatched: true,
      relatedMessageIds: batch.messages.map((m) => m.id).toList(),
    );
    
    await _sendMessage(combinedMessage);
    
    // Mark original messages as sent
    for (final msg in batch.messages) {
      final index = _messages.indexWhere((m) => m.id == msg.id);
      if (index != -1) {
        _messages[index] = msg.copyWith(
          status: MessageStatus.sent,
          sentAt: DateTime.now(),
        );
      }
    }
    
    _batchedMessages.removeWhere((b) => b.id == batchId);
    await _saveMessages();
    notifyListeners();
  }
  
  // Scheduler: Check for messages to send
  void _startScheduler() {
    _schedulerTimer?.cancel();
    _schedulerTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _processScheduledMessages();
    });
  }
  
  Future<void> _processScheduledMessages() async {
    final now = DateTime.now();
    final toSend = _messages.where((m) {
      return m.status == MessageStatus.scheduled &&
          m.scheduledFor != null &&
          m.scheduledFor!.isBefore(now);
    }).toList();
    
    // Check for batched messages first
    for (final batch in _batchedMessages) {
      if (batch.scheduledFor.isBefore(now)) {
        await sendBatchedMessage(batch.id);
        continue;
      }
    }
    
    // Send individual messages
    for (final message in toSend) {
      if (!message.isBatched) {
        await _sendMessage(message);
      }
    }
  }
  
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages.map((m) => m.toJson()).toList();
      await prefs.setString('messages', jsonEncode(messagesJson));
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }
  
  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('messages');
      if (messagesJson != null) {
        final json = jsonDecode(messagesJson) as List;
        _messages.clear();
        _messages.addAll(json.map((j) => Message.fromJson(j)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }
  
  @override
  void dispose() {
    _schedulerTimer?.cancel();
    super.dispose();
  }
}
