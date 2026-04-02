import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/interaction_model.dart';
import '../../widgets/info_fetcher.dart';

/// Widget hiển thị một item tương tác (comment hoặc rating)
class InteractionListItem extends StatelessWidget {
  final InteractionModel interaction;
  final String type; // "comment" hoặc "rating"
  final VoidCallback? onDelete; // Callback khi xóa
  final VoidCallback? onBan; // Callback khi cấm user (Optional)
  final VoidCallback? onTap; // Callback khi bấm vào thẻ (để xem chi tiết)

  const InteractionListItem({
    super.key,
    required this.interaction,
    required this.type,
    this.onDelete,
    this.onBan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      clipBehavior:
          Clip.antiAlias, // Cắt viền để hiệu ứng InkWell không bị tràn
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: InkWell(
        onTap: onTap, // <-- Bắt sự kiện click vào thẻ tại đây
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.blue.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 6),
              _buildMovieInfo(),
              const SizedBox(height: 10),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  /// Header: User Info + Time + Action Buttons (Ban/Delete)
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar + Tên User
        Expanded(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: UserNameFetcher(
                  userId: interaction.userId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Ngày giờ + Nút thao tác
        Row(
          children: [
            Text(
              DateFormat('dd/MM HH:mm').format(interaction.createdAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(width: 4),

            // Nút Ban User (Khóa tài khoản)
            if (onBan != null)
              IconButton(
                constraints: const BoxConstraints(), // Thu gọn padding mặc định
                padding: const EdgeInsets.all(8),
                tooltip: "Khóa tài khoản này",
                icon: const Icon(Icons.block,
                    color: Colors.orangeAccent, size: 18),
                onPressed: onBan,
              ),

            // Nút Xóa
            if (onDelete != null)
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                tooltip: "Xóa tương tác này",
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 20),
                onPressed: onDelete,
              ),
          ],
        ),
      ],
    );
  }

  /// Movie Info (Tên phim)
  Widget _buildMovieInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.movie_creation_outlined,
            color: Colors.blueAccent,
            size: 14,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: MovieNameFetcher(
              movieId: interaction.movieId,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Content Body (Comment text hoặc Rating stars)
  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26, // Nền tối hơn nền Card một chút
        borderRadius: BorderRadius.circular(8),
      ),
      child: type == 'comment' ? _buildCommentContent() : _buildRatingContent(),
    );
  }

  /// Hiển thị nội dung comment
  Widget _buildCommentContent() {
    return Text(
      interaction.content.isNotEmpty
          ? interaction.content
          : "(Không có nội dung)",
      style: const TextStyle(color: Colors.white, height: 1.4),
      maxLines: 4, // Giới hạn số dòng hiển thị để danh sách không quá dài
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Hiển thị rating với stars
  Widget _buildRatingContent() {
    return Row(
      children: [
        Text(
          "${interaction.ratingValue.toStringAsFixed(1)} / 10",
          style: TextStyle(
            color: _getRatingColor(interaction.ratingValue),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 12),
        _buildStars(interaction.ratingValue),
      ],
    );
  }

  /// Lấy màu dựa trên điểm rating
  Color _getRatingColor(double score) {
    if (score >= 8) return Colors.greenAccent;
    if (score >= 5) return Colors.amber;
    return Colors.redAccent;
  }

  /// Xây dựng các ngôi sao rating
  Widget _buildStars(double score) {
    return Row(
      children: List.generate(5, (index) {
        // Logic hiển thị sao: 10 điểm = 5 sao
        // index chạy từ 0 -> 4
        // Ví dụ 7.5 điểm -> 3.75 sao
        double starScore = score / 2;

        if (index < starScore.floor()) {
          // Sao đầy
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (index < starScore && (starScore - index) >= 0.5) {
          // Sao nửa (Logic đơn giản)
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          // Sao rỗng
          return const Icon(Icons.star_border, color: Colors.grey, size: 18);
        }
      }),
    );
  }
}
