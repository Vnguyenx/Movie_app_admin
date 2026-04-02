import 'package:flutter/material.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../models/movie_model.dart';
import '../../widgets/movie_list_item.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSwitchToMovies;
  final VoidCallback? onOpenMenu;

  const DashboardScreen({
    super.key,
    this.onSwitchToMovies,
    this.onOpenMenu,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _controller = DashboardController();
  final ChatController _chatController = ChatController();

  int _totalUsers = 0;
  int _totalMovies = 0;
  int _totalReviews = 0;
  List<MovieModel> _recentMovies = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final data = await _controller.fetchDashboardData();

      if (mounted) {
        setState(() {
          _totalUsers = data.totalUsers;
          _totalMovies = data.totalMovies;
          _totalReviews = data.totalReviews;
          _recentMovies = data.recentMovies;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            if (widget.onOpenMenu != null) widget.onOpenMenu!();
          },
        ),
        title: const Text("Tổng quan hệ thống",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN 1: THẺ THỐNG KÊ ---
            Row(
              children: [
                _buildStatCard("Người dùng", _totalUsers.toString(),
                    Icons.people, Colors.blue),
                const SizedBox(width: 15),
                _buildStatCard("Tổng phim", _totalMovies.toString(),
                    Icons.movie, Colors.purple),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildStatCard("Tương tác", _totalReviews.toString(),
                    Icons.star, Colors.orange),
                const SizedBox(width: 15),
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _chatController
                        .getUnreadMessagesCount(), // Gọi hàm stream ở trên
                    initialData: 0,
                    builder: (context, snapshot) {
                      int unreadCount = snapshot.data ?? 0;
                      return _buildStatCard(
                        "Tin nhắn mới",
                        unreadCount.toString(),
                        Icons.message,
                        unreadCount > 0
                            ? Colors.redAccent
                            : Colors
                                .green, // Có tin mới thì màu đỏ, không thì xanh
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- PHẦN 2: TIÊU ĐỀ ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Phim mới cập nhật",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.onSwitchToMovies != null) {
                      widget.onSwitchToMovies!();
                    }
                  },
                  child: const Text("Xem tất cả",
                      style: TextStyle(color: Color(0xff448aff))),
                )
              ],
            ),
            const SizedBox(height: 15),

            // --- PHẦN 3: LIST VIEW ---
            if (_recentMovies.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("Chưa có dữ liệu phim",
                          style: TextStyle(color: Colors.white54))))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentMovies.length,
                itemBuilder: (context, index) {
                  final movie = _recentMovies[index];
                  // Sử dụng widget MovieListItem
                  return MovieListItem(
                    movie: movie,
                    onMovieUpdated: _loadData,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 15),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(title,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
