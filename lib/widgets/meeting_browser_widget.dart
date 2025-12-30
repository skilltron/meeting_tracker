import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/calendar_provider.dart';
import '../models/calendar_event.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MeetingBrowserWidget extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  
  const MeetingBrowserWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, child) {
        // Load meetings from data folder
        final meetings = _loadMeetingsFromData();
        
        return Container(
          padding: const EdgeInsets.all(16),
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEETING BROWSER',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Date filter
              _buildDateFilter(context),
              const SizedBox(height: 16),
              
              // Meetings list
              Expanded(
                child: meetings.isEmpty
                    ? Center(
                        child: Text(
                          'No meetings found',
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: meetings.length,
                        itemBuilder: (context, index) {
                          return _buildMeetingCard(context, meetings[index]);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDateFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: 14,
            color: accentColor,
          ),
          const SizedBox(width: 8),
          Text(
            'View by date',
            style: TextStyle(
              fontSize: 11,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMeetingCard(BuildContext context, Map<String, dynamic> meetingData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.15),
            accentColor.withOpacity(0.08),
          ],
        ),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meetingData['title'] ?? 'Untitled Meeting',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meetingData['date'] ?? '',
            style: TextStyle(
              fontSize: 11,
              color: textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Map<String, dynamic>> _loadMeetingsFromData() {
    // TODO: Load from data/meetings/ folder
    return [];
  }
}
