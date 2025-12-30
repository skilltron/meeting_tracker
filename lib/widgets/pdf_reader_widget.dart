import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PDFReaderWidget extends StatefulWidget {
  final Color textColor;
  final Color accentColor;
  
  const PDFReaderWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  State<PDFReaderWidget> createState() => _PDFReaderWidgetState();
}

class _PDFReaderWidgetState extends State<PDFReaderWidget> {
  String? _pdfPath;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.9),
            const Color(0xFF1F2A4A).withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: widget.accentColor.withOpacity(0.35),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DOCUMENTATION',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: widget.accentColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _openPDFFile();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.accentColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 14,
                        color: widget.accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'OPEN PDF',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: widget.accentColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Quick link to project documentation
          GestureDetector(
            onTap: () async {
              if (kIsWeb) {
                // On web, can't access local files directly
                // Could open a URL or use file picker
                return;
              }
              // Try to find the PDF in the project (desktop/mobile only)
              final pdfPath = _findProjectPDF();
              if (pdfPath != null) {
                try {
                  final uri = Uri.file(pdfPath);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                } catch (e) {
                  debugPrint('Error opening PDF: $e');
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.accentColor.withOpacity(0.2),
                    widget.accentColor.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: widget.accentColor.withOpacity(0.4),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 24,
                    color: widget.accentColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reaction Modeler Project Documentation',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: widget.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete project documentation and specifications',
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 20,
                    color: widget.accentColor,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // PDF viewer placeholder
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 64,
                    color: widget.accentColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PDF Reader',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a PDF file to view',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.textColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _openPDFFile() {
    // TODO: Implement file picker for PDF selection
  }
  
  String? _findProjectPDF() {
    if (kIsWeb) return null; // Can't access local files on web
    
    // Look for Reaction-Modeler-Project-Documentation.pdf (desktop/mobile only)
    // This would require dart:io which isn't available on web
    // For now, return null on web
    return null;
  }
}
