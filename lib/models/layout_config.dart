import '../providers/usage_tracker_provider.dart';

enum LayoutMode {
  compact,    // Minimal, essential only
  balanced,   // Mix of essential and secondary
  expanded,   // All features visible
}

class LayoutConfig {
  final LayoutMode mode;
  final List<FeatureType> primaryFeatures;
  final List<FeatureType> secondaryFeatures;
  final List<FeatureType> hiddenFeatures;
  final bool showPredictions;
  
  LayoutConfig({
    required this.mode,
    required this.primaryFeatures,
    required this.secondaryFeatures,
    required this.hiddenFeatures,
    this.showPredictions = true,
  });
  
  static LayoutConfig fromUsageTracker(UsageTrackerProvider tracker) {
    final allFeatures = FeatureType.values;
    final scores = <FeatureType, double>{};
    
    for (final feature in allFeatures) {
      scores[feature] = tracker.getFeatureScore(feature);
    }
    
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Determine layout mode based on usage patterns
    final totalEvents = tracker.events.length;
    LayoutMode mode;
    if (totalEvents < 20) {
      mode = LayoutMode.expanded; // Show everything for new users
    } else if (totalEvents < 100) {
      mode = LayoutMode.balanced;
    } else {
      mode = LayoutMode.compact; // Focus on most used
    }
    
    // Split features by priority
    final primary = <FeatureType>[];
    final secondary = <FeatureType>[];
    final hidden = <FeatureType>[];
    
    for (final entry in sorted) {
      if (entry.value >= 50) {
        primary.add(entry.key);
      } else if (entry.value >= 20) {
        secondary.add(entry.key);
      } else {
        hidden.add(entry.key);
      }
    }
    
    // Always show timer and meeting info
    if (!primary.contains(FeatureType.timer)) {
      primary.insert(0, FeatureType.timer);
    }
    
    // Limit primary features based on mode
    if (mode == LayoutMode.compact) {
      primary.removeRange(4, primary.length);
    } else if (mode == LayoutMode.balanced) {
      primary.removeRange(6, primary.length);
    }
    
    return LayoutConfig(
      mode: mode,
      primaryFeatures: primary,
      secondaryFeatures: secondary,
      hiddenFeatures: hidden,
    );
  }
}
