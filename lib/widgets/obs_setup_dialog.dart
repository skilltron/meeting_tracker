import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/obs_provider.dart';

/// Grandmother-simple OBS setup dialog
/// Guides users through downloading and setting up OBS
class OBSSetupDialog extends StatelessWidget {
  const OBSSetupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFFE0E0E0);
    final accentColor = const Color(0xFFA8D5BA);
    
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: accentColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'SET UP RECORDING',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: accentColor,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Step 1: Download OBS
            _buildStep(
              context,
              stepNumber: 1,
              title: 'Download OBS Studio',
              description: 'OBS Studio is free recording software',
              buttonText: 'DOWNLOAD OBS',
              onPressed: () => _downloadOBS(context),
              textColor: textColor,
              accentColor: accentColor,
            ),
            const SizedBox(height: 16),
            
            // Step 2: Install and Start
            _buildStep(
              context,
              stepNumber: 2,
              title: 'Install and Start OBS',
              description: 'Install OBS, then open it',
              textColor: textColor,
              accentColor: accentColor,
            ),
            const SizedBox(height: 16),
            
            // Step 3: Enable WebSocket
            _buildStep(
              context,
              stepNumber: 3,
              title: 'Enable WebSocket in OBS',
              description: 'OBS → Tools → WebSocket Server Settings → Enable (port 4455)',
              textColor: textColor,
              accentColor: accentColor,
            ),
            const SizedBox(height: 24),
            
            // Connect button
            Consumer<OBSProvider>(
              builder: (context, obsProvider, child) {
                return SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final connected = await obsProvider.connect();
                      if (connected && context.mounted) {
                        // Auto-configure OBS
                        await obsProvider.autoConfigure();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Could not connect to OBS. Make sure OBS is running and WebSocket is enabled.',
                              style: TextStyle(color: textColor),
                            ),
                            backgroundColor: Colors.red.withOpacity(0.8),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      'CONNECT & AUTO-SETUP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStep(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String description,
    String? buttonText,
    VoidCallback? onPressed,
    required Color textColor,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: textColor.withOpacity(0.7),
              ),
            ),
          ),
          if (buttonText != null && onPressed != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor.withOpacity(0.2),
                    foregroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(buttonText),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Future<void> _downloadOBS(BuildContext context) async {
    // Detect platform and open appropriate download page
    final uri = Uri.parse('https://obsproject.com/download');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open download page'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
