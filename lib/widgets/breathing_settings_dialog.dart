import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/breathing_provider.dart';
import '../models/breathing_settings.dart';

class BreathingSettingsDialog extends StatefulWidget {
  const BreathingSettingsDialog({super.key});

  @override
  State<BreathingSettingsDialog> createState() => _BreathingSettingsDialogState();
}

class _BreathingSettingsDialogState extends State<BreathingSettingsDialog> {
  late int _inhaleSeconds;
  late int _holdSeconds;
  late int _exhaleSeconds;
  late int _pauseSeconds;
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BreathingProvider>(context, listen: false);
    _inhaleSeconds = provider.settings.inhaleSeconds;
    _holdSeconds = provider.settings.holdSeconds;
    _exhaleSeconds = provider.settings.exhaleSeconds;
    _pauseSeconds = provider.settings.pauseSeconds;
  }
  
  Widget _buildTimeSlider({
    required String label,
    required String description,
    required int value,
    required ValueChanged<int> onChanged,
    int min = 0,
    int max = 20,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (color ?? const Color(0xFFA8D5BA)).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color ?? const Color(0xFFB8D4E3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFFB8D4E3).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (color ?? const Color(0xFFA8D5BA)).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value}s',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color ?? const Color(0xFFA8D5BA),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            activeColor: color ?? const Color(0xFFA8D5BA),
            inactiveColor: const Color(0xFFB8D4E3).withOpacity(0.2),
            onChanged: (newValue) => onChanged(newValue.toInt()),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<BreathingProvider>(
      builder: (context, provider, child) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A2E).withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFFA8D5BA).withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'BREATHING SETTINGS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB8D4E3),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFFB8D4E3),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Time controls
                _buildTimeSlider(
                  label: 'Inhale (Attack)',
                  description: 'Time to breathe in',
                  value: _inhaleSeconds,
                  onChanged: (value) {
                    setState(() => _inhaleSeconds = value);
                  },
                  color: const Color(0xFFA8D5BA),
                ),
                
                _buildTimeSlider(
                  label: 'Hold (Dwell)',
                  description: 'Time to hold breath',
                  value: _holdSeconds,
                  onChanged: (value) {
                    setState(() => _holdSeconds = value);
                  },
                  color: const Color(0xFFB8D4E3),
                ),
                
                _buildTimeSlider(
                  label: 'Exhale (Release)',
                  description: 'Time to breathe out',
                  value: _exhaleSeconds,
                  onChanged: (value) {
                    setState(() => _exhaleSeconds = value);
                  },
                  color: const Color(0xFFD4A5A5),
                ),
                
                _buildTimeSlider(
                  label: 'Pause',
                  description: 'Rest before next cycle',
                  value: _pauseSeconds,
                  onChanged: (value) {
                    setState(() => _pauseSeconds = value);
                  },
                  min: 0,
                  max: 10,
                  color: const Color(0xFFB8D4E3).withOpacity(0.5),
                ),
                
                const SizedBox(height: 20),
                
                // Total cycle time
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8D5BA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Cycle Time',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB8D4E3),
                        ),
                      ),
                      Text(
                        '${_inhaleSeconds + _holdSeconds + _exhaleSeconds + _pauseSeconds}s',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFA8D5BA),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Preset buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildPresetButton(
                        '4-7-8 (Default)',
                        () {
                          setState(() {
                            _inhaleSeconds = 4;
                            _holdSeconds = 7;
                            _exhaleSeconds = 8;
                            _pauseSeconds = 0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPresetButton(
                        'Box (4-4-4-4)',
                        () {
                          setState(() {
                            _inhaleSeconds = 4;
                            _holdSeconds = 4;
                            _exhaleSeconds = 4;
                            _pauseSeconds = 4;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPresetButton(
                        'Equal (5-5-5)',
                        () {
                          setState(() {
                            _inhaleSeconds = 5;
                            _holdSeconds = 5;
                            _exhaleSeconds = 5;
                            _pauseSeconds = 0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPresetButton(
                        'Quick (3-3-3)',
                        () {
                          setState(() {
                            _inhaleSeconds = 3;
                            _holdSeconds = 3;
                            _exhaleSeconds = 3;
                            _pauseSeconds = 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.updateSettings(
                        BreathingSettings(
                          inhaleSeconds: _inhaleSeconds,
                          holdSeconds: _holdSeconds,
                          exhaleSeconds: _exhaleSeconds,
                          pauseSeconds: _pauseSeconds,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA8D5BA).withOpacity(0.2),
                      foregroundColor: const Color(0xFFA8D5BA),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: const Color(0xFFA8D5BA).withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Save Settings',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPresetButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFA8D5BA).withOpacity(0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFA8D5BA),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
