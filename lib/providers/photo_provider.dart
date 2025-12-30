import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class PhotoProvider with ChangeNotifier {
  final List<Photo> _photos = [];
  final ImagePicker _imagePicker = ImagePicker();
  
  // Getters
  List<Photo> get photos => List.unmodifiable(_photos);
  List<Photo> get photosByDate {
    final sorted = List<Photo>.from(_photos);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }
  
  PhotoProvider() {
    _loadPhotos();
  }
  
  // Pick image from gallery or camera
  Future<Photo?> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (pickedFile == null) return null;
      
      final photo = Photo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        path: pickedFile.path,
        url: kIsWeb ? pickedFile.path : null, // On web, path is the URL
        createdAt: DateTime.now(),
      );
      
      _photos.add(photo);
      await _savePhotos();
      notifyListeners();
      return photo;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }
  
  // Add photo from file path (for importing)
  Future<Photo> addPhotoFromPath(String path, {String? title, String? description}) async {
    final photo = Photo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: path,
      url: kIsWeb ? path : null,
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    
    _photos.add(photo);
    await _savePhotos();
    notifyListeners();
    return photo;
  }
  
  // Update photo metadata
  Future<void> updatePhoto(String id, {String? title, String? description}) async {
    final index = _photos.indexWhere((p) => p.id == id);
    if (index != -1) {
      _photos[index] = _photos[index].copyWith(
        title: title,
        description: description,
        modifiedAt: DateTime.now(),
      );
      await _savePhotos();
      notifyListeners();
    }
  }
  
  // Delete photo
  Future<bool> deletePhoto(String id) async {
    try {
      final photo = _photos.firstWhere((p) => p.id == id);
      
      // Delete file if it exists (not on web)
      if (!kIsWeb && photo.path.isNotEmpty) {
        try {
          final file = File(photo.path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          debugPrint('Error deleting file: $e');
        }
      }
      
      _photos.removeWhere((p) => p.id == id);
      await _savePhotos();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return false;
    }
  }
  
  // Get photo by ID
  Photo? getPhotoById(String id) {
    try {
      return _photos.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Save photos to SharedPreferences
  Future<void> _savePhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photosJson = _photos.map((p) => p.toJson()).toList();
      await prefs.setString('photos', jsonEncode(photosJson));
    } catch (e) {
      debugPrint('Error saving photos: $e');
    }
  }
  
  // Load photos from SharedPreferences
  Future<void> _loadPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photosJson = prefs.getString('photos');
      if (photosJson != null) {
        final json = jsonDecode(photosJson) as List;
        _photos.clear();
        _photos.addAll(json.map((j) => Photo.fromJson(j)));
        
        // On non-web platforms, verify files still exist
        if (!kIsWeb) {
          _photos.removeWhere((photo) {
            try {
              final file = File(photo.path);
              return !file.existsSync();
            } catch (e) {
              return true; // Remove if path is invalid
            }
          });
          await _savePhotos();
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading photos: $e');
    }
  }
}
