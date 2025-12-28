import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meeting_provider.dart';
import '../providers/calendar_provider.dart';
import '../providers/todo_provider.dart';
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
    return Consumer2<MeetingProvider, CalendarProvider>(
      builder: (context, meetingProvider, calendarProvider, child) {
        final currentEvent = calendarProvider.currentEvent;
        final upcomingEvents = calendarProvider.upcomingEvents.take(5).toList();
        
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
            
            // Upcoming meetings
            if (upcomingEvents.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 80),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = upcomingEvents[index];
                    final time = '${event.start.hour.toString().padLeft(2, '0')}:${event.start.minute.toString().padLeft(2, '0')}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        '$time - ${event.title}',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.75),
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    );
                  },
                ),
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
}
