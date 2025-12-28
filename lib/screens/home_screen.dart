import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meeting_provider.dart';
import '../providers/calendar_provider.dart';
import '../providers/ui_provider.dart';
import '../providers/social_tips_provider.dart';
import '../providers/notes_provider.dart';
import '../services/audio_service.dart';
import '../widgets/meeting_tracker_widget.dart';
import '../widgets/adaptive_meeting_tracker.dart';
import '../widgets/dock_controls.dart';
import '../widgets/quick_notes_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _flashController;
  late AnimationController _brightnessController;
  Timer? _visualUpdateTimer;
  final AudioService _audioService = AudioService();
  bool _lastAlertState = false;
  
  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    
    _brightnessController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Update flash animation based on UI provider
    final uiProvider = Provider.of<UIProvider>(context, listen: false);
    uiProvider.addListener(_updateFlashAnimation);
    
    // Start brightness at dark
    _brightnessController.value = 0.15;
    
    // Update visual effects every second
    _visualUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateVisualEffects();
    });
  }
  
  void _updateVisualEffects() {
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    final uiProvider = Provider.of<UIProvider>(context, listen: false);
    
    final nextMeeting = calendarProvider.getNextMeetingIn20Minutes();
    if (nextMeeting != null) {
      final now = DateTime.now();
      final minutesUntil = nextMeeting.start.difference(now).inMinutes;
      final isWithin10Minutes = minutesUntil <= 10 && minutesUntil > 0;
      
      uiProvider.updateVisualEffects(
        isMeetingApproaching: true,
        minutesUntilMeeting: minutesUntil.toDouble(),
      );
      
      // Audio alerts (only if enabled and within 10 minutes)
      if (uiProvider.audioAlertsEnabled && isWithin10Minutes && !_lastAlertState) {
        _audioService.playAlert();
        _lastAlertState = true;
      } else if (!isWithin10Minutes) {
        _lastAlertState = false;
      }
    } else {
      uiProvider.updateVisualEffects(
        isMeetingApproaching: false,
        minutesUntilMeeting: 999.0,
      );
      _lastAlertState = false;
    }
  }
  
  void _updateFlashAnimation() {
    final uiProvider = Provider.of<UIProvider>(context, listen: false);
    final duration = uiProvider.flashDuration;
    
    if (duration < 100) {
      // Only flash if duration is reasonable (10 min or less before meeting)
      _flashController.duration = Duration(
        milliseconds: (duration * 1000).round(),
      );
      if (!_flashController.isAnimating) {
        _flashController.repeat(reverse: true);
      }
    } else {
      // Stop flashing
      _flashController.stop();
      _flashController.value = 0;
    }
    
    // Update brightness transition
    if (uiProvider.hasBeenClicked && _brightnessController.value < 1.0) {
      _brightnessController.animateTo(1.0);
    }
  }
  
  @override
  void dispose() {
    final uiProvider = Provider.of<UIProvider>(context, listen: false);
    uiProvider.removeListener(_updateFlashAnimation);
    _visualUpdateTimer?.cancel();
    _flashController.dispose();
    _brightnessController.dispose();
    _audioService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<UIProvider>(
      builder: (context, uiProvider, child) {
        return GestureDetector(
          onTap: () {
            uiProvider.onUserClick();
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([_flashController, _brightnessController]),
            builder: (context, child) {
              // Pleasant pastel colors
              final baseBg = const Color(0xFF1A1A2E); // Deep navy
              final baseText = const Color(0xFFB8D4E3); // Soft blue
              final accent = const Color(0xFFA8D5BA); // Soft mint green
              
              // Flash only if meeting is approaching (within 10 min)
              final flashValue = uiProvider.flashDuration < 100 
                  ? _flashController.value * 0.2 // Subtle flash
                  : 0.0;
              
              // Brightness transition
              final brightness = _brightnessController.value;
              
              // In overlay mode, make background more transparent
              final bgOpacity = uiProvider.isOverlayMode
                  ? uiProvider.ghostOpacity
                  : 1.0;
              
              final backgroundColor = Color.lerp(
                baseBg,
                const Color(0xFF2D3561), // Slightly lighter navy when bright
                flashValue + (brightness * 0.3),
              )!.withOpacity(bgOpacity);
              
              final textColor = Color.lerp(
                baseText.withOpacity(0.4), // Very dim when dark
                baseText,
                brightness,
              )!;
              
            // In overlay mode, use ghost opacity
            final effectiveOpacity = uiProvider.isOverlayMode
                ? uiProvider.ghostOpacity
                : uiProvider.opacity;
            
            return Container(
              color: backgroundColor,
              child: Stack(
                children: [
                  // Main content with ghost transparency in overlay mode
                  Positioned.fill(
                    child: Opacity(
                      opacity: effectiveOpacity,
                      child: AdaptiveMeetingTracker(
                        textColor: textColor,
                        accentColor: accent,
                      ),
                    ),
                  ),
                  
                  // Dock controls - more visible in overlay mode
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Opacity(
                      opacity: uiProvider.isOverlayMode
                          ? uiProvider.ghostOpacity + 0.2
                          : brightness,
                      child: const DockControls(),
                    ),
                  ),
                  
                  // Quick Notes - bottom left
                  Opacity(
                    opacity: effectiveOpacity,
                    child: QuickNotesWidget(
                      textColor: textColor,
                      accentColor: accent,
                    ),
                  ),
                ],
              ),
            );
            },
          ),
        );
      },
    );
  }
}
