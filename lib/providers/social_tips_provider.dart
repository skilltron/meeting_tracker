import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/social_tip.dart';

class SocialTipsProvider with ChangeNotifier {
  List<SocialTip> _allTips = SocialTip.getAllTips();
  Set<String> _selectedTipIds = {};
  SocialTip? _currentTip;
  Timer? _shuffleTimer;
  bool _autoShuffle = false;
  int _shuffleInterval = 300; // 5 minutes default
  
  List<SocialTip> get allTips => _allTips;
  Set<String> get selectedTipIds => _selectedTipIds;
  SocialTip? get currentTip => _currentTip;
  bool get autoShuffle => _autoShuffle;
  int get shuffleInterval => _shuffleInterval;
  
  List<SocialTip> get selectedTips {
    if (_selectedTipIds.isEmpty) {
      return _allTips; // Show all if none selected
    }
    return _allTips.where((tip) => _selectedTipIds.contains(tip.id)).toList();
  }
  
  SocialTipsProvider() {
    _loadPreferences();
    _shuffleTip();
  }
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedJson = prefs.getString('selected_social_tips');
      if (selectedJson != null) {
        final List<dynamic> decoded = json.decode(selectedJson);
        _selectedTipIds = decoded.map((e) => e.toString()).toSet();
      } else {
        // Default: select all tips
        _selectedTipIds = _allTips.map((tip) => tip.id).toSet();
      }
      
      _autoShuffle = prefs.getBool('auto_shuffle_tips') ?? false;
      _shuffleInterval = prefs.getInt('shuffle_interval') ?? 300;
      
      if (_autoShuffle) {
        _startAutoShuffle();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading social tips preferences: $e');
    }
  }
  
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'selected_social_tips',
        json.encode(_selectedTipIds.toList()),
      );
      await prefs.setBool('auto_shuffle_tips', _autoShuffle);
      await prefs.setInt('shuffle_interval', _shuffleInterval);
    } catch (e) {
      debugPrint('Error saving social tips preferences: $e');
    }
  }
  
  void toggleTipSelection(String tipId) {
    if (_selectedTipIds.contains(tipId)) {
      _selectedTipIds.remove(tipId);
    } else {
      _selectedTipIds.add(tipId);
    }
    _savePreferences();
    _shuffleTip();
    notifyListeners();
  }
  
  void selectAllTips() {
    _selectedTipIds = _allTips.map((tip) => tip.id).toSet();
    _savePreferences();
    _shuffleTip();
    notifyListeners();
  }
  
  void deselectAllTips() {
    _selectedTipIds.clear();
    _savePreferences();
    _currentTip = null;
    notifyListeners();
  }
  
  void selectByCategory(String category) {
    _selectedTipIds = _allTips
        .where((tip) => tip.category == category)
        .map((tip) => tip.id)
        .toSet();
    _savePreferences();
    _shuffleTip();
    notifyListeners();
  }
  
  void _shuffleTip() {
    final available = selectedTips;
    if (available.isEmpty) {
      _currentTip = null;
      return;
    }
    
    final random = Random();
    _currentTip = available[random.nextInt(available.length)];
    notifyListeners();
  }
  
  void shuffleTip() {
    _shuffleTip();
  }
  
  void setAutoShuffle(bool enabled) {
    _autoShuffle = enabled;
    _savePreferences();
    
    if (enabled) {
      _startAutoShuffle();
    } else {
      _stopAutoShuffle();
    }
    notifyListeners();
  }
  
  void setShuffleInterval(int seconds) {
    _shuffleInterval = seconds;
    _savePreferences();
    
    if (_autoShuffle) {
      _stopAutoShuffle();
      _startAutoShuffle();
    }
    notifyListeners();
  }
  
  void _startAutoShuffle() {
    _stopAutoShuffle();
    _shuffleTimer = Timer.periodic(
      Duration(seconds: _shuffleInterval),
      (_) => _shuffleTip(),
    );
  }
  
  void _stopAutoShuffle() {
    _shuffleTimer?.cancel();
    _shuffleTimer = null;
  }
  
  @override
  void dispose() {
    _stopAutoShuffle();
    super.dispose();
  }
}
