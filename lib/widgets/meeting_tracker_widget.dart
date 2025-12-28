import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meeting_provider.dart';
import '../providers/calendar_provider.dart';
import 'daily_quote_widget.dart';
import 'moon_phase_widget.dart';
import 'timer_widget.dart';
import 'meeting_info_widget.dart';
import 'auth_section_widget.dart';
import 'scheduler_widget.dart';
import 'todays_meetings_list.dart';
import 'social_tips_widget.dart';
import 'breathing_exercise_widget.dart';

class MeetingTrackerWidget extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  
  const MeetingTrackerWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient effect
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'MEETING TRACKER',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: textColor,
                  shadows: [
                    Shadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                    Shadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Daily Quote
            DailyQuoteWidget(textColor: textColor, accentColor: accentColor),
            const SizedBox(height: 18),
            
            // Social Tips (ADHD)
            SocialTipsWidget(textColor: textColor, accentColor: accentColor),
            const SizedBox(height: 18),
            
            // Breathing Exercise
            BreathingExerciseWidget(textColor: textColor, accentColor: accentColor),
            const SizedBox(height: 18),
            
            // Moon Phase
            MoonPhaseWidget(textColor: textColor),
            const SizedBox(height: 24),
            
            // Today's Meetings List
            const TodaysMeetingsList(),
            const SizedBox(height: 15),
            
            // Auth Section
            AuthSectionWidget(textColor: textColor, accentColor: accentColor),
            const SizedBox(height: 15),
            
            // Scheduler
            SchedulerWidget(textColor: textColor, accentColor: accentColor),
            const SizedBox(height: 15),
            
            // Meeting Display
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A1A2E).withOpacity(0.9),
                    const Color(0xFF1F2A4A).withOpacity(0.7),
                  ],
                ),
                border: Border.all(
                  color: accentColor.withOpacity(0.35),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.15),
                    blurRadius: 24,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Timer
                  TimerWidget(textColor: textColor),
                  const SizedBox(height: 18),
                  
                  // Meeting Info
                  MeetingInfoWidget(textColor: textColor, accentColor: accentColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
