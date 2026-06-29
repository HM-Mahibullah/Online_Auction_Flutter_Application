import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/models/bid_model.dart';
import '../data/models/antique_model.dart';
import '../data/services/firestore_service.dart';
import '../data/services/firebase_auth_service.dart';
import 'antique_repository.dart';
import 'user_repository.dart';

class BidRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final AntiqueRepository _antiqueRepository = AntiqueRepository();
  final UserRepository _userRepository = UserRepository();

  // Place bid with Firebase Transaction to prevent race conditions
  Future<BidModel> placeBid({
    required String antiqueId,
    required double bidAmount,
  }) async {
    try {
      final userId = _authService.currentUserId;
      final userName = _authService.currentUser?.displayName ?? 'Unknown';

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if this is a demo antique (for testing with demo data)
      if (antiqueId.startsWith('demo_')) {
        debugPrint('DEBUG: Demo antique detected - $antiqueId');
        // For demo antiques, create a mock bid without Firestore transaction
        final antiqueRepository = AntiqueRepository();
        final antique = await antiqueRepository.getAntique(antiqueId).catchError((_) {
          // If not found in Firestore, that's ok for demo
          return null;
        });

        if (antique == null) {
          // Create a mock antique from demo data
          debugPrint('DEBUG: Creating mock bid for demo antique');
          final bidId = _firestoreService.bidsCollection.doc().id;
          final mockBid = BidModel(
            id: bidId,
            antiqueId: antiqueId,
            antiqueName: 'Demo Antique',
            antiqueImageUrl: '',
            userId: userId,
            userName: userName,
            bidAmount: bidAmount,
            bidTime: DateTime.now(),
            status: BidStatus.winning,
          );
          debugPrint('✓ Mock bid created successfully: $bidId');
          return mockBid;
        }

        // If antique exists, create the bid
        final bidId = _firestoreService.bidsCollection.doc().id;
        final bid = BidModel(
          id: bidId,
          antiqueId: antiqueId,
          antiqueName: antique.title,
          antiqueImageUrl: antique.imageUrl,
          userId: userId,
          userName: userName,
          bidAmount: bidAmount,
          bidTime: DateTime.now(),
          status: BidStatus.winning,
        );
        debugPrint('✓ Bid created for demo antique: $bidId');
        return bid;
      }

      // Use Firestore runTransaction to prevent race conditions
      final result = await FirebaseFirestore.instance.runTransaction<BidModel>(
        (transaction) async {
          // Get antique in transaction
          final antiqueRef = _firestoreService.antiquesCollection.doc(antiqueId);
          final antiqueSnapshot = await transaction.get(antiqueRef);
          
          if (!antiqueSnapshot.exists) {
            throw Exception('Antique not found in Firestore');
          }

          final antique = AntiqueModel.fromSnapshot(antiqueSnapshot);

          // Validate bid inside transaction
          if (!antique.isAuctionActive) {
            throw Exception('Auction has ended');
          }

          if (bidAmount <= antique.minimumNextBid) {
            throw Exception(
              'Bid must be greater than Tk${antique.minimumNextBid.toStringAsFixed(2)}',
            );
          }

          // Generate bid ID
          final bidId = _firestoreService.bidsCollection.doc().id;

          // Create bid model
          final bid = BidModel(
            id: bidId,
            antiqueId: antiqueId,
            antiqueName: antique.title,
            antiqueImageUrl: antique.imageUrl,
            userId: userId,
            userName: userName,
            bidAmount: bidAmount,
            bidTime: DateTime.now(),
            status: BidStatus.winning,
          );

          // Update previous highest bidder's bids to outbid
          if (antique.currentBidderUserId != null &&
              antique.currentBidderUserId != userId) {
            final previousBidsQuery = await _firestoreService.bidsCollection
                .where('antiqueId', isEqualTo: antiqueId)
                .where('userId', isEqualTo: antique.currentBidderUserId)
                .where('status', isEqualTo: BidStatus.winning.name)
                .get();
            
            for (var doc in previousBidsQuery.docs) {
              transaction.update(doc.reference, {
                'status': BidStatus.outbid.name,
              });
            }
          }

          // Create new bid (only allowed fields)
          final bidRef = _firestoreService.bidsCollection.doc(bidId);
          final bidMap = bid.toFirestoreMap();
          debugPrint('DEBUG: Sending bid to Firestore: $bidMap');
          debugPrint('DEBUG: Bid fields count: ${bidMap.keys.length}');
          transaction.set(bidRef, bidMap);

          // Update antique with new bid
          transaction.update(antiqueRef, {
            'currentBid': bidAmount,
            'currentBidderUserId': userId,
            'currentBidderName': userName,
            'totalBids': FieldValue.increment(1),
          });

          // Update user's total bids
          final userRef = _firestoreService.usersCollection.doc(userId);
          transaction.update(userRef, {
            'totalBids': FieldValue.increment(1),
          });

          return bid;
        },
        timeout: const Duration(seconds: 10),
      );

      return result;
    } on FirebaseException catch (e) {
      debugPrint('\n========== BID PLACEMENT ERROR =========');
      debugPrint('Error Code: ${e.code}');
      debugPrint('Error Message: ${e.message}');
      debugPrint('Full Error: ${e.toString()}');
      debugPrint('========================================\n');
      
      if (e.code == 'permission-denied') {
        throw Exception('😞 Permission denied. This might mean:\n• You\'re not authenticated properly\n• Firestore security rules need updating\n• The auction may have ended');
      } else if (e.code == 'invalid-argument') {
        throw Exception('❌ Invalid bid data. Please check:\n• Bid amount is a valid number\n• All required fields are present');
      } else if (e.code == 'not-found') {
        throw Exception('❌ The antique was not found. It may have been removed.');
      } else if (e.code == 'failed-precondition') {
        throw Exception('❌ Transaction failed. Please try again.');
      } else if (e.code == 'deadline-exceeded') {
        throw Exception('⏱ Request timeout. Too many users bidding. Please try again.');
      } else if (e.code == 'aborted') {
        throw Exception('⚠️ Bid was interrupted. This usually means another bid came in. Please refresh and try again.');
      } else if (e.code == 'unauthenticated') {
        throw Exception('🔐 You are not logged in. Please sign in and try again.');
      } else {
        throw Exception(e.message ?? e.code);
      }
    } catch (e) {
      debugPrint('\n========== UNEXPECTED ERROR =========');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('====================================\n');
      
      // If it's already an Exception with our custom message, re-throw it
      if (e is Exception) {
        rethrow;
      }
      throw Exception(e.toString());
    }
  }

  // Get bid by ID
  Future<BidModel?> getBid(String bidId) async {
    try {
      return await _firestoreService.getBid(bidId);
    } catch (e) {
      throw Exception('Failed to get bid: $e');
    }
  }

  // Get bids for antique
  Future<List<BidModel>> getBidsForAntique(String antiqueId) async {
    try {
      return await _firestoreService.getBidsForAntique(antiqueId);
    } catch (e) {
      throw Exception('Failed to get bids for antique: $e');
    }
  }

  // Stream bids for antique
  Stream<List<BidModel>> streamBidsForAntique(String antiqueId) {
    return _firestoreService.streamBidsForAntique(antiqueId);
  }

  // Get bids by user
  Future<List<BidModel>> getBidsByUser(String userId) async {
    try {
      final bids = await _firestoreService.getBidsByUser(userId);
      
      // Update bid statuses based on current antique state
      final updatedBids = <BidModel>[];
      for (var bid in bids) {
        try {
          final antique = await _antiqueRepository.getAntique(bid.antiqueId);
          if (antique != null) {
            BidStatus status = bid.status;
            
            if (!antique.isAuctionActive) {
              // Auction has ended
              if (antique.currentBidderUserId == userId) {
                status = BidStatus.won;
              } else {
                status = BidStatus.lost;
              }
            } else {
              // Auction is still active
              if (antique.currentBidderUserId == userId) {
                status = BidStatus.winning;
              } else {
                status = BidStatus.outbid;
              }
            }
            
            // Update Firestore if status changed
            if (status != bid.status) {
              await _firestoreService.updateBid(bid.id, {
                'status': status.name,
              });
            }
            
            updatedBids.add(bid.copyWith(status: status));
          } else {
            // Antique no longer exists, keep original bid
            updatedBids.add(bid);
          }
        } catch (e) {
          // If there's an error fetching antique, keep original bid
          updatedBids.add(bid);
        }
      }
      
      return updatedBids;
    } catch (e) {
      throw Exception('Failed to get bids by user: $e');
    }
  }

  // Stream bids by user
  Stream<List<BidModel>> streamBidsByUser(String userId) {
    return _firestoreService.streamBidsByUser(userId);
  }

  // Update bid status
  Future<void> updateBidStatus(String bidId, BidStatus status) async {
    try {
      await _firestoreService.updateBid(bidId, {
        'status': status.name,
      });
    } catch (e) {
      throw Exception('Failed to update bid status: $e');
    }
  }

  // Finalize auction bids
  Future<void> finalizeAuctionBids(AntiqueModel antique) async {
    try {
      if (antique.isAuctionActive) {
        throw Exception('Auction is still active');
      }

      // Get all bids for this antique
      final bids = await _firestoreService.getBidsForAntique(antique.id);

      // Update winning bid
      if (antique.currentBidderUserId != null) {
        for (var bid in bids) {
          if (bid.userId == antique.currentBidderUserId) {
            await _firestoreService.updateBid(bid.id, {
              'status': BidStatus.won.name,
              'isWinningBid': true,
            });
            
            // Increment user's won auctions
            await _userRepository.incrementWonAuctions(bid.userId);
          } else {
            await _firestoreService.updateBid(bid.id, {
              'status': BidStatus.lost.name,
              'isWinningBid': false,
            });
          }
        }
      } else {
        // No winner, all bids are lost
        for (var bid in bids) {
          await _firestoreService.updateBid(bid.id, {
            'status': BidStatus.lost.name,
            'isWinningBid': false,
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to finalize auction bids: $e');
    }
  }
}
