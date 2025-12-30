import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/photo_provider.dart';
import '../models/photo.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'photo_viewer_widget.dart';

class PhotoLibraryWidget extends StatelessWidget {
  final Color textColor;
  final Color accentColor;
  
  const PhotoLibraryWidget({
    super.key,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoProvider>(
      builder: (context, photoProvider, child) {
        final photos = photoProvider.photosByDate;
        
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
              color: accentColor.withOpacity(0.35),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PHOTO LIBRARY',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: accentColor,
                    ),
                  ),
                  Row(
                    children: [
                      // Add from gallery
                      GestureDetector(
                        onTap: () async {
                          await photoProvider.pickImage(fromCamera: false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: accentColor.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library,
                                size: 14,
                                color: accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'GALLERY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Add from camera
                      GestureDetector(
                        onTap: () async {
                          await photoProvider.pickImage(fromCamera: true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: accentColor.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: accentColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'CAMERA',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
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
              
              // Photo grid
              Expanded(
                child: photos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 64,
                              color: textColor.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No photos yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add photos from gallery or camera',
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          return _buildPhotoThumbnail(context, photos[index], photoProvider);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPhotoThumbnail(BuildContext context, Photo photo, PhotoProvider provider) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PhotoViewerWidget(
              photo: photo,
              textColor: textColor,
              accentColor: accentColor,
            ),
          ),
        );
      },
      onLongPress: () {
        _showPhotoOptions(context, photo, provider);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: accentColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              kIsWeb
                  ? (photo.url != null
                      ? Image.network(
                          photo.url!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF1A1A2E),
                              child: Icon(
                                Icons.broken_image,
                                color: textColor.withOpacity(0.3),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFF1A1A2E),
                          child: Icon(
                            Icons.image,
                            color: textColor.withOpacity(0.3),
                          ),
                        ))
                  : (File(photo.path).existsSync()
                      ? Image.file(
                          File(photo.path),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF1A1A2E),
                              child: Icon(
                                Icons.broken_image,
                                color: textColor.withOpacity(0.3),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFF1A1A2E),
                          child: Icon(
                            Icons.image,
                            color: textColor.withOpacity(0.3),
                          ),
                        )),
              // Overlay gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Title if exists
              if (photo.title != null && photo.title!.isNotEmpty)
                Positioned(
                  bottom: 4,
                  left: 4,
                  right: 4,
                  child: Text(
                    photo.title!,
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showPhotoOptions(BuildContext context, Photo photo, PhotoProvider provider) {
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
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: accentColor),
              title: Text(
                'Edit Info',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, photo, provider);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1A1A2E),
                    title: Text(
                      'Delete Photo?',
                      style: TextStyle(color: textColor),
                    ),
                    content: Text(
                      'This action cannot be undone.',
                      style: TextStyle(color: textColor.withOpacity(0.7)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel', style: TextStyle(color: textColor)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await provider.deletePhoto(photo.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEditDialog(BuildContext context, Photo photo, PhotoProvider provider) {
    final titleController = TextEditingController(text: photo.title ?? '');
    final descriptionController = TextEditingController(text: photo.description ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(
          'Edit Photo Info',
          style: TextStyle(color: accentColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: accentColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: accentColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: textColor)),
          ),
          TextButton(
            onPressed: () {
              provider.updatePhoto(
                photo.id,
                title: titleController.text.isEmpty ? null : titleController.text,
                description: descriptionController.text.isEmpty ? null : descriptionController.text,
              );
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }
}
