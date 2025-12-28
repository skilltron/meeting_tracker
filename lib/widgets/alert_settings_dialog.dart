import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ui_provider.dart';

class AlertSettingsDialog extends StatelessWidget {
  const AlertSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UIProvider>(
      builder: (context, uiProvider, child) {
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
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'ALERT SETTINGS',
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
                
                // Visual Alerts
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFA8D5BA).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visual Alerts',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB8D4E3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Flashing and opacity changes',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFB8D4E3).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: uiProvider.visualAlertsEnabled,
                        onChanged: (value) => uiProvider.setVisualAlerts(value),
                        activeColor: const Color(0xFFA8D5BA),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Audio Alerts
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFA8D5BA).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Audio Alerts',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB8D4E3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sound notifications',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFB8D4E3).withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: uiProvider.audioAlertsEnabled,
                        onChanged: (value) => uiProvider.setAudioAlerts(value),
                        activeColor: const Color(0xFFA8D5BA),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Info text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA8D5BA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Tip: You can enable both, one, or neither. Alerts only activate when a meeting is within 10 minutes.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB8D4E3),
                      height: 1.4,
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
}
