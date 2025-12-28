import 'package:flutter/foundation.dart';
import 'dart:async';

class MeetingProvider with ChangeNotifier {
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;
  bool _isRunning = false;
  Timer? _timer;
  
  String? _currentMeetingTitle;
  DateTime? _currentMeetingStart;
  DateTime? _currentMeetingEnd;
  
  List<UpcomingMeeting> _upcomingMeetings = [];
  
  // Getters
  DateTime? get startTime => _startTime;
  Duration get elapsedTime => _elapsedTime;
  bool get isRunning => _isRunning;
  String? get currentMeetingTitle => _currentMeetingTitle;
  DateTime? get currentMeetingStart => _currentMeetingStart;
  DateTime? get currentMeetingEnd => _currentMeetingEnd;
  List<UpcomingMeeting> get upcomingMeetings => _upcomingMeetings;
  
  String get formattedTime {
    final hours = _elapsedTime.inHours.toString().padLeft(2, '0');
    final minutes = (_elapsedTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_elapsedTime.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
  
  void start() {
    if (!_isRunning) {
      _startTime = DateTime.now().subtract(_elapsedTime);
      _isRunning = true;
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _elapsedTime = DateTime.now().difference(_startTime!);
        notifyListeners();
      });
      notifyListeners();
    }
  }
  
  void stop() {
    if (_isRunning) {
      _isRunning = false;
      _timer?.cancel();
      notifyListeners();
    }
  }
  
  void reset() {
    stop();
    _elapsedTime = Duration.zero;
    _startTime = null;
    notifyListeners();
  }
  
  void setCurrentMeeting(String? title, DateTime? start, DateTime? end) {
    _currentMeetingTitle = title;
    _currentMeetingStart = start;
    _currentMeetingEnd = end;
    notifyListeners();
  }
  
  void setUpcomingMeetings(List<UpcomingMeeting> meetings) {
    _upcomingMeetings = meetings;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class UpcomingMeeting {
  final String title;
  final DateTime start;
  final DateTime end;
  final String? location;
  
  UpcomingMeeting({
    required this.title,
    required this.start,
    required this.end,
    this.location,
  });
}
