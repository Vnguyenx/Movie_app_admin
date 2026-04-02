import 'package:cloud_firestore/cloud_firestore.dart';

class MovieModel {
  String id;
  String movieTitle;
  String moviePoster;
  String trailerUrl; // 1. Thêm biến này
  double rating;
  int year;
  String description;
  String category;
  DateTime createdAt;

  MovieModel({
    required this.id,
    required this.movieTitle,
    required this.moviePoster,
    this.trailerUrl = '', // 2. Thêm vào constructor (để mặc định rỗng)
    required this.rating,
    required this.year,
    this.description = '',
    this.category = '',
    required this.createdAt,
  });

  // Factory: Chuyển từ Firestore Document sang Object Dart
  factory MovieModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MovieModel(
      id: doc.id,
      movieTitle: data['movieTitle'] ?? '',
      moviePoster: data['moviePoster'] ?? '',
      trailerUrl: data['trailerUrl'] ?? '', // 3. Lấy dữ liệu từ Firestore
      // Xử lý an toàn cho rating
      rating: (data['rating'] is int)
          ? (data['rating'] as int).toDouble()
          : (data['rating'] ?? 0.0),
      year: data['year'] ?? 0,
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Method: Chuyển từ Object Dart sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'movieTitle': movieTitle,
      'moviePoster': moviePoster,
      'trailerUrl': trailerUrl, // 4. Lưu dữ liệu lên Firestore
      'rating': rating,
      'year': year,
      'description': description,
      'category': category,
      'createdAt': createdAt,
    };
  }
}
