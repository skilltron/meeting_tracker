import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/breathing_settings.dart';

enum BreathingPhase {
  inhale,
  hold,
  exhale,
  pause,
}

class BreathingProvider with ChangeNotifier {
  BreathingSettings _settings = BreathingSettings.getDefault();
  bool _isActive = false;
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _phaseProgress = 0; // 0-100
  Timer? _breathingTimer;
  int _cycleCount = 0;
  
  BreathingSettings get settings => _settings;
  bool get isActive => _isActive;
  BreathingPhase get currentPhase => _currentPhase;
  int get phaseProgress => _phaseProgress;
  int get cycleCount => _cycleCount;
  
  String get currentPhaseLabel {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Breathe In';
      case BreathingPhase.hold:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Breathe Out';
      case BreathingPhase.pause:
        return 'Pause';
    }
  }
  
  int get currentPhaseDuration {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return _settings.inhaleSeconds;
      case BreathingPhase.hold:
        return _settings.holdSeconds;
      case BreathingPhase.exhale:
        return _settings.exhaleSeconds;
      case BreathingPhase.pause:
        return _settings.pauseSeconds;
    }
  }
  
  BreathingProvider() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('breathing_settings');
      if (settingsJson != null) {
        _settings = BreathingSettings.fromJson(json.decode(settingsJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading breathing settings: $e');
    }
  }
  
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'breathing_settings',
        json.encode(_settings.toJson()),
      );
    } catch (e) {
      debugPrint('Error saving breathing settings: $e');
    }
  }
  
  void updateSettings(BreathingSettings newSettings) {
    _settings = newSettings;
    _saveSettings();
    notifyListeners();
  }
  
  void start() {
    if (_isActive) return;
    
    _isActive = true;
    _currentPhase = BreathingPhase.inhale;
    _phaseProgress = 0;
    _cycleCount = 0;
    _startPhase();
    notifyListeners();
  }
  
  void stop() {
    _isActive = false;
    _breathingTimer?.cancel();
    _breathingTimer = null;
    _currentPhase = BreathingPhase.inhale;
    _phaseProgress = 0;
    notifyListeners();
  }
  
  void reset() {
    stop();
    _cycleCount = 0;
    notifyListeners();
  }
  
  void _startPhase() {
    if (!_isActive) return;
    
    final duration = currentPhaseDuration;
    if (duration == 0) {
      _nextPhase();
      return;
    }
    
    _phaseProgress = 0;
    final startTime = DateTime.now();
    
    _breathingTimer?.cancel();
    _breathingTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        if (!_isActive) {
          timer.cancel();
          return;
        }
        
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        final total = duration * 1000;
        _phaseProgress = ((elapsed / total) * 100).clamp(0, 100).toInt();
        
        if (_phaseProgress >= 100) {
          timer.cancel();
          _nextPhase();
        } else {
          notifyListeners();
        }
      },
    );
  }
  
  void _nextPhase() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        _currentPhase = BreathingPhase.hold;
        break;
      case BreathingPhase.hold:
        _currentPhase = BreathingPhase.exhale;
        break;
      case BreathingPhase.exhale:
        if (_settings.pauseSeconds > 0) {
          _currentPhase = BreathingPhase.pause;
        } else {
          _currentPhase = BreathingPhase.inhale;
          _cycleCount++;
        }
        break;
      case BreathingPhase.pause:
        _currentPhase = BreathingPhase.inhale;
        _cycleCount++;
        break;
    }
    
    _startPhase();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _breathingTimer?.cancel();
    super.dispose();
  }
}
