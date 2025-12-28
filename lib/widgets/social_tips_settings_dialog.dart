import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_tips_provider.dart';
import '../models/social_tip.dart';

class SocialTipsSettingsDialog extends StatefulWidget {
  const SocialTipsSettingsDialog({super.key});

  @override
  State<SocialTipsSettingsDialog> createState() => _SocialTipsSettingsDialogState();
}

class _SocialTipsSettingsDialogState extends State<SocialTipsSettingsDialog> {
  String? _selectedCategory;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<SocialTipsProvider>(
      builder: (context, tipsProvider, child) {
        final categories = SocialTip.getAllCategories();
        final allTips = tipsProvider.allTips;
        final selectedIds = tipsProvider.selectedTipIds;
        
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
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'ADHD SOCIAL TIPS',
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
                
                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Select All',
                        () => tipsProvider.selectAllTips(),
                        const Color(0xFFA8D5BA),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        'Deselect All',
                        () => tipsProvider.deselectAllTips(),
                        const Color(0xFFB8D4E3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Category filter
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
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1A2E),
                    style: const TextStyle(color: Color(0xFFB8D4E3), fontSize: 12),
                    hint: const Text(
                      'Filter by Category (optional)',
                      style: TextStyle(color: Color(0xFFB8D4E3), fontSize: 12),
                    ),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...categories.map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                      if (value != null) {
                        tipsProvider.selectByCategory(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 15),
                
                // Tips list
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allTips.length,
                    itemBuilder: (context, index) {
                      final tip = allTips[index];
                      if (_selectedCategory != null && tip.category != _selectedCategory) {
                        return const SizedBox.shrink();
                      }
                      
                      final isSelected = selectedIds.contains(tip.id);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFA8D5BA).withOpacity(0.1)
                              : const Color(0xFF1A1A2E).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFA8D5BA).withOpacity(0.4)
                                : const Color(0xFFA8D5BA).withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Checkbox
                            GestureDetector(
                              onTap: () => tipsProvider.toggleTipSelection(tip.id),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFA8D5BA)
                                        : const Color(0xFFA8D5BA).withOpacity(0.5),
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? const Color(0xFFA8D5BA).withOpacity(0.3)
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 12,
                                        color: Color(0xFFA8D5BA),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Tip content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tip.mnemonic,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFFA8D5BA)
                                          : const Color(0xFFB8D4E3),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tip.tip,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: const Color(0xFFB8D4E3).withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tip.category,
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: const Color(0xFFB8D4E3).withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 15),
                
                // Auto-shuffle settings
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Auto Shuffle',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB8D4E3),
                            ),
                          ),
                          Switch(
                            value: tipsProvider.autoShuffle,
                            onChanged: (value) => tipsProvider.setAutoShuffle(value),
                            activeColor: const Color(0xFFA8D5BA),
                          ),
                        ],
                      ),
                      if (tipsProvider.autoShuffle) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Interval (seconds)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFB8D4E3),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Color(0xFFB8D4E3),
                                  fontSize: 12,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: const Color(0xFFA8D5BA).withOpacity(0.4),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                ),
                                onChanged: (value) {
                                  final seconds = int.tryParse(value);
                                  if (seconds != null && seconds > 0) {
                                    tipsProvider.setShuffleInterval(seconds);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildActionButton(String label, VoidCallback onPressed, Color color) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
