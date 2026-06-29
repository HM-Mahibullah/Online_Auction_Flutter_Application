import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final bool isAdmin;
  final DateTime createdAt;
  final int totalBids;
  final int wonAuctions;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.isAdmin = false,
    required this.createdAt,
    this.totalBids = 0,
    this.wonAuctions = 0,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'isAdmin': isAdmin,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalBids': totalBids,
      'wonAuctions': wonAuctions,
    };
  }

  // Create UserModel from Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'],
      isAdmin: map['isAdmin'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      totalBids: map['totalBids'] ?? 0,
      wonAuctions: map['wonAuctions'] ?? 0,
    );
  }

  // Create UserModel from DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }

  // Copy with method for updating fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    bool? isAdmin,
    DateTime? createdAt,
    int? totalBids,
    int? wonAuctions,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      totalBids: totalBids ?? this.totalBids,
      wonAuctions: wonAuctions ?? this.wonAuctions,
    );
  }
}
