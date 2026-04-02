import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../widgets/info_fetcher.dart'; // Đảm bảo import đúng đường dẫn widget fetch tên user của bạn

class MovieReviewsSection extends StatelessWidget {
  final String movieId;
  final String? highlightId; // ID cần làm nổi bật

  const MovieReviewsSection({
    super.key,
    required this.movieId,
    this.highlightId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Lọc theo phim & Sắp xếp mới nhất lên đầu
      stream: FirebaseFirestore.instance
          .collection('interactions')
          .where('movieId', isEqualTo: movieId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
              child: Text("Lỗi tải bình luận: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text("Chưa có bình luận nào. Hãy là người đầu tiên!",
                    style: TextStyle(
                        color: Colors.white54, fontStyle: FontStyle.italic)),
              ),
            ),
          );
        }

        // Trả về danh sách dạng Sliver để cuộn mượt mà cùng màn hình chính
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isHighlighted = (doc.id ==
                  highlightId); // Kiểm tra xem có phải comment cần soi không

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  // Logic highlight: Nếu đúng ID thì nền vàng nhạt, viền vàng
                  color: isHighlighted
                      ? Colors.amber.withOpacity(0.15)
                      : const Color(0xFF1E293B),
                  border: isHighlighted
                      ? Border.all(color: Colors.amber, width: 1.5)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Avatar + Tên + Ngày
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person,
                                size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          // Widget lấy tên user (Của bạn)
                          Expanded(
                            child: UserNameFetcher(
                              userId: data['userId'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14),
                            ),
                          ),
                          Text(
                            data['createdAt'] != null
                                ? DateFormat('dd/MM/yyyy').format(
                                    (data['createdAt'] as Timestamp).toDate())
                                : '',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Phần điểm số (Nếu là Rating)
                      if (data['type'] == 'rating')
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text("${data['value'] ?? 0}/10",
                                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ],
                          ),
                        ),

                      // Nội dung comment
                      Text(
                        data['content'] ?? '',
                        style:
                            const TextStyle(color: Colors.white70, height: 1.4),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: docs.length,
          ),
        );
      },
    );
  }
}
