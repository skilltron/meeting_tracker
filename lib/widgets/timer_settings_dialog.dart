import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meeting_provider.dart';

class TimerSettingsDialog extends StatefulWidget {
  final Color textColor;
  final Color accentColor;
  
  const TimerSettingsDialog({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  State<TimerSettingsDialog> createState() => _TimerSettingsDialogState();
}

class _TimerSettingsDialogState extends State<TimerSettingsDialog> {
  late TimerMode _selectedMode;
  late int _countdownMinutes;
  late bool _alarmEnabled;
  late int _alarmMinutes;
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MeetingProvider>(context, listen: false);
    _selectedMode = provider.mode;
    _countdownMinutes = provider.countdownDuration.inMinutes;
    _alarmEnabled = provider.alarmEnabled;
    _alarmMinutes = provider.alarmDuration.inMinutes;
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<MeetingProvider>(
      builder: (context, provider, child) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E).withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: widget.accentColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          title: Text(
            'TIMER SETTINGS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: widget.textColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode selection
              Text(
                'Mode',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.textColor.withOpacity(0.7),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildModeButton(
                      'STOPWATCH',
                      TimerMode.stopwatch,
                      Icons.timer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModeButton(
                      'COUNTDOWN',
                      TimerMode.countdown,
                      Icons.hourglass_empty,
                    ),
                  ),
                ],
              ),
              
              if (_selectedMode == TimerMode.countdown) ...[
                const SizedBox(height: 24),
                Text(
                  'Duration',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.textColor.withOpacity(0.7),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                // Preset buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPresetButton('15 min', 15),
                    _buildPresetButton('25 min', 25),
                    _buildPresetButton('30 min', 30),
                    _buildPresetButton('45 min', 45),
                    _buildPresetButton('60 min', 60),
                  ],
                ),
                const SizedBox(height: 12),
                // Custom slider
                Row(
                  children: [
                    Text(
                      '${_countdownMinutes} min',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _countdownMinutes.toDouble(),
                        min: 1,
                        max: 120,
                        divisions: 119,
                        activeColor: widget.accentColor,
                        inactiveColor: widget.accentColor.withOpacity(0.2),
                        onChanged: (value) {
                          setState(() {
                            _countdownMinutes = value.round();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
              
              // Alarm settings
              const SizedBox(height: 24),
              Divider(
                color: widget.accentColor.withOpacity(0.2),
                thickness: 1,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.alarm,
                        size: 18,
                        color: widget.accentColor.withOpacity(0.8),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Alarm',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.textColor.withOpacity(0.7),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _alarmEnabled,
                    onChanged: (value) {
                      setState(() {
                        _alarmEnabled = value;
                      });
                    },
                    activeColor: widget.accentColor,
                  ),
                ],
              ),
              
              if (_alarmEnabled) ...[
                const SizedBox(height: 16),
                Text(
                  _selectedMode == TimerMode.countdown
                      ? 'Alarm triggers when countdown reaches zero'
                      : 'Alarm Duration',
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.textColor.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
                if (_selectedMode == TimerMode.stopwatch) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPresetButton('5 min', 5, isAlarm: true),
                      _buildPresetButton('15 min', 15, isAlarm: true),
                      _buildPresetButton('25 min', 25, isAlarm: true),
                      _buildPresetButton('30 min', 30, isAlarm: true),
                      _buildPresetButton('60 min', 60, isAlarm: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${_alarmMinutes} min',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: widget.accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _alarmMinutes.toDouble(),
                          min: 1,
                          max: 120,
                          divisions: 119,
                          activeColor: widget.accentColor,
                          inactiveColor: widget.accentColor.withOpacity(0.2),
                          onChanged: (value) {
                            setState(() {
                              _alarmMinutes = value.round();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: widget.textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.setMode(_selectedMode);
                if (_selectedMode == TimerMode.countdown) {
                  provider.setCountdownDuration(Duration(minutes: _countdownMinutes));
                }
                provider.setAlarmEnabled(_alarmEnabled);
                if (_alarmEnabled) {
                  provider.setAlarmDuration(Duration(minutes: _alarmMinutes));
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'SAVE',
                style: TextStyle(
                  color: widget.accentColor,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildModeButton(String label, TimerMode mode, IconData icon) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    widget.accentColor.withOpacity(0.2),
                    widget.accentColor.withOpacity(0.1),
                  ]
                : [
                    widget.accentColor.withOpacity(0.05),
                    widget.accentColor.withOpacity(0.02),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? widget.accentColor.withOpacity(0.5)
                : widget.accentColor.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? widget.accentColor
                  : widget.textColor.withOpacity(0.5),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: isSelected
                    ? widget.accentColor
                    : widget.textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPresetButton(String label, int minutes, {bool isAlarm = false}) {
    final isSelected = isAlarm
        ? _alarmMinutes == minutes
        : _countdownMinutes == minutes;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isAlarm) {
            _alarmMinutes = minutes;
          } else {
            _countdownMinutes = minutes;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? widget.accentColor.withOpacity(0.2)
              : widget.accentColor.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? widget.accentColor.withOpacity(0.5)
                : widget.accentColor.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? widget.accentColor
                : widget.textColor.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
