import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/usage_tracker_provider.dart';
import '../providers/layout_provider.dart';
import '../providers/calendar_provider.dart';
import '../models/layout_config.dart';
import 'daily_quote_widget.dart';
import 'moon_phase_widget.dart';
import 'timer_widget.dart';
import 'meeting_info_widget.dart';
import 'auth_section_widget.dart';
import 'scheduler_widget.dart';
import 'todays_meetings_list.dart';
import 'social_tips_widget.dart';
import 'breathing_exercise_widget.dart';
import 'quick_notes_widget.dart';
import 'animated_turtle_widget.dart';
// import 'vagus_reminder_widget.dart'; // TODO: Re-enable when file exists

class AdaptiveMeetingTracker extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  
  const AdaptiveMeetingTracker({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer3<LayoutProvider, UsageTrackerProvider, CalendarProvider>(
      builder: (context, layoutProvider, usageTracker, calendarProvider, child) {
        final config = layoutProvider.config;
        final predictedFeatures = usageTracker.getPredictedFeatures();
        
        // Update layout based on usage
        WidgetsBinding.instance.addPostFrameCallback((_) {
          layoutProvider.updateFromUsage(usageTracker);
        });
        
        return Stack(
          children: [
            Column(
              children: [
                // Vagus nerve stimulator reminder (if showing)
                // VagusReminderWidget(textColor: textColor, accentColor: accentColor), // TODO: Re-enable when file exists
                
                // Main content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with prediction indicator
                          _buildHeader(context, predictedFeatures),
                          const SizedBox(height: 20),
                          
                          // Meeting display (always primary, top priority)
                          _buildMeetingSection(context),
                          const SizedBox(height: 20),
                          
                          // Primary features (most used) - always visible
                          _buildPrimarySection(context, config, predictedFeatures),
                          
                          // Secondary features - shown based on mode
                          if (config.mode != LayoutMode.compact)
                            _buildSecondarySection(context, config, predictedFeatures),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Animated turtle (floating in corner)
            Positioned(
              bottom: 20,
              right: 20,
              child: Opacity(
                opacity: 0.6,
                child: AnimatedTurtleWidget(
                  textColor: textColor,
                  accentColor: accentColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildHeader(BuildContext context, List<FeatureType> predicted) {
    return Column(
      children: [
        Text(
          'MEETING TRACKER',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: textColor,
            shadows: [
              Shadow(
                color: accentColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        if (predicted.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: accentColor.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Text(
              '✨ Ready for you',
              style: TextStyle(
                fontSize: 10,
                color: accentColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildPrimarySection(
    BuildContext context,
    LayoutConfig config,
    List<FeatureType> predicted,
  ) {
    // Filter out timer since it's in meeting section
    final primaryFeatures = config.primaryFeatures
        .where((f) => f != FeatureType.timer)
        .toList();
    
    if (primaryFeatures.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor.withOpacity(0.6),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: primaryFeatures
              .map((feature) => _buildFeatureWidget(
                context,
                feature,
                _getFeatureWidget(feature),
                isPredicted: predicted.contains(feature),
                isCompact: config.mode == LayoutMode.compact,
              ))
              .toList(),
        ),
      ],
    );
  }
  
  Widget _buildSecondarySection(
    BuildContext context,
    LayoutConfig config,
    List<FeatureType> predicted,
  ) {
    if (config.secondaryFeatures.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Collapsible secondary section
        _buildCollapsibleSection(
          context,
          'More Tools',
          config.secondaryFeatures.map((f) => _buildFeatureWidget(
            context,
            f,
            _getFeatureWidget(f),
            isPredicted: predicted.contains(f),
          )).toList(),
        ),
      ],
    );
  }
  
  Widget _buildMeetingSection(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
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
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.15),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              TimerWidget(textColor: textColor),
              const SizedBox(height: 18),
              MeetingInfoWidget(textColor: textColor, accentColor: accentColor),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeatureWidget(
    BuildContext context,
    FeatureType feature,
    Widget widget, {
    bool isPredicted = false,
    bool isCompact = false,
  }) {
    final usageTracker = Provider.of<UsageTrackerProvider>(context, listen: false);
    
    // Track usage when widget is built (passive tracking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      usageTracker.trackUsage(feature, context: 'displayed');
    });
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: isCompact ? 160 : 200,
      ),
      child: Stack(
        children: [
          widget,
          if (isPredicted)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.6),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTimerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.8),
            const Color(0xFF1F2A4A).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TimerWidget(textColor: textColor),
    );
  }
  
  Widget _getFeatureWidget(FeatureType feature) {
    switch (feature) {
      case FeatureType.breathing:
        return BreathingExerciseWidget(
          textColor: textColor,
          accentColor: accentColor,
        );
      case FeatureType.socialTips:
        return SocialTipsWidget(
          textColor: textColor,
          accentColor: accentColor,
        );
      case FeatureType.quote:
        return DailyQuoteWidget(
          textColor: textColor,
          accentColor: accentColor,
        );
      case FeatureType.moonPhase:
        return MoonPhaseWidget(textColor: textColor);
      case FeatureType.calendar:
        return const TodaysMeetingsList();
      case FeatureType.scheduler:
        return SchedulerWidget(
          textColor: textColor,
          accentColor: accentColor,
        );
      case FeatureType.notes:
        return const SizedBox.shrink(); // Notes handled separately
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildCollapsibleSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor.withOpacity(0.7),
          letterSpacing: 1.0,
        ),
      ),
      initiallyExpanded: false,
      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
      childrenPadding: const EdgeInsets.only(top: 8),
      children: children,
    );
  }
}
