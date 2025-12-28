import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calendar_event.dart';
import '../providers/calendar_provider.dart';

class CalendarService {
  String? _googleAccessToken;
  String? _outlookAccessToken;
  String? _oneDriveAccessToken;
  
  Future<void> connectGoogle() async {
    // Implement Google OAuth flow
    // This would use google_sign_in package
    throw UnimplementedError('Google authentication not yet implemented');
  }
  
  Future<void> connectOutlook() async {
    // Implement Microsoft OAuth flow for Outlook
    // This would use msal_flutter or oauth2 package
    throw UnimplementedError('Outlook authentication not yet implemented');
  }
  
  Future<void> connectOneDrive() async {
    // Implement Microsoft OAuth flow for OneDrive
    // Uses same Microsoft Graph API as Outlook
    throw UnimplementedError('OneDrive authentication not yet implemented');
  }
  
  Future<List<CalendarEvent>> getUpcomingEvents() async {
    final List<CalendarEvent> allEvents = [];
    
    if (_googleAccessToken != null) {
      final googleEvents = await _getGoogleEvents();
      allEvents.addAll(googleEvents);
    }
    
    if (_outlookAccessToken != null) {
      final outlookEvents = await _getOutlookEvents();
      allEvents.addAll(outlookEvents);
    }
    
    if (_oneDriveAccessToken != null) {
      final oneDriveEvents = await _getOneDriveEvents();
      allEvents.addAll(oneDriveEvents);
    }
    
    return allEvents;
  }
  
  Future<List<CalendarEvent>> _getGoogleEvents() async {
    final now = DateTime.now();
    final timeMin = now.toIso8601String();
    final timeMax = now.add(const Duration(days: 1)).toIso8601String();
    
    final url = Uri.parse(
      'https://www.googleapis.com/calendar/v3/calendars/primary/events?'
      'timeMin=$timeMin&'
      'timeMax=$timeMax&'
      'singleEvents=true&'
      'orderBy=startTime&'
      'maxResults=10',
    );
    
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_googleAccessToken',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List? ?? [];
      return items.map((item) => CalendarEvent.fromJson(item, 'google')).toList();
    }
    
    return [];
  }
  
  Future<List<CalendarEvent>> _getOutlookEvents() async {
    final now = DateTime.now();
    final timeMin = now.toIso8601String();
    final timeMax = now.add(const Duration(days: 1)).toIso8601String();
    
    final url = Uri.parse(
      'https://graph.microsoft.com/v1.0/me/calendar/calendarView?'
      'startDateTime=$timeMin&'
      'endDateTime=$timeMax&'
      '\$orderby=start/dateTime&'
      '\$top=10',
    );
    
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_outlookAccessToken',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['value'] as List? ?? [];
      return items.map((item) => CalendarEvent.fromJson(item, 'outlook')).toList();
    }
    
    return [];
  }
  
  Future<List<CalendarEvent>> _getOneDriveEvents() async {
    // Same as Outlook, uses Microsoft Graph API
    return _getOutlookEvents();
  }
  
  Future<void> createEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String? location,
    String? description,
    required CalendarProviderType provider,
  }) async {
    switch (provider) {
      case CalendarProviderType.google:
        await _createGoogleEvent(title, start, end, location, description);
        break;
      case CalendarProviderType.outlook:
        await _createOutlookEvent(title, start, end, location, description);
        break;
      case CalendarProviderType.onedrive:
        await _createOneDriveEvent(title, start, end, location, description);
        break;
    }
  }
  
  Future<void> _createGoogleEvent(
    String title,
    DateTime start,
    DateTime end,
    String? location,
    String? description,
  ) async {
    final event = {
      'summary': title,
      'start': {
        'dateTime': start.toIso8601String(),
        'timeZone': DateTime.now().timeZoneName,
      },
      'end': {
        'dateTime': end.toIso8601String(),
        'timeZone': DateTime.now().timeZoneName,
      },
      if (location != null) 'location': location,
      if (description != null) 'description': description,
    };
    
    final url = Uri.parse('https://www.googleapis.com/calendar/v3/calendars/primary/events');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_googleAccessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(event),
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create Google Calendar event: ${response.statusCode}');
    }
  }
  
  Future<void> _createOutlookEvent(
    String title,
    DateTime start,
    DateTime end,
    String? location,
    String? description,
  ) async {
    final event = {
      'subject': title,
      'start': {
        'dateTime': start.toIso8601String(),
        'timeZone': DateTime.now().timeZoneName,
      },
      'end': {
        'dateTime': end.toIso8601String(),
        'timeZone': DateTime.now().timeZoneName,
      },
      if (location != null) 'location': {'displayName': location},
      if (description != null) 'body': {
        'contentType': 'text',
        'content': description,
      },
    };
    
    final url = Uri.parse('https://graph.microsoft.com/v1.0/me/events');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_outlookAccessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(event),
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create Outlook event: ${response.statusCode}');
    }
  }
  
  Future<void> _createOneDriveEvent(
    String title,
    DateTime start,
    DateTime end,
    String? location,
    String? description,
  ) async {
    // Same as Outlook
    await _createOutlookEvent(title, start, end, location, description);
  }
}
