import 'package:flutter/material.dart';

class MoonPhaseWidget extends StatelessWidget {
  final Color textColor;
  
  const MoonPhaseWidget({
    super.key,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final moonPhase = _calculateMoonPhase();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.6),
            const Color(0xFF1F2A4A).withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA8D5BA).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA8D5BA).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: const Color(0xFFA8D5BA).withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            moonPhase,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.9),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
  
  String _calculateMoonPhase() {
    // Simplified moon phase calculation
    final now = DateTime.now();
    final knownNewMoon = DateTime(2024, 1, 11);
    final daysSinceNewMoon = now.difference(knownNewMoon).inDays % 30;
    final phase = daysSinceNewMoon / 30.0;
    
    if (phase < 0.03 || phase > 0.97) return 'New Moon';
    if (phase < 0.22) return 'Waxing Crescent';
    if (phase < 0.28) return 'First Quarter';
    if (phase < 0.47) return 'Waxing Gibbous';
    if (phase < 0.53) return 'Full Moon';
    if (phase < 0.72) return 'Waning Gibbous';
    if (phase < 0.78) return 'Last Quarter';
    return 'Waning Crescent';
  }
}
