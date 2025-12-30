import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import '../models/photo.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class PhotoViewerWidget extends StatelessWidget {
  final Photo photo;
  final Color textColor;
  final Color accentColor;
  
  const PhotoViewerWidget({
    super.key,
    required this.photo,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          photo.title ?? 'Photo',
          style: TextStyle(color: textColor),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: accentColor),
            onPressed: () => _sharePhoto(context),
            tooltip: 'Share',
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: accentColor),
            onPressed: () => _showPhotoInfo(context),
            tooltip: 'Info',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Photo viewer
          Center(
            child: kIsWeb
                ? (photo.url != null
                    ? PhotoView(
                        imageProvider: NetworkImage(photo.url!),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                        backgroundDecoration: const BoxDecoration(color: Colors.black),
                      )
                    : Center(
                        child: Text(
                          'Image not available',
                          style: TextStyle(color: textColor),
                        ),
                      ))
                : (File(photo.path).existsSync()
                    ? PhotoView(
                        imageProvider: FileImage(File(photo.path)),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                        backgroundDecoration: const BoxDecoration(color: Colors.black),
                      )
                    : Center(
                        child: Text(
                          'Image not found',
                          style: TextStyle(color: textColor),
                        ),
                      )),
          ),
          
          // Description overlay (if exists)
          if (photo.description != null && photo.description!.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  photo.description!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Future<void> _sharePhoto(BuildContext context) async {
    try {
      if (kIsWeb) {
        // On web, share the URL if available
        if (photo.url != null) {
          await Share.share(photo.url!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot share: URL not available'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // On mobile/desktop, share the file
        if (File(photo.path).existsSync()) {
          await Share.shareXFiles(
            [XFile(photo.path)],
            text: photo.title ?? 'Photo',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot share: File not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showPhotoInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photo Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            if (photo.title != null && photo.title!.isNotEmpty) ...[
              _buildInfoRow('Title', photo.title!, context),
              const SizedBox(height: 8),
            ],
            if (photo.description != null && photo.description!.isNotEmpty) ...[
              _buildInfoRow('Description', photo.description!, context),
              const SizedBox(height: 8),
            ],
            _buildInfoRow('Created', _formatDate(photo.createdAt), context),
            if (photo.modifiedAt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Modified', _formatDate(photo.modifiedAt!), context),
            ],
            const SizedBox(height: 8),
            _buildInfoRow('Path', photo.path, context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: textColor.withOpacity(0.5),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
          ),
        ),
      ],
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
