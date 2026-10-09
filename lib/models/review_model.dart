import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final List<String> likes; // un users ki uid jinhon ne like kiya
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.likes,
    required this.createdAt,
  });

  factory Review.fromMap(String id, Map<String, dynamic> m) => Review(
        id: id,
        userId: m['userId'] ?? '',
        userName: m['userName'] ?? 'User',
        rating: (m['rating'] ?? 0).toDouble(),
        comment: m['comment'] ?? '',
        likes: List<String>.from(m['likes'] ?? []),
        createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}