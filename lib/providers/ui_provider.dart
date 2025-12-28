import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DockPosition {
  right,
  left,
  top,
  bottom,
  taskbar,
  floating,
  overlay,
  edge,
  mirror,
}

class UIProvider with ChangeNotifier {
  DockPosition _dockPosition = DockPosition.right;
  bool _stayOnTop = false;
  bool _mirrorMode = false;
  double _opacity = 0.15; // Very dark until clicked
  double _flashDuration = 10.0; // No flashing until 10 min before
  bool _isMeetingApproaching = false;
  bool _hasBeenClicked = false; // Track if user has interacted
  double _brightness = 0.15; // Dark by default
  bool _isOverlayMode = false; // Track if in overlay mode
  double _ghostOpacity = 0.15; // Ghost transparency for overlay mode
  
  // Alert settings
  bool _visualAlertsEnabled = true;
  bool _audioAlertsEnabled = false;
  
  // Getters
  DockPosition get dockPosition => _dockPosition;
  bool get stayOnTop => _stayOnTop;
  bool get mirrorMode => _mirrorMode;
  double get opacity => _opacity;
  double get flashDuration => _flashDuration;
  bool get isMeetingApproaching => _isMeetingApproaching;
  bool get hasBeenClicked => _hasBeenClicked;
  double get brightness => _brightness;
  bool get isOverlayMode => _isOverlayMode;
  double get ghostOpacity => _ghostOpacity;
  bool get visualAlertsEnabled => _visualAlertsEnabled;
  bool get audioAlertsEnabled => _audioAlertsEnabled;
  
  UIProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _dockPosition = DockPosition.values.firstWhere(
      (e) => e.toString() == prefs.getString('dockPosition'),
      orElse: () => DockPosition.right,
    );
    _isOverlayMode = _dockPosition == DockPosition.overlay;
    _stayOnTop = prefs.getBool('stayOnTop') ?? false;
    _mirrorMode = prefs.getBool('mirrorMode') ?? false;
    _visualAlertsEnabled = prefs.getBool('visualAlerts') ?? true;
    _audioAlertsEnabled = prefs.getBool('audioAlerts') ?? false;
    notifyListeners();
  }
  
  Future<void> setVisualAlerts(bool enabled) async {
    _visualAlertsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('visualAlerts', enabled);
    notifyListeners();
  }
  
  Future<void> setAudioAlerts(bool enabled) async {
    _audioAlertsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audioAlerts', enabled);
    notifyListeners();
  }
  
  Future<void> setDockPosition(DockPosition position) async {
    _dockPosition = position;
    _isOverlayMode = position == DockPosition.overlay;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dockPosition', position.toString());
    notifyListeners();
  }
  
  Future<void> setStayOnTop(bool value) async {
    _stayOnTop = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stayOnTop', value);
    notifyListeners();
  }
  
  Future<void> setMirrorMode(bool value) async {
    _mirrorMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mirrorMode', value);
    notifyListeners();
  }
  
  void onUserClick() {
    if (!_hasBeenClicked) {
      _hasBeenClicked = true;
      // In overlay mode, only brighten if meeting is approaching
      if (!_isOverlayMode) {
        _brightness = 1.0; // Transition to full brightness
      }
      notifyListeners();
    }
  }
  
  void updateVisualEffects({
    required bool isMeetingApproaching,
    required double minutesUntilMeeting,
  }) {
    _isMeetingApproaching = isMeetingApproaching;
    
    // In overlay mode: ghost transparency until clicked, then ghost if no meeting
    if (_isOverlayMode) {
      if (!_hasBeenClicked) {
        // Not clicked yet - stay ghost transparent
        _ghostOpacity = 0.15;
        _opacity = 0.15;
      } else if (!isMeetingApproaching) {
        // Clicked but no meeting - stay ghost
        _ghostOpacity = 0.25;
        _opacity = 0.25;
      } else {
        // Meeting approaching - show more clearly
        if (minutesUntilMeeting <= 15) {
          final lighteningProgress = (20 - minutesUntilMeeting) / 5;
          _ghostOpacity = 0.25 + (0.75 * lighteningProgress);
          _opacity = _ghostOpacity;
        } else {
          _ghostOpacity = 0.4;
          _opacity = 0.4;
        }
      }
    } else {
      // Normal mode: base opacity depends on whether user has clicked
      final baseOpacity = _hasBeenClicked ? 1.0 : 0.15;
      
      if (isMeetingApproaching && minutesUntilMeeting <= 20) {
        // Lighten over 5 minutes (from 20 min to 15 min before meeting)
        if (minutesUntilMeeting <= 15) {
          final lighteningProgress = (20 - minutesUntilMeeting) / 5;
          _opacity = baseOpacity * (0.3 + (0.7 * lighteningProgress));
        } else {
          _opacity = baseOpacity * 0.3;
        }
      } else {
        _opacity = baseOpacity;
      }
    }
    
    // Flash rate: ONLY start at 10 minutes, ramp up to 3s at meeting time
    // Only if visual alerts are enabled
    if (_visualAlertsEnabled && isMeetingApproaching && minutesUntilMeeting <= 10 && minutesUntilMeeting > 0) {
      // Accelerate from 10 minutes to 0
      final timeRemaining = minutesUntilMeeting.clamp(0.0, 10.0);
      final accelerationFactor = ((10 - timeRemaining) / 10).clamp(0.0, 1.0);
      // Start at 10s, end at 3s
      _flashDuration = 10 - (7 * accelerationFactor);
    } else {
      // No flashing if visual alerts disabled or no meeting
      _flashDuration = 999.0; // Effectively no flashing
    }
    
    notifyListeners();
  }
}
