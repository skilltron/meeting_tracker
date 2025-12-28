import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesProvider with ChangeNotifier {
  String _notes = '';
  bool _isExpanded = false;
  
  String get notes => _notes;
  bool get isExpanded => _isExpanded;
  
  NotesProvider() {
    _loadNotes();
  }
  
  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notes = prefs.getString('quick_notes') ?? '';
      _isExpanded = prefs.getBool('notes_expanded') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
  }
  
  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('quick_notes', _notes);
      await prefs.setBool('notes_expanded', _isExpanded);
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }
  
  void updateNotes(String newNotes) {
    _notes = newNotes;
    _saveNotes();
    notifyListeners();
  }
  
  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    _saveNotes();
    notifyListeners();
  }
  
  void setExpanded(bool expanded) {
    _isExpanded = expanded;
    _saveNotes();
    notifyListeners();
  }
  
  void clearNotes() {
    _notes = '';
    _saveNotes();
    notifyListeners();
  }
}
