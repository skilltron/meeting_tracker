import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_tips_provider.dart';
import '../providers/usage_tracker_provider.dart';
import '../models/social_tip.dart';
import 'social_tips_settings_dialog.dart';

class SocialTipsWidget extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  
  const SocialTipsWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialTipsProvider>(
      builder: (context, tipsProvider, child) {
        final currentTip = tipsProvider.currentTip;
        
        if (currentTip == null) {
          return const SizedBox.shrink();
        }
        
        return GestureDetector(
          onTap: () {
            final usageTracker = Provider.of<UsageTrackerProvider>(context, listen: false);
            usageTracker.trackUsage(FeatureType.socialTips, context: 'shuffle');
            tipsProvider.shuffleTip();
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => const SocialTipsSettingsDialog(),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                color: accentColor.withOpacity(0.25),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ADHD SOCIAL TIP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => const SocialTipsSettingsDialog(),
                            );
                          },
                          child: Icon(
                            Icons.settings,
                            size: 14,
                            color: accentColor.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => tipsProvider.shuffleTip(),
                          child: Icon(
                            Icons.shuffle,
                            size: 14,
                            color: accentColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  currentTip.mnemonic,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                    letterSpacing: 0.6,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentTip.tip,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.9),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentTip.explanation,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: textColor.withOpacity(0.65),
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    currentTip.category,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: accentColor.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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
