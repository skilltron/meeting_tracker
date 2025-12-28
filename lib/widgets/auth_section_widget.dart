import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calendar_provider.dart';

class AuthSectionWidget extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  
  const AuthSectionWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, child) {
        return Column(
          children: [
            _buildAuthButton(
              'CONNECT GMAIL',
              calendarProvider.isGoogleConnected,
              () => calendarProvider.connectGoogle(),
            ),
            const SizedBox(height: 5),
            _buildAuthButton(
              'CONNECT OUTLOOK',
              calendarProvider.isOutlookConnected,
              () => calendarProvider.connectOutlook(),
            ),
            const SizedBox(height: 5),
            _buildAuthButton(
              'CONNECT ONEDRIVE',
              calendarProvider.isOneDriveConnected,
              () => calendarProvider.connectOneDrive(),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildAuthButton(String label, bool isConnected, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isConnected
                ? accentColor.withOpacity(0.2)
                : Colors.transparent,
            border: Border.all(
              color: isConnected ? accentColor : accentColor.withOpacity(0.4),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(isConnected ? 0.2 : 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isConnected ? accentColor : textColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
