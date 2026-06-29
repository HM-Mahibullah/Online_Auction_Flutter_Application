import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  outbid,
  auctionWon,
  auctionLost,
  auctionEndingSoon,
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final String antiqueId;
  final String antiqueName;
  final String antiqueImageUrl;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.antiqueId,
    required this.antiqueName,
    required this.antiqueImageUrl,
    this.read = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'message': message,
      'antiqueId': antiqueId,
      'antiqueName': antiqueName,
      'antiqueImageUrl': antiqueImageUrl,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'outbid'),
        orElse: () => NotificationType.outbid,
      ),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      antiqueId: map['antiqueId'] ?? '',
      antiqueName: map['antiqueName'] ?? '',
      antiqueImageUrl: map['antiqueImageUrl'] ?? '',
      read: map['read'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory NotificationModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromMap({...data, 'id': doc.id});
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    String? antiqueId,
    String? antiqueName,
    String? antiqueImageUrl,
    bool? read,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      antiqueId: antiqueId ?? this.antiqueId,
      antiqueName: antiqueName ?? this.antiqueName,
      antiqueImageUrl: antiqueImageUrl ?? this.antiqueImageUrl,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
