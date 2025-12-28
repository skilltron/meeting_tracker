import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/breathing_provider.dart';
import '../providers/usage_tracker_provider.dart';
import 'breathing_settings_dialog.dart';

class BreathingExerciseWidget extends StatefulWidget {
  final Color textColor;
  final Color accentColor;
  
  const BreathingExerciseWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  State<BreathingExerciseWidget> createState() => _BreathingExerciseWidgetState();
}

class _BreathingExerciseWidgetState extends State<BreathingExerciseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _updateAnimation(BreathingProvider provider) {
    if (!provider.isActive) {
      _animationController.stop();
      _animationController.reset();
      return;
    }
    
    final progress = provider.phaseProgress / 100.0;
    final phase = provider.currentPhase;
    
    switch (phase) {
      case BreathingPhase.inhale:
        // Expand during inhale
        _animationController.value = progress;
        break;
      case BreathingPhase.hold:
        // Stay at full size during hold
        _animationController.value = 1.0;
        break;
      case BreathingPhase.exhale:
        // Contract during exhale
        _animationController.value = 1.0 - progress;
        break;
      case BreathingPhase.pause:
        // Stay small during pause
        _animationController.value = 0.3;
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<BreathingProvider>(
      builder: (context, provider, child) {
        // Update animation based on provider state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateAnimation(provider);
        });
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A2E).withOpacity(0.7),
                const Color(0xFF1F2A4A).withOpacity(0.5),
              ],
            ),
            border: Border.all(
              color: widget.accentColor.withOpacity(0.25),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.08),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BREATHING EXERCISE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: widget.textColor.withOpacity(0.7),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const BreathingSettingsDialog(),
                          );
                        },
                        child: Icon(
                          Icons.settings,
                          size: 16,
                          color: widget.accentColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          final usageTracker = Provider.of<UsageTrackerProvider>(context, listen: false);
                          usageTracker.trackUsage(FeatureType.breathing, context: provider.isActive ? 'stop' : 'start');
                          if (provider.isActive) {
                            provider.stop();
                          } else {
                            provider.start();
                          }
                        },
                        child: Icon(
                          provider.isActive ? Icons.pause : Icons.play_arrow,
                          size: 16,
                          color: widget.accentColor,
                        ),
                      ),
                      if (provider.isActive) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => provider.reset(),
                          child: Icon(
                            Icons.stop,
                            size: 16,
                            color: widget.accentColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Breathing circle
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  final phaseColor = _getPhaseColor(provider.currentPhase);
                  return Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: phaseColor.withOpacity(0.5),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: phaseColor.withOpacity(0.25),
                          blurRadius: 24,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: phaseColor.withOpacity(0.15),
                          blurRadius: 40,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                phaseColor.withOpacity(0.3),
                                phaseColor.withOpacity(0.1),
                                phaseColor.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Phase label and progress
              if (provider.isActive) ...[
                Text(
                  provider.currentPhaseLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getPhaseColor(provider.currentPhase),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.currentPhaseDuration - (provider.phaseProgress * provider.currentPhaseDuration / 100).round()}s',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar
                Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.textColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: provider.phaseProgress / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getPhaseColor(provider.currentPhase),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                if (provider.cycleCount > 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Cycle ${provider.cycleCount}',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.textColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  'Tap play to start',
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.textColor.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${provider.settings.inhaleSeconds}-${provider.settings.holdSeconds}-${provider.settings.exhaleSeconds}',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.textColor.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  Color _getPhaseColor(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return const Color(0xFFA8D5BA); // Green for inhale
      case BreathingPhase.hold:
        return const Color(0xFFB8D4E3); // Blue for hold
      case BreathingPhase.exhale:
        return const Color(0xFFD4A5A5); // Soft red/pink for exhale
      case BreathingPhase.pause:
        return widget.textColor.withOpacity(0.5);
    }
  }
}
