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
        return Text(
          meetingProvider.formattedTime,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            fontFamily: 'Courier',
            color: textColor,
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                color: textColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
              Shadow(
                color: textColor.withOpacity(0.2),
                blurRadius: 24,
              ),
            ],
          ),
        );
      },
    );
  }
}
