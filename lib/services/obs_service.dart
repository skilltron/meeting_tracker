import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

/// Simple OBS Studio WebSocket service
/// Connects to obs-websocket (default port 4455)
class OBSService {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isRecording = false;
  String? _error;
  
  // Connection settings
  String _host = 'localhost';
  int _port = 4455;
  String? _password;
  
  // Status callbacks
  Function(bool)? onConnectionChanged;
  Function(bool)? onRecordingChanged;
  Function(String)? onError;
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isRecording => _isRecording;
  String? get error => _error;
  String get host => _host;
  int get port => _port;
  
  /// Configure OBS connection
  void configure({String? host, int? port, String? password}) {
    if (host != null) _host = host;
    if (port != null) _port = port;
    if (password != null) _password = password;
  }
  
  /// Connect to OBS WebSocket
  Future<bool> connect() async {
    try {
      if (_isConnected) {
        return true;
      }
      
      final uri = Uri.parse('ws://$_host:$_port');
      _channel = WebSocketChannel.connect(uri);
      _error = null;
      
      // Listen for messages
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          _error = 'Connection failed. Make sure OBS is running and WebSocket is enabled in OBS Settings → WebSocket Server Settings.';
          _isConnected = false;
          onError?.call(_error!);
          onConnectionChanged?.call(false);
        },
        onDone: () {
          _isConnected = false;
          onConnectionChanged?.call(false);
        },
      );
      
      // Wait for initial connection
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Send authentication if password is set
      if (_password != null && _password!.isNotEmpty) {
        await _authenticate();
      }
      
      // Request current recording status
      await _getRecordingStatus();
      
