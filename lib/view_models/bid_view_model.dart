import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/bid_model.dart';
import '../repository/bid_repository.dart';
import '../repository/auth_repository.dart';
import '../routes/app_routes.dart';

class BidViewModel extends GetxController {
  final BidRepository _bidRepository = BidRepository();
  final AuthRepository _authRepository = AuthRepository();

  // Controllers
  final bidAmountController = TextEditingController();

  // Observable state
  final isLoading = false.obs;
  final myBids = <BidModel>[].obs;
  final antiqueBids = <BidModel>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyBids();
  }

  @override
  void onClose() {
    bidAmountController.dispose();
    super.onClose();
  }

  // Reset bid form for new bid
  void resetBidForm() {
    bidAmountController.clear();
    isLoading.value = false;
  }

  // Load user's bids with real-time updates
  // FIXED: Removed redundant API call - Cloud Functions now handle status updates
  void loadMyBids() {
    final userId = _authRepository.currentUserId;
    if (userId != null) {
      isLoading.value = true;
      errorMessage.value = '';
      _bidRepository.streamBidsByUser(userId).listen(
        (bids) {
          // Direct stream data - Cloud Functions handle automatic status updates
          if (bids.isEmpty) {
            // Load demo bids if no bids found
            myBids.value = _getDemoBids();
          } else {
            myBids.value = bids;
          }
          isLoading.value = false;
        },
        onError: (error) {
          errorMessage.value = error.toString();
          isLoading.value = false;
        },
      );
    } else {
      errorMessage.value = 'Please log in to view your bids';
      isLoading.value = false;
    }
  }

  // Get demo bids for testing
  List<BidModel> _getDemoBids() {
    final now = DateTime.now();
    return [
      BidModel(
        id: 'demo_bid_1',
        userId: _authRepository.currentUserId ?? 'demo_user',
        userName: 'You',
        antiqueId: 'demo_1',
        antiqueName: 'Ancient Ming Dynasty Vase',
        antiqueImageUrl: 'https://images.unsplash.com/photo-1578500494198-246f612d03b3?w=500&h=500&fit=crop',
        bidAmount: 6500.0,
        bidTime: now.subtract(const Duration(hours: 2)),
        status: BidStatus.active,
      ),
      BidModel(
        id: 'demo_bid_2',
        userId: _authRepository.currentUserId ?? 'demo_user',
        userName: 'You',
        antiqueId: 'demo_3',
        antiqueName: 'Greek Classical Marble Statue',
        antiqueImageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61',
        bidAmount: 9200.0,
        bidTime: now.subtract(const Duration(hours: 5)),
        status: BidStatus.active,
      ),
      BidModel(
        id: 'demo_bid_3',
        userId: _authRepository.currentUserId ?? 'demo_user',
        userName: 'You',
        antiqueId: 'demo_5',
        antiqueName: 'Victorian Era Pocket Watch',
        antiqueImageUrl: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?w=500&h=500&fit=crop',
        bidAmount: 4200.0,
        bidTime: now.subtract(const Duration(days: 1)),
        status: BidStatus.won,
      ),
      BidModel(
        id: 'demo_bid_4',
        userId: _authRepository.currentUserId ?? 'demo_user',
        userName: 'You',
        antiqueId: 'demo_2',
        antiqueName: 'Renaissance Oil Painting',
        antiqueImageUrl: 'https://images.unsplash.com/photo-1578021394881-481c4754a214?w=500&h=500&fit=crop',
        bidAmount: 16500.0,
        bidTime: now.subtract(const Duration(days: 2)),
        status: BidStatus.lost,
      ),
    ];
  }

  // Refresh bids manually
  Future<void> refreshMyBids() async {
    final userId = _authRepository.currentUserId;
    if (userId != null) {
      try {
        isLoading.value = true;
        errorMessage.value = '';
        final bids = await _bidRepository.getBidsByUser(userId);
        myBids.value = bids;
      } catch (e) {
        errorMessage.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Load bids for specific antique
  void loadAntiqueBids(String antiqueId) {
    _bidRepository.streamBidsForAntique(antiqueId).listen((bids) {
      antiqueBids.value = bids;
    });
  }

  // Place bid with improved error handling
  Future<void> placeBid(String antiqueId, double minimumBid) async {
    try {
      if (bidAmountController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter a bid amount',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final bidAmount = double.tryParse(bidAmountController.text);
      if (bidAmount == null) {
        Get.snackbar(
          'Error',
          'Please enter a valid amount',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (bidAmount <= minimumBid) {
        Get.snackbar(
          'Error',
          'Bid must be greater than Tk${minimumBid.toStringAsFixed(2)}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      await _bidRepository.placeBid(
        antiqueId: antiqueId,
        bidAmount: bidAmount,
      );

      Get.snackbar(
        'Success',
        'Bid placed: Tk${bidAmount.toStringAsFixed(2)} ✓',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );

      // Clear field after showing confirmation
      await Future.delayed(const Duration(milliseconds: 500));
      bidAmountController.clear();
      
      // Close bottom sheet after delay and go to dashboard
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.back();
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      debugPrint('\n===== BID VIEW MODEL ERROR HANDLER =====');
      debugPrint('Exception Type: ${e.runtimeType}');
      debugPrint('Exception String: $e');
      debugPrint('========================================\n');
      
      // Extract the error message more carefully
      String userMessage = 'Failed to place bid';
      
      final errorStr = '$e';
      
      // Handle NativeError on web
      if (e.runtimeType.toString() == 'NativeError' || errorStr.contains('NativeError')) {
        userMessage = 'Network or server error. Please check your internet connection and try again.';
      }
      // Handle Exception type specifically
      else if (e is Exception) {
        debugPrint('Is Exception: true');
        
        // Remove "Exception: " prefix if present
        if (errorStr.startsWith('Exception: ')) {
          userMessage = errorStr.substring(11); // Length of "Exception: "
        } else {
          userMessage = errorStr;
        }
        
        // Clean up "Error: " prefix
        if (userMessage.startsWith('Error: ')) {
          userMessage = userMessage.substring(7);
        }
      } else {
        userMessage = errorStr;
      }
      
      // Fallback message if extraction failed
      if (userMessage.isEmpty || userMessage.contains('Dart exception thrown')) {
        userMessage = 'Failed to place bid. Please check your internet connection and try again.';
      }
      
      debugPrint('Final message for user: "$userMessage"\n');
      
      // Show error with retry option
      Get.snackbar(
        'Bid Failed',
        userMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 8),
        mainButton: TextButton(
          onPressed: () {
            Get.closeCurrentSnackbar();
            placeBid(antiqueId, minimumBid);
          },
          child: const Text(
            'RETRY',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get winning bids
  List<BidModel> get winningBids {
    return myBids.where((bid) => bid.status == BidStatus.winning).toList();
  }

  // Get lost/outbid bids
  List<BidModel> get lostBids {
    return myBids
        .where((bid) =>
            bid.status == BidStatus.lost || bid.status == BidStatus.outbid)
        .toList();
  }

  // Get pending bids
  List<BidModel> get pendingBids {
    return myBids.where((bid) => bid.status == BidStatus.pending).toList();
  }

  // Get won bids
  List<BidModel> get wonBids {
    return myBids.where((bid) => bid.status == BidStatus.won).toList();
  }
}
