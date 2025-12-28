import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/calendar_provider.dart';
import '../providers/todo_provider.dart';
import 'meeting_todo_list.dart';

class TodaysMeetingsList extends StatelessWidget {
  const TodaysMeetingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, child) {
        final todaysMeetings = calendarProvider.getTodaysMeetings();
        
        if (todaysMeetings.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withOpacity(0.6),
            border: Border.all(
              color: const Color(0xFFA8D5BA).withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA8D5BA).withOpacity(0.1),
                blurRadius: 15,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TODAY'S MEETINGS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: const Color(0xFFB8D4E3),
                ),
              ),
              const SizedBox(height: 12),
              ...todaysMeetings.map((meeting) {
                final timeFormat = DateFormat('h:mm a');
                final startTime = timeFormat.format(meeting.start);
                final endTime = timeFormat.format(meeting.end);
                final now = DateTime.now();
                final isPast = now.isAfter(meeting.end);
                final isCurrent = now.isAfter(meeting.start) && now.isBefore(meeting.end);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFFA8D5BA).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFFA8D5BA).withOpacity(0.5)
                            : const Color(0xFFA8D5BA).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFFA8D5BA)
                                : const Color(0xFFB8D4E3).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meeting.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isPast
                                      ? const Color(0xFFB8D4E3).withOpacity(0.5)
                                      : const Color(0xFFB8D4E3),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$startTime - $endTime',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(0xFFB8D4E3).withOpacity(0.7),
                                ),
                              ),
                              if (meeting.location != null && meeting.location!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    meeting.location!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: const Color(0xFFB8D4E3).withOpacity(0.6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA8D5BA).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'NOW',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFA8D5BA),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        // Add todo button
                        Consumer<TodoProvider>(
                          builder: (context, todoProvider, child) {
                            final todoCount = todoProvider.getTotalCountForMeeting(meeting.id);
                            final completedCount = todoProvider.getCompletedCountForMeeting(meeting.id);
                            final hasTodos = todoCount > 0;
                            
                            return GestureDetector(
                              onTap: () {
                                _showTodoDialog(context, meeting.id, meeting.title);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: hasTodos
                                      ? const Color(0xFFA8D5BA).withOpacity(0.2)
                                      : const Color(0xFF1A1A2E).withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFA8D5BA).withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.add,
                                      size: 14,
                                      color: Color(0xFFA8D5BA),
                                    ),
                                    if (hasTodos) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '$completedCount/$todoCount',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: completedCount == todoCount
                                              ? const Color(0xFFA8D5BA)
                                              : const Color(0xFFB8D4E3).withOpacity(0.7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
  
  void _showTodoDialog(BuildContext context, String meetingId, String meetingTitle) {
    showDialog(
      context: context,
      builder: (dialogContext) => MeetingTodoDialog(
        meetingId: meetingId,
        meetingTitle: meetingTitle,
      ),
    );
  }
}
