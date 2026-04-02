import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Cần cho BuildContext và SnackBar
import 'package:url_launcher/url_launcher.dart'; // Cần thư viện này để mở Trailer
import '../models/movie_model.dart';

class MovieController {
  // Collection reference để dùng chung
  final CollectionReference _movieCollection =
      FirebaseFirestore.instance.collection('movies');

  // 1. LẤY DANH SÁCH PHIM
  Future<List<MovieModel>> fetchMovies() async {
    try {
      QuerySnapshot snapshot =
          await _movieCollection.orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) => MovieModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Lỗi fetch movies: $e");
      return [];
    }
  }

  // 2. Logic Lọc & Tìm kiếm kết hợp
  List<MovieModel> applyFilters({
    required List<MovieModel> sourceList,
    String query = '',
    String? category, // Thể loại (null = tất cả)
    int? year, // Năm (null = tất cả)
  }) {
    return sourceList.where((movie) {
      // 1. Kiểm tra tên phim
      final bool matchName =
          movie.movieTitle.toLowerCase().contains(query.toLowerCase());

      // 2. Kiểm tra thể loại (Nếu chọn 'Tất cả' hoặc null thì luôn đúng)
      final bool matchCategory = (category == null ||
          category == 'Tất cả' ||
          movie.category == category);

      // 3. Kiểm tra năm (Nếu chọn null thì luôn đúng)
      final bool matchYear = (year == null || movie.year == year);

      // Phải thỏa mãn cả 3 điều kiện
      return matchName && matchCategory && matchYear;
    }).toList();
  }

  // 3. Hàm tiện ích: Lấy danh sách các thể loại có sẵn từ data
  List<String> getAvailableCategories(List<MovieModel> movies) {
    // Dùng Set để lọc trùng, sau đó chuyển về List
    final categories = movies.map((e) => e.category).toSet().toList();
    // Loại bỏ các giá trị rỗng nếu có
    categories.removeWhere((element) => element.isEmpty);
    categories.sort();
    return ['Tất cả', ...categories];
  }

  // 4. Hàm tiện ích: Lấy danh sách các năm có sẵn
  List<int> getAvailableYears(List<MovieModel> movies) {
    final years = movies.map((e) => e.year).toSet().toList();
    years.removeWhere((element) => element == 0); // Loại bỏ năm 0 nếu có
    years.sort(
        (a, b) => b.compareTo(a)); // Sắp xếp giảm dần (năm mới nhất lên đầu)
    return years;
  }

  // 5. THÊM PHIM MỚI (Đã cập nhật logic gọi generateKeywords)
  Future<void> addMovie(Map<String, dynamic> data) async {
    try {
      if (!data.containsKey('createdAt')) {
        data['createdAt'] = FieldValue.serverTimestamp();
      }
      // Tự động tạo keywords nếu chưa có
      if (data.containsKey('movieTitle')) {
        data['searchKeywords'] = generateKeywords(data['movieTitle']);
      }

      await _movieCollection.add(data);
    } catch (e) {
      print("Lỗi thêm phim: $e");
      rethrow;
    }
  }

  // 6. CẬP NHẬT PHIM
  Future<void> updateMovie(String docId, Map<String, dynamic> data) async {
    try {
      // Luôn cập nhật thời gian chỉnh sửa cuối cùng
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _movieCollection.doc(docId).update(data);
    } catch (e) {
      print("Lỗi cập nhật phim: $e");
      rethrow;
    }
  }

  // 7. XÓA PHIM (Cập nhật thêm try-catch)
  Future<void> deleteMovie(String docId) async {
    try {
      await _movieCollection.doc(docId).delete();
    } catch (e) {
      print("Lỗi xóa phim: $e");
      rethrow;
    }
  }

  // 8. MỞ TRAILER (Logic xử lý url_launcher)
  Future<void> openTrailer(String? url, BuildContext context) async {
    // Kiểm tra url rỗng hoặc null
    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phim này chưa có link trailer!")),
      );
      return;
    }

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        // Mở bằng ứng dụng ngoài (Youtube app hoặc Browser)
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback nếu không mở được app ngoài
        await launchUrl(uri);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể mở đường dẫn: $e")),
      );
    }
  }

// 9. Logic tạo Keywords tìm kiếm (Di chuyển từ UI sang đây)
  List<String> generateKeywords(String title) {
    List<String> keywords = [];
    String temp = "";
    for (int i = 0; i < title.length; i++) {
      temp = temp + title[i].toLowerCase();
      keywords.add(temp);
    }
    return keywords;
  }
}
