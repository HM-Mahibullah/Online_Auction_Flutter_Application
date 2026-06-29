import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/antique_model.dart';
import '../data/services/firestore_service.dart';
import '../data/services/storage_service.dart';
import '../data/services/firebase_auth_service.dart';

class AntiqueRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Create antique
  Future<AntiqueModel> createAntique({
    required String title,
    required String description,
    File? imageFile,
    required double basePrice,
    required DateTime bidEndTime,
    required String category,
  }) async {
    try {
      final userId = _authService.currentUserId;
      final userName = _authService.currentUser?.displayName ?? 'Unknown';

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Generate antique ID
      final antiqueId = _firestoreService.antiquesCollection.doc().id;

      // Upload image if provided
      String imageUrl = '';
      
      if (imageFile != null) {
        try {
          imageUrl = await _storageService.uploadAntiqueImage(
            imageFile: imageFile,
            antiqueId: antiqueId,
          );
        } catch (e) {
          // If upload fails, leave empty
          debugPrint('Image upload failed: $e');
        }
      }

      // Create antique model
      final antique = AntiqueModel(
        id: antiqueId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        basePrice: basePrice,
        currentBid: basePrice, // Set currentBid = basePrice for rules
        bidEndTime: bidEndTime,
        curatorId: userId,  // Admin/Curator who added this
        curatorName: userName,
        createdAt: DateTime.now(),
        isActive: true,
        totalBids: 0, // Explicitly set totalBids = 0 for rules
        category: category,
      );

      // Save to Firestore
      await _firestoreService.createAntique(antique);

      return antique;
    } catch (e) {
      throw Exception('Failed to create antique: $e');
    }
  }

  // Get antique by ID
  Future<AntiqueModel?> getAntique(String antiqueId) async {
    try {
      return await _firestoreService.getAntique(antiqueId);
    } catch (e) {
      throw Exception('Failed to get antique: $e');
    }
  }

  // Stream all antiques
  Stream<List<AntiqueModel>> streamAntiques() {
    return _firestoreService.streamAntiques();
  }

  // Stream active antiques
  Stream<List<AntiqueModel>> streamActiveAntiques() {
    return _firestoreService.streamActiveAntiques();
  }

  // Stream antique by ID
  Stream<AntiqueModel?> streamAntique(String antiqueId) {
    return _firestoreService.streamAntique(antiqueId);
  }

  // Get antiques by curator (admin)
  Future<List<AntiqueModel>> getAntiquesByCurator(String curatorId) async {
    try {
      return await _firestoreService.getAntiquesBySeller(curatorId);  // Keep DB method same for compatibility
    } catch (e) {
      throw Exception('Failed to get antiques by seller: $e');
    }
  }

  // Update antique
  Future<void> updateAntique(
    String antiqueId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestoreService.updateAntique(antiqueId, data);
    } catch (e) {
      throw Exception('Failed to update antique: $e');
    }
  }

  // Update antique bid
  Future<void> updateAntiqueBid({
    required String antiqueId,
    required double newBidAmount,
    required String bidderUserId,
    required String bidderName,
  }) async {
    try {
      final antique = await _firestoreService.getAntique(antiqueId);
      if (antique == null) {
        throw Exception('Antique not found');
      }

      await _firestoreService.updateAntique(antiqueId, {
        'currentBid': newBidAmount,
        'currentBidderUserId': bidderUserId,
        'currentBidderName': bidderName,
        'totalBids': antique.totalBids + 1,
      });
    } catch (e) {
      throw Exception('Failed to update antique bid: $e');
    }
  }

  // End auction
  Future<void> endAuction(String antiqueId) async {
    try {
      await _firestoreService.updateAntique(antiqueId, {
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to end auction: $e');
    }
  }

  // Delete antique
  Future<void> deleteAntique(String antiqueId) async {
    try {
      // Delete image from storage
      try {
        await _storageService.deleteAntiqueImage(antiqueId);
      } catch (e) {
        debugPrint('Failed to delete image: $e');
      }

      // Mark as inactive (safer than actual deletion)
      await _firestoreService.updateAntique(antiqueId, {
        'isActive': false,
        'bidEndTime': DateTime.now(), // End the auction immediately
      });
    } catch (e) {
      throw Exception('Failed to delete antique: $e');
    }
  }

  // Check if user can add antiques (all authenticated users)
  Future<bool> canAddAntiques(String userId) async {
    try {
      final user = await _firestoreService.getUser(userId);
      // Only users with isAdmin == true should have add/manage permissions
      return user?.isAdmin ?? false;
    } catch (e) {
      return false;
    }
  }
}
