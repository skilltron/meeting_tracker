import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/meeting_provider.dart';
import '../providers/calendar_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/obs_provider.dart';
import '../models/calendar_event.dart';
import 'meeting_todo_list.dart';
import 'timer_settings_dialog.dart';

class MeetingInfoWidget extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  
  const MeetingInfoWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer3<MeetingProvider, CalendarProvider, OBSProvider>(
      builder: (context, meetingProvider, calendarProvider, obsProvider, child) {
        final currentEvent = calendarProvider.currentEvent;
        final upcomingEvents = calendarProvider.upcomingEvents.take(5).toList();
        
        // Auto-start/stop OBS recording based on meeting
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (currentEvent != null) {
            // Meeting is active - auto-start if enabled
            obsProvider.autoStartRecording();
          } else {
            // No active meeting - auto-stop if enabled
            obsProvider.autoStopRecording();
          }
        });
        
        return Column(
          children: [
            // Current meeting
            if (currentEvent != null)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          currentEvent.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                            letterSpacing: 0.6,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer<TodoProvider>(
                        builder: (context, todoProvider, child) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => MeetingTodoDialog(
                                  meetingId: currentEvent.id,
                                  meetingTitle: currentEvent.title,
                                ),
                              );
                            },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentColor.withOpacity(0.15),
                                accentColor.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: accentColor.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.add,
                            size: 15,
                            color: accentColor.withOpacity(0.9),
                          ),
                        ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Recording alert
                  if (currentEvent.isRecording)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red.withOpacity(0.3),
                          Colors.red.withOpacity(0.15),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.6),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RECORDING IN PROGRESS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.redAccent,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Meeting location and connection info
                  _buildMeetingConnectionInfo(currentEvent),
                ],
              )
            else
              Text(
                meetingProvider.isRunning ? 'Meeting in Progress' : 'No Meeting Active',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withOpacity(0.65),
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            
            const SizedBox(height: 10),
            
            // Today's upcoming meetings
            Consumer<CalendarProvider>(
              builder: (context, calendarProvider, child) {
                final todaysMeetings = calendarProvider.getTodaysMeetings();
                if (todaysMeetings.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S MEETINGS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: textColor.withOpacity(0.5),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: todaysMeetings.length,
                        itemBuilder: (context, index) {
                          final event = todaysMeetings[index];
                          final time = '${event.start.hour.toString().padLeft(2, '0')}:${event.start.minute.toString().padLeft(2, '0')}';
                          final isNow = DateTime.now().isAfter(event.start) && DateTime.now().isBefore(event.end);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isNow
                                    ? [
                                        accentColor.withOpacity(0.2),
                                        accentColor.withOpacity(0.1),
                                      ]
                                    : [
                                        accentColor.withOpacity(0.1),
                                        accentColor.withOpacity(0.05),
                                      ],
                              ),
                              border: Border.all(
                                color: isNow
                                    ? accentColor.withOpacity(0.5)
                                    : accentColor.withOpacity(0.2),
                                width: isNow ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        time,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: accentColor,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    if (isNow) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'NOW',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: accentColor,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  event.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                // Recording indicator
                                if (event.isRecording)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.5),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'RECORDING',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.redAccent,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                if (event.location != null || event.meetingLink != null) ...[
                                  const SizedBox(height: 6),
                                  _buildMeetingConnectionInfo(event, compact: true),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 10),
            
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton(
                  'START',
                  () => meetingProvider.start(),
                  const Color(0xFF00FF00),
                ),
                const SizedBox(width: 8),
                _buildButton(
                  'STOP',
                  () => meetingProvider.stop(),
                  const Color(0xFF00FF00),
                ),
                const SizedBox(width: 8),
                _buildButton(
                  'RESET',
                  () => meetingProvider.reset(),
                  const Color(0xFF00FF00),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => TimerSettingsDialog(
                        textColor: textColor,
                        accentColor: accentColor,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentColor.withOpacity(0.12),
                          accentColor.withOpacity(0.06),
                        ],
                      ),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.settings,
                      size: 14,
                      color: textColor.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withOpacity(0.12),
              accentColor.withOpacity(0.06),
            ],
          ),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: textColor.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
  
  Widget _buildMeetingConnectionInfo(CalendarEvent event, {bool compact = false}) {
    final hasLink = event.meetingLink != null;
    final hasLocation = event.location != null;
    final hasCode = event.meetingCode != null;
    final hasPassword = event.meetingPassword != null;
    
    if (!hasLink && !hasLocation && !hasCode && !hasPassword) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location (room or web indicator)
        if (hasLocation)
          Padding(
            padding: EdgeInsets.only(bottom: compact ? 4 : 6),
            child: Row(
              children: [
                Icon(
                  event.isVirtualMeeting ? Icons.video_call : Icons.room,
                  size: compact ? 12 : 14,
                  color: accentColor.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.location!,
                    style: TextStyle(
                      fontSize: compact ? 10 : 11,
                      color: textColor.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Meeting link (join button)
        if (hasLink)
          Padding(
            padding: EdgeInsets.only(bottom: compact ? 4 : 6),
              child: GestureDetector(
              onTap: () async {
                if (event.meetingLink != null) {
                  final uri = Uri.parse(event.meetingLink!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: compact ? 6 : 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacity(0.25),
                      accentColor.withOpacity(0.15),
                    ],
                  ),
                  border: Border.all(
                    color: accentColor.withOpacity(0.4),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.video_call,
                      size: compact ? 12 : 14,
                      color: accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'JOIN MEETING',
                      style: TextStyle(
                        fontSize: compact ? 10 : 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Meeting code and password
        if (hasCode || hasPassword)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (hasCode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Code: ',
                        style: TextStyle(
                          fontSize: compact ? 9 : 10,
                          color: textColor.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        event.meetingCode!,
                        style: TextStyle(
                          fontSize: compact ? 9 : 10,
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                ),
              if (hasPassword)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: accentColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pass: ',
                        style: TextStyle(
                          fontSize: compact ? 9 : 10,
                          color: textColor.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        event.meetingPassword!,
                        style: TextStyle(
                          fontSize: compact ? 9 : 10,
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
