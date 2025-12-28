import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/usage_tracker_provider.dart';
import '../models/layout_config.dart';

class LayoutProvider with ChangeNotifier {
  LayoutConfig _config;
  bool _autoAdapt = true;
  
  LayoutConfig get config => _config;
  bool get autoAdapt => _autoAdapt;
  
  LayoutProvider(UsageTrackerProvider usageTracker) 
      : _config = LayoutConfig.fromUsageTracker(usageTracker) {
    _loadPreferences();
  }
  
  void updateFromUsage(UsageTrackerProvider usageTracker) {
    if (_autoAdapt) {
      _config = LayoutConfig.fromUsageTracker(usageTracker);
      _savePreferences();
      notifyListeners();
    }
  }
  
  void setAutoAdapt(bool enabled) {
    _autoAdapt = enabled;
    _savePreferences();
    notifyListeners();
  }
  
  void setLayoutMode(LayoutMode mode) {
    _config = LayoutConfig(
      mode: mode,
      primaryFeatures: _config.primaryFeatures,
      secondaryFeatures: _config.secondaryFeatures,
      hiddenFeatures: _config.hiddenFeatures,
    );
    _savePreferences();
    notifyListeners();
  }
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoAdapt = prefs.getBool('layout_auto_adapt') ?? true;
    } catch (e) {
      debugPrint('Error loading layout preferences: $e');
    }
  }
  
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('layout_auto_adapt', _autoAdapt);
    } catch (e) {
      debugPrint('Error saving layout preferences: $e');
    }
  }
}
