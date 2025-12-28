import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusProvider with ChangeNotifier {
  bool _isFocusModeActive = false;
  bool _reducedMotionEnabled = false;
  int _breakReminderInterval = 30; // minutes
  bool _breakRemindersEnabled = true;
  Timer? _breakReminderTimer;
  DateTime? _lastBreakTime;
  
  // Getters
  bool get isFocusModeActive => _isFocusModeActive;
  bool get reducedMotionEnabled => _reducedMotionEnabled;
  int get breakReminderInterval => _breakReminderInterval;
  bool get breakRemindersEnabled => _breakRemindersEnabled;
  
  FocusProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isFocusModeActive = prefs.getBool('focusMode') ?? false;
    _reducedMotionEnabled = prefs.getBool('reducedMotion') ?? false;
    _breakReminderInterval = prefs.getInt('breakReminderInterval') ?? 30;
    _breakRemindersEnabled = prefs.getBool('breakRemindersEnabled') ?? true;
    notifyListeners();
  }
  
  Future<void> setFocusMode(bool enabled) async {
    _isFocusModeActive = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('focusMode', enabled);
    
    if (enabled) {
      _startBreakReminders();
    } else {
      _stopBreakReminders();
    }
    
    notifyListeners();
  }
  
  Future<void> setReducedMotion(bool enabled) async {
    _reducedMotionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reducedMotion', enabled);
    notifyListeners();
  }
  
  Future<void> setBreakReminderInterval(int minutes) async {
    _breakReminderInterval = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('breakReminderInterval', minutes);
    if (_isFocusModeActive) {
      _startBreakReminders();
    }
    notifyListeners();
  }
  
  Future<void> setBreakRemindersEnabled(bool enabled) async {
    _breakRemindersEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('breakRemindersEnabled', enabled);
    
    if (enabled && _isFocusModeActive) {
      _startBreakReminders();
    } else {
      _stopBreakReminders();
    }
    
    notifyListeners();
  }
  
  void _startBreakReminders() {
    _stopBreakReminders();
    if (!_breakRemindersEnabled) return;
    
    _lastBreakTime = DateTime.now();
    _breakReminderTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        if (_lastBreakTime != null) {
          final minutesSinceBreak = DateTime.now().difference(_lastBreakTime!).inMinutes;
          if (minutesSinceBreak >= _breakReminderInterval) {
            _showBreakReminder();
            _lastBreakTime = DateTime.now();
          }
        }
      },
    );
  }
  
  void _stopBreakReminders() {
    _breakReminderTimer?.cancel();
    _breakReminderTimer = null;
  }
  
  void _showBreakReminder() {
    // This will be handled by the UI
    notifyListeners();
  }
  
  void acknowledgeBreak() {
    _lastBreakTime = DateTime.now();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _stopBreakReminders();
    super.dispose();
  }
}
