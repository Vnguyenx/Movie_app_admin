import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../models/interaction_model.dart';
import '../../models/movie_model.dart'; // Import Model Phim
import '../../controllers/interaction_controller.dart';
import '../../widgets/interaction_list_item.dart';
import '../movies/movie_detail_screen.dart'; // Import màn hình chi tiết phim

class ReviewManageTab extends StatefulWidget {
  final VoidCallback? onOpenMenu;

  const ReviewManageTab({super.key, this.onOpenMenu});

  @override
  State<ReviewManageTab> createState() => _ReviewManageTabState();
}

class _ReviewManageTabState extends State<ReviewManageTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InteractionController _controller = InteractionController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- LOGIC XỬ LÝ ---

  /// 1. Xử lý xóa tương tác
  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title:
            const Text("Xác nhận xóa", style: TextStyle(color: Colors.white)),
        content: const Text("Dữ liệu sẽ bị mất vĩnh viễn.",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _controller.deleteInteraction(docId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã xóa thành công!")),
                );
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 2. Xử lý chuyển sang màn hình chi tiết phim
  Future<void> _navigateToMovieDetail(InteractionModel interaction) async {
    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Lấy thông tin phim từ Firestore dựa trên movieId trong interaction
      final doc = await FirebaseFirestore.instance
          .collection('movies')
          .doc(interaction.movieId)
          .get();

      // Tắt loading
      if (mounted) Navigator.pop(context);

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Parse dữ liệu sang MovieModel (đảm bảo khớp với model của bạn)
        final movie = MovieModel(
          id: doc.id,
          movieTitle: data['movieTitle'] ?? 'Unknown',
          description: data['description'] ?? '',
          moviePoster: data['moviePoster'] ?? '',
          category: data['category'] ?? '',
          year: data['year'] ?? 0,
          rating: (data['rating'] ?? 0.0).toDouble(),
          trailerUrl: data['trailerUrl'] ?? '',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );

        // Chuyển trang và truyền highlightId
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(
                movie: movie,
                highlightId:
                    interaction.id, // 🔥 QUAN TRỌNG: Truyền ID để highlight
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phim này đã bị xóa khỏi hệ thống!")),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tắt loading nếu lỗi
      print("Lỗi khi lấy thông tin phim: $e");
    }
  }

  // --- GIAO DIỆN ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (widget.onOpenMenu != null) ...[
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: widget.onOpenMenu,
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Text(
                    "Quản lý Tương tác",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Bình luận"),
                Tab(text: "Đánh giá"),
              ],
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList("comment"),
                  _buildList("rating"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng danh sách tương tác theo type
  Widget _buildList(String type) {
    return StreamBuilder<List<InteractionModel>>(
      stream: _controller.getInteractionsStream(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Lỗi: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "Chưa có dữ liệu $type",
              style: const TextStyle(color: Colors.white54),
            ),
          );
        }

        final interactions = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: interactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = interactions[index];

            return InteractionListItem(
              interaction: item,
              type: type,
              onDelete: () => _confirmDelete(item.id),
              // Truyền callback onTap để chuyển trang
              onTap: () => _navigateToMovieDetail(item),
            );
          },
        );
      },
    );
  }
}
