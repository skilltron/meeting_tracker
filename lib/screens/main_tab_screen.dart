import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/adaptive_meeting_tracker.dart';
import '../widgets/task_board_widget.dart';
import '../widgets/scribe_widget.dart';
import '../widgets/document_viewer_widget.dart';
import '../widgets/photo_library_widget.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<UIProvider>(
      builder: (context, uiProvider, child) {
        final baseText = const Color(0xFFB8D4E3);
        final accent = const Color(0xFFA8D5BA);
        final brightness = uiProvider.brightness;
        
        final textColor = Color.lerp(
          baseText.withOpacity(0.4),
          baseText,
          brightness,
        )!;
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withOpacity(0.9),
                  border: Border(
                    bottom: BorderSide(
                      color: accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: accent,
                  labelColor: accent,
                  unselectedLabelColor: textColor.withOpacity(0.6),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                  ),
                  tabs: const [
                    Tab(text: 'MEETINGS'),
                    Tab(text: 'TASKS'),
                    Tab(text: 'SCRIBE'),
                    Tab(text: 'DOCS'),
                    Tab(text: 'PHOTOS'),
                  ],
                ),
              ),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Meetings tab
                    Container(
                      color: Colors.transparent,
                      child: AdaptiveMeetingTracker(
                        textColor: textColor,
                        accentColor: accent,
                      ),
                    ),
                    
                    // Tasks tab
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(16),
                      child: TaskBoardWidget(
                        textColor: textColor,
                        accentColor: accent,
                      ),
                    ),
                    
                    // Scribe tab
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(16),
                      child: ScribeWidget(
                        textColor: textColor,
                        accentColor: accent,
                      ),
                    ),
                    
                    // Docs tab (PDF, HTML, MD)
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(16),
                      child: DocumentViewerWidget(
                        textColor: textColor,
                        accentColor: accent,
                      ),
                    ),
                    
                    // Photos tab
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(16),
                      child: PhotoLibraryWidget(
                        textColor: textColor,
                        accentColor: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
