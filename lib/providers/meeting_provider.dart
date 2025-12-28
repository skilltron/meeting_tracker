import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

enum TimerMode {
  stopwatch,
  countdown,
}

class MeetingProvider with ChangeNotifier {
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;
  bool _isRunning = false;
  Timer? _timer;
  
  TimerMode _mode = TimerMode.stopwatch;
  Duration _countdownDuration = const Duration(minutes: 25); // Default pomodoro
  bool _countdownCompleted = false;
  
  // Alarm settings
  bool _alarmEnabled = false;
  Duration _alarmDuration = const Duration(minutes: 25); // Default alarm duration
  bool _alarmTriggered = false;
  Function()? _onAlarmTriggered;
  
  String? _currentMeetingTitle;
  DateTime? _currentMeetingStart;
  DateTime? _currentMeetingEnd;
  
  List<UpcomingMeeting> _upcomingMeetings = [];
  
  MeetingProvider() {
    _loadSettings();
  }
  
  // Getters
  DateTime? get startTime => _startTime;
  Duration get elapsedTime => _elapsedTime;
  bool get isRunning => _isRunning;
  TimerMode get mode => _mode;
  Duration get countdownDuration => _countdownDuration;
  bool get countdownCompleted => _countdownCompleted;
  String? get currentMeetingTitle => _currentMeetingTitle;
  DateTime? get currentMeetingStart => _currentMeetingStart;
  DateTime? get currentMeetingEnd => _currentMeetingEnd;
  List<UpcomingMeeting> get upcomingMeetings => _upcomingMeetings;
  
  Duration get remainingTime {
    if (_mode == TimerMode.countdown) {
      final remaining = _countdownDuration - _elapsedTime;
      return remaining.isNegative ? Duration.zero : remaining;
    }
    return _elapsedTime;
  }
  
  String get formattedTime {
    final duration = _mode == TimerMode.countdown ? remainingTime : _elapsedTime;
    
    if (_mode == TimerMode.stopwatch) {
      // Stopwatch mode: show 2 decimal places (centiseconds)
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      final centiseconds = ((duration.inMilliseconds % 1000) / 10).floor().toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds.$centiseconds';
    } else {
      // Countdown mode: standard format
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
  }
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeIndex = prefs.getInt('timer_mode') ?? 0;
      _mode = TimerMode.values[modeIndex];
      final countdownMinutes = prefs.getInt('countdown_minutes') ?? 25;
      _countdownDuration = Duration(minutes: countdownMinutes);
      _alarmEnabled = prefs.getBool('alarm_enabled') ?? false;
      final alarmMinutes = prefs.getInt('alarm_minutes') ?? 25;
      _alarmDuration = Duration(minutes: alarmMinutes);
    } catch (e) {
      debugPrint('Error loading timer settings: $e');
    }
  }
  
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('timer_mode', _mode.index);
      await prefs.setInt('countdown_minutes', _countdownDuration.inMinutes);
      await prefs.setBool('alarm_enabled', _alarmEnabled);
      await prefs.setInt('alarm_minutes', _alarmDuration.inMinutes);
    } catch (e) {
      debugPrint('Error saving timer settings: $e');
    }
  }
  
  void setAlarmEnabled(bool enabled) {
    if (_alarmEnabled != enabled) {
      _alarmEnabled = enabled;
      _alarmTriggered = false;
      _saveSettings();
      notifyListeners();
    }
  }
  
  void setAlarmDuration(Duration duration) {
    if (_alarmDuration != duration) {
      _alarmDuration = duration;
      _alarmTriggered = false;
      _saveSettings();
      notifyListeners();
    }
  }
  
  void setOnAlarmTriggered(Function()? callback) {
    _onAlarmTriggered = callback;
  }
  
  void dismissAlarm() {
    _alarmTriggered = false;
    notifyListeners();
  }
  
  void setMode(TimerMode mode) {
    if (_mode != mode) {
      stop();
      reset();
      _mode = mode;
      _countdownCompleted = false;
      _saveSettings();
      notifyListeners();
    }
  }
  
  void setCountdownDuration(Duration duration) {
    if (_countdownDuration != duration) {
      _countdownDuration = duration;
      if (_mode == TimerMode.countdown && !_isRunning) {
        _elapsedTime = Duration.zero;
      }
      _saveSettings();
      notifyListeners();
    }
  }
  
  void start() {
    if (!_isRunning) {
      if (_mode == TimerMode.countdown && _elapsedTime >= _countdownDuration) {
        // Reset if countdown was completed
        _elapsedTime = Duration.zero;
        _countdownCompleted = false;
      }
      
      _startTime = DateTime.now().subtract(_elapsedTime);
      _isRunning = true;
      _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        if (_mode == TimerMode.stopwatch) {
          _elapsedTime = DateTime.now().difference(_startTime!);
        } else {
          // Countdown mode
          _elapsedTime = DateTime.now().difference(_startTime!);
          if (_elapsedTime >= _countdownDuration) {
            _elapsedTime = _countdownDuration;
            _countdownCompleted = true;
            stop();
            // Could trigger notification here
          }
        }
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
    _countdownCompleted = false;
    _alarmTriggered = false;
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
