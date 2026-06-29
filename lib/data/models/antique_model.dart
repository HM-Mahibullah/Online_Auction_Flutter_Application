import 'package:cloud_firestore/cloud_firestore.dart';

class AntiqueModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double basePrice;
  final double currentBid;
  final String? currentBidderUserId;
  final String? currentBidderName;
  final DateTime bidEndTime;
  final String? curatorId;  // Admin who added this item
  final String? curatorName;
  final DateTime createdAt;
  final bool isActive;
  final int totalBids;
  final String category;

  AntiqueModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.basePrice,
    required this.currentBid,
    this.currentBidderUserId,
    this.currentBidderName,
    required this.bidEndTime,
    this.curatorId,
    this.curatorName,
    required this.createdAt,
    required this.isActive,
    this.totalBids = 0,
    this.category = 'Other',
  });

  // Convert AntiqueModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'basePrice': basePrice,
      'currentBid': currentBid,
      'currentBidderUserId': currentBidderUserId,
      'currentBidderName': currentBidderName,
      'bidEndTime': Timestamp.fromDate(bidEndTime),
      'curatorId': curatorId,
      'curatorName': curatorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'totalBids': totalBids,
      'category': category,
    };
  }

  // Create AntiqueModel from Firestore Document
  factory AntiqueModel.fromMap(Map<String, dynamic> map) {
    return AntiqueModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      basePrice: (map['basePrice'] ?? 0).toDouble(),
      currentBid: (map['currentBid'] ?? 0).toDouble(),
      currentBidderUserId: map['currentBidderUserId'],
      currentBidderName: map['currentBidderName'],
      bidEndTime: (map['bidEndTime'] as Timestamp).toDate(),
      curatorId: map['curatorId'] ?? map['sellerId'],  // Backward compatibility, can be null
      curatorName: map['curatorName'] ?? map['sellerName'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      totalBids: map['totalBids'] ?? 0,
      category: map['category'] ?? 'Other',
    );
  }

  // Create AntiqueModel from DocumentSnapshot
  factory AntiqueModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AntiqueModel.fromMap(data);
  }

  // Copy with method for updating fields
  AntiqueModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    double? basePrice,
    double? currentBid,
    String? currentBidderUserId,
    String? currentBidderName,
    DateTime? bidEndTime,
    String? curatorId,
    String? curatorName,
    DateTime? createdAt,
    bool? isActive,
    int? totalBids,
    String? category,
  }) {
    return AntiqueModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      basePrice: basePrice ?? this.basePrice,
      currentBid: currentBid ?? this.currentBid,
      currentBidderUserId: currentBidderUserId ?? this.currentBidderUserId,
      currentBidderName: currentBidderName ?? this.currentBidderName,
      bidEndTime: bidEndTime ?? this.bidEndTime,
      curatorId: curatorId ?? this.curatorId,
      curatorName: curatorName ?? this.curatorName,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      totalBids: totalBids ?? this.totalBids,
      category: category ?? this.category,
    );
  }
  
  // Check if auction is still active
  bool get isAuctionActive {
    return isActive && DateTime.now().isBefore(bidEndTime);
  }
  
  // Get the minimum next bid amount
  double get minimumNextBid {
    return currentBid > 0 ? currentBid : basePrice;
  }
}
