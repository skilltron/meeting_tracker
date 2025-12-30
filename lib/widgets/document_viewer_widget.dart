import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';

class DocumentViewerWidget extends StatefulWidget {
  final Color textColor;
  final Color accentColor;
  
  const DocumentViewerWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  State<DocumentViewerWidget> createState() => _DocumentViewerWidgetState();
}

class _DocumentViewerWidgetState extends State<DocumentViewerWidget> {
  String? _documentPath;
  String? _documentContent;
  DocumentType? _documentType;
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
              Row(
                children: [
                  // Open file button
                  GestureDetector(
                    onTap: _openFile,
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
                            Icons.folder_open,
                            size: 14,
                            color: widget.accentColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'OPEN FILE',
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
            ],
          ),
          const SizedBox(height: 16),
          
          // Document viewer
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: widget.accentColor,
                    ),
                  )
                : _documentContent == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description,
                              size: 64,
                              color: widget.accentColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Document Viewer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: widget.textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Open a PDF, HTML, or Markdown file',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.textColor.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Supported formats:\n• PDF\n• HTML\n• Markdown (.md)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: widget.textColor.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildDocumentView(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDocumentView() {
    switch (_documentType) {
      case DocumentType.html:
        return _buildHtmlView();
      case DocumentType.markdown:
        return _buildMarkdownView();
      case DocumentType.pdf:
        return _buildPdfView();
      default:
        return Center(
          child: Text(
            'Unsupported document type',
            style: TextStyle(color: widget.textColor),
          ),
        );
    }
  }
  
  Widget _buildHtmlView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HTML content rendered as text (for now - could use webview_flutter for full HTML)
            SelectableText(
              _documentContent!,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMarkdownView() {
    // Simple markdown rendering (could use flutter_markdown package for full support)
    final lines = _documentContent!.split('\n');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: lines.map((line) {
            return _buildMarkdownLine(line);
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildMarkdownLine(String line) {
    // Simple markdown parsing
    if (line.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(
          line.substring(2),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: widget.accentColor,
          ),
        ),
      );
    } else if (line.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(
          line.substring(3),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: widget.accentColor,
          ),
        ),
      );
    } else if (line.startsWith('### ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: Text(
          line.substring(4),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: widget.textColor,
          ),
        ),
      );
    } else if (line.startsWith('- ') || line.startsWith('* ')) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ', style: TextStyle(color: widget.accentColor)),
            Expanded(
              child: Text(
                line.substring(2),
                style: TextStyle(
                  fontSize: 12,
                  color: widget.textColor,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (line.trim().isEmpty) {
      return const SizedBox(height: 8);
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Text(
          line,
          style: TextStyle(
            fontSize: 12,
            color: widget.textColor,
          ),
        ),
      );
    }
  }
  
  Widget _buildPdfView() {
    return Center(
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
            'PDF Viewer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PDF viewing requires external viewer',
            style: TextStyle(
              fontSize: 12,
              color: widget.textColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          if (_documentPath != null && !kIsWeb)
            ElevatedButton(
              onPressed: () async {
                try {
                  final uri = Uri.file(_documentPath!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                } catch (e) {
                  debugPrint('Error opening PDF: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accentColor.withOpacity(0.2),
                foregroundColor: widget.accentColor,
              ),
              child: Text('Open in External Viewer'),
            ),
        ],
      ),
    );
  }
  
  Future<void> _openFile() async {
    if (kIsWeb) {
      // On web, show a message that file picking is limited
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File picking on web is limited. Please use desktop/mobile for full file access.'),
          backgroundColor: widget.accentColor.withOpacity(0.8),
        ),
      );
      return;
    }
    
    // For desktop/mobile, would use file_picker package
    // For now, show a dialog to enter file path
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Open Document',
          style: TextStyle(color: widget.accentColor),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: widget.textColor),
          decoration: InputDecoration(
            labelText: 'File Path',
            labelStyle: TextStyle(color: widget.textColor.withOpacity(0.6)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.accentColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.accentColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: widget.textColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Open', style: TextStyle(color: widget.accentColor)),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty) {
      await _loadDocument(result);
    }
  }
  
  Future<void> _loadDocument(String path) async {
    setState(() {
      _isLoading = true;
      _documentPath = path;
    });
    
    try {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File not found');
      }
      
      // Determine document type
      if (path.toLowerCase().endsWith('.html') || path.toLowerCase().endsWith('.htm')) {
        _documentType = DocumentType.html;
      } else if (path.toLowerCase().endsWith('.md') || path.toLowerCase().endsWith('.markdown')) {
        _documentType = DocumentType.markdown;
      } else if (path.toLowerCase().endsWith('.pdf')) {
        _documentType = DocumentType.pdf;
      } else {
        throw Exception('Unsupported file type');
      }
      
      // Read file content (for HTML and Markdown)
      if (_documentType == DocumentType.html || _documentType == DocumentType.markdown) {
        _documentContent = await file.readAsString();
      } else {
        _documentContent = 'PDF file loaded';
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _documentContent = null;
        _documentType = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

enum DocumentType {
  pdf,
  html,
  markdown,
}
