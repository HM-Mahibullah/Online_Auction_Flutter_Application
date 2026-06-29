import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload antique image
  Future<String> uploadAntiqueImage({
    required File imageFile,
    required String antiqueId,
  }) async {
    try {
      final fileName = '${antiqueId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('antique_images/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload user profile image
  Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final fileName = '${userId}_profile.jpg';
      final ref = _storage.ref().child('profile_images/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Delete image by URL
  Future<void> deleteImageByUrl(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Delete antique image
  Future<void> deleteAntiqueImage(String antiqueId) async {
    try {
      final listResult = await _storage.ref().child('antique_images').listAll();
      
      for (var item in listResult.items) {
        if (item.name.contains(antiqueId)) {
          await item.delete();
        }
      }
    } catch (e) {
      throw Exception('Failed to delete antique image: $e');
    }
  }

  // Get download URL from path
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }
}
