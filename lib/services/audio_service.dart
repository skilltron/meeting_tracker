import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioService {
  bool _isPlaying = false;
  
  Future<void> playAlert() async {
    if (_isPlaying) return;
    
    try {
      _isPlaying = true;
      // Use system sound (HapticFeedback for vibration + system sound)
      HapticFeedback.mediumImpact();
      // Note: For actual audio, you'd need platform channels or audio files
      // This provides haptic feedback as a gentle alert
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Audio alert error: $e');
    } finally {
      _isPlaying = false;
    }
  }
  
  Future<void> playMeetingAlert() async {
    // Different pattern for meeting starting
    try {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Meeting alert error: $e');
    }
  }
  
  void dispose() {
    // No cleanup needed for HapticFeedback
  }
}
