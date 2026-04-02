import 'dart:convert';
import 'package:http/http.dart' as http;

class TMDBService {
  final String _apiKey = "7299ef774c2cae4899fd13ffeb5f3284"; // API Key của bạn

  // Map chuyển đổi ID thể loại
  final Map<int, String> _genreMap = {
    28: 'Hành động',
    12: 'Phiêu lưu',
    16: 'Hoạt hình',
    35: 'Hài',
    80: 'Tội phạm',
    99: 'Tài liệu',
    18: 'Chính kịch',
    10751: 'Gia đình',
    14: 'Giả tưởng',
    36: 'Lịch sử',
    27: 'Kinh dị',
    10402: 'Âm nhạc',
    9648: 'Bí ẩn',
    10749: 'Lãng mạn',
    878: 'Khoa học viễn tưởng',
    10770: 'Phim TV',
    53: 'Giật gân',
    10752: 'Chiến tranh',
    37: 'Miền tây'
  };

  // 1. Tìm kiếm phim
  Future<List<dynamic>> searchMovies(String query) async {
    try {
      final url = Uri.parse(
          "https://api.themoviedb.org/3/search/movie?api_key=$_apiKey&query=$query&language=vi-VN");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body)['results'];
      }
    } catch (e) {
      print("Lỗi TMDB Service: $e");
    }
    return [];
  }

  // 2. Lấy link Trailer (YouTube)
  Future<String> getTrailerUrl(int movieId) async {
    try {
      final videoUrl = Uri.parse(
          "https://api.themoviedb.org/3/movie/$movieId/videos?api_key=$_apiKey");
      final res = await http.get(videoUrl);
      final videos = json.decode(res.body)['results'] as List;

      final trailer = videos.firstWhere(
          (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
          orElse: () => null);

      if (trailer != null) {
        return "https://www.youtube.com/watch?v=${trailer['key']}";
      }
    } catch (e) {
      print("Lỗi lấy trailer: $e");
    }
    return "";
  }

  // 3. Chuyển đổi List ID thể loại thành chuỗi text (VD: "Hành động, Hài")
  String getGenres(List<dynamic>? genreIds) {
    if (genreIds == null || genreIds.isEmpty) return "Khác";

    List<int> ids = List<int>.from(genreIds);
    List<String> genreNames = ids
        .map((id) => _genreMap[id] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return genreNames.isNotEmpty ? genreNames.join(", ") : "Khác";
  }
}
