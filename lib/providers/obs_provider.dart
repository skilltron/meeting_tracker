import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/obs_service.dart';

class OBSProvider with ChangeNotifier {
  final OBSService _obsService = OBSService();
  dynamic _transcriptionProvider; // TranscriptionProvider - using dynamic to avoid circular import
  
  bool _autoStartEnabled = false;
  bool _autoStopEnabled = true;
  
  // Getters
  bool get isConnected => _obsService.isConnected;
  bool get isRecording => _obsService.isRecording;
  String? get error => _obsService.error;
  bool get autoStartEnabled => _autoStartEnabled;
  bool get autoStopEnabled => _autoStopEnabled;
  
  OBSProvider() {
    _loadSettings();
    _setupCallbacks();
  }
  
  /// Set transcription provider for auto-detection
  void setTranscriptionProvider(dynamic provider) {
    _transcriptionProvider = provider;
  }
  
  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoStartEnabled = prefs.getBool('obs_auto_start') ?? false;
      _autoStopEnabled = prefs.getBool('obs_auto_stop') ?? true;
      
      // Load connection settings
      final host = prefs.getString('obs_host') ?? 'localhost';
      final port = prefs.getInt('obs_port') ?? 4455;
      final password = prefs.getString('obs_password');
      
      _obsService.configure(host: host, port: port, password: password);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading OBS settings: $e');
    }
  }
  
  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('obs_auto_start', _autoStartEnabled);
      await prefs.setBool('obs_auto_stop', _autoStopEnabled);
    } catch (e) {
      debugPrint('Error saving OBS settings: $e');
    }
  }
  
  /// Setup OBS service callbacks
  void _setupCallbacks() {
    _obsService.onConnectionChanged = (connected) {
      notifyListeners();
    };
    
    _obsService.onRecordingChanged = (recording) {
      // Start/stop transcription when recording changes
      if (recording && _transcriptionProvider != null) {
        try {
          _transcriptionProvider.startTranscription();
        } catch (e) {
          debugPrint('Error starting transcription: $e');
        }
      } else if (!recording && _transcriptionProvider != null) {
        try {
          _transcriptionProvider.stopTranscription();
        } catch (e) {
          debugPrint('Error stopping transcription: $e');
        }
      }
      notifyListeners();
    };
    
    _obsService.onError = (error) {
      notifyListeners();
    };
  }
  
  /// Configure OBS connection
  Future<void> configure({
    String? host,
    int? port,
    String? password,
  }) async {
    _obsService.configure(host: host, port: port, password: password);
    
    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      if (host != null) await prefs.setString('obs_host', host);
      if (port != null) await prefs.setInt('obs_port', port);
      if (password != null) await prefs.setString('obs_password', password);
    } catch (e) {
      debugPrint('Error saving OBS config: $e');
    }
    
    notifyListeners();
  }
  
  /// Connect to OBS (returns false if OBS not available)
  Future<bool> connect() async {
    try {
      final connected = await _obsService.connect();
      notifyListeners();
      return connected;
    } catch (e) {
      debugPrint('OBS connection error: $e');
      notifyListeners();
      return false;
    }
  }
  
  /// Disconnect from OBS
  void disconnect() {
    _obsService.disconnect();
    notifyListeners();
  }
  
  /// Start recording
  Future<bool> startRecording() async {
    final success = await _obsService.startRecording();
    notifyListeners();
    return success;
  }
  
  /// Stop recording
  Future<bool> stopRecording() async {
    final success = await _obsService.stopRecording();
    notifyListeners();
    return success;
  }
  
  /// Toggle recording
  Future<bool> toggleRecording() async {
    final success = await _obsService.toggleRecording();
    notifyListeners();
    return success;
  }
  
  /// Enable/disable auto-start
  Future<void> setAutoStart(bool enabled) async {
    _autoStartEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }
  
  /// Enable/disable auto-stop
  Future<void> setAutoStop(bool enabled) async {
    _autoStopEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }
  
  /// Auto-start recording (called when meeting starts)
  Future<void> autoStartRecording() async {
    if (_autoStartEnabled && !_obsService.isRecording) {
      await startRecording();
    }
  }
  
  /// Auto-stop recording (called when meeting ends)
  Future<void> autoStopRecording() async {
    if (_autoStopEnabled && _obsService.isRecording) {
      await stopRecording();
    }
  }
  
  /// Auto-configure OBS for screen recording with computer audio
  Future<bool> autoConfigure() async {
    final success = await _obsService.autoConfigure();
    notifyListeners();
    return success;
  }
  
  /// Check if OBS is available (connected)
  bool get isAvailable => _obsService.isConnected;
}
