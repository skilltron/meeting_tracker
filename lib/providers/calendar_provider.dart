import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/calendar_service.dart';
import '../models/calendar_event.dart';

class CalendarProvider with ChangeNotifier {
  final CalendarService _calendarService = CalendarService();
  
  bool _isGoogleConnected = false;
  bool _isOutlookConnected = false;
  bool _isOneDriveConnected = false;
  
  List<CalendarEvent> _events = [];
  CalendarEvent? _currentEvent;
  List<CalendarEvent> _upcomingEvents = [];
  Timer? _eventRefreshTimer;
  
  // Getters
  bool get isGoogleConnected => _isGoogleConnected;
  bool get isOutlookConnected => _isOutlookConnected;
  bool get isOneDriveConnected => _isOneDriveConnected;
  List<CalendarEvent> get events => _events;
  CalendarEvent? get currentEvent => _currentEvent;
  List<CalendarEvent> get upcomingEvents => _upcomingEvents;
  
  Future<void> connectGoogle() async {
    try {
      await _calendarService.connectGoogle();
      _isGoogleConnected = true;
      await loadEvents();
      _startEventRefresh();
      notifyListeners();
    } catch (e) {
      debugPrint('Error connecting to Google: $e');
      rethrow;
    }
  }
  
  void _startEventRefresh() {
    _eventRefreshTimer?.cancel();
    // Refresh events every minute and remove past meetings
    _eventRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      loadEvents();
    });
  }
  
  @override
  void dispose() {
    _eventRefreshTimer?.cancel();
    super.dispose();
  }
  
  Future<void> connectOutlook() async {
    try {
      await _calendarService.connectOutlook();
      _isOutlookConnected = true;
      await loadEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('Error connecting to Outlook: $e');
      rethrow;
    }
  }
  
  Future<void> connectOneDrive() async {
    try {
      await _calendarService.connectOneDrive();
      _isOneDriveConnected = true;
      await loadEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('Error connecting to OneDrive: $e');
      rethrow;
    }
  }
  
  Future<void> loadEvents() async {
    try {
      _events = await _calendarService.getUpcomingEvents();
      _updateCurrentAndUpcoming();
      _removePastMeetings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }
  
  void _removePastMeetings() {
    final now = DateTime.now();
    _events = _events.where((event) {
      final minutesPastStart = now.difference(event.start).inMinutes;
      // Keep if not started yet, or less than 15 minutes past start
      return minutesPastStart < 15;
    }).toList();
  }
  
  Future<void> createEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String? location,
    String? description,
    required CalendarProviderType provider,
  }) async {
    try {
      await _calendarService.createEvent(
        title: title,
        start: start,
        end: end,
        location: location,
        description: description,
        provider: provider,
      );
      await loadEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating event: $e');
      rethrow;
    }
  }
  
  void _updateCurrentAndUpcoming() {
    final now = DateTime.now();
    _currentEvent = null;
    _upcomingEvents = [];
    
    for (final event in _events) {
      if (now.isAfter(event.start) && now.isBefore(event.end)) {
        _currentEvent = event;
      } else if (event.start.isAfter(now)) {
        _upcomingEvents.add(event);
      }
    }
    
    _upcomingEvents.sort((a, b) => a.start.compareTo(b.start));
  }
  
  CalendarEvent? getNextMeetingIn20Minutes() {
    final now = DateTime.now();
    final twentyMinutesFromNow = now.add(const Duration(minutes: 20));
    
    for (final event in _upcomingEvents) {
      if (event.start.isAfter(now) && event.start.isBefore(twentyMinutesFromNow)) {
        return event;
      }
    }
    return null;
  }
  
  List<CalendarEvent> getTodaysMeetings() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    // Filter events for today and remove those 15+ minutes past start
    return _events.where((event) {
      final isToday = event.start.isAfter(todayStart) && event.start.isBefore(todayEnd);
      if (!isToday) return false;
      
      // Remove if 15+ minutes past start time
      final minutesPastStart = now.difference(event.start).inMinutes;
      return minutesPastStart < 15;
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }
}

enum CalendarProviderType {
  google,
  outlook,
  onedrive,
}
