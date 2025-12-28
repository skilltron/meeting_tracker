import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meeting_provider.dart';

class TimerWidget extends StatelessWidget {
  final Color textColor;
  
  const TimerWidget({
    super.key,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MeetingProvider>(
      builder: (context, meetingProvider, child) {
        final isCountdown = meetingProvider.mode == TimerMode.countdown;
        final isCompleted = meetingProvider.countdownCompleted;
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode indicator
            Text(
              isCountdown ? 'COUNTDOWN' : 'STOPWATCH',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: textColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 4),
            // Timer display
            Text(
              meetingProvider.formattedTime,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                fontFamily: 'Courier',
                color: isCompleted ? Colors.redAccent : textColor,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: (isCompleted ? Colors.redAccent : textColor).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 2),
                  ),
                  Shadow(
                    color: (isCompleted ? Colors.redAccent : textColor).withOpacity(0.2),
                    blurRadius: 24,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
