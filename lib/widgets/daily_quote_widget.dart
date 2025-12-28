import 'package:flutter/material.dart';

class DailyQuoteWidget extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  
  const DailyQuoteWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Get quote based on day of year
    final today = DateTime.now();
    final startOfYear = DateTime(today.year, 1, 1);
    final dayOfYear = today.difference(startOfYear).inDays;
    
    final quotes = _getQuotes();
    final quote = quotes[dayOfYear % quotes.length];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
        children: [
          Text(
            '"${quote['text']}"',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: textColor.withOpacity(0.95),
              letterSpacing: 0.4,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '— ${quote['author']}',
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.65),
              letterSpacing: 1.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  List<Map<String, String>> _getQuotes() {
    return [
      {'text': 'Gratitude turns what we have into enough.', 'author': 'Anonymous'},
      {'text': 'The only way to do great work is to love what you do.', 'author': 'Steve Jobs'},
      // Add more quotes as needed
    ];
  }
}
