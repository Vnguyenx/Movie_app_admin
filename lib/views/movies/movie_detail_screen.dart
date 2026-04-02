import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../controllers/movie_controller.dart';
import '../../widgets/movie_reviews_section.dart';
import 'edit_movie_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final MovieModel movie;
  final String? highlightId; // Nhận ID từ Admin panel

  const MovieDetailScreen({super.key, required this.movie, this.highlightId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final MovieController _controller = MovieController();

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title:
            const Text("Xác nhận xóa", style: TextStyle(color: Colors.white)),
        content: const Text("Bạn có chắc muốn xóa phim này vĩnh viễn không?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _controller.deleteMovie(widget.movie.id);
              if (mounted) Navigator.pop(context, true);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          // 1. ẢNH HEADER
          SliverAppBar(
            expandedHeight: 400,
            backgroundColor: const Color(0xFF0F172A),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.movie.moviePoster,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image,
                        size: 50, color: Colors.white)),
              ),
            ),
          ),

          // 2. NỘI DUNG CHI TIẾT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.movie.movieTitle,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text("${widget.movie.rating}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 15),
                    Text("${widget.movie.year}",
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(width: 15),
                    Text(widget.movie.category,
                        style: const TextStyle(color: Colors.blueAccent)),
                  ]),

                  const SizedBox(height: 25),

                  // ACTION BUTTONS
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _controller.openTrailer(
                            widget.movie.trailerUrl, context),
                        icon: const Icon(Icons.play_circle_fill,
                            color: Colors.white),
                        label: const Text("Xem Trailer",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    EditMovieScreen(movie: widget.movie)));
                        if (result == true && mounted)
                          Navigator.pop(context, true);
                      },
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.blue[900]),
                      icon: const Icon(Icons.edit, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: _confirmDelete,
                      style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[800]),
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                    ),
                  ]),

                  const SizedBox(height: 25),
                  const Text("Nội dung phim",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(widget.movie.description,
                      style: const TextStyle(
                          color: Colors.white70, height: 1.5, fontSize: 15)),

                  const SizedBox(height: 30),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),

                  // TIÊU ĐỀ PHẦN BÌNH LUẬN
                  const Text("Bình luận & Đánh giá",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          // 3. DANH SÁCH BÌNH LUẬN (Gọi Widget tách riêng ở đây)
          MovieReviewsSection(
            movieId: widget.movie.id,
            highlightId: widget.highlightId, // Truyền highlightId xuống
          ),

          // Spacer dưới cùng
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}
