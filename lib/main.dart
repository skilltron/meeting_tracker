import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/meeting_provider.dart';
import 'providers/calendar_provider.dart';
import 'providers/ui_provider.dart';
import 'providers/todo_provider.dart';
import 'providers/social_tips_provider.dart';
import 'providers/breathing_provider.dart';
import 'providers/notes_provider.dart';
import 'providers/usage_tracker_provider.dart';
import 'providers/layout_provider.dart';
import 'providers/obs_provider.dart';
import 'providers/transcription_provider.dart';
import 'providers/task_provider.dart';
import 'providers/photo_provider.dart';
// import 'providers/vagus_reminder_provider.dart'; // TODO: Re-enable when file exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager for desktop platforms (if available)
  if (!kIsWeb && isDesktop()) {
    try {
      // Window manager initialization will be handled in the app if needed
      // For now, we'll skip it to avoid compilation issues
    } catch (e) {
      // Window manager not available, continue without it
      debugPrint('Window manager not available: $e');
    }
  }
  
  runApp(const MeetingTrackerApp());
}

bool isDesktop() {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.macOS,
    TargetPlatform.linux,
  ].contains(defaultTargetPlatform);
}

Future<dynamic> _getWindowManager() async {
  try {
    // Dynamic import to avoid issues if package not available
    return null; // Will be implemented when window_manager is properly configured
  } catch (e) {
    return null;
  }
}

class MeetingTrackerApp extends StatelessWidget {
  const MeetingTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MeetingProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => UIProvider()),
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
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => OBSProvider()),
        ChangeNotifierProxyProvider2<TaskProvider, OBSProvider, TranscriptionProvider>(
          create: (_) {
            final taskProvider = Provider.of<TaskProvider>(_, listen: false);
            final obsProvider = Provider.of<OBSProvider>(_, listen: false);
            final transcriptionProvider = TranscriptionProvider(taskProvider, obsProvider);
            obsProvider.setTranscriptionProvider(transcriptionProvider);
            return transcriptionProvider;
          },
          update: (_, taskProvider, obsProvider, previous) {
            if (previous != null) {
              return previous;
            }
            final transcriptionProvider = TranscriptionProvider(taskProvider, obsProvider);
            obsProvider.setTranscriptionProvider(transcriptionProvider);
            return transcriptionProvider;
          },
        ),
        // ChangeNotifierProvider(create: (_) => VagusReminderProvider()), // TODO: Re-enable when file exists
      ],
      child: MaterialApp(
        title: 'Meeting Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFFA8D5BA),
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          fontFamily: 'Courier',
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFA8D5BA),
            secondary: Color(0xFFB8D4E3),
            surface: Color(0xFF1A1A2E),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
