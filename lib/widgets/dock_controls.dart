import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ui_provider.dart';
import 'alert_settings_dialog.dart';
// import 'vagus_reminder_settings_dialog.dart'; // TODO: Re-enable when file exists

class DockControls extends StatefulWidget {
  const DockControls({super.key});

  @override
  State<DockControls> createState() => _DockControlsState();
}

class _DockControlsState extends State<DockControls> {
  bool _showMenu = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<UIProvider>(
      builder: (context, uiProvider, child) {
        return Stack(
          children: [
            // Dock button
            GestureDetector(
              onTap: () {
                setState(() {
                _showMenu = !_showMenu;
              });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withOpacity(0.8),
                  border: Border.all(
                    color: const Color(0xFFA8D5BA).withOpacity(0.4),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA8D5BA).withOpacity(0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Text(
                  '⚓',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFA8D5BA),
                  ),
                ),
              ),
            ),
            
            // Menu
            if (_showMenu)
              Positioned(
                top: 40,
                right: 0,
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withOpacity(0.95),
                    border: Border.all(
                      color: const Color(0xFFA8D5BA).withOpacity(0.4),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFA8D5BA).withOpacity(0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDockOption('→ Right', DockPosition.right, uiProvider),
                      _buildDockOption('← Left', DockPosition.left, uiProvider),
                      _buildDockOption('↑ Top', DockPosition.top, uiProvider),
                      _buildDockOption('↓ Bottom', DockPosition.bottom, uiProvider),
                      _buildDockOption('▬ Taskbar', DockPosition.taskbar, uiProvider),
                      _buildDockOption('○ Floating', DockPosition.floating, uiProvider),
                      _buildDockOption('🔲 Overlay', DockPosition.overlay, uiProvider),
                    _buildDockOption('📌 Edge', DockPosition.edge, uiProvider),
                    _buildDockOption('🪞 Mirror', DockPosition.mirror, uiProvider),
                    const Divider(color: Color(0xFFA8D5BA), height: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() => _showMenu = false);
                        showDialog(
                          context: context,
                          builder: (context) => const AlertSettingsDialog(),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.settings,
                              size: 14,
                              color: Color(0xFFB8D4E3),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Alert Settings',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB8D4E3),
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // TODO: Re-enable when VagusReminderSettingsDialog exists
                    // GestureDetector(
                    //   onTap: () {
                    //     setState(() => _showMenu = false);
                    //     showDialog(
                    //       context: context,
                    //       builder: (context) => const VagusReminderSettingsDialog(),
                    //     );
                    //   },
                    //   child: Container(
                    //     width: double.infinity,
                    //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    //     child: Row(
                    //       children: [
                    //         const Icon(
                    //           Icons.favorite,
                    //           size: 14,
                    //           color: Color(0xFFB8D4E3),
                    //         ),
                    //         const SizedBox(width: 8),
                    //         const Text(
                    //           'Vagus Reminder',
                    //           style: TextStyle(
                    //             fontSize: 12,
                    //             color: Color(0xFFB8D4E3),
                    //             fontWeight: FontWeight.w400,
                    //             letterSpacing: 0.5,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildDockOption(String label, DockPosition position, UIProvider uiProvider) {
    final isActive = uiProvider.dockPosition == position;
    return GestureDetector(
      onTap: () {
        uiProvider.setDockPosition(position);
        setState(() {
          _showMenu = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFA8D5BA).withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? const Color(0xFFA8D5BA)
                : const Color(0xFFB8D4E3),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