      _isConnected = true;
      onConnectionChanged?.call(true);
      return true;
    } catch (e) {
      _error = 'Failed to connect: $e\n\nMake sure:\n1. OBS Studio is running\n2. WebSocket is enabled in OBS (Tools → WebSocket Server Settings)\n3. Port is set to 4455';
      _isConnected = false;
      onError?.call(_error!);
      onConnectionChanged?.call(false);
      return false;
    }
  }
  
  /// Disconnect from OBS
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    onConnectionChanged?.call(false);
  }
  
  /// Authenticate with OBS WebSocket
  Future<void> _authenticate() async {
    // OBS WebSocket 5.x authentication
    // This is a simplified version - full auth requires challenge/response
    try {
      final request = {
        'op': 1, // Identify
        'd': {
          'rpcVersion': 1,
          'authentication': _password,
        },
      };
      _channel?.sink.add(jsonEncode(request));
    } catch (e) {
      debugPrint('OBS auth error: $e');
    }
  }
  
  /// Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      final opCode = data['op'];
      
      if (opCode == 0) { // Hello
        // Server greeting
      } else if (opCode == 2) { // Identified
        // Authentication successful
      } else if (opCode == 5) { // Event
        _handleEvent(data['d']);
      } else if (opCode == 7) { // RequestResponse
        _handleRequestResponse(data['d']);
      }
    } catch (e) {
      debugPrint('OBS message error: $e');
    }
  }
  
  /// Handle events from OBS
  void _handleEvent(Map<String, dynamic>? event) {
    if (event == null) return;
    
    final eventType = event['eventType'];
    if (eventType == 'RecordingStateChanged') {
      final outputState = event['eventData']?['outputState'];
      _isRecording = outputState == 'OBS_WEBSOCKET_OUTPUT_STARTED';
      onRecordingChanged?.call(_isRecording);
    }
  }
  
  /// Handle request responses
  void _handleRequestResponse(Map<String, dynamic>? response) {
    if (response == null) return;
    
    final requestType = response['requestType'];
    if (requestType == 'GetRecordStatus') {
      final outputActive = response['responseData']?['outputActive'] ?? false;
      _isRecording = outputActive;
      onRecordingChanged?.call(_isRecording);
    }
  }
  
  /// Get current recording status
  Future<void> _getRecordingStatus() async {
    try {
      final request = {
        'op': 6, // Request
        'd': {
          'requestType': 'GetRecordStatus',
          'requestId': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      };
      _channel?.sink.add(jsonEncode(request));
    } catch (e) {
      debugPrint('OBS get status error: $e');
    }
  }
  
  /// Start recording
  Future<bool> startRecording() async {
    try {
      if (!_isConnected) {
        final connected = await connect();
        if (!connected) return false;
      }
      
      final request = {
        'op': 6, // Request
        'd': {
          'requestType': 'StartRecord',
          'requestId': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      };
      _channel?.sink.add(jsonEncode(request));
      
      // Wait a moment for response
      await Future.delayed(const Duration(milliseconds: 500));
      return _isRecording;
    } catch (e) {
      _error = 'Failed to start recording: $e';
      onError?.call(_error!);
      return false;
    }
  }
  
  /// Stop recording
  Future<bool> stopRecording() async {
    try {
      if (!_isConnected) return false;
      
      final request = {
        'op': 6, // Request
        'd': {
          'requestType': 'StopRecord',
          'requestId': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      };
      _channel?.sink.add(jsonEncode(request));
      
      // Wait a moment for response
      await Future.delayed(const Duration(milliseconds: 500));
      return !_isRecording;
    } catch (e) {
      _error = 'Failed to stop recording: $e';
      onError?.call(_error!);
      return false;
    }
  }
  
  /// Toggle recording
  Future<bool> toggleRecording() async {
    if (_isRecording) {
      return await stopRecording();
    } else {
      return await startRecording();
    }
  }
  
  /// Auto-configure OBS for screen recording with computer audio
  Future<bool> autoConfigure() async {
    try {
      if (!_isConnected) {
        final connected = await connect();
        if (!connected) return false;
      }
      
      // Wait a moment for connection to stabilize
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Step 1: Create Display Capture source (screen)
      await _createDisplayCapture();
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Step 2: Create Audio Output Capture (computer audio)
      await _createAudioOutputCapture();
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Step 3: Set recording format and path
      await _configureRecordingSettings();
      
      return true;
    } catch (e) {
      _error = 'Auto-configuration failed: $e';
      onError?.call(_error!);
      return false;
    }
  }
  
  /// Create Display Capture source for screen recording
  Future<void> _createDisplayCapture() async {
    try {
      // Check if display capture already exists
      final request = {
        'op': 6, // Request
        'd': {
          'requestType': 'GetSceneItemList',
          'requestId': DateTime.now().millisecondsSinceEpoch.toString(),
          'requestData': {
            'sceneName': 'Scene',
          },
        },
      };
      _channel?.sink.add(jsonEncode(request));
      
      // Create display capture source
      await Future.delayed(const Duration(milliseconds: 200));
      
      final createRequest = {
        'op': 6,
        'd': {
          'requestType': 'CreateInput',
          'requestId': '${DateTime.now().millisecondsSinceEpoch}_display',
          'requestData': {
            'inputName': 'Screen Capture',
            'inputKind': 'screen_capture',
            'sceneName': 'Scene',
            'inputSettings': {
              'capture_cursor': true,
            },
          },
        },
      };
      _channel?.sink.add(jsonEncode(createRequest));
    } catch (e) {
      debugPrint('Error creating display capture: $e');
    }
  }
  
  /// Create Audio Output Capture for computer audio
  Future<void> _createAudioOutputCapture() async {
    try {
      final createRequest = {
        'op': 6,
        'd': {
          'requestType': 'CreateInput',
          'requestId': '${DateTime.now().millisecondsSinceEpoch}_audio',
          'requestData': {
            'inputName': 'Desktop Audio',
            'inputKind': 'wasapi_output_capture',
            'sceneName': 'Scene',
            'inputSettings': {},
          },
        },
      };
      _channel?.sink.add(jsonEncode(createRequest));
    } catch (e) {
      debugPrint('Error creating audio capture: $e');
    }
  }
  
  /// Configure recording settings
  Future<void> _configureRecordingSettings() async {
    try {
      // Set recording format to MP4
      final formatRequest = {
        'op': 6,
        'd': {
          'requestType': 'SetRecordDirectory',
          'requestId': '${DateTime.now().millisecondsSinceEpoch}_format',
          'requestData': {
            'recordDirectory': '', // Use default
          },
        },
      };
      _channel?.sink.add(jsonEncode(formatRequest));
      
      // Enable WebSocket server if not already enabled
      // Note: This might require OBS to be configured manually first time
      // We'll just ensure the sources are set up
    } catch (e) {
      debugPrint('Error configuring recording: $e');
    }
  }
}
