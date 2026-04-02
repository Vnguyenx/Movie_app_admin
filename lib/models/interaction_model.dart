import 'package:cloud_firestore/cloud_firestore.dart';

class InteractionModel {
  final String id;
  final String userId;
  final String movieId;
  final String type; // 'rating' hoặc 'comment'
  final String content;
  final double ratingValue;
  final DateTime createdAt;

  InteractionModel({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.type,
    this.content = '',
    this.ratingValue = 0,
    required this.createdAt,
  });

  factory InteractionModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Xử lý logic điểm số: hệ 5 -> hệ 10 (nếu cần)
    double rawRating = (data['value'] ?? 0).toDouble();
    if (rawRating > 0 && rawRating <= 5) {
      rawRating = rawRating * 2;
    }

    return InteractionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      movieId: data['movieId'] ?? '',
      type: data['type'] ?? 'comment',
      content: data['content'] ?? '',
      ratingValue: rawRating,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
