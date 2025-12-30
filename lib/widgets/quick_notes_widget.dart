import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';

class QuickNotesWidget extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  final double opacity;
  
  const QuickNotesWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        // Only show if there's room (check screen size)
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        
        // Hide on very small screens
        if (screenHeight < 600 || screenWidth < 400) {
          return const SizedBox.shrink();
        }
        
        return Positioned(
          left: 10,
          bottom: 10,
          child: Opacity(
            opacity: opacity,
            child: GestureDetector(
              onTap: () => notesProvider.toggleExpanded(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: notesProvider.isExpanded ? 250 : 180,
                height: notesProvider.isExpanded ? 180 : 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A2E).withOpacity(0.95),
                      const Color(0xFF1F2A4A).withOpacity(0.85),
                    ],
                  ),
                  border: Border.all(
                    color: accentColor.withOpacity(0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: notesProvider.isExpanded
                    ? _buildExpandedView(context, notesProvider)
                    : _buildCollapsedView(notesProvider),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCollapsedView(NotesProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        provider.notes.isEmpty
            ? 'Notes'
            : provider.notes.length > 18
                ? '${provider.notes.substring(0, 18)}...'
                : provider.notes,
        style: TextStyle(
          fontSize: 10,
          fontFamily: 'Lucida Sans',
          color: provider.notes.isEmpty
              ? textColor.withOpacity(0.4)
              : textColor.withOpacity(0.7),
          fontStyle: provider.notes.isEmpty
              ? FontStyle.italic
              : FontStyle.normal,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
  
  Widget _buildExpandedView(BuildContext context, NotesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Minimal header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: accentColor.withOpacity(0.15),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NOTES',
                style: TextStyle(
                  fontSize: 8,
                  fontFamily: 'Lucida Sans',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: textColor.withOpacity(0.5),
                ),
              ),
              GestureDetector(
                onTap: () => provider.setExpanded(false),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
        // Text field - simple notepad style
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: TextField(
              controller: TextEditingController(text: provider.notes)
                ..selection = TextSelection.collapsed(
                  offset: provider.notes.length,
                ),
              onChanged: (value) => provider.updateNotes(value),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Lucida Sans',
                color: textColor,
                height: 1.3,
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '...',
                hintStyle: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Lucida Sans',
                  color: textColor.withOpacity(0.3),
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
