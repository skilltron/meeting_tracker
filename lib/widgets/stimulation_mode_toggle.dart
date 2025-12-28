import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ui_provider.dart';

class StimulationModeToggle extends StatelessWidget {
  const StimulationModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UIProvider>(
      builder: (context, uiProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFA8D5BA).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ADHD label
              GestureDetector(
                onTap: () => uiProvider.setLowStimulationMode(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: !uiProvider.lowStimulationMode
                        ? const Color(0xFFA8D5BA).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'ADHD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: !uiProvider.lowStimulationMode
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: !uiProvider.lowStimulationMode
                          ? const Color(0xFFA8D5BA)
                          : const Color(0xFFB8D4E3).withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              // Cozy label
              GestureDetector(
                onTap: () => uiProvider.setLowStimulationMode(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: uiProvider.lowStimulationMode
                        ? const Color(0xFFA8D5BA).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Cozy',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: uiProvider.lowStimulationMode
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: uiProvider.lowStimulationMode
                          ? const Color(0xFFA8D5BA)
                          : const Color(0xFFB8D4E3).withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
