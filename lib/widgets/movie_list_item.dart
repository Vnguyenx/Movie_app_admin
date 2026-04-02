import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../views/movies/movie_detail_screen.dart';

/// Widget hiển thị một item phim trong danh sách
/// Có thể tái sử dụng ở nhiều màn hình khác nhau
class MovieListItem extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onMovieUpdated; // Callback khi cần refresh data

  const MovieListItem({
    super.key,
    required this.movie,
    this.onMovieUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: _buildPoster(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white30,
          size: 16,
        ),
        onTap: () => _navigateToDetail(context),
      ),
    );
  }

  /// Xây dựng phần poster
  Widget _buildPoster() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 50,
        height: 75,
        color: Colors.grey[800],
        child: movie.moviePoster.isNotEmpty
            ? Image.network(
                movie.moviePoster,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                ),
              )
            : const Icon(
                Icons.movie,
                color: Colors.white54,
              ),
      ),
    );
  }

  /// Xây dựng phần tiêu đề
  Widget _buildTitle() {
    return Text(
      movie.movieTitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  /// Xây dựng phần subtitle với rating và năm
  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            "${movie.rating}/10",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(width: 15),
          const Icon(Icons.calendar_today, color: Colors.white38, size: 14),
          const SizedBox(width: 4),
          Text(
            movie.year.toString(),
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// Điều hướng đến màn hình chi tiết
  Future<void> _navigateToDetail(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(movie: movie),
      ),
    );

    // Nếu có thay đổi, gọi callback để refresh
    if (result == true && onMovieUpdated != null) {
      onMovieUpdated!();
    }
  }
}
