import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/antique_model.dart';
import '../models/bid_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get antiquesCollection => _firestore.collection('antiques');
  CollectionReference get bidsCollection => _firestore.collection('bids');

  // ==================== USER OPERATIONS ====================

  // Create user document
  Future<void> createUser(UserModel user) async {
    try {
      await usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await usersCollection.doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Stream user
  Stream<UserModel?> streamUser(String userId) {
    return usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromSnapshot(doc);
      }
      return null;
    });
  }

  // Get user by email (for credential verification)
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snapshot = await usersCollection
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromSnapshot(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Verify user credentials from Firestore
  Future<bool> verifyUserCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final user = await getUserByEmail(email);
      if (user == null) {
        return false;
      }
      // Get the password hash from the user document
      final userDoc = await usersCollection.doc(user.id).get();
      final passwordHash = userDoc['passwordHash'] as String?;
      
      if (passwordHash == null) {
        return false;
      }

      // Simple verification (compare with stored hash)
      // Note: You should use a proper hashing algorithm like bcrypt in production
      return passwordHash == _simpleHash(password);
    } catch (e) {
      throw Exception('Failed to verify credentials: $e');
    }
  }

  // Simple hash function (for demo purposes - USE BCRYPT IN PRODUCTION)
  String _simpleHash(String value) {
    return value.hashCode.toString();
  }


  // ==================== ANTIQUE OPERATIONS ====================

  // Create antique
  Future<void> createAntique(AntiqueModel antique) async {
    try {
      await antiquesCollection.doc(antique.id).set(antique.toMap());
    } catch (e) {
      throw Exception('Failed to create antique: $e');
    }
  }

  // Get antique by ID
  Future<AntiqueModel?> getAntique(String antiqueId) async {
    try {
      final doc = await antiquesCollection.doc(antiqueId).get();
      if (doc.exists) {
        return AntiqueModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get antique: $e');
    }
  }

  // Update antique
  Future<void> updateAntique(String antiqueId, Map<String, dynamic> data) async {
    try {
      await antiquesCollection.doc(antiqueId).update(data);
    } catch (e) {
      throw Exception('Failed to update antique: $e');
    }
  }

  // Stream all antiques
  Stream<List<AntiqueModel>> streamAntiques() {
    return antiquesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AntiqueModel.fromSnapshot(doc))
          .toList();
    });
  }

  // Stream active antiques
  Stream<List<AntiqueModel>> streamActiveAntiques() {
    return antiquesCollection
        .where('isActive', isEqualTo: true)
        .orderBy('bidEndTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AntiqueModel.fromSnapshot(doc))
          .where((antique) => antique.isAuctionActive)
          .toList();
    });
  }

  // Stream antique by ID
  Stream<AntiqueModel?> streamAntique(String antiqueId) {
    return antiquesCollection.doc(antiqueId).snapshots().map((doc) {
      if (doc.exists) {
        return AntiqueModel.fromSnapshot(doc);
      }
      // Return null - ViewModel will handle fallback to demo data
      debugPrint('WARNING: Antique not found in Firestore: $antiqueId');
      return null;
    });
  }

  // Get antiques by seller
  Future<List<AntiqueModel>> getAntiquesBySeller(String sellerId) async {
    try {
      final snapshot = await antiquesCollection
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => AntiqueModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get antiques by seller: $e');
    }
  }

  // ==================== BID OPERATIONS ====================

  // Create bid
  Future<void> createBid(BidModel bid) async {
    try {
      await bidsCollection.doc(bid.id).set(bid.toMap());
    } catch (e) {
      throw Exception('Failed to create bid: $e');
    }
  }

  // Get bid by ID
  Future<BidModel?> getBid(String bidId) async {
    try {
      final doc = await bidsCollection.doc(bidId).get();
      if (doc.exists) {
        return BidModel.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get bid: $e');
    }
  }

  // Update bid
  Future<void> updateBid(String bidId, Map<String, dynamic> data) async {
    try {
      await bidsCollection.doc(bidId).update(data);
    } catch (e) {
      throw Exception('Failed to update bid: $e');
    }
  }

  // Get bids for an antique
  Future<List<BidModel>> getBidsForAntique(String antiqueId) async {
    try {
      final snapshot = await bidsCollection
          .where('antiqueId', isEqualTo: antiqueId)
          .orderBy('bidTime', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => BidModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bids for antique: $e');
    }
  }

  // Stream bids for an antique
  Stream<List<BidModel>> streamBidsForAntique(String antiqueId) {
    return bidsCollection
        .where('antiqueId', isEqualTo: antiqueId)
        .orderBy('bidTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BidModel.fromSnapshot(doc))
          .toList();
    });
  }

  // Get bids by user
  Future<List<BidModel>> getBidsByUser(String userId) async {
    try {
      final snapshot = await bidsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('bidTime', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => BidModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bids by user: $e');
    }
  }

  // Stream bids by user
  Stream<List<BidModel>> streamBidsByUser(String userId) {
    return bidsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('bidTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BidModel.fromSnapshot(doc))
          .toList();
    });
  }

  // Update all bids status for an antique
  Future<void> updateBidsStatusForAntique(
    String antiqueId,
    BidStatus status,
  ) async {
    try {
      final snapshot = await bidsCollection
          .where('antiqueId', isEqualTo: antiqueId)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'status': status.name});
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update bids status: $e');
    }
  }

  // ==================== BATCH OPERATIONS ====================

  // Perform batch write
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();
      
      for (var operation in operations) {
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String;
        final data = operation['data'] as Map<String, dynamic>;
        final type = operation['type'] as String; // 'set' or 'update'
        
        final docRef = _firestore.collection(collection).doc(docId);
        
        if (type == 'set') {
          batch.set(docRef, data);
        } else if (type == 'update') {
          batch.update(docRef, data);
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to perform batch write: $e');
    }
  }
}
