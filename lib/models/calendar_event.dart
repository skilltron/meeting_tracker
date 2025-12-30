class CalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? location;
  final String? description;
  final String provider; // 'google', 'outlook', 'onedrive'
  final String? meetingLink; // Join URL for virtual meetings
  final String? meetingCode; // Meeting ID/code
  final String? meetingPassword; // Meeting password
  final String? organizer; // Meeting organizer
  final bool isRecording; // Whether meeting is being recorded
  
  CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.location,
    this.description,
    required this.provider,
    this.meetingLink,
    this.meetingCode,
    this.meetingPassword,
    this.organizer,
    this.isRecording = false,
  });
  
  // Parse meeting link and codes from description/location
  static String? _extractMeetingLink(String? text) {
    if (text == null) return null;
    
    // Look for common meeting URL patterns
    final patterns = [
      RegExp(r'https?://(?:meet\.google\.com|zoom\.us|teams\.microsoft\.com|webex\.com|gotomeeting\.com)[^\s]*', caseSensitive: false),
      RegExp(r'https?://[^\s]*(?:meeting|join|call)[^\s]*', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(0);
      }
    }
    return null;
  }
  
  // Extract meeting code (Zoom, Teams, etc.)
  static String? _extractMeetingCode(String? text) {
    if (text == null) return null;
    
    // Zoom meeting ID pattern
    final zoomPattern = RegExp(r'(?:meeting|zoom)\s*(?:id|code|number)[\s:]*(\d{9,11})', caseSensitive: false);
    final zoomMatch = zoomPattern.firstMatch(text);
    if (zoomMatch != null) {
      return zoomMatch.group(1);
    }
    
    // Teams meeting ID
    final teamsPattern = RegExp(r'teams\s*(?:meeting|id|code)[\s:]*([a-zA-Z0-9-]+)', caseSensitive: false);
    final teamsMatch = teamsPattern.firstMatch(text);
    if (teamsMatch != null) {
      return teamsMatch.group(1);
    }
    
    // Generic meeting code pattern
    final genericPattern = RegExp(r'(?:meeting|call)\s*(?:id|code|number)[\s:]*([a-zA-Z0-9-]{6,})', caseSensitive: false);
    final genericMatch = genericPattern.firstMatch(text);
    if (genericMatch != null) {
      return genericMatch.group(1);
    }
    
    return null;
  }
  
  // Extract meeting password
  static String? _extractMeetingPassword(String? text) {
    if (text == null) return null;
    
    final patterns = [
      RegExp(r'(?:password|passcode|pin)[\s:]*([a-zA-Z0-9]{4,})', caseSensitive: false),
      RegExp(r'pass[:\s]*([a-zA-Z0-9]{4,})', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }
  
  // Check if recording is in progress
  static bool _checkRecordingStatus(String? text) {
    if (text == null) return false;
    
    final recordingPatterns = [
      RegExp(r'recording\s*(?:is\s*)?(?:in\s*)?progress', caseSensitive: false),
      RegExp(r'this\s*meeting\s*is\s*being\s*recorded', caseSensitive: false),
      RegExp(r'recording\s*started', caseSensitive: false),
      RegExp(r'🔴\s*recording', caseSensitive: false),
    ];
    
    for (final pattern in recordingPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    return false;
  }
  
  // Determine if location is virtual (web) or physical (room)
  bool get isVirtualMeeting => meetingLink != null || (location?.toLowerCase().contains('web') ?? false) || (location?.toLowerCase().contains('online') ?? false);
  bool get isPhysicalMeeting => location != null && !isVirtualMeeting;
  
  factory CalendarEvent.fromJson(Map<String, dynamic> json, String provider) {
    final description = json['description'] ?? json['body']?['content'] ?? '';
    final locationText = json['location']?['displayName'] ?? json['location'] ?? '';
    final combinedText = '$description $locationText';
    
    // Extract meeting information
    final meetingLink = _extractMeetingLink(combinedText) ?? 
                       json['hangoutLink'] ?? 
                       json['onlineMeeting']?['joinUrl'] ??
                       json['joinUrl'];
    final meetingCode = _extractMeetingCode(combinedText) ?? 
                       json['conferenceData']?['entryPoints']?[0]?['meetingCode'];
    final meetingPassword = _extractMeetingPassword(combinedText) ??
                           json['conferenceData']?['entryPoints']?[0]?['passcode'];
    
    // Check if recording is in progress
    final isRecording = _checkRecordingStatus(combinedText) ||
                       json['conferenceData']?['conferenceSolution']?['type'] == 'recorded' ||
                       json['isRecording'] == true;
    
    return CalendarEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? json['subject'] ?? 'Untitled Meeting',
      start: DateTime.parse(json['start']?['dateTime'] ?? json['start']),
      end: DateTime.parse(json['end']?['dateTime'] ?? json['end']),
      location: locationText.isNotEmpty ? locationText : null,
      description: description.isNotEmpty ? description : null,
      provider: provider,
      meetingLink: meetingLink,
      meetingCode: meetingCode,
      meetingPassword: meetingPassword,
      organizer: json['organizer']?['email'] ?? json['organizer']?['displayName'],
      isRecording: isRecording,
    );
  }
}
