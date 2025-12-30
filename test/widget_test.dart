// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:meeting_tracker/main.dart';
import 'package:meeting_tracker/providers/meeting_provider.dart';
import 'package:meeting_tracker/providers/calendar_provider.dart';
import 'package:meeting_tracker/providers/ui_provider.dart';
import 'package:meeting_tracker/providers/todo_provider.dart';
import 'package:meeting_tracker/providers/social_tips_provider.dart';
import 'package:meeting_tracker/providers/breathing_provider.dart';
import 'package:meeting_tracker/providers/notes_provider.dart';
import 'package:meeting_tracker/providers/usage_tracker_provider.dart';
import 'package:meeting_tracker/providers/layout_provider.dart';
import 'package:meeting_tracker/providers/task_provider.dart';
import 'package:meeting_tracker/providers/messaging_provider.dart';
import 'package:meeting_tracker/providers/meeting_actions_provider.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UIProvider()),
          ChangeNotifierProvider(create: (_) => MeetingProvider()),
          ChangeNotifierProvider(create: (_) => CalendarProvider()),
          ChangeNotifierProvider(create: (_) => TodoProvider()),
          ChangeNotifierProvider(create: (_) => SocialTipsProvider()),
          ChangeNotifierProvider(create: (_) => BreathingProvider()),
          ChangeNotifierProvider(create: (_) => NotesProvider()),
          ChangeNotifierProvider(create: (_) => UsageTrackerProvider()),
          ChangeNotifierProxyProvider<UsageTrackerProvider, LayoutProvider>(
            create: (_) => LayoutProvider(
              Provider.of<UsageTrackerProvider>(_, listen: false),
            ),
            update: (_, usageTracker, previous) =>
                previous ?? LayoutProvider(usageTracker),
          ),
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => MessagingProvider()),
          ChangeNotifierProvider(create: (_) => MeetingActionsProvider()),
        ],
        child: const MeetingTrackerApp(),
      ),
    );

    // Verify that the app loads
    await tester.pumpAndSettle();
    expect(find.byType(MeetingTrackerApp), findsOneWidget);
  });
}
