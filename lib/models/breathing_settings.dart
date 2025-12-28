class BreathingSettings {
  final int inhaleSeconds; // Attack
  final int holdSeconds; // Dwell
  final int exhaleSeconds; // Release
  final int pauseSeconds; // Pause before repeat
  
  BreathingSettings({
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.pauseSeconds,
  });
  
  // Default for average person: 4-7-8 breathing technique
  static BreathingSettings getDefault() {
    return BreathingSettings(
      inhaleSeconds: 4,
      holdSeconds: 7,
      exhaleSeconds: 8,
      pauseSeconds: 0,
    );
  }
  
  int get totalCycleSeconds {
    return inhaleSeconds + holdSeconds + exhaleSeconds + pauseSeconds;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'inhaleSeconds': inhaleSeconds,
      'holdSeconds': holdSeconds,
      'exhaleSeconds': exhaleSeconds,
      'pauseSeconds': pauseSeconds,
    };
  }
  
  factory BreathingSettings.fromJson(Map<String, dynamic> json) {
    return BreathingSettings(
      inhaleSeconds: json['inhaleSeconds'] ?? 4,
      holdSeconds: json['holdSeconds'] ?? 7,
      exhaleSeconds: json['exhaleSeconds'] ?? 8,
      pauseSeconds: json['pauseSeconds'] ?? 0,
    );
  }
  
  BreathingSettings copyWith({
    int? inhaleSeconds,
    int? holdSeconds,
    int? exhaleSeconds,
    int? pauseSeconds,
  }) {
    return BreathingSettings(
      inhaleSeconds: inhaleSeconds ?? this.inhaleSeconds,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      exhaleSeconds: exhaleSeconds ?? this.exhaleSeconds,
      pauseSeconds: pauseSeconds ?? this.pauseSeconds,
    );
  }
}
