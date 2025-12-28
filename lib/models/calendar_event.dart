class CalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? location;
  final String? description;
  final String provider; // 'google', 'outlook', 'onedrive'
  
  CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.location,
    this.description,
    required this.provider,
  });
  
  factory CalendarEvent.fromJson(Map<String, dynamic> json, String provider) {
    return CalendarEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? json['subject'] ?? 'Untitled Meeting',
      start: DateTime.parse(json['start']?['dateTime'] ?? json['start']),
      end: DateTime.parse(json['end']?['dateTime'] ?? json['end']),
      location: json['location']?['displayName'] ?? json['location'],
      description: json['description'] ?? json['body']?['content'],
      provider: provider,
    );
  }
}
