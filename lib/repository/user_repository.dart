import '../data/models/user_model.dart';
import '../data/services/firestore_service.dart';

class UserRepository {
  final FirestoreService _firestoreService = FirestoreService();

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      return await _firestoreService.getUser(userId);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Stream user
  Stream<UserModel?> streamUser(String userId) {
    return _firestoreService.streamUser(userId);
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateUser(userId, data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Increment total bids
  Future<void> incrementTotalBids(String userId) async {
    try {
      final user = await _firestoreService.getUser(userId);
      if (user != null) {
        await _firestoreService.updateUser(userId, {
          'totalBids': user.totalBids + 1,
        });
      }
    } catch (e) {
      throw Exception('Failed to increment total bids: $e');
    }
  }

  // Increment won auctions
  Future<void> incrementWonAuctions(String userId) async {
    try {
      final user = await _firestoreService.getUser(userId);
      if (user != null) {
        await _firestoreService.updateUser(userId, {
          'wonAuctions': user.wonAuctions + 1,
        });
      }
    } catch (e) {
      throw Exception('Failed to increment won auctions: $e');
    }
  }

  // Update user admin status (for testing purposes)
  Future<void> updateAdminStatus(String userId, bool isAdmin) async {
    try {
      await _firestoreService.updateUser(userId, {
        'isAdmin': isAdmin,
      });
    } catch (e) {
      throw Exception('Failed to update admin status: $e');
    }
  }
}
