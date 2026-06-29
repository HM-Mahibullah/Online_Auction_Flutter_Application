import 'package:cloud_firestore/cloud_firestore.dart';

enum BidStatus {
  pending, // Auction is still active
  winning, // User is currently the highest bidder
  outbid, // User was outbid by someone else
  won, // User won the auction
  lost, active, // User lost the auction
}

class BidModel {
  final String id;
  final String antiqueId;
  final String antiqueName;
  final String antiqueImageUrl;
  final String userId;
  final String userName;
  final double bidAmount;
  final DateTime bidTime;
  final BidStatus status;
  final bool isWinningBid; // Was this the winning bid?

  BidModel({
    required this.id,
    required this.antiqueId,
    required this.antiqueName,
    required this.antiqueImageUrl,
    required this.userId,
    required this.userName,
    required this.bidAmount,
    required this.bidTime,
    required this.status,
    this.isWinningBid = false,
  });

  // Convert BidModel to Map for Firestore (all fields)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'antiqueId': antiqueId,
      'antiqueName': antiqueName,
      'antiqueImageUrl': antiqueImageUrl,
      'userId': userId,
      'userName': userName,
      'bidAmount': bidAmount,
      'bidTime': Timestamp.fromDate(bidTime),
      'status': status.name,
      'isWinningBid': isWinningBid,
    };
  }

  // Only allowed fields for Firestore bid creation (per security rules)
  // Rules allow: userId, antiqueId, bidAmount, bidTime only
  Map<String, dynamic> toFirestoreMap() {
    return {
      'antiqueId': antiqueId,
      'userId': userId,
      'bidAmount': bidAmount,
      'bidTime': Timestamp.fromDate(bidTime),
      // Note: 'status' and 'isWinningBid' are calculated server-side via Cloud Functions
    };
  }

  // Create BidModel from Firestore Document
  factory BidModel.fromMap(Map<String, dynamic> map) {
    return BidModel(
      id: map['id'] ?? '',
      antiqueId: map['antiqueId'] ?? '',
      antiqueName: map['antiqueName'] ?? '',
      antiqueImageUrl: map['antiqueImageUrl'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      bidAmount: (map['bidAmount'] ?? 0).toDouble(),
      bidTime: (map['bidTime'] as Timestamp).toDate(),
      status: BidStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BidStatus.pending,
      ),
      isWinningBid: map['isWinningBid'] ?? false,
    );
  }

  // Create BidModel from DocumentSnapshot
  factory BidModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BidModel.fromMap(data);
  }

  // Copy with method for updating fields
  BidModel copyWith({
    String? id,
    String? antiqueId,
    String? antiqueName,
    String? antiqueImageUrl,
    String? userId,
    String? userName,
    double? bidAmount,
    DateTime? bidTime,
    BidStatus? status,
    bool? isWinningBid,
  }) {
    return BidModel(
      id: id ?? this.id,
      antiqueId: antiqueId ?? this.antiqueId,
      antiqueName: antiqueName ?? this.antiqueName,
      antiqueImageUrl: antiqueImageUrl ?? this.antiqueImageUrl,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      bidAmount: bidAmount ?? this.bidAmount,
      bidTime: bidTime ?? this.bidTime,
      status: status ?? this.status,
      isWinningBid: isWinningBid ?? this.isWinningBid,
    );
  }
  
  // Get status display text
  String get statusText {
    switch (status) {
      case BidStatus.pending:
        return 'Pending';
      case BidStatus.winning:
        return 'Winning';
      case BidStatus.outbid:
        return 'Outbid';
      case BidStatus.won:
        return 'Won';
      case BidStatus.lost:
        return 'Lost';
      case BidStatus.active:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
