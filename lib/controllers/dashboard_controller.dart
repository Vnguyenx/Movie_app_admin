import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';

// Class nhỏ để chứa dữ liệu trả về (DTO - Data Transfer Object)
class DashboardData {
  final int totalUsers;
  final int totalMovies;
  final int movies;
  final int totalReviews;
  final List<MovieModel> recentMovies;

  DashboardData({
    required this.totalUsers,
    required this.totalMovies,
    required this.movies,
    required this.totalReviews,
    required this.recentMovies,
  });
}

class DashboardController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm load tất cả dữ liệu tổng quan
  Future<DashboardData> fetchDashboardData() async {
    try {
      // Gọi song song 3 tác vụ để tiết kiệm thời gian
      final results = await Future.wait([
        _firestore.collection('users').count().get(), // 0. Đếm User
        _firestore
            .collection('movies')
            .orderBy('createdAt', descending: true)
            .limit(10)
            .get(), // 1. Lấy phim mới nhất

        _firestore.collection('interactions').count().get(), // 2. Đếm Reviews
        _firestore.collection('movies').count().get(), // 3 đếm phim
      ]);

      final userCountSnapshot = results[0] as AggregateQuerySnapshot;
      final movieQuerySnapshot = results[1] as QuerySnapshot;
      final reviewCountSnapshot = results[2] as AggregateQuerySnapshot;
      final moviesCountSnapshot = results[3] as AggregateQuerySnapshot;

      // Parse danh sách phim từ Snapshot sang Model
      final List<MovieModel> movies = movieQuerySnapshot.docs
          .map((doc) => MovieModel.fromSnapshot(doc))
          .toList();

      // Trả về object chứa toàn bộ dữ liệu
      return DashboardData(
        totalUsers: userCountSnapshot.count ?? 0,
        totalMovies: moviesCountSnapshot.count ?? 0,
        totalReviews: reviewCountSnapshot.count ?? 0,
        movies: movieQuerySnapshot.size,
        recentMovies: movies,
      );
    } catch (e) {
      print("Lỗi Dashboard Controller: $e");
      rethrow; // Ném lỗi ra để UI biết mà xử lý (nếu cần)
    }
  }
}
