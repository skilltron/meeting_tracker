import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

enum FeatureType {
  timer,
  breathing,
  socialTips,
  notes,
  calendar,
  scheduler,
  moonPhase,
  quote,
}

class UsageEvent {
  final FeatureType feature;
  final DateTime timestamp;
  final String? context; // Additional context (e.g., meeting time, phase)
  
  UsageEvent({
    required this.feature,
    required this.timestamp,
    this.context,
  });
  
  Map<String, dynamic> toJson() => {
    'feature': feature.toString(),
    'timestamp': timestamp.toIso8601String(),
    'context': context,
  };
  
  factory UsageEvent.fromJson(Map<String, dynamic> json) => UsageEvent(
    feature: FeatureType.values.firstWhere(
      (e) => e.toString() == json['feature'],
    ),
    timestamp: DateTime.parse(json['timestamp']),
    context: json['context'],
  );
}

class UsageTrackerProvider with ChangeNotifier {
  List<UsageEvent> _events = [];
  Map<FeatureType, int> _featureCounts = {};
  Map<FeatureType, DateTime> _lastUsed = {};
  Map<String, dynamic> _patterns = {};
  
  // Pattern learning: time-based usage
  Map<int, List<FeatureType>> _hourlyPatterns = {}; // hour -> most used features
  Map<String, List<FeatureType>> _dayPatterns = {}; // dayOfWeek -> most used features
  
  List<UsageEvent> get events => _events;
  Map<FeatureType, int> get featureCounts => _featureCounts;
  Map<FeatureType, DateTime> get lastUsed => _lastUsed;
  Map<String, dynamic> get patterns => _patterns;
  
  // Get most used features (sorted)
  List<FeatureType> get mostUsedFeatures {
    final sorted = _featureCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }
  
  // Get features likely to be used now (based on time patterns)
  List<FeatureType> getPredictedFeatures() {
    final now = DateTime.now();
    final hour = now.hour;
    final dayOfWeek = now.weekday.toString();
    
    final predicted = <FeatureType>{};
    
    // Check hourly patterns
    if (_hourlyPatterns.containsKey(hour)) {
      predicted.addAll(_hourlyPatterns[hour]!.take(3));
    }
    
    // Check day patterns
    if (_dayPatterns.containsKey(dayOfWeek)) {
      predicted.addAll(_dayPatterns[dayOfWeek]!.take(2));
    }
    
    // Fallback to most used overall
    if (predicted.isEmpty) {
      predicted.addAll(mostUsedFeatures.take(3));
    }
    
    return predicted.toList();
  }
  
  UsageTrackerProvider() {
    _loadData();
    _analyzePatterns();
  }
  
  void trackUsage(FeatureType feature, {String? context}) {
    final event = UsageEvent(
      feature: feature,
      timestamp: DateTime.now(),
      context: context,
    );
    
    _events.add(event);
    _featureCounts[feature] = (_featureCounts[feature] ?? 0) + 1;
    _lastUsed[feature] = DateTime.now();
    
    // Keep only last 1000 events
    if (_events.length > 1000) {
      _events = _events.sublist(_events.length - 1000);
    }
    
    _saveData();
    _analyzePatterns();
    notifyListeners();
  }
  
  void _analyzePatterns() {
    // Analyze hourly patterns
    _hourlyPatterns.clear();
    final hourlyUsage = <int, Map<FeatureType, int>>{};
    
    for (final event in _events) {
      final hour = event.timestamp.hour;
      hourlyUsage[hour] ??= {};
      hourlyUsage[hour]![event.feature] = 
          (hourlyUsage[hour]![event.feature] ?? 0) + 1;
    }
    
    for (final entry in hourlyUsage.entries) {
      final sorted = entry.value.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _hourlyPatterns[entry.key] = sorted.map((e) => e.key).toList();
    }
    
    // Analyze day-of-week patterns
    _dayPatterns.clear();
    final dayUsage = <String, Map<FeatureType, int>>{};
    
    for (final event in _events) {
      final day = event.timestamp.weekday.toString();
      dayUsage[day] ??= {};
      dayUsage[day]![event.feature] = 
          (dayUsage[day]![event.feature] ?? 0) + 1;
    }
    
    for (final entry in dayUsage.entries) {
      final sorted = entry.value.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _dayPatterns[entry.key] = sorted.map((e) => e.key).toList();
    }
    
    // Store patterns
    _patterns = {
      'hourly': _hourlyPatterns.map((k, v) => 
        MapEntry(k.toString(), v.map((f) => f.toString()).toList())),
      'daily': _dayPatterns,
    };
  }
  
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString('usage_events');
      if (eventsJson != null) {
        final List<dynamic> decoded = json.decode(eventsJson);
        _events = decoded.map((e) => UsageEvent.fromJson(e)).toList();
        
        // Rebuild counts
        _featureCounts.clear();
        _lastUsed.clear();
        for (final event in _events) {
          _featureCounts[event.feature] = 
              (_featureCounts[event.feature] ?? 0) + 1;
          final last = _lastUsed[event.feature];
          if (last == null || event.timestamp.isAfter(last)) {
            _lastUsed[event.feature] = event.timestamp;
          }
        }
      }
      
      final patternsJson = prefs.getString('usage_patterns');
      if (patternsJson != null) {
        _patterns = json.decode(patternsJson);
      }
      
      _analyzePatterns();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading usage data: $e');
    }
  }
  
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'usage_events',
        json.encode(_events.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        'usage_patterns',
        json.encode(_patterns),
      );
    } catch (e) {
      debugPrint('Error saving usage data: $e');
    }
  }
  
  // Get feature priority score (0-100)
  double getFeatureScore(FeatureType feature) {
    final count = _featureCounts[feature] ?? 0;
    final lastUsed = _lastUsed[feature];
    final predicted = getPredictedFeatures();
    
    double score = 0;
    
    // Usage frequency (0-50 points)
    if (_featureCounts.isNotEmpty) {
      final maxCount = _featureCounts.values.reduce(max);
      score += (count / maxCount) * 50;
    }
    
    // Recency (0-30 points)
    if (lastUsed != null) {
      final daysSince = DateTime.now().difference(lastUsed).inDays;
      score += (1 - (daysSince / 30).clamp(0, 1)) * 30;
    }
    
    // Prediction match (0-20 points)
    if (predicted.contains(feature)) {
      final index = predicted.indexOf(feature);
      score += (1 - index / predicted.length) * 20;
    }
    
    return score.clamp(0, 100);
  }
}
